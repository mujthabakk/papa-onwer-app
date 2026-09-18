import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_categories_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class PackagesCategoriesScreen extends StatefulWidget {
  const PackagesCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<PackagesCategoriesScreen> createState() => _PackagesCategoriesScreen();
}

class _PackagesCategoriesScreen extends State<PackagesCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PackagesCategoriesController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(value),
          body: value.apiCalled == false
              ? _buildSkeletonLoader()
              : _buildServicesList(value),
          bottomNavigationBar: _buildBottomActions(value),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(PackagesCategoriesController value) {
    int selectedCount =
        value.servicesList.where((service) => service.isChecked == true).length;

    return AppBar(
      backgroundColor: ThemeProvider.appColor,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Package Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (selectedCount > 0)
            Text(
              '$selectedCount selected',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        if (selectedCount > 0)
          TextButton(
            onPressed: () => _clearAllSelections(value),
            child: const Text(
              'Clear All',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SkeletonItem(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList(PackagesCategoriesController value) {
    if (value.servicesList.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(value),
          const SizedBox(height: 16),
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: value.servicesList.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) => _buildServiceCard(value, index),
          ),
          const SizedBox(height: 100), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildHeader(PackagesCategoriesController value) {
    int totalServices = value.servicesList.length;
    int selectedServices =
        value.servicesList.where((service) => service.isChecked == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeProvider.appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.design_services_outlined,
              color: ThemeProvider.appColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Services',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$selectedServices of $totalServices services selected',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (selectedServices > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeProvider.appColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$selectedServices',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(PackagesCategoriesController value, int index) {
    final service = value.servicesList[index];
    final isSelected = service.isChecked == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => value.updateStatus(!isSelected, service.id as int),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? ThemeProvider.appColor : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? ThemeProvider.appColor.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildServiceImage(service),
                const SizedBox(width: 16),
                Expanded(child: _buildServiceInfo(service)),
                const SizedBox(width: 12),
                _buildSelectionIndicator(isSelected,
                    () => value.updateStatus(!isSelected, service.id as int)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceImage(dynamic service) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetImage(
              path: service.cover,
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.grey[100],
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[400],
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        if (service.discount > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${service.discount}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceInfo(dynamic service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.name.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          service.webCatesData?.name?.toString() ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildPriceRow(service),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip(
              icon: Icons.access_time_outlined,
              label: '${service.duration} min',
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _buildGenderChip(service.gender ?? 0),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(dynamic service) {
    return Row(
      children: [
        if (service.discount > 0) ...[
          Text(
            CurrencyHelper.format(service.price),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          CurrencyHelper.format(service.off),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ThemeProvider.greenColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(int gender) {
    IconData icon;
    String label;
    Color color;

    switch (gender) {
      case 0:
        icon = Icons.male;
        label = 'Kids';
        color = Colors.blue;
        break;
      case 1:
        icon = Icons.female;
        label = 'Male';
        color = Colors.pink;
        break;
      case 2:
        icon = Icons.child_care;
        label = 'Female';
        color = Colors.orange;
        break;
      case 3:
        icon = Icons.family_restroom;
        label = 'Family';
        color = Colors.purple;
        break;
      default:
        icon = Icons.person;
        label = 'All';
        color = Colors.grey;
    }

    return _buildInfoChip(icon: icon, label: label, color: color);
  }

  Widget _buildSelectionIndicator(bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? ThemeProvider.appColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? ThemeProvider.appColor : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.design_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Services Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no services to select at the moment.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(PackagesCategoriesController value) {
    int selectedCount =
        value.servicesList.where((service) => service.isChecked == true).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: true,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: selectedCount > 0 ? () => value.onAdd() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeProvider.greenColor,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: selectedCount > 0 ? 4 : 0,
                ),
                child: Text(
                  selectedCount > 0
                      ? 'Add ($selectedCount)'
                      : 'Select Services',
                  style: TextStyle(
                    color: selectedCount > 0 ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => value.onBack(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ThemeProvider.redColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: ThemeProvider.redColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllSelections(PackagesCategoriesController value) {
    for (var service in value.servicesList) {
      if (service.isChecked == true) {
        value.updateStatus(false, service.id as int);
      }
    }
    value.removeAll();
  }
}
