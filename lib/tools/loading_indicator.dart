import 'package:flutter/material.dart';

class LoadingScreen {
  LoadingScreen._privateConstructor();

  static final LoadingScreen _instance = LoadingScreen._privateConstructor();

  factory LoadingScreen() => _instance;

  OverlayEntry? _overlayEntry;

  void show(BuildContext context, {String? text}) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context, text: text);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context, {String? text}) {
    return OverlayEntry(
      builder: (context) {
        return Material(
          color: Colors.black.withAlpha(150),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                if (text != null)
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}