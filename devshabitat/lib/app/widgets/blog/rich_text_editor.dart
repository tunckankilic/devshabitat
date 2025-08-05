import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class RichTextEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onChanged;
  final bool readOnly;

  const RichTextEditor({
    super.key,
    this.initialText = '',
    required this.onChanged,
    this.readOnly = false,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late HtmlEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HtmlEditorController();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlEditor(
      controller: _controller,
      htmlEditorOptions: HtmlEditorOptions(
        hint: 'Blog içeriğinizi yazın...',
        initialText: widget.initialText,
        shouldEnsureVisible: true,
        disabled: widget.readOnly,
      ),
      htmlToolbarOptions: widget.readOnly
          ? const HtmlToolbarOptions(toolbarPosition: ToolbarPosition.custom)
          : HtmlToolbarOptions(
              toolbarPosition: ToolbarPosition.aboveEditor,
              defaultToolbarButtons: [
                StyleButtons(),
                FontSettingButtons(fontSizeUnit: false),
                FontButtons(clearAll: false),
                ColorButtons(),
                ListButtons(),
                ParagraphButtons(
                  textDirection: false,
                  lineHeight: false,
                  caseConverter: false,
                ),
                InsertButtons(
                  audio: false,
                  video: false,
                  table: false,
                  hr: false,
                ),
              ],
            ),
      callbacks: Callbacks(
        onChangeContent: (String? changed) {
          if (changed != null) {
            widget.onChanged(changed);
          }
        },
      ),
    );
  }
}
