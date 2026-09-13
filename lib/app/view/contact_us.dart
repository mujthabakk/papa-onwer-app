import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/contact_us_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({Key? key}) : super(key: key);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactUsController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 40.0, bottom: 80, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Customer Support Working Hours: 9 AM to 5 PM'.tr,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _makePhoneCall,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: whatsappButtonStyle(),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.call,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Call',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: 'bold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between buttons
                    Expanded(
                      child: InkWell(
                        onTap: _openWhatsApp,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: whatsappButtonStyle(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const ImageIcon(
                                AssetImage('assets/images/whatsapp.png'),
                                size: 24.0,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'WhatsApp'.tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: 'bold'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Submit Button

                const SizedBox(height: 20),
                // Working Hours
              ],
            ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: ThemeProvider.appColor,
                floating: true,
                pinned: true,
                snap: false,
                elevation: 0,
                forceElevated: true,
                iconTheme: const IconThemeData(color: Colors.white),
                titleSpacing: 0,
                centerTitle: true,
                title: Text(
                  'Contact Us'.tr,
                  style: ThemeProvider.titleStyle,
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTextField(
                            controller: value.nameContact,
                            hintText: 'Full Name'.tr,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: value.emailContanct,
                            hintText: 'Email Address'.tr,
                          ),
                          const SizedBox(height: 15),
                          _buildTextField(
                            controller: value.messageContanct,
                            hintText: 'Message'.tr,
                            maxLines: 5,
                          ),
                          const SizedBox(height: 35),
                          Center(
                            child: InkWell(
                              onTap: () {
                                value.saveContacts();
                              },
                              child: Container(
                                width: 250,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13.0),
                                decoration: submitButtonStyle(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    value.isLogin.value == true
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Text(
                                            'Submit'.tr,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontFamily: 'bold'),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: ThemeProvider.appColor,
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14.0, horizontal: 10.0),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ThemeProvider.appColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _openWhatsApp() async {
    const phoneNumber = '+919562121333'; // Replace with your WhatsApp number
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication, // Ensures it opens in WhatsApp
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not open WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _makePhoneCall() async {
    const phoneNumber = '+919562121333'; // Replace with your phone number
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    // Check and request permission
    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
      if (!status.isGranted) {
        Get.snackbar(
          'Permission Denied',
          'Phone call permission is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    // Try launching the phone call intent
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(
          launchUri,
          mode: LaunchMode
              .externalApplication, // Handles restrictions in Android 12+
        );
      } else {
        Get.snackbar(
          'Error',
          'Could not make the call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  submitButtonStyle() {
    return const BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(100.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.fromARGB(255, 39, 30, 3),
          Color.fromARGB(255, 41, 32, 10),
        ],
      ),
    );
  }

  whatsappButtonStyle() {
    return const BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(100.0),
      ),
      color: Color(0xFF25D366),
    );
  }
}
