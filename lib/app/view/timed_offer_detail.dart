import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/coupons_model.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timed_offer_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/timed_offers_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/currency_helper.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class TimedOfferDetailScreen extends StatelessWidget {
  final TimedCampaignModel campaign;

  const TimedOfferDetailScreen({Key? key, required this.campaign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimedOffersController>(builder: (controller) {
      final current = controller.selectedCampaign ?? campaign;
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            current.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            if (current.hasJoined)
              TextButton(
                onPressed: () {
                  Get.to(() => TimedOfferFormScreen(campaign: current));
                },
                child: Text(
                  'Edit'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => TimedOfferFormScreen(
                  campaign: current,
                  addMore: current.hasJoined,
                ));
          },
          backgroundColor: ThemeProvider.golden,
          foregroundColor: Colors.black,
          icon: const Icon(Icons.add_rounded),
          label: Text(current.hasJoined ? 'Add services' : 'Join Campaign'),
        ),
        body: RefreshIndicator(
          onRefresh: () => controller.fetchCampaignItems(current.id),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _headerCard(current, controller),
              const SizedBox(height: 20),
              if (controller.loadingItems.value)
                const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.campaignItems.isEmpty)
                _emptyItems(current)
              else
                ...controller.campaignItems.map(
                  (item) => _itemCard(context, item, controller),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      );
    });
  }

  String _campaignImage(
      TimedCampaignModel current, TimedOffersController controller) {
    final partner = controller.partnerOffer?.displayImage ?? '';
    if (partner.isNotEmpty) return partner;
    return current.displayImage;
  }

  Widget _headerCard(
      TimedCampaignModel current, TimedOffersController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_campaignImage(current, controller).isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: AppNetImage(
                  path: _campaignImage(current, controller),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if ((controller.partnerOffer?.displayDiscount ??
                  current.displayDiscount)
              .isNotEmpty)
            Text(
              controller.partnerOffer?.displayDiscount ??
                  current.displayDiscount,
              style: const TextStyle(
                color: Color(0xFFB45309),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (current.statusText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              current.statusText,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule_rounded,
                  size: 16, color: Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              Text(
                '${current.dailyStartTime} - ${current.dailyEndTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Text(
                '${current.myItemsCount} services',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (current.hasJoined) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Active on this campaign'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: current.status == 1,
                  activeThumbColor: ThemeProvider.appColor,
                  onChanged: (_) => controller.togglePartnerStatus(current),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyItems(TimedCampaignModel current) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.flash_on_outlined, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text('No services added yet'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Join ${current.name} and pick the services you want to include.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(
    BuildContext context,
    TimedOfferItemModel item,
    TimedOffersController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: AppNetImage(
                  path: item.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.duration} min',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  if (item.startDate.isNotEmpty || item.expire.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.startDate.isNotEmpty) item.startDate,
                        if (item.expire.isNotEmpty) item.expire,
                      ].join(' → '),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        CurrencyHelper.format(item.displayPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF059669),
                        ),
                      ),
                      if (item.originalPrice > item.displayPrice)
                        Text(
                          CurrencyHelper.format(item.originalPrice),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (item.discountText.isNotEmpty)
                        _miniBadge(item.discountText, const Color(0xFFB45309)),
                      if (item.isSoldOut)
                        _miniBadge('Sold out', const Color(0xFFDC2626))
                      else if (item.canBuy)
                        _miniBadge('Can buy', const Color(0xFF10B981)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _showItemEditor(context, item, controller),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF374151),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Price / Stock'.tr),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            _confirmRemove(context, item, controller),
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFDC2626)),
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

  Widget _miniBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showItemEditor(
    BuildContext context,
    TimedOfferItemModel item,
    TimedOffersController controller,
  ) {
    final priceController =
        TextEditingController(text: item.displayPrice.toString());
    final stockController =
        TextEditingController(text: item.stock > 0 ? item.stock.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Offer price (${CurrencyHelper.code()})'.tr,
                  prefixIcon: const Icon(Icons.payments),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stock (optional)'.tr,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final price = num.tryParse(priceController.text);
                    if (price == null) return;
                    final stock = int.tryParse(stockController.text);
                    Navigator.of(sheetContext).pop();
                    await controller.updateItemPrice(
                      itemId: item.id,
                      offerPrice: price,
                      stock: stock,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Save Item'.tr),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmRemove(
    BuildContext context,
    TimedOfferItemModel item,
    TimedOffersController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Remove service'.tr),
          content: Text(
              'Remove "${item.name}" from this limited offer?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await Future.delayed(const Duration(milliseconds: 200));
                await controller.removeItem(item.id);
              },
              child: Text('Remove'.tr),
            ),
          ],
        );
      },
    );
  }
}

class TimedOfferFormScreen extends StatefulWidget {
  final TimedCampaignModel campaign;
  final bool addMore;

  const TimedOfferFormScreen({
    Key? key,
    required this.campaign,
    this.addMore = false,
  }) : super(key: key);

  @override
  State<TimedOfferFormScreen> createState() => _TimedOfferFormScreenState();
}

class _TimedOfferFormScreenState extends State<TimedOfferFormScreen> {
  final TimedOffersController _controller = Get.find();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController originalPriceController = TextEditingController();
  final TextEditingController sellPriceController = TextEditingController();
  final TextEditingController uptoController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController expireController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController maxUsageController = TextEditingController();
  int selectedType = 1;
  bool applyAllServices = false;
  final Set<int> selectedServiceIds = {};
  final Map<int, int> serviceOfferType = {};
  final Map<int, TextEditingController> serviceDiscountCtrls = {};
  final Map<int, TextEditingController> serviceStartDateCtrls = {};
  final Map<int, TextEditingController> serviceExpireCtrls = {};
  bool _recalcLock = false;
  XFile? _imageFile;

  bool get isEdit => widget.campaign.hasJoined && !widget.addMore;
  bool get alreadyJoined => widget.campaign.hasJoined;

  String get _currencySymbol {
    final info = CurrencyHelper.active();
    return info.code.toUpperCase() == 'INR' ? info.symbol : info.code;
  }

  @override
  void initState() {
    super.initState();
    originalPriceController.addListener(_recalculateSell);
    discountController.addListener(_recalculateSell);
    _fillFromExisting(_controller.partnerOffer);
    if (nameController.text.isEmpty) {
      nameController.text = widget.campaign.name;
    }
    if (startTimeController.text.isEmpty) {
      startTimeController.text = widget.campaign.dailyStartTime;
    }
    if (endTimeController.text.isEmpty) {
      endTimeController.text = widget.campaign.dailyEndTime;
    }
    if (discountController.text.isEmpty) {
      _prefillDiscountFromCampaign();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.fetchPartnerServices();
      await _controller.fetchCampaignItems(widget.campaign.id);
      if (!mounted) return;
      _fillFromExisting(_controller.partnerOffer);
      _fillFromCampaignItems();
      _fillCampaignDatesIfEmpty();
      if (nameController.text.isEmpty) {
        nameController.text = widget.campaign.name;
      }
      setState(() {
        _syncAllServicesFromSelection(_controller.partnerServices);
        if (applyAllServices && selectedServiceIds.isEmpty) {
          selectedServiceIds
              .addAll(_controller.partnerServices.map((s) => s.id));
        }
        if (selectedServiceIds.isEmpty) {
          selectedServiceIds.addAll(_controller.matchedServiceIds());
        }
      });
      _syncOriginalFromServices();
      _recalculateSell();
    });
  }

  void _fillFromExisting(TimedPartnerOfferModel? existing) {
    if (existing == null) {
      _fillCampaignDatesIfEmpty();
      return;
    }
    if (existing.name.isNotEmpty) nameController.text = existing.name;
    if (existing.shortDescription.isNotEmpty) {
      descriptionController.text = existing.shortDescription;
    }
    if (existing.code.isNotEmpty) codeController.text = existing.code;
    if (existing.type != 0) selectedType = existing.type == 0 ? 1 : existing.type;
    if (existing.discount > 0) discountController.text = '${existing.discount}';
    if (existing.upto > 0) uptoController.text = '${existing.upto}';
    if (existing.startDate.isNotEmpty) {
      startDateController.text = existing.startDate;
    }
    if (existing.expire.isNotEmpty) expireController.text = existing.expire;
    if (existing.startTime.isNotEmpty) {
      startTimeController.text = existing.startTime;
    }
    if (existing.endTime.isNotEmpty) endTimeController.text = existing.endTime;
    if (existing.maxUsage > 0) {
      maxUsageController.text = '${existing.maxUsage}';
    }
    applyAllServices = existing.applyAllServices;
    if (existing.serviceIds.isNotEmpty) {
      selectedServiceIds
        ..clear()
        ..addAll(existing.serviceIds);
    }
    for (final line in existing.serviceOffers) {
      if (line.id <= 0) continue;
      selectedServiceIds.add(line.id);
      _ensureOfferFields(
        line.id,
        type: line.type,
        discount: line.discount,
        startDate: line.startDate,
        expire: line.expire,
      );
    }
    for (final service in existing.services) {
      selectedServiceIds.add(service.id);
      _ensureOfferFields(
        service.id,
        type: service.offerType,
        discount: service.discount,
        startDate: service.startDate,
        expire: service.expire,
      );
    }
    _fillCampaignDatesIfEmpty();
  }

  void _fillFromCampaignItems() {
    for (final item in _controller.campaignItems) {
      var id = item.id;
      if (!_controller.partnerServices.any((s) => s.id == id)) {
        OfferServiceModel? match;
        for (final service in _controller.partnerServices) {
          if (service.name.toLowerCase() == item.name.toLowerCase()) {
            match = service;
            break;
          }
        }
        if (match == null) continue;
        id = match.id;
      }
      selectedServiceIds.add(id);
      _ensureOfferFields(
        id,
        type: item.type,
        discount: item.discount,
        startDate: item.startDate,
        expire: item.expire,
      );
    }
  }

  void _fillCampaignDatesIfEmpty() {
    if (startDateController.text.isEmpty &&
        widget.campaign.startDate.isNotEmpty) {
      startDateController.text = widget.campaign.startDate;
    }
    if (expireController.text.isEmpty &&
        widget.campaign.expireDate.isNotEmpty) {
      expireController.text = widget.campaign.expireDate;
    }
    if (maxUsageController.text.isEmpty && widget.campaign.maxUsage > 0) {
      maxUsageController.text = '${widget.campaign.maxUsage}';
    }
  }

  void _prefillDiscountFromCampaign() {
    if (discountController.text.isNotEmpty) return;
    final offer = _controller.partnerOffer;
    if (offer != null && offer.discount > 0) {
      selectedType = offer.isPercent ? 1 : 2;
      discountController.text = '${offer.discount}';
      return;
    }
    if (widget.campaign.discountValue > 0) {
      selectedType = widget.campaign.discountType == 'flat' ? 2 : 1;
      discountController.text = '${widget.campaign.discountValue}';
    }
  }

  int get _defaultOfferType =>
      widget.campaign.discountType.toLowerCase() == 'flat' ? 2 : 1;

  String get _defaultDiscountText {
    final value = widget.campaign.discountValue;
    if (value <= 0) return '';
    return value % 1 == 0 ? '${value.toInt()}' : '$value';
  }

  void _ensureOfferFields(
    int id, {
    int? type,
    num? discount,
    String? startDate,
    String? expire,
  }) {
    if (type != null) {
      serviceOfferType[id] = type == 2 ? 2 : 1;
    } else {
      serviceOfferType.putIfAbsent(id, () => _defaultOfferType);
    }
    if (!serviceDiscountCtrls.containsKey(id)) {
      final text = discount != null && discount > 0
          ? (discount % 1 == 0 ? '${discount.toInt()}' : '$discount')
          : _defaultDiscountText;
      serviceDiscountCtrls[id] = TextEditingController(text: text);
    } else if (discount != null &&
        discount > 0 &&
        serviceDiscountCtrls[id]!.text.isEmpty) {
      serviceDiscountCtrls[id]!.text =
          discount % 1 == 0 ? '${discount.toInt()}' : '$discount';
    }
    _ensureDateCtrl(
      serviceStartDateCtrls,
      id,
      startDate,
      widget.campaign.startDate,
    );
    _ensureDateCtrl(
      serviceExpireCtrls,
      id,
      expire,
      widget.campaign.expireDate,
    );
  }

  void _ensureDateCtrl(
    Map<int, TextEditingController> map,
    int id,
    String? value,
    String fallback,
  ) {
    final text = (value != null && value.isNotEmpty) ? value : fallback;
    if (!map.containsKey(id)) {
      map[id] = TextEditingController(text: text);
    } else if (value != null && value.isNotEmpty) {
      map[id]!.text = value;
    }
  }

  void _syncAllServicesFromSelection(List services) {
    if (services.isEmpty) {
      applyAllServices = false;
      return;
    }
    final allSelected =
        services.every((s) => selectedServiceIds.contains(s.id));
    applyAllServices = allSelected;
  }

  double _selectedServicesTotal() {
    final services = applyAllServices
        ? _controller.partnerServices
        : _controller.partnerServices
            .where((service) => selectedServiceIds.contains(service.id));
    return services.fold<double>(0, (sum, service) => sum + service.price);
  }

  void _syncOriginalFromServices() {
    final total = _selectedServicesTotal();
    if (total <= 0) return;
    _recalcLock = true;
    originalPriceController.text = total.toStringAsFixed(2);
    _recalcLock = false;
  }

  void _recalculateSell() {
    if (_recalcLock) return;
    _recalcLock = true;
    final original = double.tryParse(originalPriceController.text) ?? 0;
    final discount = double.tryParse(discountController.text) ?? 0;
    double sell = original;
    if (selectedType == 1) {
      sell = original - ((original * discount) / 100);
    } else {
      sell = original - discount;
    }
    if (sell < 0) sell = 0;
    sellPriceController.text = sell.toStringAsFixed(2);
    _recalcLock = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          widget.addMore
              ? 'Add services'
              : (isEdit ? 'Update Limited Offer' : 'Join Limited Offer'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _infoBanner(),
            const SizedBox(height: 16),
            _buildFormCard([
              OfferImagePickerTile(
                file: _imageFile,
                existingUrl: _controller.partnerOffer?.displayImage.isNotEmpty ==
                        true
                    ? _controller.partnerOffer!.displayImage
                    : widget.campaign.displayImage,
                onPick: _pickOfferImage,
                onClear: () => setState(() => _imageFile = null),
              ),
              _buildServicePicker(),
            ]),
            const SizedBox(height: 20),
            _buildFormCard([
              _buildTextField(
                controller: nameController,
                label: 'Offer Name'.tr,
                hint: widget.campaign.name,
                icon: Icons.local_offer,
              ),
              _buildTextField(
                controller: descriptionController,
                label: 'Description'.tr,
                hint: 'Short description for this timed offer'.tr,
                icon: Icons.description,
                maxLines: 3,
              ),
              _buildTextField(
                controller: codeController,
                label: 'Offer Code'.tr,
                hint: 'Optional coupon code'.tr,
                icon: Icons.code,
              ),
            ]),
            const SizedBox(height: 20),
            _buildFormCard([
              _buildTextField(
                controller: maxUsageController,
                label: 'Max Usage'.tr,
                hint: '0'.tr,
                icon: Icons.repeat,
                isNumeric: true,
              ),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                widget.addMore
                    ? 'Add services'
                    : (isEdit ? 'Update Limited Offer' : 'Join Limited Offer'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFB45309)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.campaign.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildServicePicker() {
    return Obx(() {
      final services = _controller.partnerServices;
      if (_controller.loadingServices.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apply to services'.tr,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.addMore
                ? 'Select extra services. Set type, discount and dates on each row.'
                : 'Required. Each selected service has its own type, discount, start date and end date.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('All services'.tr),
            value: applyAllServices,
            activeThumbColor: const Color(0xFF6C5CE7),
            activeTrackColor: const Color(0xFF6C5CE7).withOpacity(0.45),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            onChanged: (value) {
              setState(() {
                applyAllServices = value;
                if (value) {
                  selectedServiceIds
                    ..clear()
                    ..addAll(services.map((s) => s.id));
                  for (final s in services) {
                    _ensureOfferFields(s.id);
                  }
                }
              });
              _syncOriginalFromServices();
              _recalculateSell();
            },
          ),
          if (services.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('No active services found for this partner.'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            )
            else
            ...services.map((service) {
              final selected =
                  applyAllServices || selectedServiceIds.contains(service.id);
              if (selected) _ensureOfferFields(service.id);
              return _serviceOfferRow(service, selected);
            }),
        ],
      );
    });
  }

  Widget _serviceOfferRow(OfferServiceModel service, bool selected) {
    final type = serviceOfferType[service.id] ?? _defaultOfferType;
    final discountCtrl = serviceDiscountCtrls[service.id];
    final discount = double.tryParse(discountCtrl?.text ?? '') ?? 0;
    double sell = service.price;
    if (type == 1) {
      sell = service.price - ((service.price * discount) / 100);
    } else {
      sell = service.price - discount;
    }
    if (sell < 0) sell = 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: selected,
            title: Text(
              service.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: _servicePriceSubtitle(service, selected: selected),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: applyAllServices
                ? null
                : (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedServiceIds.add(service.id);
                        _ensureOfferFields(service.id);
                      } else {
                        selectedServiceIds.remove(service.id);
                      }
                      _syncAllServicesFromSelection(
                          _controller.partnerServices);
                    });
                  },
          ),
          if (selected && discountCtrl != null) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: type,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Type'.tr,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 1, child: Text('Percent %'.tr)),
                        DropdownMenuItem(
                            value: 2,
                            child: Text('Flat $_currencySymbol'.tr)),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => serviceOfferType[service.id] = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: discountCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) => _discountError(
                        service: service,
                        type: type,
                        raw: value,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: type == 1 ? 'Discount %' : 'Discount',
                        isDense: true,
                        prefixText: type == 2 ? '$_currencySymbol ' : null,
                        errorMaxLines: 2,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (selected &&
              discount > 0 &&
              _discountError(
                    service: service,
                    type: type,
                    raw: discountCtrl.text,
                  ) ==
                  null)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Text(
                '${CurrencyHelper.format(service.price, decimals: 2)} → ${CurrencyHelper.format(sell, decimals: 2)}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ),
          if (selected)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 4, bottom: 4),
              child: Column(
                children: [
                  _buildServiceDateField(
                    controller: serviceStartDateCtrls[service.id]!,
                    label: 'Start date'.tr,
                    icon: Icons.event_available,
                    validator: (_) => _serviceDateError(service.id),
                  ),
                  _buildServiceDateField(
                    controller: serviceExpireCtrls[service.id]!,
                    label: 'End date'.tr,
                    icon: Icons.event_busy,
                    validator: (_) => _serviceDateError(service.id),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _servicePriceSubtitle(OfferServiceModel service,
      {required bool selected}) {
    final original = CurrencyHelper.format(service.price, decimals: 2);
    final offer = CurrencyHelper.format(service.offerPrice, decimals: 2);
    final mins = service.duration % 1 == 0
        ? service.duration.toInt().toString()
        : service.duration.toStringAsFixed(1);
    final showDiscount = selected && service.hasDiscount;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          if (showDiscount) ...[
            Text(
              original,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              offer,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF059669),
              ),
            ),
            if (service.discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${service.discount % 1 == 0 ? service.discount.toInt() : service.discount}% OFF',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFB45309),
                  ),
                ),
              ),
          ] else
            Text(
              original,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          Text(
            '• $mins min',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumeric = false,
    int maxLines = 1,
    bool readOnly = false,
    String? prefixText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: isNumeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey[100] : Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        decoration: _fieldDecoration(label, hint, icon, hasDropdown: true),
        onTap: () => _pickDate(controller),
      ),
    );
  }

  String _displayDate(String raw) {
    final parsed = DateTime.tryParse(raw.trim());
    if (parsed == null) return raw;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  Widget _buildServiceDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: FormField<String>(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator,
        builder: (state) {
          return InkWell(
            onTap: () async {
              await _pickDate(controller);
              state.didChange(controller.text);
            },
            borderRadius: BorderRadius.circular(10),
            child: InputDecorator(
              isEmpty: controller.text.trim().isEmpty,
              decoration: InputDecoration(
                labelText: label,
                hintText: 'DD MMM YYYY',
                isDense: true,
                prefixIcon:
                    Icon(icon, color: const Color(0xFF6C5CE7), size: 20),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon:
                    const Icon(Icons.calendar_today_outlined, size: 16),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                errorText: state.errorText,
                errorMaxLines: 2,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF6C5CE7), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              child: Text(
                controller.text.trim().isEmpty
                    ? 'Select date'.tr
                    : _displayDate(controller.text),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: controller.text.trim().isEmpty
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF111827),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF6C5CE7),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  InputDecoration _fieldDecoration(
    String label,
    String hint,
    IconData icon, {
    bool hasDropdown = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
      suffixIcon: hasDropdown ? const Icon(Icons.arrow_drop_down) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Future<void> _pickOfferImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imageFile = picked);
  }

  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  OfferServiceModel? _serviceById(int id) {
    for (final service in _controller.partnerServices) {
      if (service.id == id) return service;
    }
    return null;
  }

  String? _discountError({
    required OfferServiceModel service,
    required int type,
    required String? raw,
  }) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter discount'.tr;
    }
    final discount = num.tryParse(text);
    if (discount == null) {
      return 'Enter a valid number'.tr;
    }
    if (discount <= 0) {
      return 'Discount must be greater than 0'.tr;
    }
    if (type == 1) {
      if (discount >= 100) {
        return 'Percent must be less than 100'.tr;
      }
    } else if (service.price > 0 && discount >= service.price) {
      return 'Must be less than ${CurrencyHelper.format(service.price, decimals: 2)}';
    }
    return null;
  }

  String? _serviceDateError(int id) {
    final start = serviceStartDateCtrls[id]?.text.trim() ?? '';
    final expire = serviceExpireCtrls[id]?.text.trim() ?? '';
    if (start.isEmpty) return 'Select start date'.tr;
    if (expire.isEmpty) return 'Select end date'.tr;
    final startDate = DateTime.tryParse(start);
    final expireDate = DateTime.tryParse(expire);
    if (startDate != null &&
        expireDate != null &&
        expireDate.isBefore(startDate)) {
      return 'End date must be after start date'.tr;
    }
    return null;
  }

  Future<void> _submitForm() async {
    final ids = applyAllServices
        ? _controller.partnerServices.map((s) => s.id).toList()
        : selectedServiceIds.toList();
    if (ids.isEmpty && !isEdit) {
      Get.snackbar(
        'Services required',
        'Select ALL or at least one partner service',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    for (final id in ids) {
      _ensureOfferFields(id);
    }

    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) {
        Get.snackbar(
          'Invalid fields'.tr,
          'Fix discount and dates for each selected service'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    for (final id in ids) {
      final service = _serviceById(id);
      if (service == null) continue;
      final error = _discountError(
        service: service,
        type: serviceOfferType[id] ?? 1,
        raw: serviceDiscountCtrls[id]?.text,
      );
      if (error != null) {
        Get.snackbar(
          service.name,
          error,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      final dateError = _serviceDateError(id);
      if (dateError != null) {
        Get.snackbar(
          service.name,
          dateError,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    final serviceOffers = ids
        .map((id) => TimedOfferServiceLine(
              id: id,
              type: serviceOfferType[id] ?? 1,
              discount: num.tryParse(serviceDiscountCtrls[id]?.text ?? '') ?? 0,
              startDate: serviceStartDateCtrls[id]?.text.trim() ?? '',
              expire: serviceExpireCtrls[id]?.text.trim() ?? '',
            ))
        .toList();

    final offer = TimedPartnerOfferModel(
      campaignId: widget.campaign.id,
      name: nameController.text.trim(),
      shortDescription: descriptionController.text.trim(),
      code: codeController.text.trim(),
      startDate: startDateController.text.trim(),
      expire: expireController.text.trim(),
      startTime: startTimeController.text.trim(),
      endTime: endTimeController.text.trim(),
      maxUsage: _toInt(maxUsageController.text),
      minCartValue: 100,
      applyAllServices: applyAllServices,
      serviceIds: applyAllServices ? const [] : ids,
      serviceOffers: serviceOffers,
    );

    final includeServices = applyAllServices || ids.isNotEmpty;
    final success = alreadyJoined
        ? await _controller.updatePartnerOffer(
            offer,
            includeServices: includeServices,
            image: _imageFile,
          )
        : await _controller.createPartnerOffer(offer, image: _imageFile);

    if (success && mounted) {
      await Get.dialog(
        AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 28),
              const SizedBox(width: 10),
              Text(
                'Success'.tr,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            widget.addMore
                ? 'Services added to this limited offer.'.tr
                : (isEdit
                    ? 'Limited offer updated successfully.'.tr
                    : 'Limited offer saved successfully.'.tr),
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                backgroundColor: ThemeProvider.appColor,
              ),
              child: Text(
                'OK'.tr,
                style: const TextStyle(color: ThemeProvider.whiteColor),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    originalPriceController.removeListener(_recalculateSell);
    discountController.removeListener(_recalculateSell);
    nameController.dispose();
    descriptionController.dispose();
    codeController.dispose();
    discountController.dispose();
    originalPriceController.dispose();
    sellPriceController.dispose();
    uptoController.dispose();
    startDateController.dispose();
    expireController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    maxUsageController.dispose();
    for (final ctrl in serviceDiscountCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in serviceStartDateCtrls.values) {
      ctrl.dispose();
    }
    for (final ctrl in serviceExpireCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }
}
