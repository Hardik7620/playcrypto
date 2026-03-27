part of 'core.dart';

/// Represents the style of a single [FortuneItem].
///
/// See also:
///  * [StyleStrategy], which allows for styling a list of [FortuneItem]s
@immutable
class FortuneItemStyle {
  /// The color used for filling the background of a [FortuneItem].
  final Color color;

  /// The color used for painting the border of a [FortuneItem].
  final Color borderColor;

  /// The border width of a [FortuneItem].
  final double borderWidth;

  /// The alignment of text within a [FortuneItem]
  final TextAlign textAlign;

  /// The text style to use within a [FortuneItem]
  final TextStyle textStyle;

  final Gradient? gradient;

  const FortuneItemStyle({
    this.color = Colors.white,
    this.borderColor = Colors.black,
    this.borderWidth = 1.0,
    this.textAlign = TextAlign.start,
    this.textStyle = const TextStyle(),
    this.gradient,
  });

  /// Creates an opinionated disabled style based on the current [ThemeData].
  FortuneItemStyle.disabled(ThemeData theme, {double opacity = 0.0})
      : this(
          color: Color.alphaBlend(
            theme.disabledColor.withOpacity(opacity),
            theme.disabledColor,
          ),
          borderWidth: 0.0,
          textStyle: TextStyle(color: theme.colorScheme.onPrimary),
        );

  @override
  int get hashCode => hashObjects([
        borderColor,
        borderWidth,
        color,
        textAlign,
        textStyle,
      ]);

  @override
  bool operator ==(Object other) {
    return other is FortuneItemStyle &&
        borderColor == other.borderColor &&
        borderWidth == other.borderWidth &&
        color == other.color &&
        textAlign == other.textAlign &&
        textStyle == other.textStyle;
  }
}

/// Interface for providing common styling to a list of [FortuneItem]s.
abstract class StyleStrategy {
  /// {@template flutter_fortune_wheel.StyleStrategy.getItemStyle}
  /// Creates an [FortuneItemStyle] based on the passed [theme] while
  /// considering an item's [index] with respect to the overall [itemCount].
  /// {@endtemplate}
  FortuneItemStyle getItemStyle(
    ThemeData theme,
    int index,
    int itemCount,
  );
}

/// Mixin to allow style strategies to have a common style for disabled items.
mixin DisableAwareStyleStrategy {
  List<int> get disabledIndices;

  bool _isIndexDisabled(int index) {
    return disabledIndices.contains(index);
  }

  FortuneItemStyle getDisabledItemStyle(
    ThemeData theme,
    int index,
    int itemCount,
    FortuneItemStyle Function() orElse,
  ) {
    if (_isIndexDisabled(index)) {
      return FortuneItemStyle.disabled(
        theme,
        opacity: index % 2 == 0 ? 0.2 : 0.0,
      );
    } else {
      return orElse();
    }
  }
}

/// This strategy renders all items using the same style based on the current
/// [ThemeData].
///
/// The [ThemeData.primaryColor] is used as the border color and the background
/// is drawn using the same color at 0.3 opacity.
class UniformStyleStrategy with DisableAwareStyleStrategy implements StyleStrategy {
  final Color? color;
  final Color? borderColor;
  final double? borderWidth;
  final TextAlign? textAlign;
  final TextStyle? textStyle;
  final List<int> disabledIndices;

  const UniformStyleStrategy({
    this.color,
    this.borderColor,
    this.borderWidth,
    this.textAlign,
    this.textStyle,
    this.disabledIndices = const <int>[],
  });

  /// {@macro flutter_fortune_wheel.StyleStrategy.getItemStyle}
  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        color: color ??
            Color.alphaBlend(
              theme.colorScheme.primary.withOpacity(0.3),
              theme.colorScheme.surface,
            ),
        borderColor: borderColor ?? theme.colorScheme.primary,
        borderWidth: borderWidth ?? 1.0,
        textStyle: textStyle ?? TextStyle(color: theme.colorScheme.onSurface),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}

/// This strategy renders items in alternating variations of the
/// [ThemeData.primaryColor].
///
/// It renders even items at 0.5 opacity and odd items using the original color.
/// If the item count is odd, the first item is rendered with 0.7 opacity to
/// prevent a non-uniform style.
class AlternatingStyleStrategy with DisableAwareStyleStrategy implements StyleStrategy {
  final List<Color> colors;
  final List<int> disabledIndices;

  Color _getFillColor(ThemeData theme, int index, int itemCount) {
    if (colors.isEmpty) {
      final color = theme.colorScheme.primary;
      final background = theme.colorScheme.background;
      final opacity = itemCount % 2 == 1 && index == 0
          ? 0.7 // TODO: make 0.75
          : index % 2 == 0
              ? 0.5
              : 1.0;

      return Color.alphaBlend(
        color.withOpacity(opacity),
        background,
      );
    } else {
      return index.isEven ? colors.first : colors.last;
    }
  }

  const AlternatingStyleStrategy({
    this.disabledIndices = const <int>[],
    this.colors = const [],
  });

  /// {@macro flutter_fortune_wheel.StyleStrategy.getItemStyle}
  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        color: _getFillColor(theme, index, itemCount),
        borderColor: theme.colorScheme.primary,
        borderWidth: 0.0,
        textAlign: TextAlign.start,
        textStyle: TextStyle(color: theme.colorScheme.onPrimary),
      ),
    );
  }
}

class GradientSlicesStyleStrategy with DisableAwareStyleStrategy implements StyleStrategy {
  final List<int> disabledIndices;
  final List<Color> colors;

  Color _getFillColor(ThemeData theme, int index, int itemCount) {
    final color = colors[index % colors.length];
    final background = theme.colorScheme.background;
    final opacity = itemCount % 2 == 1 && index == 0
        ? 0.75
        : index % 2 == 0
            ? 0.5
            : 1.0;

    return Color.alphaBlend(
      color.withOpacity(opacity),
      background,
    );
  }

  Gradient _getFillGradient(ThemeData theme, int index, int itemCount) {
    return LinearGradient(
      colors: [
        colors[index % (colors.length)].withOpacity(0.7),
        colors[index % (colors.length)],
        colors[index % (colors.length)],
        colors[index % (colors.length)].withOpacity(0.6),
      ],
      stops: [0.1, 0.6, 0.5, 0.7],
    );
  }

  const GradientSlicesStyleStrategy({
    this.colors = const [],
    this.disabledIndices = const <int>[],
  });

  /// {@macro flutter_fortune_wheel.StyleStrategy.getItemStyle}
  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        gradient: _getFillGradient(theme, index, itemCount),
        color: _getFillColor(theme, index, itemCount),
        borderColor: Colors.white,
        borderWidth: 3.0,
        textAlign: TextAlign.start,
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

class TransparentSlicesStyleStrategy with DisableAwareStyleStrategy implements StyleStrategy {
  final List<int> disabledIndices;

  Color _getFillColor(ThemeData theme, int index, int itemCount) {
    return Colors.transparent;
  }

  const TransparentSlicesStyleStrategy({
    this.disabledIndices = const <int>[],
  });

  /// {@macro flutter_fortune_wheel.StyleStrategy.getItemStyle}
  @override
  FortuneItemStyle getItemStyle(ThemeData theme, int index, int itemCount) {
    return getDisabledItemStyle(
      theme,
      index,
      itemCount,
      () => FortuneItemStyle(
        color: _getFillColor(theme, index, itemCount),
        borderColor: Colors.red,
        borderWidth: 0.0,
        textAlign: TextAlign.start,
        textStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
