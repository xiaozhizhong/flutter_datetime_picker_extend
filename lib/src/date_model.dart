import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_extend/src/date_format.dart';
import 'package:flutter_datetime_picker_extend/src/calendar_date.dart';
import 'package:flutter_datetime_picker_extend/src/helper/calendar_helper.dart';
import 'package:flutter_datetime_picker_extend/src/i18n_model.dart';
import 'datetime_util.dart';
import 'dart:math';

//interface for picker data model
abstract class BasePickerModel {
  //a getter method for column data, return null to end list
  String getStringAtIndex(int column, int index);

  //set selected index
  void onSetIndex(int column, int index);

//return current index
  int currentIndex(int column);

  //return final time
  CalendarDate finalTime();

  //return divider string
  String getDivider(int column);

  //layout proportions for columns
  List<int> layoutProportions();

  int columnLength = 3;

  VoidCallback onForceRefresh;

  LocaleType locale;
}

//a base class for picker data model
class CommonPickerModel extends BasePickerModel {
  List<List<String>> list;
  DateTime currentTime;
  List<int> _currentIndices;
  LocaleType locale;

  CommonPickerModel({this.currentTime, locale}) : this.locale = locale ?? LocaleType.en {
    this._currentIndices = List.filled(columnLength, 0);
    list = List(columnLength);
  }

  @override
  String getStringAtIndex(int column, int index) {
    return null;
  }

  @override
  int currentIndex(int column) {
    return _currentIndices[column];
  }

  @override
  void onSetIndex(int column, int index) {
    _currentIndices[column] = index;
  }

  @override
  String getDivider(int column) {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  CalendarDate finalTime() {
    return null;
  }

  bool isAtSameDay(DateTime day1, DateTime day2) {
    return day1 != null && day2 != null && day1
        .difference(day2)
        .inDays == 0 && day1.day == day2.day;
  }
}

//a date picker model
class DatePickerModel extends CommonPickerModel {
  DateTime maxTime;
  DateTime minTime;

  DatePickerModel({DateTime currentTime, DateTime maxTime, DateTime minTime, LocaleType locale}) : super(locale: locale) {
    this.maxTime = maxTime ?? DateTime(2049, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();
    if (currentTime != null) {
      if (currentTime.compareTo(this.maxTime) > 0) {
        currentTime = this.maxTime;
      } else if (currentTime.compareTo(this.minTime) < 0) {
        currentTime = this.minTime;
      }
    }
    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentIndices[0] = this.currentTime.year - this.minTime.year;
    _currentIndices[1] = this.currentTime.month - minMonth;
    _currentIndices[2] = this.currentTime.day - minDay;
  }

  void _fillLeftLists() {
    this.list[0] = List.generate(maxTime.year - minTime.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year && currentTime.month == maxTime.month ? maxTime.day : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year && currentTime.month == minTime.month ? minTime.day : 1;
  }

  void _fillMiddleLists() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();

    this.list[1] = List.generate(maxMonth - minMonth + 1, (int index) {
      return '${_localeMonth(minMonth + index)}';
    });
  }

  void _fillRightLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    this.list[2] = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  @override
  void onSetIndex(int column, int index) {
    super.onSetIndex(column, index);
    switch (column) {
      case 0:
        _set1stIndex(index);
        break;
      case 1:
        _set2stIndex(index);
        break;
        break;
      case 2:
        _set3stIndex(index);
        break;
    }
  }

  void _set1stIndex(int index) {
    //adjust middle
    int destYear = index + minTime.year;
    int minMonth = _minMonthOfCurrentYear();
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
        destYear,
        currentTime.month,
        calcDateCount(destYear, 2),
      )
          : DateTime(
        destYear,
        currentTime.month,
        calcDateCount(destYear, 2),
      );
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(
        destYear,
        currentTime.month,
        currentTime.day,
      )
          : DateTime(
        destYear,
        currentTime.month,
        currentTime.day,
      );
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillRightLists();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentIndices[1] = currentTime.month - minMonth;
    _currentIndices[2] = currentTime.day - minDay;
  }

