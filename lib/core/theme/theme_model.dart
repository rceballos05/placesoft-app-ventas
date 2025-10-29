import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the current [ThemeMode] and notifies dependants when it changes.
class ThemeModel extends ChangeNotifier {
  ThemeModel({ThemeMode initialThemeMode = ThemeMode.system})
      : _themeMode = initialThemeMode;

  ThemeModel._fallback() : _themeMode = ThemeMode.system;

  ThemeMode _themeMode;

  static final ThemeModel _fallbackInstance = ThemeModel._fallback();

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode value) => updateThemeMode(value);

  void updateThemeMode(ThemeMode newMode) {
    if (newMode == _themeMode) {
      return;
    }
    _themeMode = newMode;
    _saveThemeMode(newMode);
    notifyListeners();
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode') ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[index];
    notifyListeners();
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  /// Returns the nearest [ThemeModel] up the widget tree, listening to updates
  /// when [listen] is `true`.
  static ThemeModel? maybeOf(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<ThemeModelInheritedNotifier>()
          ?.notifier;
    }
    final element = context
        .getElementForInheritedWidgetOfExactType<ThemeModelInheritedNotifier>();
    final widget = element?.widget;
    if (widget is ThemeModelInheritedNotifier) {
      return widget.notifier;
    }
    return null;
  }

  /// Returns the nearest [ThemeModel] or a fallback instance when not found.
  ///
  /// An assert will fire in debug mode to help detect when the
  /// [ThemeModelInheritedNotifier] has not been inserted into the tree yet.
  static ThemeModel of(BuildContext context, {bool listen = true}) {
    final themeModel = maybeOf(context, listen: listen);
    assert(
      themeModel != null,
      'ThemeModel.of() called with a context that does not contain a '
      'ThemeModelInheritedNotifier. Make sure to wrap your app with '
      'ThemeModelInheritedNotifier so that ThemeModel is available.',
    );
    return themeModel ?? _fallbackInstance;
  }
}

/// Provides access to [ThemeModel] for the widget subtree.
class ThemeModelInheritedNotifier extends InheritedNotifier<ThemeModel> {
  const ThemeModelInheritedNotifier({
    super.key,
    required ThemeModel notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);
}
