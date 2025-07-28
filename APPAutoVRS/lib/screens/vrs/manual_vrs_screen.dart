import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/ai_api_service.dart';
import '../../widgets/image_viewer.dart';
import '../../widgets/square_image_viewer.dart';

class ManualVRSScreen extends StatefulWidget {
  const ManualVRSScreen({super.key});

  @override
  State<ManualVRSScreen> createState() => _ManualVRSScreenState();
}

class _ManualVRSScreenState extends State<ManualVRSScreen> {
  double _magnification = 140;
  int _currentBoard = 4;
  final int _totalBoards = 25;
  
  // AI functionality variables
  String? _selectedImagePath;
  Map<String, dynamic>? _aiResults;
  bool _isProcessing = false;
  bool _showDetections = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Display Panel - Square VRS and 2 Reference Views
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Main VRS Image Section - Square
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Ảnh VRS với AI Detection',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  // AI Controls
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(FeatherIcons.upload, size: 16),
                                    label: const Text('Chọn ảnh'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: (_selectedImagePath != null && !_isProcessing)
                                        ? _runAIInspection
                                        : null,
                                    icon: _isProcessing
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Icon(FeatherIcons.zap, size: 16),
                                    label: Text(_isProcessing ? 'Chẩn đoán...' : 'Chẩn đoán'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_aiResults != null)
                                    IconButton(
                                      icon: Icon(
                                        _showDetections ? FeatherIcons.eye : FeatherIcons.eyeOff,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _showDetections = !_showDetections;
                                        });
                                      },
                                      tooltip: _showDetections ? 'Ẩn detection' : 'Hiện detection',
                                    ),
                                  const SizedBox(width: 16),
                                  // Navigation Controls
                                  IconButton(
                                    onPressed: _currentBoard > 1
                                        ? _previousBoard
                                        : null,
                                    icon: const Icon(FeatherIcons.arrowLeft),
                                    tooltip: 'Bo trước',
                                  ),
                                  Text('$_currentBoard / $_totalBoards'),
                                  IconButton(
                                    onPressed: _currentBoard < _totalBoards
                                        ? _nextBoard
                                        : null,
                                    icon: const Icon(FeatherIcons.arrowRight),
                                    tooltip: 'Bo tiếp theo',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Square VRS Image Viewer
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1.0, // Force square ratio
                              child: _selectedImagePath != null
                                  ? ImageViewer(
                                      imagePath: _selectedImagePath!,
                                      detections: _showDetections ? (_aiResults?['detections'] ?? []) : [],
                                      showDetections: _showDetections,
                                    )
                                  : Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              FeatherIcons.image,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Chọn ảnh để kiểm tra AI',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
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
                ),

                const SizedBox(width: 16),

                // Two Reference Views - Vertical Stack
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      // Gerber View - Square
                      Expanded(
                        child: SquareImageViewer(
                          title: 'Thiết kế Gerber',
                          imagePath: null, // Will be populated later
                          backgroundColor: Colors.grey.shade700,
                          placeholderText: 'Gerber View',
                          isInteractive: true,
                          onImageTap: () {
                            // Open gerber viewer
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // PCI AOI - Square  
                      Expanded(
                        child: SquareImageViewer(
                          title: 'PCI AOI',
                          imagePath: null, // Will be populated later
                          backgroundColor: Colors.grey.shade200,
                          placeholderText: 'AOI Capture',
                          isInteractive: true,
                          onImageTap: () {
                            // Open AOI viewer
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Info & Action Panel
          SizedBox(
            width: 320,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phán định thủ công',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Divider(height: 24),

                    // Info rows
                    _buildInfoRow('Mã Lô:', 'LOT-C-789'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Số thứ tự bo (Id_board):', '240715-008'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Loại lỗi AI dự đoán:', _aiResults != null 
                        ? '${_aiResults!['total_defects']} lỗi được tìm thấy'
                        : 'Chưa chẩn đoán'),

                    const SizedBox(height: 24),

                    // Magnification Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Độ phóng đại',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              '${_magnification.round()}x',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _magnification,
                          min: 30,
                          max: 250,
                          divisions: 220,
                          onChanged: (value) =>
                              setState(() => _magnification = value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Tools Section
                    const Text(
                      'Công cụ Định vị',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/board-align/1'),
                            icon: const Icon(FeatherIcons.move, size: 16),
                            label: const Text('Vị trí Bo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => context.push('/light-adjust'),
                            icon: const Icon(FeatherIcons.sun, size: 16),
                            label: const Text('Ánh sáng'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Judgment Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makeJudgment(true),
                            icon: const Icon(FeatherIcons.check, size: 20),
                            label: const Text(
                              'OK',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _makeJudgment(false),
                            icon: const Icon(FeatherIcons.x, size: 20),
                            label: const Text(
                              'NG',
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AI functionality methods
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'bmp', 'tiff'],
        dialogTitle: 'Chọn ảnh PCB để kiểm tra',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImagePath = result.files.single.path!;
          _aiResults = null; // Reset previous results
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã chọn ảnh: ${result.files.single.name}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runAIInspection() async {
    if (_selectedImagePath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Upload image and run AI inference
      final results = await AIApiService.runManualInspection(
        imagePath: _selectedImagePath!,
        boardId: _currentBoard,
      );

      setState(() {
        _aiResults = results['ai_results'];
        _isProcessing = false;
      });

      if (mounted) {
        final totalDefects = _aiResults!['total_defects'] as int;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'AI chẩn đoán hoàn tất! Tìm thấy $totalDefects lỗi',
            ),
            backgroundColor: totalDefects > 0 ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi AI chẩn đoán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _previousBoard() {
    if (_currentBoard > 1) {
      setState(() => _currentBoard--);
    }
  }

  void _nextBoard() {
    if (_currentBoard < _totalBoards) {
      setState(() => _currentBoard++);
    }
  }

  void _makeJudgment(bool isOK) {
    final result = isOK ? 'OK' : 'NG';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã phán định: $result cho Bo $_currentBoard'),
        backgroundColor: isOK ? Colors.green : Colors.red,
      ),
    );

    // Auto move to next board
    if (_currentBoard < _totalBoards) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        _nextBoard();
      });
    }
  }
}
