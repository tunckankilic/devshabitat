import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/controllers/event/event_detail_controller.dart';
import 'package:devshabitat/app/models/event/event_model.dart';
import '../base/base_view.dart';
import '../../widgets/responsive/responsive_safe_area.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../../widgets/responsive/responsive_overflow_handler.dart'
    hide ResponsiveText, ResponsiveSafeArea;
import '../../widgets/responsive/animated_responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsView extends BaseView<EventDetailController> {
  const EventDetailsView({super.key});

  @override
  Widget buildView(BuildContext context) {
    // Get event ID from arguments
    final eventId = Get.arguments as String?;

    if (eventId != null) {
      controller.loadEventDetails(eventId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => ResponsiveText(
              controller.event.value?.title ?? 'Etkinlik Detayları',
              style: TextStyle(
                fontSize: responsive.responsiveValue(
                  mobile: 18,
                  tablet: 22,
                ),
              ),
            )),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  controller.shareEvent();
                  break;
                case 'report':
                  controller.reportEvent();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Paylaş'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report),
                    SizedBox(width: 8),
                    Text('Raporla'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final event = controller.event.value;
        if (event == null) {
          return const Center(child: Text('Etkinlik bulunamadı'));
        }

        return ResponsiveSafeArea(
          child: ResponsiveOverflowHandler(
            child: AnimatedResponsiveLayout(
              mobile: _buildMobileEventDetails(event, context),
              tablet: _buildTabletEventDetails(event, context),
              animationDuration: const Duration(milliseconds: 300),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMobileEventDetails(EventModel event, BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventHeader(event),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          _buildEventStatus(event),
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          _buildEventDescription(event),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildEventInfo(event),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildRSVPSection(),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildActionButtons(),
          SizedBox(height: responsive.responsiveValue(mobile: 24, tablet: 32)),
          _buildCommentsSection(),
        ],
      ),
    );
  }

  Widget _buildTabletEventDetails(EventModel event, BuildContext context) {
    return SingleChildScrollView(
      padding: responsive.responsivePadding(all: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(event),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 24)),
                _buildEventStatus(event),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 16, tablet: 24)),
                _buildEventDescription(event),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 24, tablet: 32)),
                _buildRSVPSection(),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 24, tablet: 32)),
                _buildCommentsSection(),
              ],
            ),
          ),
          SizedBox(width: responsive.responsiveValue(mobile: 32, tablet: 48)),
          Expanded(
            child: Column(
              children: [
                _buildEventInfo(event),
                SizedBox(
                    height: responsive.responsiveValue(mobile: 24, tablet: 32)),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventHeader(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          event.title,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 24, tablet: 28),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Row(
          children: [
            Icon(
              _getEventTypeIcon(event.type),
              size: responsive.responsiveValue(mobile: 16, tablet: 20),
              color: Colors.grey[600],
            ),
            SizedBox(width: responsive.responsiveValue(mobile: 4, tablet: 8)),
            ResponsiveText(
              _getEventTypeText(event.type),
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventStatus(EventModel event) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (event.hasEnded) {
      statusColor = Colors.red;
      statusText = 'Sona Erdi';
      statusIcon = Icons.event_busy;
    } else if (event.isOngoing) {
      statusColor = Colors.green;
      statusText = 'Devam Ediyor';
      statusIcon = Icons.event_available;
    } else if (event.isStarting) {
      statusColor = Colors.orange;
      statusText = 'Başlamak Üzere';
      statusIcon = Icons.schedule;
    } else {
      statusColor = Colors.blue;
      statusText = 'Yaklaşıyor';
      statusIcon = Icons.event;
    }

    return Container(
      padding: responsive.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          SizedBox(width: 8),
          ResponsiveText(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDescription(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Açıklama',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
        ResponsiveText(
          event.description,
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Etkinlik Bilgileri',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        _buildInfoSection(
          AppStrings.dateAndTime,
          '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
          Icons.calendar_today,
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        _buildInfoSection(
          AppStrings.location,
          event.type == EventType.online
              ? AppStrings.online
              : event.venueAddress ?? AppStrings.noLocation,
          event.type == EventType.online ? Icons.computer : Icons.location_on,
        ),
        if (event.type == EventType.online &&
            event.onlineMeetingUrl != null) ...[
          SizedBox(height: responsive.responsiveValue(mobile: 8, tablet: 12)),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(event.onlineMeetingUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                Get.snackbar('Hata', 'URL açılamadı');
              }
            },
            child: ResponsiveText(
              '${AppStrings.onlineMeetingUrl}: ${event.onlineMeetingUrl}',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        _buildInfoSection(
          AppStrings.participantCount,
          '${event.participants.length}/${event.participantLimit}',
          Icons.person,
        ),
        if (event.categories.isNotEmpty) ...[
          SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
          _buildCategoriesSection(event),
        ],
      ],
    );
  }

  Widget _buildCategoriesSection(EventModel event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Kategoriler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: event.categories.map((category) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: ResponsiveText(
                category,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
                  color: Colors.blue,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRSVPSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Katılım Durumu',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        Obx(() => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRSVPButton(
                        RSVPStatus.going,
                        'Katılıyorum',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildRSVPButton(
                        RSVPStatus.maybe,
                        'Belki',
                        Icons.help,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildRSVPButton(
                        RSVPStatus.notGoing,
                        'Katılmıyorum',
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildRSVPCounts(),
              ],
            )),
      ],
    );
  }

  Widget _buildRSVPButton(
      RSVPStatus status, String text, IconData icon, Color color) {
    return Obx(() {
      final isSelected = controller.rsvpStatus.value == status;
      return GestureDetector(
        onTap: () => controller.updateRSVPStatus(status),
        child: Container(
          padding: responsive.responsivePadding(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? color : color.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: responsive.responsiveValue(mobile: 20, tablet: 24),
              ),
              SizedBox(height: 4),
              ResponsiveText(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: responsive.responsiveValue(mobile: 12, tablet: 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRSVPCounts() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: RSVPStatus.values.map((status) {
            final count = controller.rsvpCounts[status] ?? 0;
            return Column(
              children: [
                ResponsiveText(
                  count.toString(),
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 18, tablet: 20),
                    fontWeight: FontWeight.bold,
                    color: controller.getRSVPStatusColor(status),
                  ),
                ),
                ResponsiveText(
                  controller.getRSVPStatusText(status),
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 12, tablet: 14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            );
          }).toList(),
        ));
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Eylemler',
          style: TextStyle(
            fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        Obx(() {
          final event = controller.event.value;
          if (event == null) return const SizedBox.shrink();

          final currentUserId = Get.find<FirebaseAuth>().currentUser?.uid;
          final isParticipant = event.isParticipant(currentUserId ?? '');

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isParticipant
                          ? () => controller.leaveEvent()
                          : () => controller.joinEvent(),
                      icon: Icon(isParticipant ? Icons.exit_to_app : Icons.add),
                      label: Text(isParticipant ? 'Ayrıl' : 'Katıl'),
                      style: ElevatedButton.styleFrom(
                        padding: responsive.responsivePadding(vertical: 12),
                        backgroundColor: isParticipant ? Colors.red : null,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.toggleReminder(),
                      icon: Icon(
                        controller.isReminderSet.value
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                      ),
                      label: Text(
                        controller.isReminderSet.value
                            ? 'Hatırlatıcı Açık'
                            : 'Hatırlatıcı',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: responsive.responsivePadding(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              if (event.hasEnded) ...[
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showFeedbackDialog(),
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Geri Bildirim Ver'),
                    style: OutlinedButton.styleFrom(
                      padding: responsive.responsivePadding(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ],
    );
  }

  void _showFeedbackDialog() {
    final rating = 0.obs;
    final feedbackController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Etkinlik Geri Bildirimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bu etkinliği nasıl değerlendirirsiniz?'),
            const SizedBox(height: 16),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => rating.value = index + 1,
                      child: Icon(
                        index < rating.value ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                    );
                  }),
                )),
            const SizedBox(height: 16),
            TextField(
              controller: feedbackController,
              decoration: const InputDecoration(
                hintText: 'Yorumunuzu yazın (isteğe bağlı)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (rating.value > 0) {
                controller.submitEventFeedback(
                    rating.value, feedbackController.text);
                Get.back();
              }
            },
            child: const Text('Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ResponsiveText(
              'Yorumlar',
              style: TextStyle(
                fontSize: responsive.responsiveValue(mobile: 18, tablet: 20),
                fontWeight: FontWeight.w600,
              ),
            ),
            Obx(() => ResponsiveText(
                  '${controller.comments.length} yorum',
                  style: TextStyle(
                    fontSize:
                        responsive.responsiveValue(mobile: 14, tablet: 16),
                    color: Colors.grey[600],
                  ),
                )),
          ],
        ),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        _buildCommentInput(),
        SizedBox(height: responsive.responsiveValue(mobile: 16, tablet: 24)),
        Obx(() {
          if (controller.isLoadingComments.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.comments.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 48, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  ResponsiveText(
                    'Henüz yorum yok',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize:
                          responsive.responsiveValue(mobile: 14, tablet: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.comments.length,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final comment = controller.comments[index];
              return _buildCommentItem(comment);
            },
          );
        }),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: responsive.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.commentController,
              decoration: const InputDecoration(
                hintText: 'Yorumunuzu yazın...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
          SizedBox(width: 8),
          Obx(() => IconButton(
                onPressed: controller.isCommenting.value
                    ? null
                    : controller.addComment,
                icon: controller.isCommenting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              )),
        ],
      ),
    );
  }

  Widget _buildCommentItem(EventComment comment) {
    final currentUserId = Get.find<FirebaseAuth>().currentUser?.uid;
    final isOwner = comment.userId == currentUserId;
    final isLiked = comment.likes.contains(currentUserId);

    return Container(
      padding: responsive.responsivePadding(all: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText(
                comment.userName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                ),
              ),
              Row(
                children: [
                  ResponsiveText(
                    _formatCommentDate(comment.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize:
                          responsive.responsiveValue(mobile: 12, tablet: 14),
                    ),
                  ),
                  if (isOwner) ...[
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.deleteComment(comment.id),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Colors.red[400],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          ResponsiveText(
            comment.comment,
            style: TextStyle(
              fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: () => controller.likeComment(comment.id),
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isLiked ? Colors.red : Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    ResponsiveText(
                      comment.likes.length.toString(),
                      style: TextStyle(
                        fontSize:
                            responsive.responsiveValue(mobile: 12, tablet: 14),
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: responsive.responsiveValue(mobile: 24, tablet: 28),
          color: Colors.grey[600],
        ),
        SizedBox(width: responsive.responsiveValue(mobile: 8, tablet: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                title,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 14, tablet: 16),
                  color: Colors.grey,
                ),
              ),
              ResponsiveText(
                content,
                style: TextStyle(
                  fontSize: responsive.responsiveValue(mobile: 16, tablet: 18),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getEventTypeIcon(EventType type) {
    switch (type) {
      case EventType.inPerson:
        return Icons.location_on;
      case EventType.online:
        return Icons.computer;
    }
  }

  String _getEventTypeText(EventType type) {
    switch (type) {
      case EventType.inPerson:
        return AppStrings.inPerson;
      case EventType.online:
        return AppStrings.online;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce';
    }
  }
}
