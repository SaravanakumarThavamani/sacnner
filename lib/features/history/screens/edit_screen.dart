import 'package:flutter/material.dart';
import 'package:quick_scanner/utils/common_color.dart';

class EditRecordScreen extends StatefulWidget {
  final String extractedText;

  const EditRecordScreen({super.key, required this.extractedText});

  @override
  State<EditRecordScreen> createState() => EditRecordScreenState();
}

class EditRecordScreenState extends State<EditRecordScreen> {
  late final TextEditingController textController;

  static const primary = Color(0xFF4038D8);
  static const background = Color(0xFFF5F7FB);

  @override
  void initState() {
    super.initState();

    textController = TextEditingController(text: widget.extractedText);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void saveText() {
    final text = textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Text cannot be empty')));
      return;
    }

    Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: ColorConstants.primary,
        foregroundColor: ColorConstants.white,
        elevation: 0,
        title: const Text(
          'Edit Invoice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.12)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_note, color: primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Review and edit the extracted invoice text.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF444444)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF222222),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter invoice text...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2EA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2EA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primary, width: 1.2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: saveText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
