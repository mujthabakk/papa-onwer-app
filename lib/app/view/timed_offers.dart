import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ultimate_salon_owner_flutter/app/backend/models/timed_offer_model.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/timed_offers_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';
import 'package:ultimate_salon_owner_flutter/app/view/timed_offer_detail.dart';

class TimedOffersScreen extends StatelessWidget {
  const TimedOffersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimedOffersController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 60,
              floating: true,
              pinned: true,
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('       Limited Offers'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 400,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Obx(() {
                      if (controller.campaigns.isEmpty) {
                        return _buildEmptyState();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildStatsCard(controller),
                            const SizedBox(height: 20),
                            ...controller.campaigns.map(
                              (campaign) =>
                                  _buildCampaignCard(campaign, controller),
                            ),
                          ],
                        ),
                      );
                    }),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatsCard(TimedOffersController controller) {
    final liveCount = controller.campaigns.where((c) => c.isLive).length;
    final joinedCount = controller.campaigns.where((c) => c.hasJoined).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 53, 53, 53),
            Color.fromARGB(255, 75, 75, 75)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 59, 59, 59).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Live Campaigns'.tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$liveCount'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.flash_on_rounded,
                  color: ThemeProvider.golden,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text('$joinedCount joined'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(
      TimedCampaignModel campaign, TimedOffersController controller) {
    final status = _campaignStatus(campaign);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () async {
            await controller.openCampaign(campaign);
            Get.to(() => TimedOfferDetailScreen(campaign: campaign));
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      status.color.withOpacity(0.08),
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ThemeProvider.golden.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFB45309),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campaign.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.4,
                                ),
                              ),
                              if (campaign.displayDiscount.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  campaign.displayDiscount,
                                  style: const TextStyle(
                                    color: Color(0xFFB45309),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        _statusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (campaign.statusText.isNotEmpty)
                      Text(
                        campaign.statusText,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _metricChip(
                            icon: Icons.schedule_rounded,
                            label: _timeLabel(campaign),
                            color: const Color(0xFF3B82F6),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _metricChip(
                            icon: Icons.room_service_outlined,
                            label:
                                '${campaign.myItemsCount} service${campaign.myItemsCount == 1 ? '' : 's'}',
                            color: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await controller.openCampaign(campaign);
                          Get.to(
                              () => TimedOfferDetailScreen(campaign: campaign));
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: Text('View Services'.tr),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(255, 54, 54, 54),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 55, 55, 55),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await controller.openCampaign(campaign);
                          Get.to(() => TimedOfferFormScreen(campaign: campaign));
                        },
                        icon: Icon(
                          campaign.hasJoined
                              ? Icons.edit_rounded
                              : Icons.add_rounded,
                          size: 18,
                        ),
                        label: Text(campaign.hasJoined ? 'Edit Offer' : 'Join'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.golden,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
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
      ),
    );
  }

  Widget _metricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_CampaignStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 14),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flash_on_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text('No Limited Offers'.tr,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text('Timed campaigns from admin will appear here. Join one to add your services.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(TimedCampaignModel campaign) {
    if (campaign.dailyStartTime.isEmpty && campaign.dailyEndTime.isEmpty) {
      return campaign.scheduleType.isEmpty ? 'Timed' : campaign.scheduleType;
    }
    return '${campaign.dailyStartTime} - ${campaign.dailyEndTime}';
  }

  _CampaignStatus _campaignStatus(TimedCampaignModel campaign) {
    if (campaign.isLive) {
      return _CampaignStatus(
        label: 'Live'.tr,
        color: const Color(0xFF10B981),
        icon: Icons.check_circle_rounded,
      );
    }
    if (campaign.hasEnded) {
      return _CampaignStatus(
        label: 'Ended'.tr,
        color: const Color(0xFFDC2626),
        icon: Icons.block_rounded,
      );
    }
    return _CampaignStatus(
      label: 'Scheduled'.tr,
      color: const Color(0xFFF59E0B),
      icon: Icons.schedule_rounded,
    );
  }
}

class _CampaignStatus {
  final String label;
  final Color color;
  final IconData icon;

  const _CampaignStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}
