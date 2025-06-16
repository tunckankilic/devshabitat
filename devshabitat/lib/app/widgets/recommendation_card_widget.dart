import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/enhanced_user_model.dart';
import '../algorithms/connection_scoring_algorithm.dart';

class RecommendationCard extends StatelessWidget {
  final EnhancedUserModel user;
  final EnhancedUserModel currentUser;
  final VoidCallback? onConnect;
  final VoidCallback? onTap;
  final RxBool isLoading = false.obs;

  RecommendationCard({
    super.key,
    required this.user,
    required this.currentUser,
    this.onConnect,
    this.onTap,
  });

  double get _matchPercentage {
    return ConnectionScoringAlgorithm.calculateConnectionScore(
          currentUser,
          user,
        ) *
        100;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'İsimsiz Kullanıcı',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.experience?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 2),
                          Text(
                            user.experience!.first['role'] ?? '',
                            style: textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.experience!.first['company'] ?? '',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMatchIndicator(colorScheme),
              if (user.skills?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _buildSkillChips(colorScheme),
                ),
              ],
              const Spacer(),
              _buildConnectButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Hero(
      tag: 'avatar_${user.id}',
      child: CircleAvatar(
        radius: 32,
        backgroundImage:
            user.photoURL != null ? NetworkImage(user.photoURL!) : null,
        backgroundColor: user.photoURL == null
            ? Get.theme.colorScheme.primaryContainer
            : null,
        child: user.photoURL == null
            ? Text(
                user.displayName?[0].toUpperCase() ?? 'A',
                style: TextStyle(
                  fontSize: 24,
                  color: Get.theme.colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildMatchIndicator(ColorScheme colorScheme) {
    final percentage = _matchPercentage.round();
    final color = _getMatchColor(percentage, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '%$percentage Eşleşme',
            style: Get.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSkillChips(ColorScheme colorScheme) {
    final commonSkills = user.skills
            ?.where((skill) => currentUser.skills?.contains(skill) ?? false)
            .take(3)
            .toList() ??
        [];

    return commonSkills.map((skill) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          skill,
          style: Get.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildConnectButton(ColorScheme colorScheme) {
    return Obx(
      () => FilledButton.icon(
        onPressed: isLoading.value ? null : () => _handleConnect(),
        icon: isLoading.value
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.person_add),
        label: Text(isLoading.value ? 'Bağlanıyor...' : 'Bağlan'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 40),
        ),
      ),
    );
  }

  Color _getMatchColor(int percentage, ColorScheme colorScheme) {
    if (percentage >= 80) {
      return colorScheme.primary;
    } else if (percentage >= 60) {
      return colorScheme.tertiary;
    } else if (percentage >= 40) {
      return colorScheme.secondary;
    } else {
      return colorScheme.outline;
    }
  }

  Future<void> _handleConnect() async {
    if (onConnect != null) {
      isLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 300));
      onConnect!();
      isLoading.value = false;
    }
  }
}
