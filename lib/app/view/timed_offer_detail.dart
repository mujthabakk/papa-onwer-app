import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timed_offer_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/timed_offers_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';
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
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => TimedOfferFormScreen(campaign: current));
          },
          backgroundColor: ThemeProvider.golden,
          foregroundColor: Colors.black,
          icon: Icon(current.hasJoined ? Icons.edit_rounded : Icons.add_rounded),
          label: Text(current.hasJoined ? 'Edit Offer' : 'Join Campaign'),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        CurrencyHelper.format(item.displayPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF059669),
                        ),
                      ),
                      if (item.originalPrice > item.displayPrice) ...[
                        const SizedBox(width: 8),
                        Text(
                          CurrencyHelper.format(item.originalPrice),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
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

  const TimedOfferFormScreen({Key? key, required this.campaign})
      : super(key: key);

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
  bool _recalcLock = false;

  bool get isEdit => widget.campaign.hasJoined;

  String get _currencySymbol {
    final info = CurrencyHelper.active();
    return info.code.toUpperCase() == 'INR' ? info.symbol : info.code;
  }

  double get _tax {
    if (!Get.isRegistered<SharedPreferencesManager>()) return 0;
    return Get.find<SharedPreferencesManager>().getDouble('tax') ?? 0;
  }

  @override
  void initState() {
    super.initState();
    final existing = _controller.partnerOffer;
    nameController.text = existing?.name.isNotEmpty == true
        ? existing!.name
        : widget.campaign.name;
    descriptionController.text = existing?.shortDescription ?? '';
    codeController.text = existing?.code ?? '';
    selectedType = existing?.type == 0 ? 1 : (existing?.type ?? 1);
    discountController.text =
        existing != null && existing.discount > 0 ? '${existing.discount}' : '';
    uptoController.text =
        existing != null && existing.upto > 0 ? '${existing.upto}' : '';
    startDateController.text = existing?.startDate ?? '';
    expireController.text = existing?.expire ?? '';
    startTimeController.text = existing?.startTime.isNotEmpty == true
        ? existing!.startTime
        : widget.campaign.dailyStartTime;
    endTimeController.text = existing?.endTime.isNotEmpty == true
        ? existing!.endTime
        : widget.campaign.dailyEndTime;
    maxUsageController.text = existing != null && existing.maxUsage > 0
        ? '${existing.maxUsage}'
        : '';
    applyAllServices = existing?.applyAllServices ?? false;
    if (existing != null && existing.serviceIds.isNotEmpty) {
      selectedServiceIds.addAll(existing.serviceIds);
    } else {
      selectedServiceIds.addAll(_controller.matchedServiceIds());
    }
    _prefillDiscountFromCampaign();
    originalPriceController.addListener(_recalculateSell);
    discountController.addListener(_recalculateSell);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _controller.fetchPartnerServices();
      if (!mounted) return;
      _syncOriginalFromServices();
      _recalculateSell();
    });
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
          isEdit ? 'Update Limited Offer' : 'Join Limited Offer',
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
              _buildDiscountTypeDropdown(),
              _buildPriceSection(),
              _buildTextField(
                controller: maxUsageController,
                label: 'Max Usage'.tr,
                hint: '0'.tr,
                icon: Icons.repeat,
                isNumeric: true,
              ),
              _buildDateField(
                controller: startDateController,
                label: 'Start Date'.tr,
                hint: 'Defaults to campaign date'.tr,
                icon: Icons.event_available,
              ),
              _buildDateField(
                controller: expireController,
                label: 'Expiry Date'.tr,
                hint: 'Defaults to campaign date'.tr,
                icon: Icons.calendar_today,
              ),
            ]),
            const SizedBox(height: 20),
            _buildFormCard([_buildServicePicker()]),
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
                isEdit ? 'Update Limited Offer' : 'Join Limited Offer',
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
            isEdit
                ? 'Optional. Send a new selection to re-sync services.'
                : 'Required. Choose ALL or select partner services.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('All services'.tr),
            value: applyAllServices,
            activeThumbColor: const Color(0xFF6C5CE7),
            onChanged: (value) {
              setState(() {
                applyAllServices = value;
                if (value) {
                  selectedServiceIds.clear();
                }
              });
              _syncOriginalFromServices();
              _recalculateSell();
            },
          ),
          if (!applyAllServices) ...[
            if (services.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('No active services found for this partner.'.tr,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            else
              ...services.map((service) {
                final selected = selectedServiceIds.contains(service.id);
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: selected,
                  title: Text(service.name),
                  subtitle: Text(
                      '${CurrencyHelper.format(service.price)} • ${service.duration} min'),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedServiceIds.add(service.id);
                      } else {
                        selectedServiceIds.remove(service.id);
                      }
                    });
                    _syncOriginalFromServices();
                    _recalculateSell();
                  },
                );
              }),
          ],
        ],
      );
    });
  }

  Widget _buildDiscountTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<int>(
        value: selectedType,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Discount Type'.tr,
          prefixIcon: const Icon(Icons.tune, color: Color(0xFF6C5CE7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: [
          DropdownMenuItem(value: 1, child: Text('Percentage (%)'.tr)),
          DropdownMenuItem(
              value: 2, child: Text('Flat Amount ($_currencySymbol)'.tr)),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => selectedType = value);
          _recalculateSell();
        },
      ),
    );
  }

  Widget _buildPriceSection() {
    final isPercent = selectedType == 1;
    final sell = double.tryParse(sellPriceController.text) ?? 0;
    final taxAmount = sell * (_tax / 100);
    final finalAmount = sell + taxAmount;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPercent
                ? 'Price Information (%)'.tr
                : 'Price Information ($_currencySymbol)'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            isPercent
                ? 'Enter original price and discount percent. Sell price is calculated automatically.'
                    .tr
                : 'Enter original price and flat discount amount. Sell price is calculated automatically.'
                    .tr,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: originalPriceController,
            label: 'Original Price'.tr,
            hint: '0'.tr,
            icon: Icons.payments_outlined,
            isNumeric: true,
            prefixText: '$_currencySymbol ',
          ),
          if (isPercent)
            _buildTextField(
              controller: discountController,
              label: 'Discount %'.tr,
              hint: '0'.tr,
              icon: Icons.percent,
              isNumeric: true,
            )
          else
            _buildTextField(
              controller: discountController,
              label: 'Discount Amount'.tr,
              hint: '0'.tr,
              icon: Icons.money_off_csred_outlined,
              isNumeric: true,
              prefixText: '$_currencySymbol ',
            ),
          _buildTextField(
            controller: sellPriceController,
            label: 'Sell Price'.tr,
            hint: '0.00'.tr,
            icon: Icons.sell_outlined,
            isNumeric: true,
            readOnly: true,
            prefixText: '$_currencySymbol ',
          ),
          if (sell > 0 && _tax > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Text(
                '${'Final amount (incl. tax ${_tax.toStringAsFixed(1)}%) -'.tr} $_currencySymbol${finalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: _fieldDecoration(label, hint, icon, hasDropdown: true),
        onTap: () async {
          DateTime? picked = await showDatePicker(
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
        },
      ),
    );
  }

  Widget _buildTimeField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: _fieldDecoration(label, hint, icon, hasDropdown: true),
        onTap: () async {
          final initial = _parseTime(controller.text) ?? TimeOfDay.now();
          final picked = await showTimePicker(
            context: context,
            initialTime: initial,
          );
          if (picked != null) {
            setState(() {
              controller.text =
                  '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
            });
          }
        },
      ),
    );
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

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  int _toInt(String value) => int.tryParse(value.trim()) ?? 0;

  Future<void> _submitForm() async {
    if (!applyAllServices && selectedServiceIds.isEmpty && !isEdit) {
      Get.snackbar(
        'Services required',
        'Select ALL or at least one partner service',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final offer = TimedPartnerOfferModel(
      campaignId: widget.campaign.id,
      name: nameController.text.trim(),
      shortDescription: descriptionController.text.trim(),
      code: codeController.text.trim(),
      type: selectedType,
      discount: _toInt(discountController.text),
      upto: _toInt(uptoController.text),
      startDate: startDateController.text.trim(),
      expire: expireController.text.trim(),
      startTime: startTimeController.text.trim(),
      endTime: endTimeController.text.trim(),
      maxUsage: _toInt(maxUsageController.text),
      minCartValue: 100,
      applyAllServices: applyAllServices,
      serviceIds: applyAllServices ? const [] : selectedServiceIds.toList(),
    );

    final includeServices = applyAllServices || selectedServiceIds.isNotEmpty;
    final success = isEdit
        ? await _controller.updatePartnerOffer(
            offer,
            includeServices: includeServices,
          )
        : await _controller.createPartnerOffer(offer);

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
            isEdit
                ? 'Limited offer updated successfully.'.tr
                : 'Limited offer saved successfully.'.tr,
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
    super.dispose();
  }
}
