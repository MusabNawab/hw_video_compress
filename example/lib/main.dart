import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hw_video_compress/hw_video_compress.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HW Video Compress',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _compressor = HwVideoCompress();

  XFile? _selectedVideo;
  String? _compressedPath;
  bool _isCompressing = false;
  bool _isPicking = false;
  double _progress = 0.0;
  String? _errorMessage;

  int _originalSize = 0;
  int _compressedSize = 0;
  Duration? _timeTaken;

  StreamSubscription<double>? _progressSubscription;

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    setState(() {
      _errorMessage = null;
      _isPicking = true;
    });

    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final size = await video.length();
        setState(() {
          _selectedVideo = video;
          _compressedPath = null;
          _compressedSize = 0;
          _originalSize = size;
          _timeTaken = null;
          _progress = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick video: $e';
      });
    } finally {
      setState(() {
        _isPicking = false;
      });
    }
  }

  Future<void> _compressVideo() async {
    if (_selectedVideo == null || _isCompressing) return;

    setState(() {
      _isCompressing = true;
      _progress = 0.0;
      _errorMessage = null;
    });

    final stopwatch = Stopwatch()..start();

    // Set up progress subscription
    _progressSubscription = _compressor.onProgress.listen((progress) {
      setState(() {
        _progress = progress;
      });
    });

    try {
      final outputPath = await _compressor.compressVideo(_selectedVideo!.path);
      stopwatch.stop();

      if (outputPath != null && mounted) {
        final compressedFile = File(outputPath);
        final compressedSize = await compressedFile.length();

        setState(() {
          _compressedPath = outputPath;
          _compressedSize = compressedSize;
          _timeTaken = stopwatch.elapsed;
          _isCompressing = false;
          _progress = 1.0;
        });
      } else {
        throw Exception('Compression returned a null path');
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _isCompressing = false;
        _errorMessage = 'Compression failed: $e';
      });
    } finally {
      await _progressSubscription?.cancel();
    }
  }

  void _clearAll() {
    setState(() {
      _selectedVideo = null;
      _compressedPath = null;
      _compressedSize = 0;
      _originalSize = 0;
      _timeTaken = null;
      _progress = 0.0;
      _errorMessage = null;
    });
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    final double spaceSavedPercent = _originalSize > 0 && _compressedSize > 0
        ? ((_originalSize - _compressedSize) / _originalSize) * 100
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HW Video Compress',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header description
              const Text(
                'Compress videos using native hardware acceleration on Android and iOS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Main Dashboard Area
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF26264A)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isPicking) ...[
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading video...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else if (_selectedVideo == null) ...[
                            Icon(
                              Icons.video_library_outlined,
                              size: 72,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No video selected',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap below to select a video from your gallery',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            // File details card
                            _buildFileDetailRow(
                              icon: Icons.movie_outlined,
                              title: 'Original File',
                              value: _selectedVideo!.name,
                            ),
                            const SizedBox(height: 12),
                            _buildFileDetailRow(
                              icon: Icons.sd_storage_outlined,
                              title: 'Original Size',
                              value: _formatSize(_originalSize),
                            ),

                            if (_isCompressing) ...[
                              const SizedBox(height: 32),
                              const Text(
                                'Compressing video...',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 16),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: CircularProgressIndicator(
                                      value: _progress,
                                      strokeWidth: 8,
                                      backgroundColor: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    '${(_progress * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (_compressedPath != null) ...[
                              const Divider(
                                color: Color(0xFF26264A),
                                height: 32,
                              ),
                              _buildFileDetailRow(
                                icon: Icons.file_download_done_outlined,
                                title: 'Compressed Path',
                                value: _compressedPath!,
                                isSuccess: true,
                              ),
                              const SizedBox(height: 12),
                              _buildFileDetailRow(
                                icon: Icons.compress,
                                title: 'Compressed Size',
                                value: _formatSize(_compressedSize),
                                isSuccess: true,
                              ),
                              const SizedBox(height: 12),
                              _buildFileDetailRow(
                                icon: Icons.offline_bolt_outlined,
                                title: 'Savings',
                                value:
                                    '${spaceSavedPercent.toStringAsFixed(1)}% space saved',
                                isSuccess: true,
                              ),
                              const SizedBox(height: 12),
                              _buildFileDetailRow(
                                icon: Icons.timer_outlined,
                                title: 'Time Taken',
                                value:
                                    '${(_timeTaken!.inMilliseconds / 1000).toStringAsFixed(2)} seconds',
                              ),
                            ],
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (!_isCompressing && !_isPicking) ...[
                if (_selectedVideo == null) ...[
                  ElevatedButton.icon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Select Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ] else ...[
                  if (_compressedPath == null) ...[
                    ElevatedButton.icon(
                      onPressed: _compressVideo,
                      icon: const Icon(Icons.bolt),
                      label: const Text('Compress Video'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  OutlinedButton.icon(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isSuccess = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess
            ? Colors.green.withValues(alpha: 0.05)
            : const Color(0xFF1E1E38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess
              ? Colors.green.withValues(alpha: 0.15)
              : const Color(0xFF26264A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSuccess
                ? Colors.green
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green[100] : Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
