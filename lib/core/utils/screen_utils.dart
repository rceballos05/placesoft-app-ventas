import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Extension helpers to simplify responsive layout logic across the app.
extension ScreenContext on BuildContext {
  /// Provides the width of the available viewport.
  double get width => MediaQuery.sizeOf(this).width;

  /// Provides the height of the available viewport.
  double get height => MediaQuery.sizeOf(this).height;

  /// Generates horizontal padding based on a percentage of the screen width.
  EdgeInsets horizontalPadding(double factor) =>
      EdgeInsets.symmetric(horizontal: width * factor);
}

/// Utility helpers for consistent responsive sizing calculations.
class ScreenUtils {
  const ScreenUtils._();

  /// Returns a responsive size using [ScreenUtil]'s scaling.
  static double scaled(double value) => value.sp;
}
