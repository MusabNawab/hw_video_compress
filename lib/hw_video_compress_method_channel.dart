import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'hw_video_compress_platform_interface.dart';

/// An implementation of [HwVideoCompressPlatform] that uses method channels.
class MethodChannelHwVideoCompress extends HwVideoCompressPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('hw_video_compress');

  /// The event channel used to receive progress updates from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('hw_video_compress_progress');

  @override
  Future<String?> compressVideo(String inputPath) async {
    final outputPath = await methodChannel.invokeMethod<String>(
      'compressVideo',
      {'inputPath': inputPath},
    );
    return outputPath;
  }

  @override
  Stream<double> get onProgress {
    return eventChannel.receiveBroadcastStream().map((dynamic event) {
      // Cast to num first to safely handle both int and double coming from native
      return (event as num).toDouble();
    });
  }
}
