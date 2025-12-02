import 'package:flutter/material.dart';
import 'package:greenmalaysia/l10n/app_localizations.dart';
import 'analysis_helper.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analyzer = AnalysisHelper();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.aiAnalysis), // Refactored
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: Container(color: Colors.grey[800])),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Logic
              },
              icon: const Icon(Icons.camera),
              label: Text(l10n.captureAnalyze), // Refactored
            ),
          ),
        ],
      ),
    );
  }
}
