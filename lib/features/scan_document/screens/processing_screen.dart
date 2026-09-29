import 'package:flutter/material.dart';
class ProcessingScreen extends StatefulWidget {
  final List<String> imagePaths;
  final Future<List<String>> Function(List<String> paths) onProcess;
  const ProcessingScreen({
    super.key,
    required this.imagePaths,
    required this.onProcess,
  });
  @override
  State<ProcessingScreen> createState() => ProcessingScreenState();
}
class ProcessingScreenState extends State<ProcessingScreen> {
  double progress = 0.0;
  bool finished = false;
  @override
  void initState() {
    super.initState();
    runOcr();
  }
  Future<void> runOcr() async {
    animateProgress();
    try {
      final texts = await widget.onProcess(widget.imagePaths);

      if (mounted) {
        setState(() {
          progress = 1.0;
          finished = true;
        });
      }
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pop(context, texts);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing failed: $e')),
      );
      Navigator.pop(context, null);
    }
  }
  void animateProgress() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted || finished) return false;
      setState(() {
        if (progress < 0.9) {
          progress += 0.002;
        } else if (progress < 0.98) {
          progress += 0.001;
        }
      });
      return progress < 0.98 && !finished;
    });
  }
  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).clamp(0, 100).toInt();
    return Scaffold(
      backgroundColor: const Color(0xFF4038D8),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Processing Image...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Extracting text using OCR',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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