import 'package:flutter/material.dart';
import 'package:devshabitat/app/models/message_model.dart';
import 'package:devshabitat/app/widgets/message_bubble.dart';

class VirtualMessageList extends StatefulWidget {
  final List<Message> messages;
  final ScrollController? controller;
  final bool reverse;
  final EdgeInsets padding;
  final String? highlightText;

  const VirtualMessageList({
    super.key,
    required this.messages,
    this.controller,
    this.reverse = true,
    this.padding = const EdgeInsets.all(16),
    this.highlightText,
  });

  @override
  State<VirtualMessageList> createState() => _VirtualMessageListState();
}

class _VirtualMessageListState extends State<VirtualMessageList> {
  final _itemPositions = <int, double>{};
  final _itemSizes = <int, double>{};
  late final ScrollController _scrollController;

  // Görünür öğelerin indeks aralığı
  int _firstIndex = 0;
  int _lastIndex = 0;

  // Tampon bölge boyutu (ekran yüksekliğinin katı)
  static const double _bufferScreens = 1.5;

  // Varsayılan öğe yüksekliği
  static const double _estimatedItemHeight = 80.0;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);

    // İlk görünür aralığı hesapla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleRange();
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleRange();
  }

  void _updateVisibleRange() {
    if (!_scrollController.hasClients) return;

    final viewportHeight = _scrollController.position.viewportDimension;
    final scrollOffset = _scrollController.offset;

    // Tampon bölge ile birlikte görünür aralığı hesapla
    final bufferHeight = viewportHeight * _bufferScreens;
    final minOffset = (scrollOffset - bufferHeight).clamp(0.0, double.infinity);
    final maxOffset = scrollOffset + viewportHeight + bufferHeight;

    // Görünür indeksleri hesapla
    double currentOffset = 0;
    int firstIndex = 0;
    int lastIndex = 0;

    for (int i = 0; i < widget.messages.length; i++) {
      final itemHeight = _itemSizes[i] ?? _estimatedItemHeight;

      if (currentOffset < minOffset) {
        firstIndex = i;
      }

      if (currentOffset + itemHeight > maxOffset) {
        lastIndex = i;
        break;
      }

      currentOffset += itemHeight;
    }

    if (firstIndex != _firstIndex || lastIndex != _lastIndex) {
      setState(() {
        _firstIndex = firstIndex;
        _lastIndex = lastIndex;
      });
    }
  }

  void _onItemSizeChanged(int index, Size size) {
    _itemSizes[index] = size.height;
    _itemPositions[index] = _calculateItemOffset(index);
    _updateVisibleRange();
  }

  double _calculateItemOffset(int index) {
    double offset = 0;
    for (int i = 0; i < index; i++) {
      offset += _itemSizes[i] ?? _estimatedItemHeight;
    }
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = widget.messages.fold<double>(
          0,
          (sum, _) => sum + _estimatedItemHeight,
        );

        return SizedBox(
          height: constraints.maxHeight,
          child: ListView.builder(
            controller: _scrollController,
            reverse: widget.reverse,
            padding: widget.padding,
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              // Görünür aralık dışındaki öğeleri atla
              if (index < _firstIndex || index > _lastIndex) {
                return const SizedBox.shrink();
              }

              return _MessageItem(
                key: ValueKey(widget.messages[index].id),
                message: widget.messages[index],
                highlightText: widget.highlightText,
                onSizeChanged: (size) => _onItemSizeChanged(index, size),
              );
            },
          ),
        );
      },
    );
  }
}

class _MessageItem extends StatefulWidget {
  final Message message;
  final String? highlightText;
  final ValueChanged<Size> onSizeChanged;

  const _MessageItem({
    super.key,
    required this.message,
    required this.onSizeChanged,
    this.highlightText,
  });

  @override
  State<_MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<_MessageItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifySize();
    });
  }

  void _notifySize() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      widget.onSizeChanged(renderBox.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MessageBubble(
          message: widget.message,
          highlightText: widget.highlightText,
        );
      },
    );
  }
}
