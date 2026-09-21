import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/view/widgets/list_search_field.dart';

class ServiceCategoriesScreen extends StatefulWidget {
  const ServiceCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<ServiceCategoriesScreen> createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesCategoriesController>(
      builder: (value) {
        final filtered = filterByName(
          value.serviceList,
          _query,
          (item) => item.name?.toString() ?? '',
        );
        return Scaffold(
          backgroundColor: ThemeProvider.whiteColor,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 50,
            title: Text(
              'Select Categories'.tr,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: ThemeProvider.titleStyle,
            ),
          ),
          body: value.apiCalled == false
              ? SkeletonListView()
              : Column(
                  children: [
                    const SizedBox(height: 12),
                    ListSearchField(
                      hint: 'Search category...'.tr,
                      onChanged: (query) => setState(() => _query = query),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(child: Text('No results found'.tr))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(6, 0, 6, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final item = filtered[i];
                                return ListTile(
                                  visualDensity:
                                      const VisualDensity(vertical: -4),
                                  horizontalTitleGap: 0,
                                  leading: Radio(
                                    activeColor: ThemeProvider.appColor,
                                    value: item.id.toString(),
                                    groupValue: value.selectedService,
                                    onChanged: (data) {
                                      value.saveServices(data.toString());
                                    },
                                  ),
                                  title: Text(item.name.toString()),
                                  onTap: () =>
                                      value.saveServices(item.id.toString()),
                                );
                              },
                            ),
                    ),
                  ],
                ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeProvider.appColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: () {
                          value.onSave();
                        },
                        child: Center(
                          child: Text(
                            'Save'.tr,
                            style: const TextStyle(
                                fontFamily: 'bold',
                                color: ThemeProvider.whiteColor),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeProvider.redColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: InkWell(
                        onTap: () {
                          value.onBack();
                        },
                        child: Center(
                          child: Text(
                            'Cancle'.tr,
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
