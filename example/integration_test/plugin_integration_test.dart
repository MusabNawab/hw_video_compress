// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:hw_video_compress/hw_video_compress.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('compressVideo throws PlatformException for invalid path', (WidgetTester tester) async {
    final HwVideoCompress plugin = HwVideoCompress();
    expect(
      () => plugin.compressVideo('invalid/path/to/video.mp4'),
      throwsA(isA<PlatformException>()),
    );
  });
}
