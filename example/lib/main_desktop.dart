import 'package:flutter/foundation.dart';
import 'package:flutter_compress_image/flutter_image_compress.dart';

import 'main.dart' as m;

main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  FlutterImageCompress.validator.ignoreCheckSupportPlatform = true;
  m.main();
}
