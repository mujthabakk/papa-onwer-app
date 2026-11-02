class ProductsModel {
  int? id;
  int? freelacerId;
  String? cover;
  String? name;
  String? images;
  double? originalPrice;
  double? sellPrice;
  double? discount;
  int? cateId;
  int? subCateId;
  int? inHome;
  int? isSingle;
  int? haveGram;
  String? gram;
  int? haveKg;
  String? kg;
  int? havePcs;
  String? pcs;
  String? hsnCode;
  int? haveLiter;
  String? liter;
  int? haveMl;
  String? ml;
  String? descriptions;
  String? keyFeatures;
  String? disclaimer;
  String? expDate;
  int? inOffer;
  int? inStock;
  String? rating;
  int? totalRating;
  int? status;
  String? extraField;
  int? stockQty;
  int? stockAvailable;
  int? variantStockQty;
  String? color;
  int? measurementId;
  String? measurementValue;
  String? measurement;
  int? returnable;
  int? returnDays;
  int? acceptCod;
  int? acceptOnline;
  List<String> paymentMethods = [];
  bool hasVariants = false;
  List<ProductGalleryItem> galleryItems = [];
  List<String> imagesList = [];
  List<ProductVariant> variants = [];

  ProductsModel(
      {this.id,
      this.freelacerId,
      this.cover,
      this.name,
      this.images,
      this.originalPrice,
      this.sellPrice,
      this.discount,
      this.cateId,
      this.subCateId,
      this.inHome,
      this.isSingle,
      this.haveGram,
      this.gram,
      this.haveKg,
      this.kg,
      this.havePcs,
      this.pcs,
      this.hsnCode,
      this.haveLiter,
      this.liter,
      this.haveMl,
      this.ml,
      this.descriptions,
      this.keyFeatures,
      this.disclaimer,
      this.expDate,
      this.inOffer,
      this.inStock,
      this.rating,
      this.totalRating,
      this.status,
      this.extraField,
      this.stockQty,
      this.stockAvailable,
      this.variantStockQty,
      this.color,
      this.measurementId,
      this.measurementValue,
      this.measurement,
      this.hasVariants = false,
      List<ProductGalleryItem>? galleryItems,
      List<String>? imagesList,
      List<ProductVariant>? variants})
      : galleryItems = galleryItems ?? [],
        imagesList = imagesList ?? [],
        variants = variants ?? [];

  ProductsModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id'] ?? ''}');
    freelacerId = int.tryParse(
        '${json['freelacer_id'] ?? json['freelancer_id'] ?? ''}');
    cover = json['cover']?.toString();
    name = json['name']?.toString();
    images = json['images'] is List
        ? json['images'].join(',')
        : json['images']?.toString();
    originalPrice = double.tryParse('${json['original_price'] ?? 0}') ?? 0;
    sellPrice = double.tryParse(
            '${json['sell_price'] ?? json['amount'] ?? 0}') ??
        0;
    discount = double.tryParse('${json['discount'] ?? 0}') ?? 0;
    cateId = int.tryParse('${json['cate_id'] ?? ''}');
    subCateId = int.tryParse('${json['sub_cate_id'] ?? ''}');
    inHome = int.tryParse('${json['in_home'] ?? 0}') ?? 0;
    isSingle = int.tryParse('${json['is_single'] ?? 0}') ?? 0;
    haveGram = int.tryParse('${json['have_gram'] ?? 0}') ?? 0;
    gram = json['gram']?.toString();
    haveKg = int.tryParse('${json['have_kg'] ?? 0}') ?? 0;
    kg = json['kg']?.toString();
    hsnCode = json['hsn_code']?.toString();
    havePcs = int.tryParse('${json['have_pcs'] ?? 0}') ?? 0;
    pcs = json['pcs']?.toString();
    haveLiter = int.tryParse('${json['have_liter'] ?? 0}') ?? 0;
    liter = json['liter']?.toString();
    haveMl = int.tryParse('${json['have_ml'] ?? 0}') ?? 0;
    ml = json['ml']?.toString();
    descriptions = json['descriptions']?.toString();
    keyFeatures = json['key_features']?.toString();
    disclaimer = json['disclaimer']?.toString();
    expDate = json['exp_date']?.toString();
    inOffer = int.tryParse('${json['in_offer'] ?? 0}') ?? 0;
    inStock = int.tryParse(
            '${json['in_stock'] ?? json['stock'] ?? json['stock_qty'] ?? 0}') ??
        0;
    stockQty = int.tryParse(
            '${json['stock_qty'] ?? json['stock'] ?? json['in_stock'] ?? 0}') ??
        0;
    stockAvailable = int.tryParse('${json['stock_available'] ?? ''}');
    variantStockQty = int.tryParse('${json['variant_stock_qty'] ?? ''}');
    hasVariants = json['has_variants'] == true ||
        json['has_variants']?.toString() == '1' ||
        (json['variants'] is List && (json['variants'] as List).isNotEmpty);
    if (json['gallery'] is List) {
      galleryItems = (json['gallery'] as List)
          .whereType<Map>()
          .map((row) =>
              ProductGalleryItem.fromJson(Map<String, dynamic>.from(row)))
          .toList();
      ProductGalleryItem.sortByView(galleryItems);
    }
    if (json['images_list'] is List) {
      imagesList = (json['images_list'] as List)
          .map((row) => row.toString())
          .where((row) => row.isNotEmpty)
          .toList();
    }
    if (galleryItems.isEmpty && imagesList.isNotEmpty) {
      galleryItems = imagesList
          .map((url) => ProductGalleryItem(view: 'other', url: url))
          .toList();
    }
    rating = json['rating']?.toString();
    totalRating = int.tryParse('${json['total_rating'] ?? 0}') ?? 0;
    status = int.tryParse('${json['status'] ?? 1}') ?? 1;
    extraField = json['extra_field']?.toString();
    color = (json['color'] ?? json['colour'] ?? json['color_name'])
        ?.toString();
    measurementId = int.tryParse(
        '${json['measurement_id'] ?? json['unit_id'] ?? ''}');
    measurementValue = (json['measurement_value'] ??
            json['measurement_amount'] ??
            json['unit_value'] ??
            json['unit_amount'] ??
            json['value'])
        ?.toString();
    measurement = json['measurement']?.toString();
    final measurementType =
        (json['measurement_type'] ?? json['unit'] ?? json['symbol'])
            ?.toString();
    if ((measurement == null || measurement!.isEmpty) &&
        (measurementValue ?? '').isNotEmpty &&
        (measurementType ?? '').isNotEmpty) {
      measurement = '$measurementValue $measurementType';
    }
    returnable = int.tryParse(
            '${json['returnable'] ?? json['return_option'] ?? json['is_returnable'] ?? 0}') ??
        0;
    returnDays = int.tryParse(
            '${json['return_days'] ?? json['return_period'] ?? 0}') ??
        0;
    acceptCod = int.tryParse('${json['accept_cod'] ?? 0}') ?? 0;
    acceptOnline = int.tryParse('${json['accept_online'] ?? 0}') ?? 0;
    paymentMethods = [];
    final rawPay = json['payment_methods'];
    if (rawPay is List) {
      for (final row in rawPay) {
        if (row is Map) {
          final code =
              (row['code'] ?? row['type'] ?? '').toString().toLowerCase();
          if (code.isNotEmpty) paymentMethods.add(code);
        } else {
          final code = row.toString().toLowerCase();
          if (code.isNotEmpty) paymentMethods.add(code);
        }
      }
    }
    if (paymentMethods.isEmpty) {
      if (acceptCod == 1) paymentMethods.add('cod');
      if (acceptOnline == 1) paymentMethods.add('online');
    }
    if ((measurement == null || measurement!.isEmpty) &&
        json['measurementInfo'] is Map) {
      final info = Map<String, dynamic>.from(json['measurementInfo']);
      final unit = (info['symbol'] ?? info['code'] ?? info['name'] ?? '')
          .toString();
      if ((measurementValue ?? '').isNotEmpty && unit.isNotEmpty) {
        measurement = '$measurementValue $unit';
      }
    }
    final rawVariants = json['variants'];
    if (rawVariants is List) {
      variants = rawVariants
          .whereType<Map>()
          .map((row) =>
              ProductVariant.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['freelacer_id'] = freelacerId;
    data['cover'] = cover;
    data['name'] = name;
    data['images'] = images;
    data['original_price'] = originalPrice;
    data['sell_price'] = sellPrice;
    data['discount'] = discount;
    data['cate_id'] = cateId;
    data['sub_cate_id'] = subCateId;
    data['hsn_code'] = hsnCode;

    data['in_home'] = inHome;
    data['is_single'] = isSingle;
    data['have_gram'] = haveGram;
    data['gram'] = gram;
    data['have_kg'] = haveKg;
    data['kg'] = kg;
    data['have_pcs'] = havePcs;
    data['pcs'] = pcs;
    data['have_liter'] = haveLiter;
    data['liter'] = liter;
    data['have_ml'] = haveMl;
    data['ml'] = ml;
    data['descriptions'] = descriptions;
    data['key_features'] = keyFeatures;
    data['disclaimer'] = disclaimer;
    data['exp_date'] = expDate;
    data['in_offer'] = inOffer;
    data['in_stock'] = inStock;
    data['rating'] = rating;
    data['total_rating'] = totalRating;
    data['status'] = status;
    data['extra_field'] = extraField;
    data['variants'] = variants.map((e) => e.toJson()).toList();
    data['stock_qty'] = stockQty ?? inStock;
    data['stock_available'] = stockAvailable ?? stockQty ?? inStock;
    data['variant_stock_qty'] = variantStockQty;
    data['has_variants'] = hasVariants;
    data['gallery'] = galleryItems.map((e) => e.toJson()).toList();
    data['images_list'] = imagesList;
    data['color'] = color;
    data['measurement_id'] = measurementId;
    data['measurement_value'] = measurementValue;
    data['measurement'] = measurement;
    return data;
  }

  String? get displayImage {
    if (cover != null && cover!.isNotEmpty && cover != 'NA') return cover;
    if (galleryItems.isNotEmpty) return galleryItems.first.url;
    if (imagesList.isNotEmpty) return imagesList.first;
    return cover;
  }
}

