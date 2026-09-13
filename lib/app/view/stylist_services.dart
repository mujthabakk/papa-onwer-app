import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/stylist_service_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class StylistServicesScreen extends StatefulWidget {
  const StylistServicesScreen({Key? key}) : super(key: key);

  @override
  State<StylistServicesScreen> createState() => _StylistCategoriesScreen();
}

class _StylistCategoriesScreen extends State<StylistServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<StylistServiceController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 50,
            title: const Text(
              'Select Services',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: ThemeProvider.titleStyle,
            ),
          ),
          body: value.apiCalled == false
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                        children: List.generate(
                      20,
                      (index) => SkeletonParagraph(
                        style: SkeletonParagraphStyle(
                          lines: 1,
                          spacing: 2,
                          lineStyle: SkeletonLineStyle(
                              randomLength: true,
                              height: 20,
                              borderRadius: BorderRadius.circular(8),
                              minLength: MediaQuery.of(context).size.width),
                        ),
                      ),
                    )),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        for (var item in value.selectEditProfileList)
                          CheckboxListTile(
                            title: Text(item.name.toString()),
                            checkColor: Colors.white,
                            activeColor: ThemeProvider.appColor,
                            value: item.isChecked,
                            onChanged: (status) {
                              // isChecked = value!;
                              value.updateStatus(status!, item.id as int,
                                  item.name.toString());
                            },
                          ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: SizedBox(
              height: 70,
              child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      value.onAdd();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeProvider.greenColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Add'.tr,
                          style: const TextStyle(
                              fontFamily: 'bold',
                              color: ThemeProvider.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      value.onBack();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeProvider.redColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel'.tr,
                          style: const TextStyle(
                              fontFamily: 'bold',
                              color: ThemeProvider.whiteColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }
}
