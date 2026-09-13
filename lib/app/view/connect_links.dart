import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/connect_links_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ConnectLinksScreen extends StatelessWidget {
  const ConnectLinksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(builder: (_) {
      return GetBuilder<ConnectLinksController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Connect & Social Links'.tr,
              style: const TextStyle(fontFamily: 'bold', fontSize: 18),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading || controller.isSaving
                          ? null
                          : controller.saveLinks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeProvider.appColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Save Links'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'bold',
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: controller.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ThemeProvider.appColor,
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoCard(controller),
                      const SizedBox(height: 16),
                      _section(
                        title: 'Website & Contact'.tr,
                        icon: Icons.language,
                        children: [
                          _field(
                            label: 'Website'.tr,
                            controller: controller.websiteController,
                            hint: 'https://yourwebsite.com'.tr,
                            icon: Icons.public,
                          ),
                          _field(
                            label: 'WhatsApp Number'.tr,
                            controller: controller.whatsappController,
                            hint: '919876543210'.tr,
                            icon: Icons.chat,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: 'Social Profiles'.tr,
                        icon: Icons.share_outlined,
                        children: [
                          _field(
                            label: 'Instagram'.tr,
                            controller: controller.instagramController,
                            hint: 'https://instagram.com/yourpage'.tr,
                            icon: Icons.camera_alt_outlined,
                          ),
                          _field(
                            label: 'YouTube'.tr,
                            controller: controller.youtubeController,
                            hint: 'https://youtube.com/@yourchannel'.tr,
                            icon: Icons.play_circle_outline,
                          ),
                          _field(
                            label: 'Facebook'.tr,
                            controller: controller.facebookController,
                            hint: 'https://facebook.com/yourpage'.tr,
                            icon: Icons.facebook_outlined,
                          ),
                          _field(
                            label: 'Twitter / X'.tr,
                            controller: controller.twitterController,
                            hint: 'https://twitter.com/yourpage'.tr,
                            icon: Icons.alternate_email,
                          ),
                          _field(
                            label: 'LinkedIn'.tr,
                            controller: controller.linkedinController,
                            hint: 'https://linkedin.com/company/yourpage'.tr,
                            icon: Icons.business_center_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _section(
                        title: 'Customer Actions'.tr,
                        icon: Icons.touch_app_outlined,
                        children: [
                          _toggleTile(
                            title: 'Show Call Button'.tr,
                            subtitle: 'Let customers call your shop phone'.tr,
                            value: controller.callEnabled,
                            onChanged: controller.toggleCallEnabled,
                          ),
                          const Divider(height: 1),
                          _toggleTile(
                            title: 'Show Chat Button'.tr,
                            subtitle: 'Let customers start a chat with you'.tr,
                            value: controller.chatEnabled,
                            onChanged: controller.toggleChatEnabled,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
    });
  }

  Widget _infoCard(ConnectLinksController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A1A), Color(0xFF333333)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.profile.name?.isNotEmpty == true
                ? controller.profile.name!
                : (controller.isSalon ? 'Business Profile' : 'Freelancer Profile')
                    .tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'bold',
            ),
          ),
          const SizedBox(height: 8),
          if (controller.profile.mobile?.isNotEmpty == true)
            _infoRow(Icons.phone, controller.profile.mobile!),
          if (controller.profile.email?.isNotEmpty == true)
            _infoRow(Icons.email_outlined, controller.profile.email!),
          const SizedBox(height: 8),
          Text(
            'These links appear on your public shop profile for customers.'
                .tr,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeProvider.appColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'bold',
                  color: ThemeProvider.blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.url,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeProvider.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: ThemeProvider.greyColor, size: 20),
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'bold',
          fontSize: 15,
          color: ThemeProvider.blackColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: ThemeProvider.greyColor),
      ),
      value: value,
      activeColor: ThemeProvider.appColor,
      onChanged: onChanged,
    );
  }
}
