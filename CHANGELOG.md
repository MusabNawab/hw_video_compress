## 1.0.0

* Initial release of `hw_video_compress`.
* Support hardware-accelerated video compression on Android (using native `Transcoder`).
* Support hardware-accelerated video compression on iOS (using `AVAssetExportSession`).
* Expose `compressVideo` method returning the output file path.
* Expose `onProgress` stream to track real-time compression progress.
* Provide an interactive example application featuring video picking and compression statistics.
