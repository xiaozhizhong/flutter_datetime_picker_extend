import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_extend/src/helper/date_helper.dart';
import 'package:flutter_datetime_picker_extend/src/helper/lunar_solar_converter.dart';

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

  ///农历、新历互转
  CalendarDate get convert {
    if (this.isLunar)
      return LunarSolarConverter.lunarToSolar(this);
    else
      return LunarSolarConverter.solarToLunar(this);
  }

  DateTime get toDateTime => DateTime(this.year, this.month, this.day, this.hour, this.minute, this.second);

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

  @override
  bool operator <(CalendarMonth another) {
    if (this.isLunarLeap == another.isLunarLeap || this.month!=another.month) return this.month < another.month;
    return another.isLunarLeap ? true : false;
  }

  @override
  bool operator >(CalendarMonth another) {
    if (this.isLunarLeap == another.isLunarLeap || this.month!=another.month) return this.month > another.month;
    return this.isLunarLeap ? true : false;
  }

  @override
  bool operator ==(Object other) {
    if (other is CalendarMonth) {
      return this.isLunarLeap == other.isLunarLeap && this.month == other.month;
    }
    return false;
  }

  @override
  String toString() {
    return "month: $month isLunarLeap:$isLunarLeap";
  }
}
