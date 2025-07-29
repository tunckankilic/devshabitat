import 'package:flutter/material.dart';
import '../../core/theme/dev_habitat_colors.dart';

/// Message Input Widget - Mesaj gönderme için kullanılan widget
class MessageInput extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onCamera;
  final bool isLoading;
  final bool isTyping;
  final Function(bool)? onTypingChanged;

  const MessageInput({
    super.key,
    required this.controller,
    this.onSend,
    this.onAttachment,
    this.onCamera,
    this.isLoading = false,
    this.isTyping = false,
    this.onTypingChanged,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });

      // Notify typing status
      widget.onTypingChanged?.call(hasText);
    }
  }

  void _handleSend() {
    if (_hasText && !widget.isLoading) {
      widget.onSend?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: DevHabitatColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment button
            IconButton(
              onPressed: widget.onAttachment,
              icon: Icon(
                Icons.attach_file,
                color: DevHabitatColors.textGray,
              ),
            ),

            // Camera button
            IconButton(
              onPressed: widget.onCamera,
              icon: Icon(
                Icons.camera_alt,
                color: DevHabitatColors.textGray,
              ),
            ),

            // Text input field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Mesajınızı yazın...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 16.0,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Send button
            Container(
              decoration: BoxDecoration(
                color: _hasText && !widget.isLoading
                    ? DevHabitatColors.primary
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _handleSend,
                icon: widget.isLoading
                    ? SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _hasText ? Colors.white : Colors.grey[600]!,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: _hasText && !widget.isLoading
                            ? Colors.white
                            : Colors.grey[600],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
