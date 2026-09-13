import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/services_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

// Enum for sort options
enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  durationShortToLong,
  durationLongToShort,
  nameAtoZ,
  nameZtoA,
}

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({Key? key}) : super(key: key);

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Active', 'Inactive'];

  // Sort state
  SortOption _currentSort = SortOption.none;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Sort services based on the selected option
  List _sortServices(List services, SortOption sortOption) {
    if (sortOption == SortOption.none || services.isEmpty) return services;

    List sortedList = List.from(services);

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
        case SortOption.durationShortToLong:
          sortedList.sort((a, b) {
            int durationA = _parseInt(a.duration);
            int durationB = _parseInt(b.duration);
            return durationA.compareTo(durationB);
          });
          break;
        case SortOption.durationLongToShort:
          sortedList.sort((a, b) {
            int durationA = _parseInt(a.duration);
            int durationB = _parseInt(b.duration);
            return durationB.compareTo(durationA);
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
        default:
          break;
      }
    } catch (e) {
      // If sorting fails, return original list
      return services;
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

  // Filter services by category
  List _filterByCategory(List services, String? category) {
    if (category == null || category.isEmpty || services.isEmpty)
      return services;

    try {
      return services.where((service) {
        if (service.webCatesData?.name == null) return false;
        return service.webCatesData!.name.toString().toLowerCase() ==
            category.toLowerCase();
      }).toList();
    } catch (e) {
      return services;
    }
  }

  // Get available categories from services
  List<String> _getAvailableCategories(List services) {
    Set<String> categories = {};
    try {
      for (var service in services) {
        if (service.webCatesData?.name != null) {
          categories.add(service.webCatesData!.name.toString());
        }
      }
    } catch (e) {
      // Return empty list if error occurs
    }
    return categories.toList()..sort();
  }

  // Apply all filters and sorting
  List _getProcessedServices(List originalServices) {
    if (originalServices.isEmpty) return originalServices;

    List processed = List.from(originalServices);

    // Apply category filter first
    if (_selectedCategory != null) {
      processed = _filterByCategory(processed, _selectedCategory);
    }

    // Then apply sorting
    processed = _sortServices(processed, _currentSort);

    return processed;
  }

  // Get sort option display name
  String _getSortDisplayName(SortOption option) {
    switch (option) {
      case SortOption.priceLowToHigh:
        return 'Price: Low to High'.tr;
      case SortOption.priceHighToLow:
        return 'Price: High to Low'.tr;
      case SortOption.durationShortToLong:
        return 'Duration: Short to Long'.tr;
      case SortOption.durationLongToShort:
        return 'Duration: Long to Short'.tr;
      case SortOption.nameAtoZ:
        return 'Name: A to Z'.tr;
      case SortOption.nameZtoA:
        return 'Name: Z to A'.tr;
      default:
        return 'Default'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesController>(
      builder: (value) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              foregroundColor: ThemeProvider.whiteColor,
              backgroundColor: ThemeProvider.appColor,
              elevation: 0,
              title: Text(
                'Services'.tr,
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
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: _tabs.map((tab) => Tab(text: tab.tr)).toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => value.onAddNew(),
              backgroundColor: ThemeProvider.appColor,
              icon: const Icon(
                Icons.add,
                color: ThemeProvider.whiteColor,
              ),
              label: Text(
                'Add Service'.tr,
                style: const TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
            body: value.apiCalled == false
                ? _buildLoadingSkeleton()
                : value.servicesList.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          // Active filters display
                          if (_currentSort != SortOption.none ||
                              _selectedCategory != null)
                            _buildActiveFiltersBar(),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                // All services
                                _buildServicesList(
                                    _getProcessedServices(value.servicesList)),
                                // Active services
                                _buildServicesList(_getProcessedServices(value
                                    .servicesList
                                    .where((service) => service.status == 1)
                                    .toList())),
                                // Inactive services
                                _buildServicesList(_getProcessedServices(value
                                    .servicesList
                                    .where((service) => service.status == 0)
                                    .toList())),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.filter_alt, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_currentSort != SortOption.none)
                    _buildFilterChip(
                      label: _getSortDisplayName(_currentSort),
                      onRemove: () {
                        setState(() {
                          _currentSort = SortOption.none;
                        });
                      },
                    ),
                  if (_selectedCategory != null) ...[
                    if (_currentSort != SortOption.none)
                      const SizedBox(width: 8),
                    _buildFilterChip(
                      label: _selectedCategory!,
                      onRemove: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _currentSort = SortOption.none;
                _selectedCategory = null;
              });
            },
            child: Text(
              'Clear All'.tr,
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

  Widget _buildFilterChip(
      {required String label, required VoidCallback onRemove}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ThemeProvider.appColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeProvider.appColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ThemeProvider.appColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: ThemeProvider.appColor,
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
          delegate: ServiceSearchDelegate(Get.find<ServicesController>()),
        );
      },
    );
  }

  Widget _buildFilterButton(
      BuildContext context, ServicesController controller) {
    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.filter_list, color: Colors.white),
          if (_currentSort != SortOption.none || _selectedCategory != null)
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
        _showFilterBottomSheet(context, controller);
      },
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, ServicesController controller) {
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
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.tune, color: ThemeProvider.appColor),
                    const SizedBox(width: 10),
                    Text(
                      'Filter & Sort'.tr,
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
                          _selectedCategory = null;
                        });
                        setModalState(() {});
                      },
                      child: Text('Reset'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sort Section
                Text(
                  'Sort By'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

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

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Category Filter Section
                        Text(
                          'Filter by Category'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Category options
                        _buildCategoryOption(
                          title: 'All Categories'.tr,
                          isSelected: _selectedCategory == null,
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                            setModalState(() {});
                          },
                        ),
                        ..._getAvailableCategories(controller.servicesList).map(
                          (category) => _buildCategoryOption(
                            title: category,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
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
                      'Apply Filters'.tr,
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
      case SortOption.durationShortToLong:
        return Icons.access_time;
      case SortOption.durationLongToShort:
        return Icons.access_time;
      case SortOption.nameAtoZ:
        return Icons.sort_by_alpha;
      case SortOption.nameZtoA:
        return Icons.sort_by_alpha;
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

  Widget _buildCategoryOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        Icons.category,
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
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SkeletonListView(
          itemCount: 8,
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
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_data.png', // Make sure this asset exists
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              'No Services Found'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                'Add your first service by tapping the button below'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Get.find<ServicesController>().onAddNew(),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.add),
              label: Text('Create Service'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(List services) {
    return services.isEmpty
        ? Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.spa_outlined,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No services in this category'.tr,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  left: 15, right: 15, top: 15, bottom: 140),
              itemCount: services.length,
              itemBuilder: (context, index) {
                var item = services[index];
                return _buildServiceCard(item, context);
              },
            ),
          );
  }

  Widget _buildServiceCard(dynamic item, BuildContext context) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image with discount badge
            Stack(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: AppNetImage(
                    path: item.cover,
                    errorAsset: 'assets/images/notfound.png',
                    fit: BoxFit.cover,
                    height: 140,
                    width: double.infinity,
                  ),
                ),
                // Status badge
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
                // Discount badge
                if (item.discount != null && _parseInt(item.discount) > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: ThemeProvider.appColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${item.discount}% OFF'.tr,
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

            // Service details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service name and category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name?.toString() ?? 'Unknown Service',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.category,
                                  size: 14,
                                  color: ThemeProvider.appColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.webCatesData?.name?.toString() ??
                                      'No Category',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Duration chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: ThemeProvider.greyColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.duration ?? 0} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Price display
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: ThemeProvider.appColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            if (item.discount != null &&
                                _parseInt(item.discount) > 0) ...[
                              Text(
                                Get.find<ServicesController>().currencySide ==
                                        'left'
                                    ? '${Get.find<ServicesController>().currencySymbol} ${item.price ?? 0}'
                                    : '${item.price ?? 0} ${Get.find<ServicesController>().currencySymbol}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              Get.find<ServicesController>().currencySide ==
                                      'left'
                                  ? '${Get.find<ServicesController>().currencySymbol} ${item.off ?? 0}'
                                  : '${item.off ?? 0} ${Get.find<ServicesController>().currencySymbol}',
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
                        onTap: () => Get.find<ServicesController>()
                            .updateStatus(item.id as int, item.status as int),
                      ),
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit'.tr,
                        color: ThemeProvider.appColor,
                        onTap: () => Get.find<ServicesController>()
                            .onEdit(item.id as int, item.cateId as int),
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
                'Delete Service?'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Are you sure you want to delete this service? This action cannot be undone.'
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
                          Get.find<ServicesController>()
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

// Search delegate for services
class ServiceSearchDelegate extends SearchDelegate<String> {
  final ServicesController controller;

  ServiceSearchDelegate(this.controller);

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
    final results = controller.servicesList
        .where((service) =>
            service.name.toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? []
        : controller.servicesList
            .where((service) => service.name
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
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
                  'No services found'.tr,
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
                  item.name?.toString() ?? 'Unknown Service',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      item.webCatesData?.name?.toString() ?? 'No Category',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${item.duration ?? 0} min',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ThemeProvider.appColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Get.find<ServicesController>().currencySide == 'left'
                        ? '${Get.find<ServicesController>().currencySymbol} ${item.off ?? 0}'
                        : '${item.off ?? 0} ${Get.find<ServicesController>().currencySymbol}',
                    style: const TextStyle(
                      color: ThemeProvider.appColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  close(context, item.id.toString());
                  controller.onEdit(item.id as int, item.cateId as int);
                },
              );
            },
          );
  }
}
