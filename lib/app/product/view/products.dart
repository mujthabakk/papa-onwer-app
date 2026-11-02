import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/appointment_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/tabs_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/products_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:skeletons/skeletons.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductsController>(
      builder: (controller) {
        // Filter products based on search query
        final filteredProducts = controller.productsInfo.where((product) {
          return product.name
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
        }).toList();

        return GetBuilder<AppointmentController>(
          builder: (home) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(home),
              body: controller.apiCalled == false
                  ? _buildLoadingState()
                  : _buildProductsHome(filteredProducts, controller, home),
              floatingActionButton: _buildFloatingActionButton(controller),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppointmentController home) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: ThemeProvider.appColor,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 64,
      iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
      leading: IconButton(
        icon: const Icon(Icons.menu, color: ThemeProvider.whiteColor),
        onPressed: () {
          if (Get.isRegistered<TabsController>()) {
            Get.find<TabsController>().scaffoldKey.currentState?.openDrawer();
          }
        },
      ),
      leadingWidth: 40,
      title: Row(
        children: [
          Image.asset(
            'assets/images/icon_logo.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              home.name,
              style: ThemeProvider.titleStyle.copyWith(
                fontSize: 13,
                height: 1.15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () {
            if (home.parser.getPremium()) {
              home.showDialogScreen(
                context,
                'Premium User'.tr,
                'Congratulations,\nEnjoy all premium benefits'.tr,
                Icons.star,
                Colors.green,
              );
            } else {
              home.onUpgradeScreen();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeProvider.golden, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              home.parser.getPremium()
                  ? Icons.star
                  : Icons.workspace_premium,
              color: ThemeProvider.golden,
              size: 18,
            ),
          ),
        ),
        GestureDetector(
          onTap: home.onOpenNotifications,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Icon(Icons.notifications_active,
                color: ThemeProvider.golden, size: 22),
          ),
        ),
        GestureDetector(
          onTap: home.onInbox,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Icon(Icons.chat, color: ThemeProvider.golden, size: 22),
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildAdSlider(AppointmentController home) {
    final items = home.partnerAdList;
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180,
          viewportFraction: 1.0,
          padEnds: false,
          disableCenter: true,
          autoPlay: items.length > 1,
          autoPlayInterval: const Duration(seconds: 6),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          enlargeCenterPage: false,
          enableInfiniteScroll: items.length > 1,
          pauseAutoPlayOnTouch: true,
        ),
        items: items.map((banner) {
          return GestureDetector(
            onTap: () => home.onPartnerAdTap(banner),
            child: SizedBox(
              width: double.infinity,
              height: 180,
              child: AppNetImage(
                path: banner.cover,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductsHome(
    List products,
    ProductsController controller,
    AppointmentController home,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.getProductWFreelancer();
        await home.getBannerData();
      },
      color: ThemeProvider.appColor,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildAdSlider(home)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _buildSearchBar(),
            ),
          ),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildProductCard(products[index], controller),
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search products...'.tr,
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: TextStyle(fontFamily: 'regular', color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
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
              SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: 100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductsList(List products, ProductsController controller) {
    if (products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => controller.getProductWFreelancer(),
      child: ListView.builder(
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product, controller);
        },
      ),
    );
  }

  Widget _buildProductCard(dynamic product, ProductsController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (product.id != null) {
              controller.onOpenDetail(product.id as int);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductImage(product),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProductInfo(product, controller),
                ),
                _buildProductActions(product, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(dynamic product) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AppNetImage(
          path: product.displayImage?.toString() ?? product.cover?.toString(),
          fit: BoxFit.cover,
          placeholder: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(dynamic product, ProductsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.toString(),
          style: const TextStyle(
            fontFamily: 'semibold',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if ((product.measurement ?? '').toString().isNotEmpty ||
            (product.color ?? '').toString().isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            [
              if ((product.measurement ?? '').toString().isNotEmpty)
                product.measurement.toString(),
              if ((product.color ?? '').toString().isNotEmpty)
                product.color.toString(),
            ].join(' · '),
            style: TextStyle(
              fontFamily: 'regular',
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            if (product.originalPrice != product.sellPrice) ...[
              Text(
                controller.currencySide == 'left'
                    ? '${controller.currencySymbol}${product.originalPrice}'
                    : '${product.originalPrice}${controller.currencySymbol}',
                style: TextStyle(
                  fontFamily: 'regular',
                  fontSize: 12,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              controller.currencySide == 'left'
                  ? '${controller.currencySymbol}${product.sellPrice}'
                  : '${product.sellPrice}${controller.currencySymbol}',
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ThemeProvider.greenColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${'Stock'.tr}: ${product.stockAvailable ?? product.stockQty ?? product.inStock ?? 0}',
          style: TextStyle(fontFamily: 'regular', fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        _buildStatusChip(product.status),
      ],
    );
  }

  Widget _buildStatusChip(int status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 1 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 1 ? Colors.green[200]! : Colors.red[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 1 ? Icons.check_circle : Icons.cancel,
            size: 12,
            color: status == 1 ? Colors.green[700] : Colors.red[700],
          ),
          const SizedBox(width: 4),
          Text(
            status == 1 ? 'Active'.tr : 'Inactive'.tr,
            style: TextStyle(
              fontFamily: 'medium',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: status == 1 ? Colors.green[700] : Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductActions(dynamic product, ProductsController controller) {
    return Column(
      children: [
        _buildActionButton(
          icon: product.status == 1 ? Icons.visibility : Icons.visibility_off,
          color: product.status == 1
              ? ThemeProvider.greenColor
              : Colors.grey[600]!,
          onTap: () {
            controller.updateStatus(product.id as int, product.status as int);
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.inventory_2_outlined,
          color: Colors.orange[700]!,
          onTap: () {
            controller.onAddStock(
              product.id as int,
              current: (product.stockAvailable ??
                      product.stockQty ??
                      product.inStock ??
                      0) as int,
            );
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: ThemeProvider.appColor,
          onTap: () {
            controller.onUpdateProducts(product.id as int);
          },
        ),
        const SizedBox(height: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: ThemeProvider.redColor,
          onTap: () {
            _showDeleteDialog(context, controller, product);
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No products found for "$_searchQuery"'.tr
                : 'No products available'.tr,
            style: TextStyle(
              fontFamily: 'medium',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try searching with different keywords'.tr
                : 'Add your first product to get started'.tr,
            style: TextStyle(
              fontFamily: 'regular',
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Use + Add Product below'.tr,
              style: TextStyle(fontFamily: 'regular', fontSize: 12, color: Colors.grey[400]),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(ProductsController controller) {
    return FloatingActionButton.extended(
      onPressed: () {
        controller.onCreateProducts();
      },
      backgroundColor: ThemeProvider.appColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add),
      label: Text('Add Product'.tr),
      elevation: 8,
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ProductsController controller,
    dynamic product,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red[700],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Product'.tr,
                style: const TextStyle(
                  fontFamily: 'semibold',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this product?'.tr,
                style: const TextStyle(fontFamily: 'regular', fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.'.tr,
                style: TextStyle(
                  fontFamily: 'regular',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  fontFamily: 'medium',
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.destroyProduct(product.id as int);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Delete'.tr),
            ),
          ],
        );
      },
    );
  }
}
