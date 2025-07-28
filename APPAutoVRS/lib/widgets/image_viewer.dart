// lib/widgets/image_viewer.dart
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImageViewer extends StatefulWidget {
  final String imagePath;
  final List<dynamic> detections;
  final bool showDetections;

  const ImageViewer({
    super.key,
    required this.imagePath,
    this.detections = const [],
    this.showDetections = true,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late PhotoViewController _photoViewController;
  bool _showDetections = true;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _showDetections = widget.showDetections;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: Stack(
        children: [
          // Main Image with Zoom/Pan
          ClipRect(
            child: PhotoView.customChild(
              controller: _photoViewController,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4.0,
              initialScale: PhotoViewComputedScale.contained,
              backgroundDecoration: const BoxDecoration(color: Colors.transparent),
              child: _buildImageWithDetections(),
            ),
          ),
          
          // Controls Overlay
          _buildControlsOverlay(),
          
          // Detection Info
          if (widget.detections.isNotEmpty && _showDetections)
            _buildDetectionInfo(),
        ],
      ),
    );
  }

  Widget _buildImageWithDetections() {
    Widget imageWidget;

    // Load image from path
    if (widget.imagePath.startsWith('http')) {
      imageWidget = Image.network(
        widget.imagePath,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      imageWidget = Image.file(
        File(widget.imagePath),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }

    // Add detection overlay if needed
    if (_showDetections && widget.detections.isNotEmpty) {
      return ClipRect( // Clip để chỉ vẽ trong vùng ảnh
        child: CustomPaint(
          foregroundPainter: DetectionPainter(widget.detections),
          child: imageWidget,
        ),
      );
    }

    return imageWidget;
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Zoom In
          FloatingActionButton.small(
            heroTag: "zoom_in",
            onPressed: () {
              _photoViewController.scale = (_photoViewController.scale ?? 1.0) * 1.5;
            },
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(Icons.zoom_in, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          
          // Zoom Out
          FloatingActionButton.small(
            heroTag: "zoom_out",
            onPressed: () {
              _photoViewController.scale = (_photoViewController.scale ?? 1.0) / 1.5;
            },
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(Icons.zoom_out, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          
          // Reset Zoom
          FloatingActionButton.small(
            heroTag: "reset_zoom",
            onPressed: () {
              _photoViewController.reset();
            },
            backgroundColor: Colors.white.withOpacity(0.9),
            child: const Icon(Icons.center_focus_strong, color: Colors.black87),
          ),
          
          // Toggle Detections
          if (widget.detections.isNotEmpty) ...[
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: "toggle_detections",
              onPressed: () {
                setState(() {
                  _showDetections = !_showDetections;
                });
              },
              backgroundColor: _showDetections 
                  ? Colors.blue.withOpacity(0.9) 
                  : Colors.white.withOpacity(0.9),
              child: Icon(
                Icons.visibility,
                color: _showDetections ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetectionInfo() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Defects: ${widget.detections.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Path: ${widget.imagePath}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    super.dispose();
  }
}

class DetectionPainter extends CustomPainter {
  final List<dynamic> detections;

  DetectionPainter(this.detections);

  @override
  void paint(Canvas canvas, Size size) {
    // Chỉ vẽ trong vùng có size hợp lệ
    if (size.width <= 0 || size.height <= 0) return;
    
    for (var detection in detections) {
      _drawDetection(canvas, size, detection);
    }
  }

  void _drawDetection(Canvas canvas, Size size, dynamic detection) {
    final bbox = detection['bbox'] as List<dynamic>;
    final confidence = detection['confidence'] as double;
    final className = detection['class_name'] as String;

    // Convert coordinates từ AI model
    // AI trả về [x_center, y_center, width, height] trong tỷ lệ relative (0-1)
    // hoặc [x_center, y_center, width, height] trong pixel coordinates
    
    double x, y, w, h;
    
    // Kiểm tra xem tọa độ có phải là relative (0-1) hay absolute pixels
    if (bbox[0] <= 1.0 && bbox[1] <= 1.0 && bbox[2] <= 1.0 && bbox[3] <= 1.0) {
      // Relative coordinates (0-1)
      x = bbox[0] * size.width;  // x_center
      y = bbox[1] * size.height; // y_center  
      w = bbox[2] * size.width;  // width
      h = bbox[3] * size.height; // height
    } else {
      // Absolute pixel coordinates
      x = bbox[0].toDouble();
      y = bbox[1].toDouble(); 
      w = bbox[2].toDouble();
      h = bbox[3].toDouble();
      
      // Scale to current widget size if needed
      // Giả định ảnh gốc có kích thước chuẩn và cần scale
      // x = (bbox[0] / originalImageWidth) * size.width;
      // y = (bbox[1] / originalImageHeight) * size.height;
      // w = (bbox[2] / originalImageWidth) * size.width;
      // h = (bbox[3] / originalImageHeight) * size.height;
    }

    // Đảm bảo bounding box nằm trong vùng ảnh
    final left = (x - w/2).clamp(0.0, size.width);
    final top = (y - h/2).clamp(0.0, size.height);
    final right = (x + w/2).clamp(0.0, size.width);
    final bottom = (y + h/2).clamp(0.0, size.height);
    
    // Chỉ vẽ nếu bounding box có kích thước hợp lệ
    if (right <= left || bottom <= top) return;

    // Draw bounding box
    final paint = Paint()
      ..color = _getColorForClass(className)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromLTRB(left, top, right, bottom);
    canvas.drawRect(rect, paint);

    // Draw label background và text
    final textSpan = TextSpan(
      text: '$className (${(confidence * 100).toStringAsFixed(1)}%)',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Đặt label phía trên bounding box, nhưng không vượt quá vùng ảnh
    final labelTop = (top - textPainter.height - 4).clamp(0.0, size.height - textPainter.height);
    final labelLeft = left.clamp(0.0, size.width - textPainter.width - 8);
    
    final labelRect = Rect.fromLTWH(
      labelLeft,
      labelTop,
      textPainter.width + 8,
      textPainter.height + 4,
    );

    // Chỉ vẽ label nếu nằm trong vùng ảnh
    if (labelRect.right <= size.width && labelRect.bottom <= size.height) {
      canvas.drawRect(labelRect, Paint()..color = _getColorForClass(className));
      textPainter.paint(canvas, Offset(labelLeft + 4, labelTop + 2));
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
