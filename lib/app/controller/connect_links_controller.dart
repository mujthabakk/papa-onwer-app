import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/api/handler.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/connect_links_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/parse/connect_links_parse.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/util/toast.dart';

class ConnectLinksController extends GetxController implements GetxService {
  final ConnectLinksParser parser;

  ConnectLinksController({required this.parser});

  final websiteController = TextEditingController();
  final instagramController = TextEditingController();
  final youtubeController = TextEditingController();
  final facebookController = TextEditingController();
  final whatsappController = TextEditingController();
  final twitterController = TextEditingController();
  final linkedinController = TextEditingController();

  ConnectLinksModel _profile = ConnectLinksModel();
  ConnectLinksModel get profile => _profile;

  bool isLoading = true;
  bool isSaving = false;
  bool callEnabled = true;
  bool chatEnabled = true;

  bool get isSalon => parser.isSalon();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    websiteController.dispose();
    instagramController.dispose();
    youtubeController.dispose();
    facebookController.dispose();
    whatsappController.dispose();
    twitterController.dispose();
    linkedinController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading = true;
    update();
    final response = await parser.getProfile();
    if (response.statusCode == 200) {
      final myMap = Map<String, dynamic>.from(response.body);
      final data = myMap['data'];
      if (data is Map) {
        _profile = ConnectLinksModel.fromJson(
            Map<String, dynamic>.from(data as Map));
        _fillControllers();
      }
    } else {
      ApiChecker.checkApi(response);
    }
    isLoading = false;
    update();
  }

  void _fillControllers() {
    websiteController.text = _clean(_profile.website);
    instagramController.text = _clean(_profile.instagram);
    youtubeController.text = _clean(_profile.youtube);
    facebookController.text = _clean(_profile.facebook);
    whatsappController.text = _clean(_profile.whatsapp);
    twitterController.text = _clean(_profile.twitter);
    linkedinController.text = _clean(_profile.linkedin);
    callEnabled = _profile.callEnabled;
    chatEnabled = _profile.chatEnabled;
  }

  String _clean(String? value) {
    if (value == null || value == 'null' || value == 'NA') return '';
    return value;
  }

  void toggleCallEnabled(bool value) {
    callEnabled = value;
    update();
  }

  void toggleChatEnabled(bool value) {
    chatEnabled = value;
    update();
  }

  Future<void> saveLinks() async {
    if (_profile.id == null) {
      showToast('Profile not loaded. Please try again.'.tr);
      return;
    }

    isSaving = true;
    update();

    Get.dialog(
      const SimpleDialog(
        children: [
          Row(
            children: [
              SizedBox(width: 30),
              CircularProgressIndicator(color: ThemeProvider.appColor),
              SizedBox(width: 30),
              Text('Please wait', style: TextStyle(fontFamily: 'bold')),
            ],
          )
        ],
      ),
      barrierDismissible: false,
    );

    _profile
      ..website = websiteController.text.trim()
      ..instagram = instagramController.text.trim()
      ..youtube = youtubeController.text.trim()
      ..facebook = facebookController.text.trim()
      ..whatsapp = whatsappController.text.trim()
      ..twitter = twitterController.text.trim()
      ..linkedin = linkedinController.text.trim()
      ..callEnabled = callEnabled
      ..chatEnabled = chatEnabled;

    final body = _profile.toUpdateBody();
    final response = await parser.updateLinks(body);
    Get.back();

    isSaving = false;
    if (response.statusCode == 200) {
      successToast('Connect links updated successfully'.tr);
      await loadProfile();
    } else {
      ApiChecker.checkApi(response);
      update();
    }
  }
}
