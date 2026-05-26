# hw_video_compress

A powerful and easy-to-use Flutter plugin for compressing videos on Android and iOS using hardware acceleration.

> [!NOTE]
> This package uses hardware-accelerated transcoding, which makes it highly efficient and best suited for large video files (100MB+). It typically compresses video size by **80%** while maintaining great visual quality.

## Features
- **Hardware Acceleration:** Uses native hardware codecs on Android (via `Transcoder`) and iOS (`AVAssetExportSession`) for fast video compression.
- **Progress Tracking:** Provides a stream to listen to compression progress in real-time (from `0.0` to `1.0`).

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  hw_video_compress: ^1.0.0
```

## Usage

### Import the package

```dart
import 'package:hw_video_compress/hw_video_compress.dart';
```

### Compress a Video

To compress a video, create an instance of `HwVideoCompress` and call `compressVideo()` passing the absolute path of the input file.

```dart
final hwVideoCompress = HwVideoCompress();

final String? compressedFilePath = await hwVideoCompress.compressVideo(
  '/path/to/your/input_video.mp4',
);

print('Compressed video saved at: $compressedFilePath');
```

### Listen to Compression Progress

You can listen to the `onProgress` stream to get live updates while the video is compressing.

```dart
final subscription = hwVideoCompress.onProgress.listen((progress) {
  print('Compression Progress: ${(progress * 100).toStringAsFixed(1)}%');
});

// Don't forget to cancel the subscription when you are done!
// subscription.cancel();
```

## Example

For a complete working example, please check the [example](example) folder in this repository.
