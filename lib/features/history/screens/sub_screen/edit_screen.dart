import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quick_scanner/features/history/model/history_model.dart';

const primary = Color(0xFF4038D8);
const background = Color(0xFFF5F7FB);

double _sw(double px) => Get.width * (px / 375);

class EditRawTextScreen extends StatefulWidget {
  final InvoiceData invoice;
  final String initialText;
  final Future<void> Function(String text) onSave;

  const EditRawTextScreen({
    super.key,
    required this.invoice,
    required this.initialText,
    required this.onSave,
  });

  @override
  State<EditRawTextScreen> createState() => _EditRawTextScreenState();
}

class _EditRawTextScreenState extends State<EditRawTextScreen> {
  late final _ctrl = TextEditingController(text: widget.initialText);
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await widget.onSave(_ctrl.text);
      if (mounted) Get.back();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        Get.snackbar('Error', 'Could not save changes');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('Edit Raw Data '),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(_sw(16)),
          child: TextField(
            controller: _ctrl,
            expands: true,
            minLines: null,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Raw text',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_sw(12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(_sw(12)),
                borderSide: const BorderSide(color: primary, width: 1.6),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(_sw(16), _sw(12), _sw(16), _sw(16)),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cancel
              Expanded(
                child: SizedBox(
                  height: _sw(50),
                  child: OutlinedButton(
                    onPressed: _saving ? null : Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_sw(14)),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: _sw(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: _sw(12)),

              // Save
              Expanded(
                child: SizedBox(
                  height: _sw(50),
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primary.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_sw(14)),
                      ),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child:
                          _saving
                              ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                              : Row(
                                key: const ValueKey('save'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_rounded, size: 19),
                                  SizedBox(width: _sw(7)),
                                  Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: _sw(14),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
