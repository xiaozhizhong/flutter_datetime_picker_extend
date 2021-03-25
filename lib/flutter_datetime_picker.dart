library flutter_datetime_picker_extend;

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_extend/src/datetime_picker_theme.dart';
import 'package:flutter_datetime_picker_extend/src/date_model.dart';
import 'package:flutter_datetime_picker_extend/src/model/calendar_date.dart';
import 'package:flutter_datetime_picker_extend/src/widget/single_touch_recognizer_widget.dart';
import 'package:flutter_datetime_picker_extend/src/widget/cupertino_picker.dart' as cupertinoPicker;
import 'src/model/i18n_model.dart';

export 'package:flutter_datetime_picker_extend/src/datetime_picker_theme.dart';
export 'package:flutter_datetime_picker_extend/src/date_model.dart';

typedef DateChangedCallback(CalendarDate time);
typedef DateCancelledCallback();
typedef String StringAtIndexCallBack(int index);

class DatePicker {
  // ///
  // /// Display date picker bottom sheet.
  // ///
  // static Future<DateTime> showDatePicker(
  //   BuildContext context, {
  //   bool showTitleActions: true,
  //   DateTime minTime,
  //   DateTime maxTime,
  //   DateChangedCallback onChanged,
  //   DateChangedCallback onConfirm,
  //   DateCancelledCallback onCancel,
  //   locale: LocaleType.en,
  //   DateTime currentTime,
  //   DatePickerTheme theme,
  // }) async {
  //   return await Navigator.push(
  //     context,
  //     _DatePickerRoute(
  //       showTitleActions: showTitleActions,
  //       onChanged: onChanged,
  //       onConfirm: onConfirm,
  //       onCancel: onCancel,
  //       locale: locale,
  //       theme: theme,
  //       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //       pickerModel: DatePickerModel(
  //         currentTime: currentTime,
  //         maxTime: maxTime,
  //         minTime: minTime,
  //         locale: locale,
  //       ),
  //     ),
  //   );
  // }
  //
  // ///
  // /// Display time picker bottom sheet.
  // ///
  // static Future<DateTime> showTimePicker(
  //   BuildContext context, {
  //   bool showTitleActions: true,
  //   bool showSecondsColumn: true,
  //   DateChangedCallback onChanged,
  //   DateChangedCallback onConfirm,
  //   DateCancelledCallback onCancel,
  //   locale: LocaleType.en,
  //   DateTime currentTime,
  //   DatePickerTheme theme,
  // }) async {
  //   return await Navigator.push(
  //     context,
  //     _DatePickerRoute(
  //       showTitleActions: showTitleActions,
  //       onChanged: onChanged,
  //       onConfirm: onConfirm,
  //       onCancel: onCancel,
  //       locale: locale,
  //       theme: theme,
  //       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //       pickerModel: TimePickerModel(
  //         currentTime: currentTime,
  //         locale: locale,
  //         showSecondsColumn: showSecondsColumn,
  //       ),
  //     ),
  //   );
  // }
  //
  // ///
  // /// Display time picker bottom sheet with AM/PM.
  // ///
  // static Future<DateTime> showTime12hPicker(
  //   BuildContext context, {
  //   bool showTitleActions: true,
  //   DateChangedCallback onChanged,
  //   DateChangedCallback onConfirm,
  //   DateCancelledCallback onCancel,
  //   locale: LocaleType.en,
  //   DateTime currentTime,
  //   DatePickerTheme theme,
  // }) async {
  //   return await Navigator.push(
  //     context,
  //     _DatePickerRoute(
  //       showTitleActions: showTitleActions,
  //       onChanged: onChanged,
  //       onConfirm: onConfirm,
  //       onCancel: onCancel,
  //       locale: locale,
  //       theme: theme,
  //       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //       pickerModel: Time12hPickerModel(
  //         currentTime: currentTime,
  //         locale: locale,
  //       ),
  //     ),
  //   );
  // }
  //
  // ///
  // /// Display date&time picker bottom sheet.
  // ///
  // static Future<DateTime> showDateTimePicker(
  //   BuildContext context, {
  //   bool showTitleActions: true,
  //   DateTime minTime,
  //   DateTime maxTime,
  //   DateChangedCallback onChanged,
  //   DateChangedCallback onConfirm,
  //   DateCancelledCallback onCancel,
  //   locale: LocaleType.en,
  //   DateTime currentTime,
  //   DatePickerTheme theme,
  // }) async {
  //   return await Navigator.push(
  //     context,
  //     _DatePickerRoute(
  //       showTitleActions: showTitleActions,
  //       onChanged: onChanged,
  //       onConfirm: onConfirm,
  //       onCancel: onCancel,
  //       locale: locale,
  //       theme: theme,
  //       barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  //       pickerModel: DateTimePickerModel(
  //         currentTime: currentTime,
  //         minTime: minTime,
  //         maxTime: maxTime,
  //         locale: locale,
  //       ),
  //     ),
  //   );
  // }
  //

