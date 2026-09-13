import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/city_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/country_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/signup_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  DateTime date = DateTime(2022, 12, 24);
  String genderValue = 'Male';
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignUpController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 50,
            title: Text(
              'Send Register Request'.tr,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: ThemeProvider.titleStyle,
            ),
          ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: value.currentView == 1
                  ? InkWell(
                      onTap: () {
                        value.onNext();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: contentButtonStyle(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next'.tr,
                                style: const TextStyle(
                                    color: ThemeProvider.whiteColor,
                                    fontSize: 17),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : value.currentView == 2
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                  onPressed: () {
                                    value.onBack();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: ThemeProvider.whiteColor,
                                      backgroundColor: ThemeProvider.greyColor,
                                      shadowColor: ThemeProvider.blackColor,
                                      elevation: 3,
                                      shape: (RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                      padding: const EdgeInsets.all(0)),
                                  child: Text(
                                    'Previews'.tr,
                                    style: const TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 16,
                                        color: ThemeProvider.whiteColor,
                                        fontFamily: 'bold'),
                                  )),
                            )),
                            const SizedBox(width: 10),
                            Expanded(
                                child: SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: ElevatedButton(
                                  onPressed: () {
                                    value.onRegister();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      foregroundColor: ThemeProvider.whiteColor,
                                      backgroundColor: ThemeProvider.appColor,
                                      shadowColor: ThemeProvider.blackColor,
                                      elevation: 3,
                                      shape: (RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                      padding: const EdgeInsets.all(0)),
                                  child: Text(
                                    'Submit'.tr,
                                    style: const TextStyle(
                                        letterSpacing: 1,
                                        fontSize: 16,
                                        color: ThemeProvider.whiteColor,
                                        fontFamily: 'bold'),
                                  )),
                            )),
                          ],
                        )
                      : const SizedBox(),
            ),
          ),
          body: SingleChildScrollView(
              child: value.currentView == 1
                  ? Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Select your type'.tr,
                            style: const TextStyle(
                                fontFamily: 'bold', fontSize: 14),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          GestureDetector(
                            onTap: () {
                              value.updateType(1);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                    color: value.type == 1
                                        ? ThemeProvider.appColor.withOpacity(0.08)
                                        : Colors.white,
                                    border: Border.all(
                                        color: value.type == 1
                                            ? ThemeProvider.appColor
                                            : ThemeProvider.greyColor
                                                .withOpacity(0.4),
                                        width: value.type == 1 ? 2 : 1)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                              value.type == 1
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: value.type == 1
                                                  ? ThemeProvider.appColor
                                                  : ThemeProvider.greyColor),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text('Business'.tr,
                                            style: TextStyle(
                                                fontFamily: 'bold',
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 56,
                                        width: 56,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/salon.png'),
                                              fit: BoxFit.cover),
                                        ),
                                        child: const SizedBox(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          GestureDetector(
                            onTap: () {
                              value.updateType(0);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(14),
                                    ),
                                    color: value.type == 0
                                        ? ThemeProvider.appColor.withOpacity(0.08)
                                        : Colors.white,
                                    border: Border.all(
                                        color: value.type == 0
                                            ? ThemeProvider.appColor
                                            : ThemeProvider.greyColor
                                                .withOpacity(0.4),
                                        width: value.type == 0 ? 2 : 1)),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                              value.type == 0
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              color: value.type == 0
                                                  ? ThemeProvider.appColor
                                                  : ThemeProvider.greyColor),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text('Freelancer'.tr,
                                            style: TextStyle(
                                                fontFamily: 'bold',
                                                fontSize: 14),
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 56,
                                        width: 56,
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/freelancer.png'),
                                              fit: BoxFit.cover),
                                        ),
                                        child: const SizedBox(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: myBoxDecoration(),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: _uploadImageBox(
                                        context: context,
                                        imageUrl: AppImage.url(value.cover),
                                        label: 'Upload Image'.tr,
                                        hint: 'Tap to upload profile / shop photo'.tr,
                                        onTap: () => _pickImageSheet(
                                          context,
                                          (source) => value
                                              .selectFromGallery(1, source),
                                        ),
                                      ),
                                    ),
                                    sectionTitle('Account Details'.tr),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.emailTextEditor,
                                          onChanged: (String txt) {},
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: requiredLabel('Email'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              value.openCountryCodePicker(),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 14),
                                            decoration: textFieldDecoration(),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                smallText('Code'.tr),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    bodyText1(
                                                        value.countryCodeMobile),
                                                    const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: 18,
                                                      color: ThemeProvider
                                                          .greyColor,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              decoration: textFieldDecoration(),
                                              child: TextFormField(
                                                controller:
                                                    value.mobileTextEditor,
                                                keyboardType:
                                                    TextInputType.phone,
                                                cursorColor:
                                                    ThemeProvider.appColor,
                                                decoration: InputDecoration(
                                                  labelStyle: const TextStyle(
                                                      fontSize: 14,
                                                      color: ThemeProvider
                                                          .greyColor),
                                                  border: InputBorder.none,
                                                  labelText: requiredLabel(
                                                      'Mobile Number'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (value.type == 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: textFieldDecoration(),
                                          child: TextFormField(
                                            controller: value.name,
                                            cursorColor: ThemeProvider.appColor,
                                            decoration: InputDecoration(
                                              labelStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      ThemeProvider.greyColor),
                                              border: InputBorder.none,
                                              labelText:
                                                  requiredLabel('Shop Name'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              decoration: textFieldDecoration(),
                                              child: TextFormField(
                                                controller:
                                                    value.firstNameTextEditor,
                                                onChanged: (String txt) {},
                                                cursorColor:
                                                    ThemeProvider.appColor,
                                                decoration: InputDecoration(
                                                    labelStyle: const TextStyle(
                                                        fontSize: 14,
                                                        color: ThemeProvider
                                                            .greyColor),
                                                    border: InputBorder.none,
                                                    labelText: "First Name".tr),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              decoration: textFieldDecoration(),
                                              child: TextFormField(
                                                controller:
                                                    value.lastNameTextEditor,
                                                onChanged: (String txt) {},
                                                cursorColor:
                                                    ThemeProvider.appColor,
                                                decoration: InputDecoration(
                                                    labelStyle: const TextStyle(
                                                        fontSize: 14,
                                                        color: ThemeProvider
                                                            .greyColor),
                                                    border: InputBorder.none,
                                                    labelText: "Last Name".tr),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.passwordTextEditor,
                                          onChanged: (String txt) {},
                                          cursorColor: ThemeProvider.appColor,
                                          obscureText: value.passwordVisible,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                value.togglePasswordBtn();
                                              },
                                              icon: Icon(
                                                value.passwordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: ThemeProvider.appColor,
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            labelText: "Password".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller:
                                              value.confirmPasswordTextEditor,
                                          onChanged: (String txt) {},
                                          cursorColor: ThemeProvider.appColor,
                                          obscureText: value.passwordVisible,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            suffixIcon: IconButton(
                                              onPressed: () {
                                                value.togglePasswordBtn();
                                              },
                                              icon: Icon(
                                                value.passwordVisible
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                                color: ThemeProvider.appColor,
                                              ),
                                            ),
                                            border: InputBorder.none,
                                            labelText: "Confirm Password".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: DropdownButton<String>(
                                            value: value.selectedGender,
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            onChanged: (String? newValue) {
                                              value.saveGender(
                                                  newValue.toString());
                                            },
                                            items: value.genderList
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.feeStart,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Fee Started Price".tr,
                                            prefixText: '${value.currencySymbol} ',
                                            prefixStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: ThemeProvider.blackColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller:
                                              value.descriptionsTextEditor,
                                          onChanged: (String txt) {},
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                              labelStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      ThemeProvider.greyColor),
                                              border: InputBorder.none,
                                              labelText: "Description".tr),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        value.onCategoriesList();
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            smallText('Select Category'.tr),
                                            const SizedBox(height: 4),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                  value.servedCategoriesList
                                                      .length,
                                                  (index) => Text(value
                                                      .servedCategoriesList[
                                                          index]
                                                      .name
                                                      .toString())),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    sectionTitle('Location'.tr),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: textFieldDecoration(),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<
                                              SignupCountryModel>(
                                            isExpanded: true,
                                            value: value.selectedCountry,
                                            hint: Text(requiredLabel('Country')),
                                            items: value.countryList
                                                .map((SignupCountryModel item) {
                                              return DropdownMenuItem<
                                                  SignupCountryModel>(
                                                value: item,
                                                child: Text(
                                                    '${item.name} (${item.countryCode})'),
                                              );
                                            }).toList(),
                                            onChanged:
                                                (SignupCountryModel? newValue) {
                                              if (newValue != null) {
                                                value.onCountryChanged(newValue);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        decoration: textFieldDecoration(),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<CityModal>(
                                            isExpanded: true,
                                            value: value.selectedCity.id != null &&
                                                    value.cityList.any((city) =>
                                                        city.id ==
                                                        value.selectedCity.id)
                                                ? value.cityList.firstWhere(
                                                    (city) =>
                                                        city.id ==
                                                        value.selectedCity.id)
                                                : null,
                                            hint: Text(requiredLabel('City')),
                                            items: value.cityList
                                                .map((CityModal city) {
                                              return DropdownMenuItem<
                                                  CityModal>(
                                                value: city,
                                                child:
                                                    Text(city.name.toString()),
                                              );
                                            }).toList(),
                                            onChanged: (CityModal? newValue) {
                                              if (newValue != null) {
                                                value.onCityChanged(newValue);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.addressTextEditor,
                                          onChanged: (String txt) {},
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                              labelStyle: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      ThemeProvider.greyColor),
                                              border: InputBorder.none,
                                              labelText: "Address".tr),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.zipcode,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Zipcode".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Column(
                                    //   children: [
                                    //     Text(
                                    //       'Select Latitude & Longitude from here :'
                                    //           .tr,
                                    //       style: const TextStyle(
                                    //           fontSize: 12,
                                    //           fontFamily: 'regular'),
                                    //     ),
                                    //     const SizedBox(
                                    //       height: 5,
                                    //     ),
                                    //     InkWell(
                                    //       onTap: () {
                                    //         value.openLink();
                                    //       },
                                    //       child: const Text(
                                    //           'https://www.mapcoordinates.net/en',
                                    //           style: TextStyle(
                                    //               fontSize: 12,
                                    //               fontFamily: 'regular',
                                    //               color: Colors.blue)),
                                    //     ),
                                    //     const SizedBox(
                                    //       height: 10,
                                    //     ),
                                    //     Text(
                                    //       'Please enter valid Latitude & Longitude otherwise app may not work properly.'
                                    //           .tr,
                                    //       style: const TextStyle(
                                    //           fontSize: 12,
                                    //           fontFamily: 'regular'),
                                    //       textAlign: TextAlign.center,
                                    //     ),
                                    //   ],
                                    // ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        value.getCurrentLocation();
                                      },
                                      icon: const Icon(Icons.my_location),
                                      label: Text('Get Coordinates'.tr),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            ThemeProvider.appColor,
                                        foregroundColor: Colors.white,
                                        minimumSize:
                                            const Size(double.infinity, 48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: textFieldDecoration(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          smallText('Coordinates'.tr),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.place_outlined,
                                                  size: 18,
                                                  color:
                                                      ThemeProvider.greyColor),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  value.lat.text.isEmpty &&
                                                          value.lng.text.isEmpty
                                                      ? 'Tap Get Coordinates to detect your location'
                                                          .tr
                                                      : 'Lat: ${value.lat.text}  •  Lng: ${value.lng.text}',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: ThemeProvider
                                                        .blackColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    sectionTitle(requiredLabel('Upload Id Proof')),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: _uploadImageBox(
                                            context: context,
                                            imageUrl: AppImage.url(value.id_proof),
                                            label: 'Upload Image'.tr,
                                            hint: 'Id Proof Front'.tr,
                                            height: 120,
                                            onTap: () => _pickImageSheet(
                                              context,
                                              (source) => value
                                                  .selectFromGallery(2, source),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _uploadImageBox(
                                            context: context,
                                            imageUrl:
                                                AppImage.url(value.id_proof_back),
                                            label: 'Upload Image'.tr,
                                            hint: 'Id Proof Back'.tr,
                                            height: 120,
                                            onTap: () => _pickImageSheet(
                                              context,
                                              (source) => value
                                                  .selectFromGallery(3, source),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.panNumber,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "PAN Number".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.gstNumber,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "GST Number (Optional)".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.bankName,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Bank Name".tr,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.ifscCode,
                                          keyboardType: TextInputType.text,
                                          cursorColor: ThemeProvider.appColor,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "IFSC Code".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.accountNumber,
                                          cursorColor: ThemeProvider.appColor,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Account Number".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.accountName,
                                          keyboardType: TextInputType.text,
                                          cursorColor: ThemeProvider.appColor,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Account Holder Name".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: Text('How do you heard about us?'.tr,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ThemeProvider.greyColor),
                                        ),
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: DropdownButton<String>(
                                            value: value.selectedHow,
                                            isExpanded: true,
                                            underline: const SizedBox(),
                                            onChanged: (String? newValue) {
                                              value
                                                  .saveHow(newValue.toString());
                                            },
                                            items: value.howList
                                                .map<DropdownMenuItem<String>>(
                                                    (String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (value.showExecutiveId)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          decoration: textFieldDecoration(),
                                          child: TextFormField(
                                            controller: value.executiveId,
                                            keyboardType: TextInputType.number,
                                            cursorColor: ThemeProvider.appColor,
                                            decoration: InputDecoration(
                                              labelStyle: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      ThemeProvider.greyColor),
                                              border: InputBorder.none,
                                              labelText:
                                                  "Executive Id (Optional)".tr,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.whatsapp,
                                          keyboardType: TextInputType.number,
                                          cursorColor: ThemeProvider.appColor,
                                          decoration: InputDecoration(
                                            labelStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText:
                                                requiredLabel('WhatsApp Number'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: textFieldDecoration(),
                                        child: TextFormField(
                                          controller: value.teamsize,
                                          keyboardType: TextInputType.number,
                                          cursorColor: ThemeProvider.appColor,
                                          decoration: InputDecoration(
                                            labelStyle: TextStyle(
                                                fontSize: 14,
                                                color: ThemeProvider.greyColor),
                                            border: InputBorder.none,
                                            labelText: "Team Size".tr,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
        );
      },
    );
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
        Color.fromARGB(228, 0, 0, 0),
        Color.fromARGB(227, 28, 28, 28),
      ],
    ),
  );
}

textFieldDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.all(
      Radius.circular(12.0),
    ),
    border: Border.all(
      color: ThemeProvider.greyColor.withOpacity(0.25),
    ),
  );
}

myBoxDecoration() {
  return BoxDecoration(
    color: ThemeProvider.whiteColor,
    borderRadius: const BorderRadius.all(
      Radius.circular(16),
    ),
    border: Border.all(
      color: ThemeProvider.greyColor.withOpacity(0.2),
    ),
    boxShadow: [
      BoxShadow(
          color: ThemeProvider.blackColor.withOpacity(0.06),
          offset: const Offset(0, 4),
          blurRadius: 12),
    ],
  );
}

sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontFamily: 'bold',
          color: ThemeProvider.blackColor,
        ),
      ),
    ),
  );
}

requiredLabel(String label) {
  return '$label *';
}

smallText(val) {
  return Text(
    val,
    style: const TextStyle(fontSize: 11, color: ThemeProvider.greyColor),
  );
}

bodyText1(val) {
  return Text(
    val,
    style: const TextStyle(fontSize: 14, color: ThemeProvider.blackColor),
  );
}

void _pickImageSheet(
  BuildContext context,
  void Function(String source) onPick,
) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: Text('Choose From'.tr),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: Text('Gallery'.tr),
          onPressed: () {
            Navigator.pop(context);
            onPick('gallery');
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Camera'.tr),
          onPressed: () {
            Navigator.pop(context);
            onPick('camera');
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            'Cancel'.tr,
            style: const TextStyle(
              fontFamily: 'bold',
              color: Colors.red,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

Widget _uploadImageBox({
  required BuildContext context,
  required String label,
  required String hint,
  required VoidCallback onTap,
  String? imageUrl,
  double height = 140,
}) {
  final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasImage
              ? ThemeProvider.appColor
              : ThemeProvider.greyColor.withOpacity(0.35),
          width: hasImage ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _uploadPlaceholder(label, hint),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.black45,
                  child: Text(
                    'Change Image'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'bold',
                    ),
                  ),
                ),
              ],
            )
          : _uploadPlaceholder(label, hint),
    ),
  );
}

Widget _uploadPlaceholder(String label, String hint) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ThemeProvider.appColor.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cloud_upload_outlined,
          color: ThemeProvider.appColor,
          size: 24,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'bold',
          color: ThemeProvider.blackColor,
        ),
      ),
      const SizedBox(height: 4),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          hint,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: ThemeProvider.greyColor,
          ),
        ),
      ),
    ],
  );
}
