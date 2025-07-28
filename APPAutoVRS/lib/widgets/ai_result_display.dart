// lib/widgets/ai_result_display.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class AIResultDisplay extends StatelessWidget {
  final Map<String, dynamic> results;

  const AIResultDisplay({
    super.key,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    final detections = results['detections'] as List<dynamic>? ?? [];
    final totalDefects = results['total_defects'] as int? ?? 0;
    final isModelLoaded = results['model_loaded'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummarySection(totalDefects, isModelLoaded),
          
          const SizedBox(height: 16),
          
          // Defects List
          if (detections.isNotEmpty) ...[
            const Text(
              'Detected Defects',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildDefectsList(detections),
            ),
          ] else
            _buildNoDefectsWidget(),
        ],
      ),
    );
  }

  Widget _buildSummarySection(int totalDefects, bool isModelLoaded) {
    return Column(
      children: [
        // Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isModelLoaded ? Colors.green.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isModelLoaded ? Colors.green.shade200 : Colors.orange.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isModelLoaded ? FeatherIcons.check : FeatherIcons.alertTriangle,
                color: isModelLoaded ? Colors.green.shade600 : Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isModelLoaded ? 'AI Model Active' : 'Demo Mode (No Model)',
                  style: TextStyle(
                    color: isModelLoaded ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Defects Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: totalDefects > 0 ? Colors.red.shade50 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: totalDefects > 0 ? Colors.red.shade200 : Colors.blue.shade200,
            ),
          ),
          child: Column(
            children: [
              Icon(
                totalDefects > 0 ? FeatherIcons.alertCircle : FeatherIcons.checkCircle,
                color: totalDefects > 0 ? Colors.red.shade600 : Colors.blue.shade600,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                '$totalDefects',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: totalDefects > 0 ? Colors.red.shade700 : Colors.blue.shade700,
                ),
              ),
              Text(
                totalDefects == 1 ? 'Defect Found' : 'Defects Found',
                style: TextStyle(
                  fontSize: 12,
                  color: totalDefects > 0 ? Colors.red.shade600 : Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefectsList(List<dynamic> detections) {
    return ListView.separated(
      itemCount: detections.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final detection = detections[index];
        return _buildDefectCard(detection, index + 1);
      },
    );
  }

  Widget _buildDefectCard(Map<String, dynamic> detection, int index) {
    final className = detection['class_name'] as String? ?? 'Unknown';
    final confidence = detection['confidence'] as double? ?? 0.0;
    final bbox = detection['bbox'] as List<dynamic>? ?? [0, 0, 0, 0];

    final color = _getColorForClass(className);
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatClassName(className),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$confidencePercent%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                FeatherIcons.mapPin,
                size: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Position: (${bbox[0].toStringAsFixed(0)}, ${bbox[1].toStringAsFixed(0)})',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                FeatherIcons.square,
                size: 12,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Size: ${bbox[2].toStringAsFixed(0)}×${bbox[3].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoDefectsWidget() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.checkCircle,
              size: 48,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'No defects detected',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Board appears to be OK',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getColorForClass(String className) {
    switch (className.toLowerCase()) {
      case 'scratch': return Colors.red;
      case 'dent': return Colors.orange;
      case 'crack': return Colors.purple;
      case 'missing_component': return Colors.blue;
      case 'solder_bridge': return Colors.green;
      case 'cold_joint': return Colors.yellow;
      default: return Colors.pink;
    }
  }

  String _formatClassName(String className) {
    return className
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