  ///
  /// Display date&time picker bottom sheet.
  ///
  static Future<CalendarDate> showFullDateTimePicker(BuildContext context, {
    bool showTitleActions: true,
    CalendarDate minTime,
    CalendarDate maxTime,
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
    DateCancelledCallback onCancel,
    locale: LocaleType.en,
    CalendarDate currentTime,
    DatePickerTheme theme,
    bool isLunar = false,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel: MaterialLocalizations
            .of(context)
            .modalBarrierDismissLabel,
        pickerModel: FullDateTimePickerModelWithLunar(
            initCurrentDateTime: currentTime,
            initMinDateTime: minTime,
            initMaxDateTime: maxTime,
            locale: locale,
            lunarType: isLunar),
      ),
    );
  }

  ///
  /// Display date picker bottom sheet witch custom picker model.
  ///
  static Future<CalendarDate> showPicker(BuildContext context, {
    bool showTitleActions: true,
    DateChangedCallback onChanged,
    DateChangedCallback onConfirm,
    DateCancelledCallback onCancel,
    locale: LocaleType.en,
    BasePickerModel pickerModel,
    DatePickerTheme theme,
  }) async {
    return await Navigator.push(
      context,
      _DatePickerRoute(
        showTitleActions: showTitleActions,
        onChanged: onChanged,
        onConfirm: onConfirm,
        onCancel: onCancel,
        locale: locale,
        theme: theme,
        barrierLabel: MaterialLocalizations
            .of(context)
            .modalBarrierDismissLabel,
        pickerModel: pickerModel..locale = locale,
      ),
    );
  }
}

class _DatePickerRoute<T> extends PopupRoute<T> {
  _DatePickerRoute({
    this.showTitleActions,
    this.onChanged,
    this.onConfirm,
    this.onCancel,
    theme,
    this.barrierLabel,
    this.locale,
    RouteSettings settings,
    pickerModel,
  })
      : this.pickerModel = pickerModel ?? DatePickerModel(),
        this.theme = theme ?? DatePickerTheme(),
        super(settings: settings);

  final bool showTitleActions;
  final DateChangedCallback onChanged;
  final DateChangedCallback onConfirm;
  final DateCancelledCallback onCancel;
  final DatePickerTheme theme;
  final LocaleType locale;
  final BasePickerModel pickerModel;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController = BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _DatePickerComponent(
        onChanged: onChanged,
        locale: this.locale,
        route: this,
        pickerModel: pickerModel,
      ),
    );
    return InheritedTheme.captureAll(context, bottomSheet);
  }
}

class _DatePickerComponent extends StatefulWidget {
  _DatePickerComponent({
    Key key,
    @required this.route,
    this.onChanged,
    this.locale,
    this.pickerModel,
  }) : super(key: key);

  final DateChangedCallback onChanged;

  final _DatePickerRoute route;

  final LocaleType locale;

  final BasePickerModel pickerModel;

