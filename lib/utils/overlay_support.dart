import 'package:flutter/material.dart';
import 'package:jebby/utils/loader.dart';
import 'package:overlay_support/overlay_support.dart';

class Loader {
  static OverlaySupportEntry? _currentLoader;

  static void show() {
    _currentLoader = showOverlay((context, t) {
      return Opacity(
        opacity: t,
        child: Material(color: Colors.black54, child: LoaderWidget()),
      );
    }, duration: Duration.zero);
  }

  static void hide() {
    _currentLoader?.dismiss();
    _currentLoader = null;
  }
}
