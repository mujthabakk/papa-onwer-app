import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';
import 'package:ultimate_salon_owner_flutter/app/controller/inbox_controller.dart';
import 'package:ultimate_salon_owner_flutter/app/util/app_image.dart';
import 'package:ultimate_salon_owner_flutter/app/util/theme.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({Key? key}) : super(key: key);

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<InboxController>(
      builder: (value) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          appBar: AppBar(
            backgroundColor: ThemeProvider.whiteColor,
            elevation: 0,
            toolbarHeight: 70,
            iconTheme: IconThemeData(color: ThemeProvider.appColor),
            title: Text(
              'Messages'.tr,
              style: const TextStyle(
                color: Color(0xFF1A1F36),
                fontSize: 24,
                fontFamily: 'bold',
                letterSpacing: -0.5,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: const Color(0xFFE8ECF4),
                height: 1,
              ),
            ),
          ),
          floatingActionButton: value.showAdminChatFAB
              ? FloatingActionButton.extended(
                  onPressed: () {
                    value.createAdminChatRoom();
                  },
                  backgroundColor: ThemeProvider.appColor,
                  elevation: 4,
                  icon: const Icon(Icons.support_agent_rounded,
                      color: ThemeProvider.whiteColor, size: 22),
                  label: Text(
                    'Chat with Admin'.tr,
                    style: const TextStyle(
                      color: ThemeProvider.whiteColor,
                      fontFamily: 'semibold',
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                )
              : null,
          body: value.apiCalled == false
              ? _buildSkeletonLoader()
              : Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      color: ThemeProvider.whiteColor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FD),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE8ECF4),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: value.searchController,
                          onChanged: (query) => value.searchChat(query),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A1F36),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search conversations...'.tr,
                            hintStyle: TextStyle(
                              fontSize: 15,
                              color: const Color(0xFF6B7280).withOpacity(0.7),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Color(0xFF6B7280),
                              size: 22,
                            ),
                            suffixIcon: value.searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF6B7280),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      value.searchController.clear();
                                      value.searchChat('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Chat List
                    Expanded(
                      child: value.chatList.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: value.chatList.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final chat = value.chatList[index];
                                final isSender =
                                    chat.senderId.toString() == value.uid;

                                return _buildChatItem(
                                  context: context,
                                  value: value,
                                  chat: chat,
                                  isSender: isSender,
                                  index: index,
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      color: const Color(0xFFF8F9FD),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.separated(
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeProvider.whiteColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  shape: BoxShape.circle,
                  width: 56,
                  height: 56,
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
                        width: 140,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 14,
                        width: 200,
                        borderRadius: BorderRadius.circular(8),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: ThemeProvider.appColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 56,
                color: ThemeProvider.appColor.withOpacity(0.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Messages Yet'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'bold',
              color: Color(0xFF1A1F36),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations will appear here'.tr,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFF6B7280).withOpacity(0.8),
              fontFamily: 'regular',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required InboxController value,
    required dynamic chat,
    required bool isSender,
    required int index,
  }) {
    final name = isSender
        ? '${chat.receiverName} ${chat.receiverLastName}'
        : '${chat.senderFirstName} ${chat.senderLastName}';
    final cover = isSender ? chat.receiverCover : chat.senderCover;
    final userId =
        isSender ? chat.receiverId.toString() : chat.senderId.toString();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => value.onChat(userId, name),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: ThemeProvider.whiteColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1F36).withOpacity(0.04),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with status indicator
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            ThemeProvider.appColor.withOpacity(0.1),
                            ThemeProvider.appColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: AppNetImage(
                          path: cover,
                          fit: BoxFit.cover,
                          placeholder: Container(
                            color: ThemeProvider.appColor.withOpacity(0.1),
                            child: Icon(
                              Icons.person_rounded,
                              color: ThemeProvider.appColor.withOpacity(0.5),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Online status indicator (optional - can be removed if not tracking status)
                    // Positioned(
                    //   right: 2,
                    //   bottom: 2,
                    //   child: Container(
                    //     width: 14,
                    //     height: 14,
                    //     decoration: BoxDecoration(
                    //       color: const Color(0xFF10B981),
                    //       shape: BoxShape.circle,
                    //       border: Border.all(
                    //         color: ThemeProvider.whiteColor,
                    //         width: 2.5,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(width: 16),
                // Name and message preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: 'semibold',
                                color: Color(0xFF1A1F36),
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDateTime(chat.last_message_time),
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF6B7280).withOpacity(0.9),
                              fontFamily: 'regular',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Tap to view conversation'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF6B7280).withOpacity(0.8),
                                fontFamily: 'regular',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: const Color(0xFF6B7280).withOpacity(0.4),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatDateTime(dynamic rawTime) {
  try {
    // Adjust parsing depending on the format of your `last_message_time`
    final dateTime = DateTime.parse(rawTime.toString());
    final formatted = DateFormat('dd MMM yyyy').format(dateTime);
    return formatted;
  } catch (e) {
    return ''; // or fallback to rawTime.toString();
  }
}