class ProductGalleryItem {
  String? view;
  String? label;
  String? url;

  ProductGalleryItem({this.view, this.label, this.url});

  factory ProductGalleryItem.fromJson(Map<String, dynamic> json) {
    return ProductGalleryItem(
      view: json['view']?.toString(),
      label: json['label']?.toString(),
      url: (json['url'] ?? json['image_name'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'view': view ?? 'other',
      if (label != null && label!.isNotEmpty) 'label': label,
      'url': url ?? '',
    };
  }

  static const List<String> viewOrder = [
    'front',
    'back',
    'side',
    'left',
    'right',
    'top',
    'bottom',
    'detail',
    'other',
  ];

  static void sortByView(List<ProductGalleryItem> items) {
    items.sort((a, b) {
      final ai = viewOrder.indexOf((a.view ?? 'other').toLowerCase());
      final bi = viewOrder.indexOf((b.view ?? 'other').toLowerCase());
      return (ai < 0 ? 99 : ai).compareTo(bi < 0 ? 99 : bi);
    });
  }
}

class ProductMeasurement {
  int? id;
  String? name;
  String? code;
  String? symbol;
  String? unit;
  String? displayLabel;
  int? status;

  ProductMeasurement({
    this.id,
    this.name,
    this.code,
    this.symbol,
    this.unit,
    this.displayLabel,
    this.status,
  });

  factory ProductMeasurement.fromJson(Map<String, dynamic> json) {
    return ProductMeasurement(
      id: int.tryParse('${json['id'] ?? ''}'),
      name: json['name']?.toString(),
      code: json['code']?.toString(),
      symbol: json['symbol']?.toString(),
      unit: json['unit']?.toString(),
      displayLabel: json['label']?.toString(),
      status: int.tryParse('${json['status'] ?? 1}') ?? 1,
    );
  }

  String get label {
    if (displayLabel != null && displayLabel!.trim().isNotEmpty) {
      return displayLabel!.trim();
    }
    final title = name ?? code ?? '';
    final unitText = symbol ?? unit ?? code ?? '';
    if (title.isNotEmpty && unitText.isNotEmpty && title != unitText) {
      return '$title ($unitText)';
    }
    return title.isNotEmpty ? title : unitText;
  }
}

class ProductVariant {
  int? id;
  String? name;
  String? color;
  int? measurementId;
  String? measurementValue;
  String? measurement;
  num? originalPrice;
  num? sellPrice;
  num? discount;
  int? inStock;
  String? sku;
  String? cover;
  List<ProductGalleryItem> galleryItems = [];

  ProductVariant({
    this.id,
    this.name,
    this.color,
    this.measurementId,
    this.measurementValue,
    this.measurement,
    this.originalPrice,
    this.sellPrice,
    this.discount,
    this.inStock,
    this.sku,
    this.cover,
    List<ProductGalleryItem>? galleryItems,
  }) : galleryItems = galleryItems ?? [];

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final gallery = <ProductGalleryItem>[];
    if (json['gallery'] is List) {
      gallery.addAll((json['gallery'] as List)
          .whereType<Map>()
          .map((row) =>
              ProductGalleryItem.fromJson(Map<String, dynamic>.from(row))));
      ProductGalleryItem.sortByView(gallery);
    }
    return ProductVariant(
      id: int.tryParse('${json['id'] ?? ''}'),
      name: json['name']?.toString(),
      color: (json['color'] ?? json['colour'] ?? json['color_name'])
          ?.toString(),
      measurementId: int.tryParse(
          '${json['measurement_id'] ?? json['unit_id'] ?? ''}'),
      measurementValue: (json['measurement_value'] ??
              json['measurement_amount'] ??
              json['unit_value'] ??
              json['unit_amount'] ??
              json['value'])
          ?.toString(),
      measurement: () {
        final raw = json['measurement']?.toString();
        if (raw != null && raw.isNotEmpty) return raw;
        final value = (json['measurement_value'] ??
                json['measurement_amount'] ??
                json['unit_value'] ??
                json['value'])
            ?.toString();
        final type =
            (json['measurement_type'] ?? json['unit'] ?? json['symbol'])
                ?.toString();
        if ((value ?? '').isNotEmpty && (type ?? '').isNotEmpty) {
          return '$value $type';
        }
        return json['measurement_type']?.toString();
      }(),
      originalPrice: num.tryParse(
          '${json['original_price'] ?? json['original'] ?? json['mrp'] ?? ''}'),
      sellPrice: num.tryParse(
          '${json['sell_price'] ?? json['price'] ?? json['sellPrice'] ?? ''}'),
      discount: num.tryParse('${json['discount'] ?? ''}'),
      inStock: int.tryParse(
          '${json['in_stock'] ?? json['stock'] ?? json['stock_qty'] ?? json['qty'] ?? ''}'),
      sku: json['sku']?.toString(),
      cover: (json['cover'] ??
              json['picture'] ??
              json['image'] ??
              json['photo'])
          ?.toString(),
      galleryItems: gallery,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name ?? '',
      if (color != null && color!.isNotEmpty) 'color': color,
      if (measurementId != null) 'measurement_id': measurementId,
      if (measurementId != null) 'unit_id': measurementId,
      if (measurementValue != null && measurementValue!.isNotEmpty)
        'measurement_value': measurementValue,
      if (originalPrice != null) 'original_price': originalPrice,
      if (originalPrice != null) 'original': originalPrice,
      'sell_price': sellPrice ?? 0,
      if (discount != null) 'discount': discount,
      'in_stock': inStock ?? 1,
      'stock': inStock ?? 1,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      if (cover != null && cover!.isNotEmpty) 'cover': cover,
      if (cover != null && cover!.isNotEmpty) 'picture': cover,
      if (galleryItems.isNotEmpty)
        'gallery': galleryItems.map((e) => e.toJson()).toList(),
    };
  }

  List<String> get imageUrls {
    final urls = <String>[];
    if (cover != null && cover!.isNotEmpty && cover != 'null') {
      urls.add(cover!);
    }
    for (final item in galleryItems) {
      final url = item.url ?? '';
      if (url.isNotEmpty && !urls.contains(url)) urls.add(url);
    }
    return urls;
  }

  String get title {
    return [name, color]
        .where((part) => part != null && part.trim().isNotEmpty)
        .join(' • ');
  }
}
