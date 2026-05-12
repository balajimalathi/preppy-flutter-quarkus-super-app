import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const sm = Radius.circular(6);
  static const md = Radius.circular(8);
  static const lg = Radius.circular(12);

  static const roundedSm = BorderRadius.all(sm);
  static const roundedMd = BorderRadius.all(md);
  static const roundedLg = BorderRadius.all(lg);
}
