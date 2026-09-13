import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/conversion_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/inbox_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/chat_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/router.dart';

class InboxController extends GetxController implements GetxService {
  final InboxParser parser;
  String uid = '';
  bool apiCalled = false;
  List<ChatConversionModel> _chatList = <ChatConversionModel>[];
  List<ChatConversionModel> _filteredChatList = <ChatConversionModel>[];
  List<ChatConversionModel> get chatList => _filteredChatList;
  bool showAdminChatFAB = false;
  TextEditingController searchController = TextEditingController();
  InboxController({required this.parser});

  @override
  void onInit() {
    super.onInit();
    uid = parser.getUID();
    getChatConversion();
  }

  Future<void> getChatConversion() async {
    Response response = await parser.getChatConversion(uid);
    debugPrint(uid + " uid");
    apiCalled = true;
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      dynamic body = myMap["data"];
      _chatList = [];
      body.forEach((data) {
        ChatConversionModel datas = ChatConversionModel.fromJson(data);
        _chatList.add(datas);
      });
      debugPrint(chatList.length.toString());

      // Sort and pin PapaBear Admin to top
      _sortChatList();

      // Check if there's any chat with admin (ID 1)
      showAdminChatFAB = !_chatList
          .any((chat) => (chat.senderId == 1 || chat.receiverId == 1));
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  void _sortChatList() {
    // Sort chat list to pin PapaBear Admin (ID 1) to the top
    _chatList.sort((a, b) {
      bool aIsAdmin = (a.senderId == 1 || a.receiverId == 1);
      bool bIsAdmin = (b.senderId == 1 || b.receiverId == 1);

      if (aIsAdmin && !bIsAdmin) return -1;
      if (!aIsAdmin && bIsAdmin) return 1;

      // Sort other chats by last_message_time (latest first)
      try {
        DateTime aTime = DateTime.parse(a.last_message_time.toString());
        DateTime bTime = DateTime.parse(b.last_message_time.toString());
        return bTime.compareTo(aTime);
      } catch (e) {
        return 0;
      }
    });
    _filteredChatList = List.from(_chatList);
  }

  void searchChat(String query) {
    if (query.isEmpty) {
      _filteredChatList = List.from(_chatList);
    } else {
      _filteredChatList = _chatList.where((chat) {
        String senderName =
            '${chat.senderFirstName} ${chat.senderLastName}'.toLowerCase();
        String receiverName =
            '${chat.receiverName} ${chat.receiverLastName}'.toLowerCase();
        return senderName.contains(query.toLowerCase()) ||
            receiverName.contains(query.toLowerCase());
      }).toList();
    }
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void onChat(String uid, String name) {
    Get.delete<ChatController>(force: true);
    Get.toNamed(AppRouter.getChatRoute(), arguments: [uid, name]);
  }

  Future<void> createAdminChatRoom() async {
    Response response = await parser.createChatRoom('1', uid);
    if (response.statusCode == 200) {
      // Get.snackbar(
      //   'Success',
      //   'Admin chatroom created successfully',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      // );
      await getChatConversion();
      onChat('1', 'PapaBear Admin');
    } else {
      Get.snackbar(
        'Error',
        'Failed to create chatroom',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
