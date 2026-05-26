import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hw_video_compress/hw_video_compress_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelHwVideoCompress platform = MethodChannelHwVideoCompress();
  const MethodChannel channel = MethodChannel('hw_video_compress');
  const MethodChannel progressChannel = MethodChannel('hw_video_compress_progress');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'compressVideo') {
        expect(methodCall.arguments['inputPath'], 'input/path.mp4');
        return 'output/path.mp4';
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(progressChannel, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(progressChannel, null);
  });

  test('compressVideo', () async {
    expect(await platform.compressVideo('input/path.mp4'), 'output/path.mp4');
  });

  test('onProgress stream receives events', () async {
    const codec = StandardMethodCodec();
    final List<double> progressValues = [];
    final subscription = platform.onProgress.listen((progress) {
      progressValues.add(progress);
    });

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'hw_video_compress_progress',
      codec.encodeSuccessEnvelope(0.5),
      (ByteData? data) {},
    );

    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      'hw_video_compress_progress',
      codec.encodeSuccessEnvelope(1.0),
      (ByteData? data) {},
    );

    // Give microtasks a chance to run
    await Future.delayed(Duration.zero);

    expect(progressValues, [0.5, 1.0]);
    await subscription.cancel();
  });
}
