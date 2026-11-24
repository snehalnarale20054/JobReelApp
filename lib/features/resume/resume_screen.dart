import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../models/candidate_profile_model.dart';
import 'widgets/resume_pdf_builder.dart';

class ResumeScreen extends ConsumerWidget {
  final CandidateProfileModel profile;

  const ResumeScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Resume'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Resume PDF',
            onPressed: () async {
              final pdfBytes = await ResumePdfBuilder.buildPdf(profile);
              await Printing.sharePdf(
                bytes: pdfBytes,
                filename: '${profile.fullName.replaceAll(' ', '_')}_Resume.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => ResumePdfBuilder.buildPdf(profile),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: '${profile.fullName.replaceAll(' ', '_')}_Resume.pdf',
      ),
    );
  }
}
