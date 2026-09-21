import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/login_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/view/widgets/locale_picker.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    // Rebuild when language changes so .tr strings update immediately.
    return GetBuilder<LocaleController>(builder: (_) {
      return GetBuilder<LoginController>(builder: (value) {
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Stack(
          children: [
            // Background Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                color: ThemeProvider.appColor,
                // image: DecorationImage(
                //   fit: BoxFit.cover,
                //   //image: AssetImage('assets/images/p7.jpg'),
                // ),
              ),
            ),
            // Gradient Overlay for better readability
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                centerTitle: true,
                actions: const [
                  LocalePickerBar(
                    foregroundColor: Colors.white,
                    compact: true,
                  ),
                  SizedBox(width: 8),
                ],
              ),
              body: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 30),
                        decoration: BoxDecoration(
                          color: ThemeProvider.whiteColor.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo
                            Image.asset(
                              'assets/images/ic_launcher.png',
                              height: 100,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 20),
                            // Header
                            Text(
                              'Welcome Back!'.tr,
                              style: const TextStyle(
                                color: ThemeProvider.blackColor,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Login to continue'.tr,
                              style: const TextStyle(
                                color: ThemeProvider.greyColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.fromLTRB(14, 16, 14, 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: ThemeProvider.golden,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        ThemeProvider.golden.withOpacity(0.28),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'New to PapaBear?'.tr,
                                    style: const TextStyle(
                                      color: ThemeProvider.blackColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ThemeProvider.golden,
                                        foregroundColor:
                                            ThemeProvider.blackColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      onPressed: value.onSignUp,
                                      child: Text(
                                        'Create Account'.tr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'LOG IN'.tr,
                                    style: const TextStyle(
                                      color: ThemeProvider.greyColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Content based on login version
                            if (value.loginVersion == 0) ...[
                              // Email Login
                              TextField(
                                controller: value.emailTextEditor,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hintText: 'Email Address'.tr,
                                  prefixIcon: const Icon(Icons.email_outlined,
                                      color: ThemeProvider.appColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: value.passwordTextEditor,
                                obscureText: !value.passwordVisible.value,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hintText: 'Password'.tr,
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: ThemeProvider.appColor),
                                  suffixIcon: IconButton(
                                    onPressed: value.togglePassword,
                                    icon: Icon(
                                      value.passwordVisible.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: ThemeProvider.appColor,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: value.onForgot,
                                  child: Text(
                                    'Forgot Password?'.tr,
                                    style: const TextStyle(
                                        color: ThemeProvider.appColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeProvider.appColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: value.onLogin,
                                  child: Text(
                                    'LOG IN'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ] else if (value.loginVersion == 1) ...[
                              // Mobile Password Login - Adapted
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: CountryCodePicker(
                                          onChanged: (e) =>
                                              value.updateCountryCode(
                                                  e.dialCode.toString()),
                                          initialSelection: 'IN',
                                          favorite: const ['+91', 'IN'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller: value.mobileNo,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        hintText: 'Mobile Number'.tr,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: value.passwordTextEditor,
                                obscureText: !value.passwordVisible.value,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hintText: 'Password'.tr,
                                  prefixIcon: const Icon(Icons.lock_outline,
                                      color: ThemeProvider.appColor),
                                  suffixIcon: IconButton(
                                    onPressed: value.togglePassword,
                                    icon: Icon(
                                      value.passwordVisible.value
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: ThemeProvider.appColor,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: value.onForgot,
                                  child: Text(
                                    'Forgot Password?'.tr,
                                    style: const TextStyle(
                                        color: ThemeProvider.appColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeProvider.appColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: value.loginWithPhonePassword,
                                  child: Text(
                                    'LOG IN'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Mobile OTP Login - Adapted
                              Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: CountryCodePicker(
                                          onChanged: (e) =>
                                              value.updateCountryCode(
                                                  e.dialCode.toString()),
                                          initialSelection: 'IN',
                                          favorite: const ['+91', 'IN'],
                                          showCountryOnly: false,
                                          showOnlyCountryWhenClosed: false,
                                          alignLeft: false,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      )),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 5,
                                    child: TextField(
                                      controller: value.mobileNo,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        hintText: 'Mobile Number'.tr,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: value.onForgot,
                                  child: Text(
                                    'Forgot Password?'.tr,
                                    style: const TextStyle(
                                        color: ThemeProvider.appColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ThemeProvider.appColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: value.loginWithPhoneOTP,
                                  child: Text(
                                    'LOG IN'.tr,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      });
    });
  }
}

contentButtonStyle() {
  return const BoxDecoration(
    borderRadius: BorderRadius.all(
      Radius.circular(100.0),
    ),
    gradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color.fromARGB(229, 52, 1, 255),
        Color.fromARGB(228, 111, 75, 255),
      ],
    ),
  );
}
