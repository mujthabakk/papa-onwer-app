import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/locale_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class LanguagesScreen extends StatefulWidget {
  const LanguagesScreen({Key? key}) : super(key: key);

  @override
  State<LanguagesScreen> createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !Get.isRegistered<LocaleController>()) return;
      final locale = Get.find<LocaleController>();
      if (locale.languages.isEmpty || locale.countries.isEmpty) {
        locale.bootstrap();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ApiLanguageModel> _filteredLanguages(LocaleController controller) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return controller.languages;
    return controller.languages.where((language) {
      return language.name.toLowerCase().contains(q) ||
          language.nativeName.toLowerCase().contains(q) ||
          language.code.toLowerCase().contains(q);
    }).toList();
  }

  List<LocaleCountryModel> _filteredCountries(LocaleController controller) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return controller.countries;
    return controller.countries.where((country) {
      return country.name.toLowerCase().contains(q) ||
          country.nameEn.toLowerCase().contains(q) ||
          country.code.toLowerCase().contains(q) ||
          country.countryCode.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(
      builder: (controller) {
        final languages = _filteredLanguages(controller);
        final countries = _filteredCountries(controller);
        final showLoader = controller.isLoading &&
            controller.languages.isEmpty &&
            controller.countries.isEmpty;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            title: Text('Languages'.tr, style: ThemeProvider.titleStyle),
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
          ),
          body: showLoader
              ? const Center(
                  child:
                      CircularProgressIndicator(color: ThemeProvider.appColor),
                )
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          final showCountry = !controller.isLoggedIn;
                          final empty = languages.isEmpty &&
                              (!showCountry || countries.isEmpty);
                          if (empty) {
                            return Center(
                              child: Text(
                                'No results found'.tr,
                                style: const TextStyle(
                                  color: ThemeProvider.greyColor,
                                ),
                              ),
                            );
                          }
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            children: [
                              if (showCountry && countries.isNotEmpty) ...[
                                _sectionTitle('Select Country'.tr),
                                ...countries.map(
                                  (country) =>
                                      _countryTile(controller, country),
                                ),
                              ],
                              if (languages.isNotEmpty) ...[
                                if (showCountry && countries.isNotEmpty)
                                  const SizedBox(height: 16),
                                _sectionTitle('Select Language'.tr),
                                ...languages.map(
                                  (language) =>
                                      _languageTile(controller, language),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search language or country'.tr,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ThemeProvider.appColor),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontFamily: 'bold',
          color: ThemeProvider.blackColor,
        ),
      ),
    );
  }

  Widget _languageTile(LocaleController controller, ApiLanguageModel language) {
    final selected = controller.languageCode == language.code;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? ThemeProvider.appColor : Colors.grey.shade200,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              selected ? ThemeProvider.appColor : Colors.grey.shade200,
          child: Text(
            language.code.toUpperCase(),
            style: TextStyle(
              color: selected ? Colors.white : ThemeProvider.blackColor,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          language.nativeName.isNotEmpty ? language.nativeName : language.name,
          style: const TextStyle(fontFamily: 'bold'),
        ),
        subtitle: Text(language.name),
        trailing: selected
            ? const Icon(Icons.check_circle, color: ThemeProvider.appColor)
            : null,
        onTap: () => controller.changeLanguage(language.code),
      ),
    );
  }

  Widget _countryTile(LocaleController controller, LocaleCountryModel country) {
    final selected = controller.countryCode == country.code;
    final langs = country.languages.isEmpty
        ? null
        : country.languages.map((code) => code.toUpperCase()).join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? ThemeProvider.appColor : Colors.grey.shade200,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(country.name),
        subtitle: Text(
          [
            if (country.countryCode.isNotEmpty) country.countryCode,
            if (langs != null) langs,
          ].join('  '),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: ThemeProvider.appColor)
            : null,
        onTap: () => controller.changeCountry(country.code),
      ),
    );
  }
}
