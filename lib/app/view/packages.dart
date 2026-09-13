import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/packages_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// Enum for sort options
enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  nameAtoZ,
  nameZtoA,
  // newest,
  // oldest,
  // mostServices,
  // leastServices,
}

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({Key? key}) : super(key: key);

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _filters = ['All', 'Active', 'Inactive'];

  // Sort state
  SortOption _currentSort = SortOption.none;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sort packages based on the selected option
  List _sortPackages(List packages, SortOption sortOption) {
    if (sortOption == SortOption.none || packages.isEmpty) return packages;

    List sortedList = List.from(packages);

    try {
      switch (sortOption) {
        case SortOption.priceLowToHigh:
          sortedList.sort((a, b) {
            double priceA = _parseDouble(a.off);
            double priceB = _parseDouble(b.off);
            return priceA.compareTo(priceB);
          });
          break;
        case SortOption.priceHighToLow:
          sortedList.sort((a, b) {
            double priceA = _parseDouble(a.off);
            double priceB = _parseDouble(b.off);
            return priceB.compareTo(priceA);
          });
          break;
        case SortOption.nameAtoZ:
          sortedList.sort((a, b) {
            String nameA = (a.name ?? '').toString().toLowerCase();
            String nameB = (b.name ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          });
          break;
        case SortOption.nameZtoA:
          sortedList.sort((a, b) {
            String nameA = (a.name ?? '').toString().toLowerCase();
            String nameB = (b.name ?? '').toString().toLowerCase();
            return nameB.compareTo(nameA);
          });
          break;
        // case SortOption.newest:
        //   // Sort by ID assuming higher ID means newer
        //   sortedList.sort((a, b) {
        //     int idA = _parseInt(a.id);
        //     int idB = _parseInt(b.id);
        //     return idB.compareTo(idA);
        //   });
        //   break;
        // case SortOption.oldest:
        //   sortedList.sort((a, b) {
        //     int idA = _parseInt(a.id);
        //     int idB = _parseInt(b.id);
        //     return idA.compareTo(idB);
        //   });
        //   break;
        // case SortOption.mostServices:
        //   sortedList.sort((a, b) {
        //     int servicesA = a.services?.length ?? 0;
        //     int servicesB = b.services?.length ?? 0;
        //     return servicesB.compareTo(servicesA);
        //   });
        //   break;
        // case SortOption.leastServices:
        //   sortedList.sort((a, b) {
        //     int servicesA = a.services?.length ?? 0;
        //     int servicesB = b.services?.length ?? 0;
        //     return servicesA.compareTo(servicesB);
        //   });
        //   break;
        default:
          break;
      }
    } catch (e) {
      // If sorting fails, return original list
      return packages;
    }

    return sortedList;
  }

  // Helper methods for safe parsing
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Apply sorting
  List _getProcessedPackages(List originalPackages) {
    if (originalPackages.isEmpty) return originalPackages;

    List processed = List.from(originalPackages);

    // Apply sorting
    processed = _sortPackages(processed, _currentSort);

    return processed;
  }

  // Get sort option display name
  String _getSortDisplayName(SortOption option) {
    switch (option) {
      case SortOption.priceLowToHigh:
        return 'Price: Low to High'.tr;
      case SortOption.priceHighToLow:
        return 'Price: High to Low'.tr;
      case SortOption.nameAtoZ:
        return 'Name: A to Z'.tr;
      case SortOption.nameZtoA:
        return 'Name: Z to A'.tr;
      // case SortOption.newest:
      //   return 'Newest First'.tr;
      // case SortOption.oldest:
      //   return 'Oldest First'.tr;
      // case SortOption.mostServices:
      //   return 'Most Services'.tr;
      // case SortOption.leastServices:
      //   return 'Least Services'.tr;
      default:
        return 'Default'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PackagesController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            foregroundColor: ThemeProvider.whiteColor,
            backgroundColor: ThemeProvider.appColor,
            elevation: 0,
            title: Text(
              'Packages'.tr,
              style: const TextStyle(
                color: ThemeProvider.whiteColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            actions: [
              _buildSearchButton(),
              _buildFilterButton(context, value),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => value.onAddPackages(),
            backgroundColor: ThemeProvider.appColor,
            icon: const Icon(
              Icons.add,
              color: ThemeProvider.whiteColor,
            ),
            label: Text(
              'Add Package'.tr,
              style: const TextStyle(color: ThemeProvider.whiteColor),
            ),
          ),
          body: value.apiCalled == false
              ? _buildLoadingSkeleton()
              : value.packagesList.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Active sort display
                        if (_currentSort != SortOption.none)
                          _buildActiveSortBar(),

                        // Tab content
                        Expanded(
                          child: _buildPackagesList(value),
                        ),
                      ],
                    ),
        );
      },
    );
  }

  Widget _buildActiveSortBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.sort, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sorted by: ${_getSortDisplayName(_currentSort)}',
              style: const TextStyle(
                color: ThemeProvider.appColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentSort = SortOption.none;
              });
            },
            child: Text(
              'Clear Sort'.tr,
              style: const TextStyle(
                color: ThemeProvider.appColor,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return IconButton(
      icon: const Icon(Icons.search, color: Colors.white),
      onPressed: () {
        // Show search functionality
        showSearch(
          context: context,
          delegate: PackageSearchDelegate(Get.find<PackagesController>()),
        );
      },
    );
  }

  Widget _buildFilterButton(
      BuildContext context, PackagesController controller) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.filter_list, color: Colors.white),
          if (_currentSort != SortOption.none)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 8,
                  minHeight: 8,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        _showSortBottomSheet(context, controller);
      },
    );
  }

  void _showSortBottomSheet(
      BuildContext context, PackagesController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.sort, color: ThemeProvider.appColor),
                    const SizedBox(width: 10),
                    Text(
                      'Sort Packages'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentSort = SortOption.none;
                        });
                        setModalState(() {});
                      },
                      child: Text('Reset'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort options
                        ...SortOption.values
                            .where((option) => option != SortOption.none)
                            .map(
                              (option) => _buildSortOption(
                                icon: _getSortIcon(option),
                                title: _getSortDisplayName(option),
                                isSelected: _currentSort == option,
                                onTap: () {
                                  setState(() {
                                    _currentSort = option;
                                  });
                                  setModalState(() {});
                                },
                              ),
                            ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeProvider.appColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Sort'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSortIcon(SortOption option) {
    switch (option) {
      case SortOption.priceLowToHigh:
        return Icons.arrow_upward;
      case SortOption.priceHighToLow:
        return Icons.arrow_downward;
      case SortOption.nameAtoZ:
        return Icons.sort_by_alpha;
      case SortOption.nameZtoA:
        return Icons.sort_by_alpha;
      // case SortOption.newest:
      //   return Icons.new_releases;
      // case SortOption.oldest:
      //   return Icons.history;
      // case SortOption.mostServices:
      //   return Icons.trending_up;
      // case SortOption.leastServices:
      //   return Icons.trending_down;
      default:
        return Icons.sort;
    }
  }

  Widget _buildSortOption({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? ThemeProvider.appColor : Colors.grey[600],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? ThemeProvider.appColor : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: ThemeProvider.appColor)
          : null,
      onTap: onTap,
      dense: true,
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SkeletonListView(
          itemCount: 6,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SkeletonItem(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonAvatar(
                      style: SkeletonAvatarStyle(
                        width: 80,
                        height: 80,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonLine(
                            style: SkeletonLineStyle(height: 16, width: 120),
                          ),
                          const SizedBox(height: 8),
                          const SkeletonLine(
                            style: SkeletonLineStyle(height: 12, width: 80),
                          ),
                          const SizedBox(height: 12),
                          SkeletonLine(
                            style: SkeletonLineStyle(
                              height: 12,
                              width: MediaQuery.of(context).size.width * 0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: 24,
                                  height: 24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: 24,
                                  height: 24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  width: 24,
                                  height: 24,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/no_data.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'No Packages Found'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Create your first package by tapping the button below'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Get.find<PackagesController>().onAddPackages(),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeProvider.appColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text('Add Package'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesList(PackagesController controller) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: ThemeProvider.appColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: _filters.map((filter) => Tab(text: filter.tr)).toList(),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            transform: Matrix4.translationValues(0.0, -20.0, 0.0),
            padding: const EdgeInsets.only(top: 20),
            child: TabBarView(
              controller: _tabController,
              children: [
                // All packages
                _buildPackagesListView(
                    _getProcessedPackages(controller.packagesList)),
                // Active packages
                _buildPackagesListView(_getProcessedPackages(controller
                    .packagesList
                    .where((pkg) => pkg.status == 1)
                    .toList())),
                // Inactive packages
                _buildPackagesListView(_getProcessedPackages(controller
                    .packagesList
                    .where((pkg) => pkg.status == 0)
                    .toList())),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPackagesListView(List packages) {
    return packages.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No packages in this category'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(
                left: 15, right: 15, top: 15, bottom: 140),
            itemCount: packages.length,
            itemBuilder: (context, index) {
              var item = packages[index];
              return _buildPackageCard(item, context);
            },
          );
  }

  Widget _buildPackageCard(dynamic item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image and status badge
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: AppNetImage(
                    path: item.cover,
                    errorAsset: 'assets/images/notfound.png',
                    fit: BoxFit.cover,
                    height: 120,
                    width: double.infinity,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: item.status == 1
                          ? ThemeProvider.greenColor
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status == 1 ? 'Active'.tr : 'Inactive'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Package details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package name and price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name?.toString() ?? 'Unknown Package',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ThemeProvider.appColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          if (item.price != null &&
                              item.off != null &&
                              _parseDouble(item.price) >
                                  _parseDouble(item.off)) ...[
                            Text(
                              '₹${item.price ?? 0}',
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            '₹${item.off ?? 0}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: ThemeProvider.appColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Included services
                if (item.services != null && item.services!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.spa,
                            size: 16,
                            color: ThemeProvider.appColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Included Services (${item.services!.length})'.tr,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: item.services!.map<Widget>((service) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              service.name?.toString() ?? 'Service',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                // Specialists (if available)
                if (item.specialist != null &&
                    item.specialist!.isNotEmpty &&
                    Get.find<PackagesController>().userType == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 16,
                              color: ThemeProvider.appColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Specialists'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 35,
                          child: Stack(
                            children: [
                              for (int i = 0;
                                  i <
                                      (item.specialist!.length > 5
                                          ? 5
                                          : item.specialist!.length);
                                  i++)
                                Positioned(
                                  left: i * 22.0,
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: AppNetImage(
                                        path: item.specialist![i].cover,
                                        errorAsset: 'assets/images/notfound.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              if (item.specialist!.length > 5)
                                Positioned(
                                  left: 5 * 22.0,
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: ThemeProvider.appColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '+${item.specialist!.length - 5}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
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

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: item.status == 1
                          ? Icons.visibility
                          : Icons.visibility_off,
                      label: item.status == 1 ? 'Active'.tr : 'Inactive'.tr,
                      color: item.status == 1
                          ? ThemeProvider.greenColor
                          : Colors.grey,
                      onTap: () => Get.find<PackagesController>()
                          .updateStatus(item.id as int, item.status as int),
                    ),
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'Edit'.tr,
                      color: ThemeProvider.appColor,
                      onTap: () =>
                          Get.find<PackagesController>().onEdit(item.id as int),
                    ),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'Delete'.tr,
                      color: ThemeProvider.redColor,
                      onTap: () => _showDeleteConfirmation(context, item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
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
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/delete.png',
                height: 80,
                width: 80,
              ),
              const SizedBox(height: 20),
              Text(
                'Delete Package?'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Are you sure you want to delete this package? This action cannot be undone.'
                      .tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 0),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancel'.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 0),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Get.find<PackagesController>()
                              .onDestroy(item.id as int);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: ThemeProvider.redColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Delete'.tr,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
}

// Search delegate for packages
class PackageSearchDelegate extends SearchDelegate<String> {
  final PackagesController controller;

  PackageSearchDelegate(this.controller);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = controller.packagesList
        .where((package) =>
            package.name
                ?.toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ??
            false)
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : controller.packagesList
            .where((package) =>
                package.name
                    ?.toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List results) {
    return results.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'No packages found'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              var item = results[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: AppNetImage(
                      path: item.cover,
                      errorAsset: 'assets/images/notfound.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  item.name?.toString() ?? 'Unknown Package',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '₹${item.off ?? 0}',
                  style: const TextStyle(
                    color: ThemeProvider.appColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.status == 1
                        ? ThemeProvider.greenColor.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.status == 1 ? 'Active'.tr : 'Inactive'.tr,
                    style: TextStyle(
                      color: item.status == 1
                          ? ThemeProvider.greenColor
                          : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  close(context, item.id.toString());
                  controller.onEdit(item.id as int);
                },
              );
            },
          );
  }
}