  @override
  State<StatefulWidget> createState() {
    return _DatePickerState();
  }
}

class _DatePickerState extends State<_DatePickerComponent> {
  List<FixedExtentScrollController> scrollCtrlList;
  int refreshValue = 0;

  @override
  void initState() {
    super.initState();
    refreshScrollOffset();
    widget.pickerModel.onForceRefresh = _forceRefresh;
  }

  _forceRefresh() {
    setState(() {
      refreshScrollOffset();
      refreshValue++;
    });
  }

  void refreshScrollOffset() {
    scrollCtrlList = List.generate(widget.pickerModel.columnLength,
            (index) => FixedExtentScrollController(initialItem: widget.pickerModel.currentIndex(index)));
  }

  @override
  Widget build(BuildContext context) {
    DatePickerTheme theme = widget.route.theme;
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation,
        builder: (BuildContext context, Widget child) {
          final double bottomPadding = MediaQuery
              .of(context)
              .padding
              .bottom;
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(
                widget.route.animation.value,
                theme,
                showTitleActions: widget.route.showTitleActions,
                bottomPadding: bottomPadding,
              ),
              child: GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: _renderPickerView(theme),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _notifyDateChanged() {
    if (widget.onChanged != null) {
      widget.onChanged(widget.pickerModel.finalTime());
    }
  }

  Widget _renderPickerView(DatePickerTheme theme) {
    Widget itemView = _renderItemView(theme);
    if (widget.route.showTitleActions) {
      return Column(
        children: <Widget>[
          _renderTitleActionsView(theme),
          Expanded(child: itemView),
        ],
      );
    }
    return itemView;
  }

  Widget _renderColumnView({ValueKey key,
    DatePickerTheme theme,
    StringAtIndexCallBack stringAtIndexCB,
    ScrollController scrollController,
    ValueChanged<int> selectedChangedWhenScrolling,
    ValueChanged<int> selectedChangedWhenScrollEnd,
    double offAxisFraction}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      height: theme.containerHeight,
      // decoration: BoxDecoration(color: theme.backgroundColor ?? Colors.white),
      child: NotificationListener(
        onNotification: (ScrollNotification notification) {
          if (notification.depth == 0 &&
              selectedChangedWhenScrollEnd != null &&
              notification is ScrollEndNotification &&
              notification.metrics is FixedExtentMetrics) {
            final FixedExtentMetrics metrics = notification.metrics;
            final int currentItemIndex = metrics.itemIndex;
            selectedChangedWhenScrollEnd(currentItemIndex);
          }
          return false;
        },
        child: cupertinoPicker.CupertinoPicker.builder(
            key: key,
            //backgroundColor: theme.backgroundColor ?? Colors.white,
            offAxisFraction: offAxisFraction,
            scrollController: scrollController,
            itemExtent: theme.itemHeight,
            onSelectedItemChanged: (int index) {
              selectedChangedWhenScrolling(index);
            },
            magnification: 1.1,
            itemBuilder: (BuildContext context, int index) {
              final content = stringAtIndexCB(index);
              if (content == null) {
                return null;
              }
              return Container(
                height: theme.itemHeight,
                alignment: Alignment.center,
                child: Text(
                  content,
                  style: theme.itemStyle,
                  textAlign: TextAlign.start,
                ),
              );
            }),
      ),
    );
  }

  Widget _renderItemView(DatePickerTheme theme) {
    return SingleTouchRecognizerWidget(
      child: Container(
        color: theme.backgroundColor ?? Colors.white,
        child: Stack(
          children: [

            ///selectBackgroundWidget
            if (theme.selectBackgroundWidget != null) theme.selectBackgroundWidget,

            ///内容
            Padding(
              padding: theme.pickerPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ...List.generate(widget.pickerModel.columnLength, (column) {
                    if (widget.pickerModel.layoutProportions()[column] <= 0) return SizedBox();

                    final view = _renderColumnView(
                        key: ValueKey(_IndexKey(
                            refreshValue: this.refreshValue,
                            length: widget.pickerModel.list[column].length,
                            parentIndex: widget.pickerModel.currentIndex(column == 0 ? 0 : column - 1))),
                        theme: theme,
                        stringAtIndexCB: (int index) => widget.pickerModel.getStringAtIndex(column, index),
                        scrollController: scrollCtrlList[column],
                        selectedChangedWhenScrolling: (index) => widget.pickerModel.onSetIndex(column, index),
                        selectedChangedWhenScrollEnd: (index) {
                          setState(() {
                            refreshScrollOffset();
                            _notifyDateChanged();
                          });
                        },
                        offAxisFraction: _buildOffAxisFraction(column));

                    final expandWrapper =
                        (Widget child) => Expanded(flex: widget.pickerModel.layoutProportions()[column], child: child);

                    if (column == widget.pickerModel.columnLength - 1) {
                      return expandWrapper(view);
                    }
                    final divider = Text(
                      widget.pickerModel.getDivider(column),
                      style: theme.itemStyle,
                    );

                    return expandWrapper(Row(children: [Expanded(child: view), divider]));
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  double _buildOffAxisFraction(int column) {
    switch (widget.pickerModel.columnLength) {
      case 1:
        return 0;
        break;
      case 2:
        return column == 0 ? -5 : 5;
      case 3:
        if (column == 0)
          return -3;
        else if (column == 1)
          return 0;
        else
          return 3;
        break;
      case 4:
        if (column == 0)
          return -0.5;
        else if (column == 1)
          return -0.25;
        else if (column == 2)
          return 0.25;
        else
          return 0.5;
        break;
      case 5:
        if (column == 0)
          return -0.5;
        else if (column == 1)
          return -0.25;
        else if (column == 2)
          return 0;
        else if (column == 3)
          return 0.25;
        else
          return 0.5;
        break;
      default:
        return 0;
    }
  }

  // Title View
  Widget _renderTitleActionsView(DatePickerTheme theme) {
    final done = _localeDone();
    final cancel = _localeCancel();

    return Container(
      height: theme.titleHeight,
      decoration: ShapeDecoration(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        color: theme.headerColor ?? theme.backgroundColor ?? Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: EdgeInsets.only(left: 16, top: 0),
              child: Text(
                '$cancel',
                style: theme.cancelStyle,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (widget.route.onCancel != null) {
                  widget.route.onCancel();
                }
              },
            ),
          ),
          Expanded(child: theme.title != null ? Center(child: theme.title) : SizedBox()),
          Container(
            height: theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: EdgeInsets.only(right: 16, top: 0),
              child: Text(
                '$done',
                style: theme.doneStyle,
              ),
              onPressed: () {
                Navigator.pop(context, widget.pickerModel.finalTime());
                if (widget.route.onConfirm != null) {
                  widget.route.onConfirm(widget.pickerModel.finalTime());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _localeDone() {
    return i18nObjInLocale(widget.locale)['done'];
  }

  String _localeCancel() {
    return i18nObjInLocale(widget.locale)['cancel'];
  }
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress,
      this.theme, {
        this.itemCount,
        this.showTitleActions,
        this.bottomPadding = 0,
      });

  final double progress;
  final int itemCount;
  final bool showTitleActions;
  final DatePickerTheme theme;
  final double bottomPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = theme.containerHeight;
    if (showTitleActions) {
      maxHeight += theme.titleHeight;
    }

    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight + bottomPadding,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

class _IndexKey {
  _IndexKey({@required this.length, @required this.parentIndex, @required this.refreshValue});

  final int length;
  final int parentIndex;
  final int refreshValue;

  @override
  bool operator ==(Object other) =>
      other is _IndexKey && runtimeType == other.runtimeType && length == other.length && parentIndex == other.parentIndex &&
          refreshValue == other.refreshValue;

  @override
  int get hashCode => length.hashCode ^ parentIndex.hashCode ^ refreshValue.hashCode;


}
