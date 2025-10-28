import 'package:flutter/material.dart';

/// Reusable numeric keyboard for login inputs.
class NumericKeyboard extends StatelessWidget {
  const NumericKeyboard({
    super.key,
    required this.onKeyTap,
    this.onBackspace,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.spacing = 12,
  });

  final ValueChanged<String> onKeyTap;
  final VoidCallback? onBackspace;
  final EdgeInsetsGeometry padding;
  final double spacing;

  static const _keys = <_KeyboardKey>[
    _KeyboardKey('1'),
    _KeyboardKey('2'),
    _KeyboardKey('3'),
    _KeyboardKey('4'),
    _KeyboardKey('5'),
    _KeyboardKey('6'),
    _KeyboardKey('7'),
    _KeyboardKey('8'),
    _KeyboardKey('9'),
    _KeyboardKey('K'),
    _KeyboardKey('0'),
    _KeyboardKey('⌫', isDelete: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final childAspectRatio = width > 420
            ? 1.8
            : width > 360
                ? 1.5
                : 1.2;

        return GridView.builder(
          shrinkWrap: true,
          padding: padding,
          itemCount: _keys.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final key = _keys[index];
            return _KeyboardButton(
              label: key.label,
              isDelete: key.isDelete,
              onPressed: key.isDelete
                  ? onBackspace
                  : () => onKeyTap(key.label),
              theme: theme,
            );
          },
        );
      },
    );
  }
}

class _KeyboardKey {
  const _KeyboardKey(this.label, {this.isDelete = false});

  final String label;
  final bool isDelete;
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    required this.label,
    required this.isDelete,
    required this.onPressed,
    required this.theme,
  });

  final String label;
  final bool isDelete;
  final VoidCallback? onPressed;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final textStyle = theme.textTheme.titleLarge;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surfaceVariant,
        foregroundColor: isDelete
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurfaceVariant,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: textStyle?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
