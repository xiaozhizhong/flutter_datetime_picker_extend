import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_extend/src/calendar_date.dart';
import 'package:flutter_datetime_picker_extend/src/helper/date_helper.dart';

///
///@author shaw
///@date 2021/2/25
///@desc 日历辅助 Helper for calendar
///
class CalendarHelper {
  CalendarHelper._();

  static const lunarMonthLeapStringPrefix = "闰";
  static const lunarMonthStringList = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一", "十二"];
  static const lunarDayStringList = [
    '初一',
    '初二',
    '初三',
    '初四',
    '初五',
    '初六',
    '初七',
    '初八',
    '初九',
    '初十',
    '十一',
    '十二',
    '十三',
    '十四',
    '十五',
    '十六',
    '十七',
    '十八',
    '十九',
    '二十',
    '廿一',
    '廿二',
    '廿三',
    '廿四',
    '廿五',
    '廿六',
    '廿七',
    '廿八',
    '廿九',
    '三十'
  ];

  /// Get year list in [minYear]-[maxYear], eg: [2020,2021]
  static List<int> yearList({@required int maxYear, @required int minYear}) {
    assert(maxYear != null && minYear != null, "maxYear & minYear must not be null");
    return List.generate(maxYear - minYear + 1, (index) => minYear + index);
  }

  /// Get month list in this [currentYear],
  /// eg: [
  /// CalendarMonth(1,isLunar:false),
  /// CalendarMonth(2,isLunar:false),
  /// CalendarMonth(2,isLunar:true)
  /// ]
  static List<CalendarMonth> monthList(
      {@required bool isLunar, @required int currentYear, @required CalendarDate maxDate, @required CalendarDate minDate}) {
    CalendarMonth minMonth =
        currentYear <= minDate.year ? CalendarMonth(minDate.month, isLunarLeap: minDate.isLunarLeap) : CalendarMonth.min();
    CalendarMonth maxMonth = currentYear >= maxDate.year
        ? CalendarMonth(maxDate.month, isLunarLeap: maxDate.isLunarLeap)
        : CalendarMonth.max(year: currentYear, isLunar: isLunar);
    if (isLunar) {
      final leapMonth = DateHelper.lunarLeapMonth(currentYear);
      return monthsIn(minMonth, maxMonth, leapMonth);
    } else {
      return monthsIn(minMonth, maxMonth, 0);
    }
  }

  /// Get month in [from] - [to]
  static List<CalendarMonth> monthsIn(CalendarMonth from, CalendarMonth to, int leapMonth) {
    if (from == to) return [from];
    if (leapMonth != 0) {
      CalendarMonth leap = CalendarMonth(leapMonth, isLunarLeap: true);
      if (leap == from) {
        // eg: 闰11-12 -> 闰11,12
        return List.generate(to.month - from.month + 1, (index) => CalendarMonth(from.month + index, isLunarLeap: index == 0));
      } else if (leap > from && leap < to) {
        // eg: 2,闰2，3，4
        final list = List<CalendarMonth>.generate(to.month - from.month + 1, (index) => CalendarMonth(from.month + index));
        final index = list.indexWhere((element) => element.month == leapMonth);
        list.insert(index + 1, CalendarMonth(leapMonth, isLunarLeap: true));
        return list;
      } else if (leap == to) {
        // eg: 11-闰12 -> 11,12,闰12
        final length = to.month - from.month + 2;
        return List.generate(
            length,
            (index) => index == length - 1
                ? CalendarMonth(to.month, isLunarLeap: true)
                : CalendarMonth(from.month + index, isLunarLeap: false));
      }
    }
    return List.generate(to.month - from.month + 1, (index) => CalendarMonth(from.month + index));
  }

  /// Get month list in this [currentYear], eg: [1,2,3]
  /// If [isLunar] and contains leap month, the lunar leap month was negative, eg: [1,2,-2,3]
  static List<int> monthListInInt(
      {@required bool isLunar, @required int currentYear, @required CalendarDate maxDate, @required CalendarDate minDate}) {
    return monthList(isLunar: isLunar, currentYear: currentYear, maxDate: maxDate, minDate: minDate)
        .map((e) => e.isLunarLeap ? -e.month : e.month)
        .toList();
  }

  /// Get day list in this [currentYear][currentMonth], eg: [1,2,3,4,5,6,7,8]
  static List<int> dayList(
      {@required bool isLunar,
      @required int currentYear,
      @required CalendarMonth currentMonth,
      @required CalendarDate maxDate,
      @required CalendarDate minDate}) {
    int minDay =
        minDate.year == currentYear && minDate.month == currentMonth.month && minDate.isLunarLeap == currentMonth.isLunarLeap
            ? minDate.day
            : 1;
    int maxDay =
        maxDate.year == currentYear && maxDate.month == currentMonth.month && maxDate.isLunarLeap == currentMonth.isLunarLeap
            ? maxDate.day
            : isLunar
                ? DateHelper.lunarMonthDays(currentYear, currentMonth.month, currentMonth.isLunarLeap)
                : DateHelper.solarMonthDays(currentYear, currentMonth.month);
    return List.generate(maxDay - minDay + 1, (index) => minDay + index);
  }

  /// 农历月份中文描述 eg：二/闰二
  static String lunarMonthString(int month, bool isLeap) {
    return "${isLeap ? lunarMonthLeapStringPrefix : ''}${lunarMonthStringList[month - 1]}月";
  }

  /// 农历日子中文描述 eg：初一
  static String lunarDayString(int day) {
    return "${lunarDayStringList[day - 1]}";
  }
}
