import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/product/controller/product_detail_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/product/models/products_model.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(
      builder: (value) {
        final images = value.galleryUrls;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: ThemeProvider.appColor,
            iconTheme: const IconThemeData(color: ThemeProvider.whiteColor),
            title: Text(
              value.product.name ?? 'Product'.tr,
              style: ThemeProvider.titleStyle,
            ),
            actions: [
              IconButton(
                onPressed: value.onOpenHistory,
                icon: const Icon(Icons.history),
              ),
              IconButton(
                onPressed: value.onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: value.apiCalled == false
              ? const Center(
                  child: CircularProgressIndicator(
                      color: ThemeProvider.appColor),
                )
              : ListView(
                  children: [
                    if (images.isNotEmpty)
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 280,
                          viewportFraction: 1,
                          enableInfiniteScroll: images.length > 1,
                          autoPlay: images.length > 1,
                        ),
                        items: images
                            .map(
                              (url) => AppNetImage(
                                path: url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 280,
                              ),
                            )
                            .toList(),
                      )
                    else
                      Container(
                        height: 220,
                        color: Colors.grey[100],
                        child: const Icon(Icons.image_not_supported, size: 64),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: 'bold',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                value.money(value.displaySellPrice),
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: ThemeProvider.greenColor,
                                  fontFamily: 'bold',
                                ),
                              ),
                              if (value.displayOriginalPrice > 0 &&
                                  value.displayOriginalPrice !=
                                      value.displaySellPrice) ...[
                                const SizedBox(width: 8),
                                Text(
                                  value.money(value.displayOriginalPrice),
                                  style: TextStyle(
                                    fontFamily: 'regular',
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${'Stock'.tr}: ${value.displayStock}',
                            style: const TextStyle(fontFamily: 'regular', fontSize: 14),
                          ),
                          if (value.displayDiscount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${'Discount'.tr}: ${value.displayDiscount}',
                              style: const TextStyle(fontFamily: 'regular', fontSize: 14),
                            ),
                          ],
                          if ((value.selectedVariant?.color ??
                                  value.product.color ??
                                  '')
                              .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                                '${'Color'.tr}: ${value.selectedVariant?.color ?? value.product.color}'),
                          ],
                          if ((value.selectedVariant?.measurement ??
                                  value.product.measurement ??
                                  '')
                              .isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                                '${'Unit'.tr}: ${value.selectedVariant?.measurement ?? value.product.measurement}'),
                          ],
                          if ((value.product.descriptions ?? '').isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(value.product.descriptions!),
                          ],
                          if (value.product.variants.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              'Variants'.tr,
                              style: const TextStyle(fontFamily: 'bold'),
                            ),
                            const SizedBox(height: 8),
                            ...value.product.variants.map(
                              (row) => _variantTile(value, row),
                            ),
                            if (value.selectedVariant != null) ...[
                              const SizedBox(height: 12),
                              _variantDetailsCard(value, value.selectedVariant!),
                            ],
                          ],
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history),
                            title: Text('Order history'.tr,
                                style: const TextStyle(fontFamily: 'bold')),
                            subtitle: Text(
                              '${'Future'.tr} ${value.history.count('future_orders')}  •  ${'Current'.tr} ${value.history.count('current_orders')}  •  ${'Past'.tr} ${value.history.count('past_deliveries')}  •  ${'Cancelled'.tr} ${value.history.count('cancelled')}',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: value.onOpenHistory,
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

  Widget _variantTile(ProductDetailController value, ProductVariant row) {
    final selected = identical(value.selectedVariant, row) ||
        (value.selectedVariant?.id != null &&
            value.selectedVariant?.id == row.id);
    return InkWell(
      onTap: () => value.selectVariant(row),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? ThemeProvider.appColor : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? ThemeProvider.appColor.withOpacity(0.06)
              : Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 52,
                height: 52,
                child: AppNetImage(
                  path: row.cover ?? '',
                  fit: BoxFit.cover,
                  placeholder: const Icon(Icons.inventory_2_outlined),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.title.isEmpty ? 'Variant'.tr : row.title,
                    style: const TextStyle(fontFamily: 'bold'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${value.money(row.sellPrice)}  •  ${'Stock'.tr} ${row.inStock ?? 0}',
                    style: TextStyle(fontFamily: 'regular', fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.expand_less : Icons.chevron_right,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _variantDetailsCard(
      ProductDetailController value, ProductVariant row) {
    final photos = row.imageUrls;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Variant details'.tr,
            style: const TextStyle(fontFamily: 'bold', fontSize: 16),
          ),
          const SizedBox(height: 10),
          _detailRow('Name'.tr, row.name ?? '-'),
          _detailRow('Color'.tr, row.color ?? '-'),
          _detailRow(
              'Unit'.tr,
              row.measurement ??
                  [
                    if ((row.measurementValue ?? '').isNotEmpty)
                      row.measurementValue,
                  ].join()),
          _detailRow('Original'.tr, value.money(row.originalPrice)),
          _detailRow('Sell Price'.tr, value.money(row.sellPrice)),
          _detailRow('Discount'.tr, '${row.discount ?? 0}'),
          _detailRow('Stock'.tr, '${row.inStock ?? 0}'),
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Photos'.tr, style: const TextStyle(fontFamily: 'bold')),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetImage(
                      path: photos[index],
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontFamily: 'regular', color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(fontFamily: 'bold')),
          ),
        ],
      ),
    );
  }
}
