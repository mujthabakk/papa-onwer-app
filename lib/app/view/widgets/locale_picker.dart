import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/locale_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class LocalePickerBar extends StatelessWidget {
  final Color? foregroundColor;
  final bool compact;
  final bool expanded;
  final bool? showCountry;

  const LocalePickerBar({
    Key? key,
    this.foregroundColor,
    this.compact = true,
    this.expanded = false,
    this.showCountry,
  }) : super(key: key);

  static Future<void> showPicker(
    BuildContext context, {
    int initialTab = 0,
    bool showCountry = true,
  }) async {
    if (!Get.isRegistered<LocaleController>()) return;
    const picker = LocalePickerBar(showCountry: true);
    await picker._openPicker(
      context,
      Get.find<LocaleController>(),
      initialTab: initialTab,
      showCountry: showCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocaleController>(
      builder: (locale) {
        final color = foregroundColor ?? Colors.white;
        final showCountry = this.showCountry ?? !locale.isLoggedIn;
        final lang = locale.languageCode.toUpperCase();
        final country = (locale.selectedCountry?.name.isNotEmpty == true
                ? locale.selectedCountry!.name
                : locale.selectedCountryLabel)
            .toUpperCase();

        final langChip = _segment(
          context,
          locale,
          icon: Icons.translate,
          label: lang,
          color: color,
          tab: 0,
          showCountry: showCountry,
        );
        if (!showCountry) {
          return langChip;
        }

        final countryChip = _segment(
          context,
          locale,
          icon: Icons.public,
          label: country,
          color: color,
          tab: 1,
          showCountry: true,
        );

        if (expanded) {
          return Row(
            children: [
              Expanded(child: langChip),
              const SizedBox(width: 8),
              Expanded(child: countryChip),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            langChip,
            const SizedBox(width: 6),
            countryChip,
          ],
        );
      },
    );
  }

  Widget _segment(
    BuildContext context,
    LocaleController locale, {
    required IconData icon,
    required String label,
    required Color color,
    required int tab,
    required bool showCountry,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openPicker(
          context,
          locale,
          initialTab: tab,
          showCountry: showCountry,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 14 : 16, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 11 : 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    LocaleController locale, {
    required int initialTab,
    required bool showCountry,
  }) async {
    if (locale.languages.isEmpty ||
        (showCountry && locale.countries.isEmpty)) {
      await locale.bootstrap(force: true, applyLocale: false);
    }

    if (!context.mounted) return;

    if (!showCountry) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Language'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'bold',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GetBuilder<LocaleController>(
                      builder: (controller) =>
                          _languageList(controller, context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 2,
          initialIndex: initialTab,
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Language & Country'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'bold',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    labelColor: ThemeProvider.appColor,
                    unselectedLabelColor: ThemeProvider.greyColor,
                    indicatorColor: ThemeProvider.appColor,
                    tabs: [
                      Tab(text: 'Language'.tr),
                      Tab(text: 'Country'.tr),
                    ],
                  ),
                  Expanded(
                    child: GetBuilder<LocaleController>(
                      builder: (controller) {
                        return TabBarView(
                          children: [
                            _languageList(controller, context),
                            _countryList(controller, context),
                          ],
                        );
                      },
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

  Widget _languageList(LocaleController controller, BuildContext context) {
    if (controller.languages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.languages.length,
      itemBuilder: (context, index) {
        final language = controller.languages[index];
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
                  fontSize: 11,
                  color: selected ? Colors.white : ThemeProvider.blackColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              language.nativeName.isNotEmpty
                  ? language.nativeName
                  : language.name,
              style: const TextStyle(fontFamily: 'bold'),
            ),
            subtitle: Text(language.name),
            trailing: selected
                ? const Icon(Icons.check_circle, color: ThemeProvider.appColor)
                : null,
            onTap: () async {
              await controller.changeLanguage(language.code);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  Widget _countryList(LocaleController controller, BuildContext context) {
    if (controller.countries.isEmpty) {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Center(
        child: Text(
          'No countries available'.tr,
          style: const TextStyle(color: ThemeProvider.greyColor),
        ),
      );
    }

    return _SearchableCountryList(
      countries: controller.countries,
      selectedCode: controller.countryCode,
      onSelect: (code) async {
        await controller.changeCountry(code);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

class _SearchableCountryList extends StatefulWidget {
  final List countries;
  final String selectedCode;
  final Future<void> Function(String code) onSelect;

  const _SearchableCountryList({
    required this.countries,
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  State<_SearchableCountryList> createState() => _SearchableCountryListState();
}

class _SearchableCountryListState extends State<_SearchableCountryList> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.countries
        : widget.countries.where((country) {
            return country.name.toLowerCase().contains(q) ||
                country.nameEn.toLowerCase().contains(q) ||
                country.code.toLowerCase().contains(q) ||
                country.countryCode.toLowerCase().contains(q);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search country'.tr,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text('No results found'.tr))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final country = filtered[index];
                    final selected = widget.selectedCode == country.code;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.flag_outlined),
                        title: Text(country.name),
                        subtitle: country.countryCode.isNotEmpty
                            ? Text(country.countryCode)
                            : null,
                        trailing: selected
                            ? const Icon(Icons.check_circle,
                                color: ThemeProvider.appColor)
                            : null,
                        onTap: () => widget.onSelect(country.code),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Backward-compatible alias.
class LanguageSwitcher extends LocalePickerBar {
  const LanguageSwitcher({
    Key? key,
    Color? iconColor,
    bool compact = false,
  }) : super(
          key: key,
          foregroundColor: iconColor,
          compact: compact,
        );
}
