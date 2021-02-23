import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Migrate DiagnosticableMixin to Diagnosticable until
// https://github.com/flutter/flutter/pull/51495 makes it into stable (v1.15.21)
class DatePickerTheme with DiagnosticableTreeMixin {
  final TextStyle cancelStyle;
  final TextStyle doneStyle;
  final TextStyle itemStyle;
  final Color backgroundColor;
  final Color headerColor;

  final double containerHeight;
  final double titleHeight;
  final double itemHeight;

  ///title
  final Widget title;
  ///选择背景Widget
  final Widget selectBackgroundWidget;
  ///picker的padding
  final EdgeInsets pickerPadding;

  const DatePickerTheme(
      {this.cancelStyle = const TextStyle(color: Colors.black54, fontSize: 16),
      this.doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
      this.itemStyle = const TextStyle(color: Color(0xFF000046), fontSize: 18),
      this.backgroundColor = Colors.white,
      this.headerColor,
      this.containerHeight = 210.0,
      this.titleHeight = 44.0,
      this.itemHeight = 36.0,
      this.title,
      this.selectBackgroundWidget,
      this.pickerPadding = EdgeInsets.zero});

  DatePickerTheme copyWith({
    TextStyle cancelStyle,
    TextStyle doneStyle,
    TextStyle itemStyle,
    Color backgroundColor,
    Color headerColor,
    double containerHeight,
    double titleHeight,
    double itemHeight,
    Widget title,
    Widget selectBackgroundWidget,
    EdgeInsets pickerPadding,
  }) {
    if ((cancelStyle == null || identical(cancelStyle, this.cancelStyle)) &&
        (doneStyle == null || identical(doneStyle, this.doneStyle)) &&
        (itemStyle == null || identical(itemStyle, this.itemStyle)) &&
        (backgroundColor == null || identical(backgroundColor, this.backgroundColor)) &&
        (headerColor == null || identical(headerColor, this.headerColor)) &&
        (containerHeight == null || identical(containerHeight, this.containerHeight)) &&
        (titleHeight == null || identical(titleHeight, this.titleHeight)) &&
        (itemHeight == null || identical(itemHeight, this.itemHeight)) &&
        (title == null || identical(title, this.title)) &&
        (selectBackgroundWidget == null || identical(selectBackgroundWidget, this.selectBackgroundWidget)) &&
        (pickerPadding == null || identical(pickerPadding, this.pickerPadding))) {
      return this;
    }

    return new DatePickerTheme(
      cancelStyle: cancelStyle ?? this.cancelStyle,
      doneStyle: doneStyle ?? this.doneStyle,
      itemStyle: itemStyle ?? this.itemStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      headerColor: headerColor ?? this.headerColor,
      containerHeight: containerHeight ?? this.containerHeight,
      titleHeight: titleHeight ?? this.titleHeight,
      itemHeight: itemHeight ?? this.itemHeight,
      title: title ?? this.title,
      selectBackgroundWidget: selectBackgroundWidget ?? this.selectBackgroundWidget,
      pickerPadding: pickerPadding ?? this.pickerPadding,
    );
  }
}
