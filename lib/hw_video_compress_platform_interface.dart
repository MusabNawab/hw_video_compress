import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'hw_video_compress_method_channel.dart';

abstract class HwVideoCompressPlatform extends PlatformInterface {
  /// Constructs a HwVideoCompressPlatform.
  HwVideoCompressPlatform() : super(token: _token);

  static final Object _token = Object();

  static HwVideoCompressPlatform _instance = MethodChannelHwVideoCompress();

  /// The default instance of [HwVideoCompressPlatform] to use.
  ///
  /// Defaults to [MethodChannelHwVideoCompress].
  static HwVideoCompressPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [HwVideoCompressPlatform] when
  /// they register themselves.
  static set instance(HwVideoCompressPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> compressVideo(String inputPath) {
    throw UnimplementedError('compressVideo() has not been implemented.');
  }

  Stream<double> get onProgress {
    throw UnimplementedError('onProgress getter has not been implemented.');
  }
}
