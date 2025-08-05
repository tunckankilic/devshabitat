import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import 'package:highlight/languages/all.dart';
import 'package:highlight/languages/dart.dart';

class CodeEditor extends StatefulWidget {
  final String initialCode;
  final String language;
  final Function(String) onChanged;
  final bool readOnly;
  final bool showLineNumbers;
  final double fontSize;
  final String? selectedText;
  final Function(String)? onTextSelected;

  const CodeEditor({
    super.key,
    required this.initialCode,
    required this.language,
    required this.onChanged,
    this.readOnly = false,
    this.showLineNumbers = true,
    this.fontSize = 14.0,
    this.selectedText,
    this.onTextSelected,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late final controller = CodeController(
    text: widget.initialCode,
    language: allLanguages[widget.language] ?? dart,
  );

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      widget.onChanged(controller.text);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Toolbar
          if (!widget.readOnly)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  // Dil seçimi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.language.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  // Kopyalama butonu
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white),
                    onPressed: () {
                      // Kopyalama işlemi
                    },
                    tooltip: 'Kopyala',
                  ),
                ],
              ),
            ),

          // Kod editörü
          Expanded(
            child: CodeTheme(
              data: CodeThemeData(),
              child: SingleChildScrollView(
                child: CodeField(
                  controller: controller,
                  enabled: !widget.readOnly,
                  textStyle: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontSize: widget.fontSize,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
