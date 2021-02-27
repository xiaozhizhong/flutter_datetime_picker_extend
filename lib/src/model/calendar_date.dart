import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_extend/src/helper/date_helper.dart';
import 'package:flutter_datetime_picker_extend/src/helper/lunar_solar_converter.dart';
import 'package:tuple/tuple.dart';

///
///@author shaw
///@date 2021/2/25
///@desc 阳历、农历
///
class CalendarDate {
  CalendarDate(
      {@required this.year,
      @required this.month,
      @required this.day,
      @required this.isLunar,
      this.isLunarLeap = false,
      this.hour = 0,
      this.minute = 0,
      this.second = 0});

  CalendarDate.solar(
      {@required this.year, @required this.month, @required this.day, this.hour = 0, this.minute = 0, this.second = 0})
      : this.isLunar = false,
        this.isLunarLeap = false;

  CalendarDate.lunar(
      {@required this.year,
      @required this.month,
      @required this.day,
      @required this.isLunarLeap,
      this.hour = 0,
      this.minute = 0,
      this.second = 0})
      : this.isLunar = true;

  CalendarDate.fromDateTime(DateTime dateTime, {@required this.isLunar, this.isLunarLeap = false})
      : this.year = dateTime.year,
        this.month = dateTime.month,
        this.day = dateTime.day,
        this.hour = dateTime.hour,
        this.minute = dateTime.minute,
        this.second = dateTime.second;

  int year;
  int month;
  int day;
  bool isLunar;
  bool isLunarLeap;
  int hour;
  int minute;
  int second;

  /// Solar now
  static CalendarDate get nowSolar {
    return CalendarDate.fromDateTime(DateTime.now(), isLunar: false);
  }

  /// Lunar now
  static CalendarDate get nowLunar {
    return LunarSolarConverter.solarToLunar(nowSolar);
  }

  /// Convert between lunar and solar
  CalendarDate get convert {
    if (this.isLunar)
      return LunarSolarConverter.lunarToSolar(this);
    else
      return LunarSolarConverter.solarToLunar(this);
  }

  /// To dateTime, no convert
  DateTime get toDateTime => DateTime(this.year, this.month, this.day, this.hour, this.minute, this.second);

  /// To solar dateTime
  DateTime get toDateTimeSolar {
    if (this.isLunar) return LunarSolarConverter.lunarToSolar(this).toDateTime;
    return toDateTime;
  }

  /// To lunar dateTime
  /// return Tuple2<dateTime,isLunarLeap>
  Tuple2<DateTime, bool> get toDateTimeLunar {
    CalendarDate calendarDate = this.isLunar ? this : LunarSolarConverter.solarToLunar(this);
    return Tuple2(calendarDate.toDateTime, calendarDate.isLunarLeap);
  }

  bool operator >(CalendarDate another) {
    assert(this.isLunar == another.isLunar, "calendar type must the same when compare two CalendarDate");
    if (this.year != another.year) {
      return this.year > another.year;
    }
    if (this.month != another.month) {
      return this.month > another.month;
    }
    if (this.isLunarLeap != another.isLunarLeap) {
      return this.isLunarLeap;
    }
    if (this.day != another.day) {
      return this.day > another.day;
    }
    if (this.hour != another.hour) {
      return this.hour > another.hour;
    }
    if (this.minute != another.minute) {
      return this.minute > another.minute;
    }
    if (this.second != another.second) {
      return this.second > another.second;
    }
    return false;
  }

  bool operator <(CalendarDate another) {
    assert(this.isLunar == another.isLunar, "calendar type must the same when compare two CalendarDate");
    if (this.year != another.year) {
      return this.year < another.year;
    }
    if (this.month != another.month) {
      return this.month < another.month;
    }
    if (this.isLunarLeap != another.isLunarLeap) {
      return !this.isLunarLeap;
    }
    if (this.day != another.day) {
      return this.day < another.day;
    }
    if (this.hour != another.hour) {
      return this.hour < another.hour;
    }
    if (this.minute != another.minute) {
      return this.minute < another.minute;
    }
    if (this.second != another.second) {
      return this.second < another.second;
    }
    return false;
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarDate &&
      runtimeType == other.runtimeType &&
      year == other.year &&
      month == other.month &&
      day == other.day &&
      isLunar == other.isLunar &&
      isLunarLeap == other.isLunarLeap &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second;

  @override
  int get hashCode =>
      year.hashCode ^
      month.hashCode ^
      day.hashCode ^
      isLunar.hashCode ^
      isLunarLeap.hashCode ^
      hour.hashCode ^
      minute.hashCode ^
      second.hashCode;

  CalendarDate copyWith({
    int year,
    int month,
    int day,
    bool isLunar,
    bool isLunarLeap,
    int hour,
    int minute,
    int second,
  }) {
    return CalendarDate(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      isLunar: isLunar ?? this.isLunar,
      isLunarLeap: isLunarLeap ?? this.isLunarLeap,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  @override
  String toString() {
    return "${isLunar ? "lunar" : "solar"} ${isLunarLeap ? "leap" : ''} ${this.year}-${this.month}-${this.day} ${this.hour}:${this.minute}:${this.second}";
  }
}

/// Calendar month support lunar leap
class CalendarMonth {
  CalendarMonth(this.month, {this.isLunarLeap = false});

  CalendarMonth.fromCalendarDate(CalendarDate date)
      : this.month = date.month,
        this.isLunarLeap = date.isLunarLeap;

  final int month;
  final bool isLunarLeap;

  /// Get min month of every year
  static CalendarMonth min() => CalendarMonth(1, isLunarLeap: false);

  /// Get max month of [year]
  static CalendarMonth max({@required int year, @required bool isLunar}) {
    if (isLunar && DateHelper.lunarLeapMonth(year) == 12) {
      return CalendarMonth(12, isLunarLeap: true);
    }
    return CalendarMonth(12, isLunarLeap: false);
  }

  bool operator <(CalendarMonth another) {
    if (this.isLunarLeap == another.isLunarLeap || this.month != another.month) return this.month < another.month;
    return another.isLunarLeap ? true : false;
  }

  bool operator >(CalendarMonth another) {
    if (this.isLunarLeap == another.isLunarLeap || this.month != another.month) return this.month > another.month;
    return this.isLunarLeap ? true : false;
  }

  @override
  bool operator ==(Object other) =>
      other is CalendarMonth && runtimeType == other.runtimeType && month == other.month && isLunarLeap == other.isLunarLeap;

  @override
  int get hashCode => month.hashCode ^ isLunarLeap.hashCode;

  @override
  String toString() {
    return "month: $month isLunarLeap:$isLunarLeap";
  }
}