  void _set2stIndex(int index) {
    //adjust right
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    )
        : DateTime(
      currentTime.year,
      destMonth,
      currentTime.day <= dayCount ? currentTime.day : dayCount,
    );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillRightLists();
    int minDay = _minDayOfCurrentMonth();
    _currentIndices[2] = currentTime.day - minDay;
  }

  void _set3stIndex(int index) {
    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(
      currentTime.year,
      currentTime.month,
      minDay + index,
    )
        : DateTime(
      currentTime.year,
      currentTime.month,
      minDay + index,
    );
  }

  @override
  String getStringAtIndex(int column, int index) {
    if (index >= 0 && index < list[column].length) {
      return list[column][index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      List monthStrings = i18nObjInLocale(locale)['monthLong'];
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  CalendarDate finalTime() {
    return CalendarDate.fromDateTime(currentTime, isLunar: false);
  }
}

//a time picker model
class TimePickerModel extends CommonPickerModel {
  bool showSecondsColumn;

  TimePickerModel({DateTime currentTime, LocaleType locale, this.showSecondsColumn: true}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentIndices[0] = this.currentTime.hour;
    _currentIndices[1] = this.currentTime.minute;
    _currentIndices[2] = this.currentTime.second;
  }

  String _firstStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  String _secondStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  String _thirdStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String getStringAtIndex(int column, int index) {
    switch (column) {
      case 0:
        return _firstStringAtIndex(index);
        break;
      case 1:
        return _secondStringAtIndex(index);
        break;
      case 2:
        return _thirdStringAtIndex(index);
        break;
      default:
        return null;
    }
  }

  @override
  String getDivider(int column) {
    if (column == 0) {
      return ":";
    } else {
      if (showSecondsColumn)
        return ":";
      else
        return "";
    }
  }

  @override
  List<int> layoutProportions() {
    if (showSecondsColumn)
      return [1, 1, 1];
    else
      return [1, 1, 0];
  }

  @override
  CalendarDate finalTime() {
    return currentTime.isUtc
        ? CalendarDate.fromDateTime(
        DateTime.utc(
            currentTime.year, currentTime.month, currentTime.day, _currentIndices[0], _currentIndices[1], _currentIndices[2]),
        isLunar: false)
        : CalendarDate.fromDateTime(
        DateTime(
            currentTime.year, currentTime.month, currentTime.day, _currentIndices[0], _currentIndices[1], _currentIndices[2]),
        isLunar: false);
  }
}

//a time picker model
class Time12hPickerModel extends CommonPickerModel {
  Time12hPickerModel({DateTime currentTime, LocaleType locale}) : super(locale: locale) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentIndices[0] = this.currentTime.hour % 12;
    _currentIndices[1] = this.currentTime.minute;
    _currentIndices[2] = this.currentTime.hour < 12 ? 0 : 1;
  }

  String _firstStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      if (index == 0) {
        return digits(12, 2);
      } else {
        return digits(index, 2);
      }
    } else {
      return null;
    }
  }

  String _secondStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  String _thirdStringAtIndex(int index) {
    if (index == 0) {
      return i18nObjInLocale(this.locale)["am"];
    } else if (index == 1) {
      return i18nObjInLocale(this.locale)["pm"];
    } else {
      return null;
    }
  }

  @override
  String getStringAtIndex(int column, int index) {
    switch (column) {
      case 0:
        return _firstStringAtIndex(index);
        break;
      case 0:
        return _secondStringAtIndex(index);
        break;
      case 0:
        return _thirdStringAtIndex(index);
        break;
      default:
        return "";
    }
  }

  @override
  String getDivider(int column) {
    return ":";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  CalendarDate finalTime() {
    int hour = _currentIndices[0] + 12 * _currentIndices[2];
    return currentTime.isUtc
        ? CalendarDate.fromDateTime(
        DateTime.utc(currentTime.year, currentTime.month, currentTime.day, hour, _currentIndices[1], 0),
        isLunar: false)
        : CalendarDate.fromDateTime(DateTime(currentTime.year, currentTime.month, currentTime.day, hour, _currentIndices[1], 0),
        isLunar: false);
  }
}

// a date&time picker model
class DateTimePickerModel extends CommonPickerModel {
  DateTime maxTime;
  DateTime minTime;

