// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/models/chat_list_model.dart';
// import 'package:ultimate_salon_owner_flutter/app/backend/parse/chat_parse.dart';

// class ChatController extends GetxController implements GetxService {
//   final ChatParser parser;
//   String receiverId = '';
//   String uid = '';
//   String name = '';
//   bool apiCalled = false;
//   bool yourMessage = false;
//   int roomId = 0;
//   final message = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//   List<ChatListModel> _chatList = <ChatListModel>[];
//   List<ChatListModel> get chatList => _chatList;
//   ChatController({required this.parser});

//   @override
//   void onInit() {
//     super.onInit();
//     receiverId = Get.arguments[0].toString();
//     name = Get.arguments[1].toString();
//     uid = parser.getUID();
//     debugPrint(name);
//     getChatRooms();
//   }

//   Future<void> getChatRooms() async {
//     Response response = await parser.getChatRooms(uid, receiverId);

//     if (response.statusCode == 200) {
//       apiCalled = true;
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       dynamic data1 = myMap["data"];
//       dynamic data2 = myMap["data2"];
//       if (data1 != null &&
//           data1 != '' &&
//           data1['id'] != null &&
//           data1['id'] != '') {
//         roomId = data1['id'];
//       } else if (data2 != null &&
//           data2 != '' &&
//           data2['id'] != null &&
//           data2['id'] != '') {
//         roomId = data2['id'];
//       }
//       getChatList();
//     } else if (response.statusCode == 404) {
//       createChatRooms();
//     } else {
//       apiCalled = true;
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   Future<void> createChatRooms() async {
//     Response response = await parser.createChatRooms(uid, receiverId);
//     apiCalled = true;
//     if (response.statusCode == 200) {
//       Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//       dynamic body = myMap["data"];
//       if (body != null && body != '') {
//         roomId = body['id'];
//         getChatList();
//       }
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   Future<void> getChatList() async {
//     debugPrint('calling API');
//     if (roomId != 0) {
//       Response response = await parser.getChatList(roomId);
//       if (response.statusCode == 200) {
//         Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
//         dynamic body = myMap["data"];
//         _chatList = [];
//         body.forEach((data) {
//           ChatListModel datas = ChatListModel.fromJson(data);
//           _chatList.add(datas);
//         });
//         update();
//         scrollDown();
//       } else {
//         ApiChecker.checkApi(response);
//       }
//       update();
//     }
//   }

//   Future<void> sendMessage() async {
//     String msg = message.text;
//     message.clear();
//     yourMessage = true;
//     update();
//     var param = {
//       'room_id': roomId,
//       'uid': uid,
//       'sender_id': uid,
//       'message': msg,
//       'message_type': 0,
//       'reported': 0,
//       'status': 1,
//     };
//     Response response = await parser.sendMessage(param);
//     yourMessage = false;
//     update();
//     if (response.statusCode == 200) {
//       var notificationParam = {
//         "id": receiverId,
//         "title": 'New message received'.tr,
//         "message": message
//       };
//       await parser.sendNotification(notificationParam);
//       getChatList();
//     } else {
//       ApiChecker.checkApi(response);
//     }
//     update();
//   }

//   void scrollDown() {
//     scrollController.animateTo(0,
//         duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
//     update();
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/chat_list_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/chat_parse.dart';

class ChatController extends GetxController implements GetxService {
  final ChatParser parser;

  String receiverId = '';
  String uid = '';
  String name = '';
  bool apiCalled = false;
  bool yourMessage = false;
  int roomId = 0;

  final message = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<ChatListModel> _chatList = <ChatListModel>[];
  List<ChatListModel> get chatList => _chatList;

  late PusherChannelsFlutter pusher;

  ChatController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    receiverId = Get.arguments[0].toString();
    name = Get.arguments[1].toString();
    uid = parser.getUID();
    debugPrint("Chat with: $name ($receiverId)");
    getChatRooms();
  }

  // -------------------------------
  // Pusher initialization
  // -------------------------------
  Future<void> initPusher() async {
    try {
      pusher = PusherChannelsFlutter.getInstance();

      await pusher.init(
        apiKey: "69a6a1c7ee697669f24c", // Replace with your key
        cluster: "ap2", // Replace with your cluster
        onEvent: (event) {
          debugPrint("📩 Pusher Event: ${event.eventName} => ${event.data}");

          // If a new message comes, reload chat list
          if (event.eventName == "user-chat" && event.data != null) {
            try {
              // Parse JSON
              final Map<String, dynamic> data =
                  Map<String, dynamic>.from(jsonDecode(event.data!));

              final String? receiverIdFromEvent =
                  data["reciever_id"]?.toString();

              debugPrint(
                  "📩 Pusher Event: ${event.eventName} => receiver_id=$receiverIdFromEvent");

              // ✅ Only refresh if this message is intended for me
              if (receiverIdFromEvent == uid) {
                debugPrint("✅ Message for me (uid=$uid). Reloading chat...");
                getChatList();
              } else {
                debugPrint(
                    "➡️ Ignored message for receiver_id=$receiverIdFromEvent");
              }
            } catch (e) {
              debugPrint("❌ Error parsing Pusher event data: $e");
            }
          }
        },
      );

      // Subscribe to the chat room channel
      await pusher.subscribe(channelName: "user-chat");

      await pusher.connect();
      debugPrint("✅ Pusher connected to chat-$roomId");
    } catch (e) {
      debugPrint("❌ Pusher init error: $e");
    }
  }

  // -------------------------------
  // API: Get Chat Room
  // -------------------------------
  Future<void> getChatRooms() async {
    Response response = await parser.getChatRooms(uid, receiverId);

    if (response.statusCode == 200) {
      apiCalled = true;
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic data1 = myMap["data"];
      dynamic data2 = myMap["data2"];

      if (data1 != null && data1['id'] != null && data1['id'] != '') {
        roomId = data1['id'];
      } else if (data2 != null && data2['id'] != null && data2['id'] != '') {
        roomId = data2['id'];
      }

      await getChatList();
      await initPusher(); // Start Pusher after roomId is ready
    } else if (response.statusCode == 404) {
      createChatRooms();
    } else {
      apiCalled = true;
      ApiChecker.checkApi(response);
    }
    update();
  }

  // -------------------------------
  // API: Create Chat Room
  // -------------------------------
  Future<void> createChatRooms() async {
    Response response = await parser.createChatRooms(uid, receiverId);
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      if (body != null && body != '') {
        roomId = body['id'];
        await getChatList();
        await initPusher();
      }
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  // -------------------------------
  // API: Get Chat Messages
  // -------------------------------
  Future<void> getChatList() async {
    debugPrint('📥 Fetching chat list for room $roomId');
    if (roomId != 0) {
      Response response = await parser.getChatList(roomId);
      if (response.statusCode == 200) {
        Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
        dynamic body = myMap["data"];
        _chatList = [];
        body.forEach((data) {
          ChatListModel datas = ChatListModel.fromJson(data);
          _chatList.add(datas);
        });
        update();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollDown();
        });
      } else {
        ApiChecker.checkApi(response);
      }
      update();
    }
  }

  // -------------------------------
  // API: Send Message
  // -------------------------------
  Future<void> sendMessage() async {
    String msg = message.text.trim();
    if (msg.isEmpty) return;

    message.clear();
    //yourMessage = true;
    // update();

    ChatListModel newMessage = ChatListModel(
      id: DateTime.now().millisecondsSinceEpoch, // temporary ID
      roomId: roomId,
      senderId: int.parse(uid),
      // receiverId: int.parse(receiverId),
      message: msg,
      messageType: 0,
      reported: 0,
      status: 1,
      // createdAt: DateTime.now().toString(),
      updatedAt: DateTime.now().toString(),
    );

    _chatList.add(newMessage);
    update();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });

    var param = {
      'room_id': roomId,
      'uid': uid,
      'sender_id': uid,
      'message': msg,
      'message_type': 0,
      'reported': 0,
      'status': 1,
    };

    Response response = await parser.sendMessage(param);
    // yourMessage = false;
    // update();

    if (response.statusCode == 200) {
      debugPrint("📤 Message sent, waiting for Pusher update...");

      // getChatList();
      // Optional: send push notification
      // var notificationParam = {
      //   "id": receiverId,
      //   "title": 'New message received'.tr,
      //   "message": msg
      // };
      // await parser.sendNotification(notificationParam);

      // Don't call getChatList() here,
      // because Pusher will trigger it for both users
      // scrollDown();
    } else {
      _chatList.removeWhere((m) => m.id == newMessage.id);
      update();

      ApiChecker.checkApi(response);
    }
    update();
  }

  // -------------------------------
  // Scroll Helper
  // -------------------------------
  void scrollDown() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void onClose() {
    pusher.unsubscribe(channelName: "user-chat");

    pusher.disconnect();
    super.onClose();
  }
}
