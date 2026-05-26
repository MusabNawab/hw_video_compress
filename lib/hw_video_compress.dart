import 'hw_video_compress_platform_interface.dart';

class HwVideoCompress {
  /// Compresses a video given its [inputPath] and returns the file path of the compressed video.
  Future<String?> compressVideo(String inputPath) {
    return HwVideoCompressPlatform.instance.compressVideo(inputPath);
  }

  /// A stream that emits the progress of the compression process.
  /// Values range from 0.0 (started) to 1.0 (completed).
  Stream<double> get onProgress {
    return HwVideoCompressPlatform.instance.onProgress;
  }
}
