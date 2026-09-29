// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import '../services/scan_history_service.dart';
// import 'edit_screen.dart';

// class LensTextScreen extends StatefulWidget {
//   final File imageFile;
//   final String extractedText;

//   const LensTextScreen({
//     super.key,
//     required this.imageFile,
//     required this.extractedText,
//   });

//   @override
//   State<LensTextScreen> createState() => LensTextScreenState();
// }

// class LensTextScreenState extends State<LensTextScreen> {
//   String? editedText;

//   bool isSaved = false;
//   bool isSaving = false;

//   String get displayText {
//     return editedText ?? widget.extractedText;
//   }

//   Future<void> copyAllText() async {
//     await Clipboard.setData(
//       ClipboardData(
//         text: displayText,
//       ),
//     );

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('All text copied successfully'),
//       ),
//     );
//   }

//   Future<void> editText() async {
//     final result = await Navigator.push<String>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => EditRecordScreen(
//           extractedText: displayText,
//         ),
//       ),
//     );
//     if (result != null && result.trim().isNotEmpty) {
//       setState(() {
//         editedText = result.trim();
//       });
//     }
//   }

//   Future<void> saveToHistory() async {
//     if (displayText.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No text available to save'),
//         ),
//       );
//       return;
//     }

//     if (isSaved || isSaving) return;

//     setState(() {
//       isSaving = true;
//     });

//     try {
//       await ScanHistoryService.addRecord(
//         text: displayText.trim(),
//         imageFile: widget.imageFile,
//       );

//       if (!mounted) return;

//       setState(() {
//         isSaved = true;
//         isSaving = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Saved to Scan History successfully'),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         isSaving = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to save history: $e'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Extracted Text'),
//         centerTitle: true,
//       ),

//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.file(
//                   widget.imageFile,
//                   width: double.infinity,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               margin: const EdgeInsets.symmetric(
//                 horizontal: 16,
//               ),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: SingleChildScrollView(
//                 child: Text(
//                   displayText.isEmpty
//                       ? 'No text found'
//                       : displayText,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     height: 1.5,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton.icon(
//                     onPressed: isSaved || isSaving
//                         ? null
//                         : saveToHistory,

//                     icon: isSaving
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Icon(
//                             isSaved
//                                 ? Icons.check
//                                 : Icons.save,
//                           ),

//                     label: Text(
//                       isSaving
//                           ? 'Saving...'
//                           : isSaved
//                               ? 'Saved to History'
//                               : 'Save to History',
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton.icon(
//                     onPressed: editText,
//                     icon: const Icon(Icons.edit),
//                     label: const Text('Edit Text'),
//                   ),
//                 ),

//                 const SizedBox(height: 10),
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: OutlinedButton.icon(
//                     onPressed: copyAllText,
//                     icon: const Icon(Icons.copy),
//                     label: const Text('Copy All Text'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
