// lib/widgets/square_image_viewer.dart
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'dart:io';

class SquareImageViewer extends StatefulWidget {
  final String title;
  final String? imagePath;
  final List<dynamic> detections;
  final bool showDetections;
  final Color backgroundColor;
  final String placeholderText;
  final VoidCallback? onImageTap;
  final List<Widget> actionButtons;
  final bool isInteractive;

  const SquareImageViewer({
    super.key,
    required this.title,
    this.imagePath,
    this.detections = const [],
    this.showDetections = true,
    this.backgroundColor = Colors.black,
    this.placeholderText = 'No image',
    this.onImageTap,
    this.actionButtons = const [],
    this.isInteractive = false,
  });

  @override
  State<SquareImageViewer> createState() => _SquareImageViewerState();
}

class _SquareImageViewerState extends State<SquareImageViewer> {
  bool _showOverlay = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.actionButtons.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.actionButtons,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            // Square image container
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // Force square ratio
                child: GestureDetector(
                  onTap: widget.onImageTap,
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _showOverlay = true),
                    onExit: (_) => setState(() => _showOverlay = false),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Stack(
                          children: [
                            // Image content
                            _buildImageContent(),
                            
                            // Detection overlay
                            if (widget.showDetections && widget.detections.isNotEmpty)
                              CustomPaint(
                                painter: SquareDetectionPainter(widget.detections),
                                size: Size.infinite,
                              ),
                            
                            // Interactive overlay
                            if (widget.isInteractive && _showOverlay)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Center(
                                  child: Icon(
                                    FeatherIcons.eye,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            
                            // Detection count badge
                            if (widget.detections.isNotEmpty)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${widget.detections.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.imagePath == null || widget.imagePath!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FeatherIcons.image,
              color: Colors.white.withOpacity(0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              widget.placeholderText,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget imageWidget;
    if (widget.imagePath!.startsWith('http')) {
      imageWidget = Image.network(
        widget.imagePath!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      imageWidget = Image.file(
        File(widget.imagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FeatherIcons.alertCircle,
            color: Colors.red.shade300,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load',
            style: TextStyle(
              color: Colors.red.shade300,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SquareDetectionPainter extends CustomPainter {
  final List<dynamic> detections;

  SquareDetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    
    for (var detection in detections) {
      _drawDetection(canvas, size, detection);
    }
  }

  void _drawDetection(Canvas canvas, Size size, dynamic detection) {
    final bbox = detection['bbox'] as List<dynamic>;
    final confidence = detection['confidence'] as double;
    final className = detection['class_name'] as String;

    // Convert relative coordinates to square canvas
    final x = bbox[0] * size.width;  // x_center
    final y = bbox[1] * size.height; // y_center  
    final w = bbox[2] * size.width;  // width
    final h = bbox[3] * size.height; // height

    // Ensure bounding box stays within square bounds
    final left = (x - w/2).clamp(0.0, size.width);
    final top = (y - h/2).clamp(0.0, size.height);
    final right = (x + w/2).clamp(0.0, size.width);
    final bottom = (y + h/2).clamp(0.0, size.height);
    
    if (right <= left || bottom <= top) return;

    // Draw bounding box
    final paint = Paint()
      ..color = _getColorForClass(className)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);

    // Draw small confidence label
    final textSpan = TextSpan(
      text: '${(confidence * 100).toStringAsFixed(0)}%',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Position label inside the box to save space
    final labelLeft = (left + 2).clamp(0.0, size.width - textPainter.width - 4);
    final labelTop = (top + 2).clamp(0.0, size.height - textPainter.height - 4);
    
    // Draw label background
    final labelRect = Rect.fromLTWH(
      labelLeft,
      labelTop,
      textPainter.width + 4,
      textPainter.height + 2,
    );

    if (labelRect.right <= size.width && labelRect.bottom <= size.height) {
      canvas.drawRect(labelRect, Paint()..color = _getColorForClass(className).withOpacity(0.8));
      textPainter.paint(canvas, Offset(labelLeft + 2, labelTop + 1));
    }
  }

  Color _getColorForClass(String className) {
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

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
