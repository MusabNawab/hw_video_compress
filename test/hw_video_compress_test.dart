import 'package:flutter_test/flutter_test.dart';
import 'package:hw_video_compress/hw_video_compress.dart';
import 'package:hw_video_compress/hw_video_compress_platform_interface.dart';
import 'package:hw_video_compress/hw_video_compress_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHwVideoCompressPlatform
    with MockPlatformInterfaceMixin
    implements HwVideoCompressPlatform {
  @override
  Future<String?> compressVideo(String inputPath) => Future.value('output/path.mp4');

  @override
  Stream<double> get onProgress => Stream.fromIterable([0.5, 1.0]);
}

void main() {
  final HwVideoCompressPlatform initialPlatform = HwVideoCompressPlatform.instance;

  test('$MethodChannelHwVideoCompress is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelHwVideoCompress>());
  });

  test('compressVideo calls platform implementation', () async {
    HwVideoCompress hwVideoCompressPlugin = HwVideoCompress();
    MockHwVideoCompressPlatform fakePlatform = MockHwVideoCompressPlatform();
    HwVideoCompressPlatform.instance = fakePlatform;

    expect(await hwVideoCompressPlugin.compressVideo('input/path.mp4'), 'output/path.mp4');
  });

  test('onProgress getter gets platform stream', () async {
    HwVideoCompress hwVideoCompressPlugin = HwVideoCompress();
    MockHwVideoCompressPlatform fakePlatform = MockHwVideoCompressPlatform();
    HwVideoCompressPlatform.instance = fakePlatform;

    expect(await hwVideoCompressPlugin.onProgress.toList(), [0.5, 1.0]);
  });
}
