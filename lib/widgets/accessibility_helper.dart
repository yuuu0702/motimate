import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// アクセシビリティ対応ヘルパーウィジェット
class AccessibilityHelper {
  /// スクリーンリーダー対応のボタン
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? hint,
    bool enabled = true,
    EdgeInsets padding = const EdgeInsets.all(8),
    Color? backgroundColor,
    Color? foregroundColor,
    BorderRadius? borderRadius,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: enabled,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }

  /// スクリーンリーダー対応のテキストフィールド
  static Widget accessibleTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
    bool readOnly = false,
    int? maxLines = 1,
    String? helperText,
  }) {
    return Semantics(
      label: label,
      hint: hint ?? helperText,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          helperText: helperText,
          suffixIcon: suffixIcon,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        // アクセシビリティのための追加設定
        enableInteractiveSelection: !readOnly,
      ),
    );
  }

  /// スクリーンリーダー対応のリストタイル
  static Widget accessibleListTile({
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    required VoidCallback? onTap,
    required String semanticLabel,
    String? hint,
    bool selected = false,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      selected: selected,
      enabled: enabled,
      child: ListTile(
        title: title,
        subtitle: subtitle,
        leading: leading,
        trailing: trailing,
        onTap: enabled ? onTap : null,
        selected: selected,
        enabled: enabled,
      ),
    );
  }

  /// スクリーンリーダー対応のチェックボックス
  static Widget accessibleCheckbox({
    required bool value,
    required ValueChanged<bool?>? onChanged,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      checked: value,
      enabled: enabled,
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: enabled ? onChanged : null,
        enabled: enabled,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  /// スクリーンリーダー対応のラジオボタン
  static Widget accessibleRadio<T>({
    required T value,
    required T? groupValue,
    required ValueChanged<T?>? onChanged,
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      inMutuallyExclusiveGroup: true,
      checked: value == groupValue,
      enabled: enabled,
      child: ListTile(
        title: Text(label),
        leading: Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: enabled ? onChanged : null,
        ),
        onTap: enabled ? () => onChanged?.call(value) : null,
        enabled: enabled,
      ),
    );
  }

  /// スクリーンリーダー対応のスライダー
  static Widget accessibleSlider({
    required double value,
    required ValueChanged<double>? onChanged,
    required double min,
    required double max,
    required String label,
    String? hint,
    int? divisions,
    bool enabled = true,
    String Function(double)? semanticFormatterCallback,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      slider: true,
      enabled: enabled,
      value: value.toString(),
      increasedValue: value < max ? (value + ((max - min) / (divisions ?? 100))).toString() : null,
      decreasedValue: value > min ? (value - ((max - min) / (divisions ?? 100))).toString() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: value,
            onChanged: enabled ? onChanged : null,
            min: min,
            max: max,
            divisions: divisions,
            label: semanticFormatterCallback?.call(value) ?? value.toStringAsFixed(1),
          ),
        ],
      ),
    );
  }

  /// スクリーンリーダー対応のタブ
  static Widget accessibleTabBar({
    required TabController controller,
    required List<Tab> tabs,
    required List<String> semanticLabels,
    List<String>? hints,
  }) {
    assert(tabs.length == semanticLabels.length);
    assert(hints == null || hints.length == tabs.length);

    return Semantics(
      container: true,
      child: TabBar(
        controller: controller,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          return Semantics(
            label: semanticLabels[index],
            hint: hints?[index],
            selected: controller.index == index,
            child: tab,
          );
        }).toList(),
      ),
    );
  }

  /// 高コントラストテーマ対応のカラー取得
  static Color getAccessibleColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
    Color? highContrastLightColor,
    Color? highContrastDarkColor,
  }) {
    final brightness = Theme.of(context).brightness;
    final isHighContrast = MediaQuery.of(context).highContrast;

    if (isHighContrast) {
      return brightness == Brightness.light
          ? (highContrastLightColor ?? lightColor)
          : (highContrastDarkColor ?? darkColor);
    }

    return brightness == Brightness.light ? lightColor : darkColor;
  }

  /// フォントサイズのアクセシビリティ対応
  static double getAccessibleFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final textScaleFactor = MediaQuery.of(context).textScaler.scale(1.0);
    return baseFontSize * textScaleFactor.clamp(0.8, 2.0);
  }

  /// 画面読み上げ順序の制御
  static Widget accessibleTraversalGroup({
    required Widget child,
    SemanticsTag? tag,
  }) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  /// ライブリージョン（動的コンテンツの読み上げ）
  static Widget accessibleLiveRegion({
    required Widget child,
    required String liveRegionLabel,
    bool polite = true,
  }) {
    return Semantics(
      label: liveRegionLabel,
      liveRegion: true,
      child: child,
    );
  }

  /// スクリーンリーダー対応のダイアログ
  static Widget accessibleDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    String? semanticLabel,
    bool barrierDismissible = true,
  }) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      label: semanticLabel ?? title,
      child: AlertDialog(
        title: Semantics(
          header: true,
          child: Text(title),
        ),
        content: content,
        actions: actions,
      ),
    );
  }

  /// プログレスインジケーターのアクセシビリティ対応
  static Widget accessibleProgressIndicator({
    double? value,
    String? label,
    String? hint,
    bool isCircular = true,
  }) {
    return Semantics(
      label: label ?? 'ローディング中',
      hint: hint,
      value: value != null ? '${(value * 100).round()}%' : null,
      child: isCircular
          ? CircularProgressIndicator(value: value)
          : LinearProgressIndicator(value: value),
    );
  }

  /// カスタムジェスチャーのアクセシビリティ対応
  static Widget accessibleCustomAction({
    required Widget child,
    required Map<CustomSemanticsAction, VoidCallback> customActions,
    String? label,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      customSemanticsActions: customActions,
      child: child,
    );
  }

  /// バリア（モーダル）のアクセシビリティ対応
  static Widget accessibleBarrier({
    required Widget child,
    required String semanticLabel,
    bool dismissible = true,
    VoidCallback? onDismiss,
  }) {
    return Semantics(
      label: semanticLabel,
      child: GestureDetector(
        onTap: dismissible ? onDismiss : null,
        child: Container(
          color: Colors.black54,
          child: child,
        ),
      ),
    );
  }

  /// テキストのアクセシビリティ向上
  static Widget accessibleText({
    required String text,
    TextStyle? style,
    String? semanticLabel,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return Semantics(
      label: semanticLabel ?? text,
      readOnly: true,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        // アクセシビリティ向けの最小フォントサイズ確保
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }

  /// エラーメッセージのアクセシビリティ対応
  static Widget accessibleErrorMessage({
    required String message,
    IconData? icon = Icons.error,
    Color? color = Colors.red,
  }) {
    return Semantics(
      label: 'エラー: $message',
      liveRegion: true,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  /// 成功メッセージのアクセシビリティ対応
  static Widget accessibleSuccessMessage({
    required String message,
    IconData? icon = Icons.check_circle,
    Color? color = Colors.green,
  }) {
    return Semantics(
      label: '成功: $message',
      liveRegion: true,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}