  DateTimePickerModel({DateTime currentTime, DateTime maxTime, DateTime minTime, LocaleType locale}) : super(locale: locale) {
    if (currentTime != null) {
      this.currentTime = currentTime;
      if (maxTime != null && (currentTime.isBefore(maxTime) || currentTime.isAtSameMomentAs(maxTime))) {
        this.maxTime = maxTime;
      }
      if (minTime != null && (currentTime.isAfter(minTime) || currentTime.isAtSameMomentAs(minTime))) {
        this.minTime = minTime;
      }
    } else {
      this.maxTime = maxTime;
      this.minTime = minTime;
      var now = DateTime.now();
      if (this.minTime != null && this.minTime.isAfter(now)) {
        this.currentTime = this.minTime;
      } else if (this.maxTime != null && this.maxTime.isBefore(now)) {
        this.currentTime = this.maxTime;
      } else {
        this.currentTime = now;
      }
    }

    if (this.minTime != null && this.maxTime != null && this.maxTime.isBefore(this.minTime)) {
      // invalid
      this.minTime = null;
      this.maxTime = null;
    }

    _currentIndices[0] = 0;
    _currentIndices[1] = this.currentTime.hour;
    _currentIndices[2] = this.currentTime.minute;
    if (this.minTime != null && isAtSameDay(this.minTime, this.currentTime)) {
      _currentIndices[1] = this.currentTime.hour - this.minTime.hour;
      if (_currentIndices[1] == 0) {
        _currentIndices[2] = this.currentTime.minute - this.minTime.minute;
      }
    }
  }

  void _set1stIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));
    if (isAtSameDay(minTime, time)) {
      var index = min(24 - minTime.hour - 1, _currentIndices[1]);
      this._set2stIndex(index);
    } else if (isAtSameDay(maxTime, time)) {
      var index = min(maxTime.hour, _currentIndices[1]);
      this._set2stIndex(index);
    }
  }

  void _set2stIndex(int index) {
    DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
    if (isAtSameDay(minTime, time) && index == 0) {
      var maxIndex = 60 - minTime.minute - 1;
      if (_currentIndices[2] > maxIndex) {
        _currentIndices[2] = maxIndex;
      }
    } else if (isAtSameDay(maxTime, time) && _currentIndices[1] == maxTime.hour) {
      var maxIndex = maxTime.minute;
      if (_currentIndices[2] > maxIndex) {
        _currentIndices[2] = maxIndex;
      }
    }
  }

  @override
  void onSetIndex(int column, int index) {
    super.onSetIndex(column, index);
    if (column == 0) {
      _set1stIndex(index);
    } else {
      _set2stIndex(index);
    }
  }

  String _firstStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));
    if (minTime != null && time.isBefore(minTime) && !isAtSameDay(minTime, time)) {
      return null;
    } else if (maxTime != null && time.isAfter(maxTime) && !isAtSameDay(maxTime, time)) {
      return null;
    }
    return formatDate(time, [ymdw], locale);
  }

  String _secondStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
      if (isAtSameDay(minTime, time)) {
        if (index >= 0 && index < 24 - minTime.hour) {
          return digits(minTime.hour + index, 2);
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time)) {
        if (index >= 0 && index <= maxTime.hour) {
          return digits(index, 2);
        } else {
          return null;
        }
      }
      return digits(index, 2);
    }

    return null;
  }

  String _thirdStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
      if (isAtSameDay(minTime, time) && _currentIndices[1] == 0) {
        if (index >= 0 && index < 60 - minTime.minute) {
          return digits(minTime.minute + index, 2);
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time) && _currentIndices[1] >= maxTime.hour) {
        if (index >= 0 && index <= maxTime.minute) {
          return digits(index, 2);
        } else {
          return null;
        }
      }
      return digits(index, 2);
    }

    return null;
  }

  @override
  String getStringAtIndex(int column, int index) {
    switch (column) {
      case 0:
        return _firstStringAtIndex(index);
        break;
      case 1:
        return _secondStringAtIndex(index);
        break;
      case 2:
        return _thirdStringAtIndex(index);
        break;
      default:
        return "";
    }
  }

  @override
  CalendarDate finalTime() {
    DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
    var hour = _currentIndices[1];
    var minute = _currentIndices[2];
    if (isAtSameDay(minTime, time)) {
      hour += minTime.hour;
      if (minTime.hour == hour) {
        minute += minTime.minute;
      }
    }

    return currentTime.isUtc
        ? CalendarDate.fromDateTime(DateTime.utc(time.year, time.month, time.day, hour, minute), isLunar: false)
        : CalendarDate.fromDateTime(DateTime(time.year, time.month, time.day, hour, minute), isLunar: false);
  }

  @override
  List<int> layoutProportions() {
    return [4, 1, 1];
  }

  @override
  String getDivider(int column) {
    if (column == 1) return ":";
    return "";
  }
}


