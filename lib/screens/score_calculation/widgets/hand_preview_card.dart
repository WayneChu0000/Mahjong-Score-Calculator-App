import 'dart:io';
import 'package:flutter/material.dart';
import '../../../localization/app_localizations.dart';

/// Card widget for hand preview (tile display, flower selection, camera/manual buttons).
class HandPreviewCard extends StatelessWidget {
  final bool isAnalyzing;
  final File? capturedImage;
  final List<String> selectedTiles;
  final Map<String, bool> selectedFlowers;
  final VoidCallback onSelectHand;
  final VoidCallback onCaptureImage;
  final void Function(String key) onFlowerToggled;
  final String Function(String tile) getAssetPath;

  const HandPreviewCard({
    super.key,
    required this.isAnalyzing,
    required this.capturedImage,
    required this.selectedTiles,
    required this.selectedFlowers,
    required this.onSelectHand,
    required this.onCaptureImage,
    required this.onFlowerToggled,
    required this.getAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Camera / Manual selection buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: Text(AppLocalizations.scanTiles),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onCaptureImage,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.grid_view),
                label: Text(AppLocalizations.selectHand),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: onSelectHand,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Hand preview card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.handPreviewArea,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: onSelectHand,
                  child: _buildHandPreview(),
                ),

                const SizedBox(height: 24),
                Text(
                  AppLocalizations.selectFlowers,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Flowers 1-4
                _buildFlowerRow(1, 4),
                const SizedBox(height: 12),
                // Flowers 5-8
                _buildFlowerRow(5, 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHandPreview() {
    if (isAnalyzing) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(AppLocalizations.analyzingTiles),
          ],
        ),
      );
    }

    if (capturedImage != null) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(capturedImage!),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    if (selectedTiles.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 67, 125, 49),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade900, width: 2),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ...selectedTiles.map((tile) {
              return Image.asset(
                getAssetPath(tile),
                width: 30,
                height: 42,
                fit: BoxFit.contain,
              );
            }),
            // Display selected flowers as visuals
            ...selectedFlowers.entries.where((e) => e.value).map((e) {
              return Image.asset(
                getAssetPath(e.key),
                width: 30,
                height: 42,
                fit: BoxFit.contain,
              );
            })
          ].toList(),
        ),
      );
    }

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          AppLocalizations.takePhotoHint,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildFlowerRow(int start, int end) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(end - start + 1, (index) {
        int id = start + index;
        String key = '${id}f';
        bool isSelected = selectedFlowers[key] == true;

        return GestureDetector(
          onTap: () => onFlowerToggled(key),
          child: Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.amber, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Opacity(
              opacity: isSelected ? 1.0 : 0.5,
              child: Image.asset(
                getAssetPath(key),
                width: 45,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      }),
    );
  }
}
