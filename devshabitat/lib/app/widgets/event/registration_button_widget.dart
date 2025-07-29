import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/event/event_model.dart';

class RegistrationButtonWidget extends StatelessWidget {
  final EventModel event;
  final bool isRegistered;
  final bool isLoading;
  final VoidCallback onRegister;
  final VoidCallback onUnregister;

  const RegistrationButtonWidget({
    super.key,
    required this.event,
    required this.isRegistered,
    required this.isLoading,
    required this.onRegister,
    required this.onUnregister,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFull = event.participants.length >= event.participantLimit;
    final bool isPast = event.endDate.isBefore(DateTime.now());

    if (isPast) {
      return _buildDisabledButton(AppStrings.eventEnded);
    }

    if (isFull && !isRegistered) {
      return _buildDisabledButton(AppStrings.quotaFull);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildParticipantInfo(),
          const SizedBox(height: 16),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.people_outline, size: 20),
        const SizedBox(width: 8),
        Text(
          '${event.participants.length}/${event.participantLimit} ${AppStrings.participants}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (isLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isRegistered ? onUnregister : onRegister,
      style: ElevatedButton.styleFrom(
        backgroundColor: isRegistered ? Colors.red : Get.theme.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isRegistered
              ? Icons.cancel_outlined
              : Icons.check_circle_outline),
          const SizedBox(width: 8),
          Text(
            isRegistered ? AppStrings.cancelRegistration : AppStrings.register,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledButton(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