//a base class for picker data model
class CommonFullPickerModel extends BasePickerModel {
  List<List> list;
  List<int> _currentIndices;

  LocaleType locale;

  List get yearList => list[0];

  set yearList(List newList) => list[0] = newList;

  List get monthList => list[1];

  set monthList(List newList) => list[1] = newList;

  List get dayList => list[2];

  set dayList(List newList) => list[2] = newList;

  List get hourList => list[3];

  set hourList(List newList) => list[3] = newList;

  List get minuteList => list[4];

  set minuteList(List newList) => list[4] = newList;

  int get yearIndex => _currentIndices[0];

  set yearIndex(int newIndex) => _currentIndices[0] = newIndex;

  int get monthIndex => _currentIndices[1];

  set monthIndex(int newIndex) => _currentIndices[1] = newIndex;

  int get dayIndex => _currentIndices[2];

  set dayIndex(int newIndex) => _currentIndices[2] = newIndex;

  int get hourIndex => _currentIndices[3];

  set hourIndex(int newIndex) => _currentIndices[3] = newIndex;

  int get minuteIndex => _currentIndices[4];

  set minuteIndex(int newIndex) => _currentIndices[4] = newIndex;

  CommonFullPickerModel({locale}) : this.locale = locale ?? LocaleType.en {
    this._currentIndices = List.filled(columnLength, 0);
    list = List(columnLength);
  }

  @override
  String getStringAtIndex(int column, int index) {
    return null;
  }

  @override
  int currentIndex(int column) {
    return _currentIndices[column];
  }

  @override
  void onSetIndex(int column, int index) {
    _currentIndices[column] = index;
  }

  @override
  String getDivider(int column) {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  CalendarDate finalTime() {
    return null;
  }

  bool isAtSameDay(DateTime day1, DateTime day2) {
    return day1 != null && day2 != null && day1
        .difference(day2)
        .inDays == 0 && day1.day == day2.day;
  }
}

class FullDateTimePickerModelWithLunar extends CommonFullPickerModel {
  FullDateTimePickerModelWithLunar(
      {this.initCurrentDateTime, this.initMaxDateTime, this.initMinDateTime, LocaleType locale, this.lunarType = false})
      : super(locale: locale) {
    _init(initCurrentDateTime, initMaxDateTime, initMinDateTime);
  }

  /// initialize data
  final CalendarDate initCurrentDateTime, initMaxDateTime, initMinDateTime;

  /// current date and calculated max and min date
  CalendarDate currentDateTime, maxDateTime, minDateTime;

  ///是否农历
  bool lunarType;

  /// Toggle lunar/solar type
  toggleCalendarType() {
    this.lunarType = !this.lunarType;
    _init(initCurrentDateTime, initMaxDateTime, initMinDateTime);
    onForceRefresh?.call();
  }

  @override
  int columnLength = 5;

  /// Do init
  _init(CalendarDate initCurrentTime, CalendarDate initMaxTime, CalendarDate initMinTime) {
    // set to default if value is null
    CalendarDate currentTime = initCurrentTime ?? CalendarDate.fromDateTime(DateTime.now(), isLunar: false);
    CalendarDate maxTime = initMaxTime ?? CalendarDate.solar(year: 2049, month: 12, day: 31);
    CalendarDate minTime = initMinTime ?? CalendarDate.solar(year: 1970, month: 1, day: 1);

    // convert if initTime type not equal current lunarType
    if (initCurrentTime.isLunar != lunarType) {
      currentTime = currentTime.convert;
    }
    if (initMaxTime.isLunar != lunarType) {
      maxTime = maxTime.convert;
    }
    if (initMinTime.isLunar != lunarType) {
      minTime = minTime.convert;
    }

    // compare currentTime with min & max time
    if (currentTime > maxTime)
      currentTime = maxTime;
    else if (currentTime < minTime) currentTime = minTime;

    this.currentDateTime = currentTime.copyWith();
    this.maxDateTime = maxTime.copyWith();
    this.minDateTime = minTime.copyWith();

    //init date list
    _fillYearList();
    _fillMonthList();
    _fillDayList();
    _fillHourList();
    _fillMinuteList();

    //set index to currentDateTime
    yearIndex = yearList.indexWhere((element) => element == currentDateTime.year);
    final calendarMonth = CalendarMonth.fromCalendarDate(currentDateTime);
    monthIndex = monthList.indexWhere((element) => calendarMonth == element);
    dayIndex = dayList.indexWhere((element) => element == currentDateTime.day);
    hourIndex = hourList.indexWhere((element) => element == currentDateTime.hour);
    minuteIndex = minuteList.indexWhere((element) => element == currentDateTime.minute);
  }

  void _fillYearList() {
    this.yearList = CalendarHelper.yearList(maxYear: this.maxDateTime.year, minYear: this.minDateTime.year);
    print("fillyear");
    print(yearList);
    print(currentDateTime);
    print(maxDateTime);
    print(minDateTime);
  }

  void _fillMonthList() {
    this.monthList = CalendarHelper.monthList(
        isLunar: this.lunarType, currentYear: this.currentDateTime.year, maxDate: this.maxDateTime, minDate: this.minDateTime);
    print("fillMonth");
    print(monthList);
    print(currentDateTime);
    print(maxDateTime);
    print(minDateTime);
  }

  void _fillDayList() {
    this.dayList = CalendarHelper.dayList(
        isLunar: lunarType,
        currentYear: currentDateTime.year,
        currentMonth: CalendarMonth.fromCalendarDate(currentDateTime),
        maxDate: this.maxDateTime,
        minDate: this.minDateTime);
    print("fillDay");
    print(dayList);
    print(currentDateTime);
    print(maxDateTime);
    print(minDateTime);
  }

  void _fillHourList() {
    this.hourList = List.generate(24, (index) => index);
  }

  void _fillMinuteList() {
    this.minuteList = List.generate(60, (index) => index);
  }

  @override
  void onSetIndex(int column, int index) {
    super.onSetIndex(column, index);
    switch (column) {
      case 0:
        _setYearIndex(index);
        break;
      case 1:
        _setMonthIndex(index);
        break;
        break;
      case 2:
        _setDayIndex(index);
        break;
      case 3:
        _setHourIndex(index);
        break;
      case 4:
        _setMinuteIndex(index);
        break;
    }
  }

  void _resetMonths() {
    _fillMonthList();
    final lastIndex = monthList.indexWhere((element) => element.month == currentDateTime.month);
    if (lastIndex != -1) {
      //reset month to last index
      monthIndex = lastIndex;
      _refreshCurrentDateTime();
    } else if (monthIndex > monthList.length - 1) {
      //set monthIndex to max index of new month list
      monthIndex = monthList.length - 1;
      _refreshCurrentDateTime();
    }
  }

  void _resetDays() {
    _fillDayList();
    final lastIndex = dayList.indexWhere((element) => element == currentDateTime.day);
    if (lastIndex != -1) {
      //reset day to last index
      dayIndex = lastIndex;
      _refreshCurrentDateTime();
    } else if (dayIndex > dayList.length - 1) {
      //set dayIndex to max index of new day list
      dayIndex = dayList.length - 1;
      _refreshCurrentDateTime();
    }
  }

  _refreshCurrentDateTime() {
    CalendarMonth calendarMonth = monthList[monthIndex];
    currentDateTime
      ..year = yearList[yearIndex]
      ..month = calendarMonth.month
      ..isLunarLeap = calendarMonth.isLunarLeap
      ..day = dayList[dayIndex];
  }

  void _setYearIndex(int index) {
    if (index < 0 || index > yearList.length - 1) return;
    currentDateTime.year = yearList[index];
    _resetMonths();
    _resetDays();
  }

  void _setMonthIndex(int index) {
    if (index < 0 || index > monthList.length - 1) return;
    CalendarMonth calendarMonth = monthList[index];
    currentDateTime
      ..month = calendarMonth.month
      ..isLunarLeap = calendarMonth.isLunarLeap;
    _resetDays();
  }

  void _setDayIndex(int index) {
    if (index < 0 || index > dayList.length - 1) return;
    currentDateTime.day = dayList[index];
  }

  void _setHourIndex(int index) {
    if (index < 0 || index > hourList.length - 1) return;
    currentDateTime.hour = hourList[index];
  }

  void _setMinuteIndex(int index) {
    if (index < 0 || index > minuteList.length - 1) return;
    currentDateTime.minute = minuteList[index];
  }

  /// 2020年
  String _yearStringAtIndex(int index) {
    if (index > yearList.length - 1) return null;
    return "${yearList[index]}${_localeYear()}";
  }

  /// 十一月/11月
  String _monthStringAtIndex(int index) {
    if (index > monthList.length - 1) return null;
    CalendarMonth calendarMonth = monthList[index];
    if (lunarType) return CalendarHelper.lunarMonthString(calendarMonth.month, calendarMonth.isLunarLeap);
    return "${_localeMonth(calendarMonth.month)}";
  }

  /// 初一/01日
  String _dayStringAtIndex(int index) {
    if (index > dayList.length - 1) return null;
    final day = dayList[index];
    return lunarType ? CalendarHelper.lunarDayString(day) : "${digits(day, 2)}${_localeDay()}";
  }

  /// 01时/01点
  String _hourStringAtIndex(int index) {
    if (index > hourList.length - 1) return null;
    return "${digits(hourList[index], 2)}${_localHour()}";
  }

  /// 01分
  String _minuteStringAtIndex(int index) {
    if (index > minuteList.length - 1) return null;
    return "${digits(minuteList[index], 2)}${_localMinute()}";
  }

  @override
  String getStringAtIndex(int column, int index) {
    print("getStringAtIndex:$column  $index");
    if (index < 0) return null;
    switch (column) {
      case 0:
        return _yearStringAtIndex(index);
        break;
      case 1:
        final string =  _monthStringAtIndex(index);
        print(string);
        return string;
        //todo
        // return _monthStringAtIndex(index);
        break;
      case 2:
        return _dayStringAtIndex(index);
        break;
      case 3:
        return _hourStringAtIndex(index);
        break;
      case 4:
        return _minuteStringAtIndex(index);
        break;
      default:
        return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '${digits(month, 2)}月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      List monthStrings = i18nObjInLocale(locale)['monthLong'];
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  String _localHour() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return lunarType ? "时" : "点";
    } else {
      return '';
    }
  }

  String _localMinute() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '分';
    } else {
      return '';
    }
  }

  @override
  CalendarDate finalTime() {
    return currentDateTime;
  }

  @override
  List<int> layoutProportions() {
    return [3, 3, 2, 2, 2];
  }
}
