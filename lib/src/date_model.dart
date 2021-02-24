import 'package:flutter_datetime_picker_extend/src/date_format.dart';
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
  DateTime finalTime();

  //return divider string
  String getDivider(int column);

  //layout proportions for columns
  List<int> layoutProportions();

  int columnLength = 3;
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
  DateTime finalTime() {
    return null;
  }

  bool isAtSameDay(DateTime day1, DateTime day2) {
    return day1 != null && day2 != null && day1.difference(day2).inDays == 0 && day1.day == day2.day;
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
  DateTime finalTime() {
    return currentTime;
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
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year, currentTime.month, currentTime.day, _currentIndices[0], _currentIndices[1], _currentIndices[2])
        : DateTime(
            currentTime.year, currentTime.month, currentTime.day, _currentIndices[0], _currentIndices[1], _currentIndices[2]);
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
  DateTime finalTime() {
    int hour = _currentIndices[0] + 12 * _currentIndices[2];
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day, hour, _currentIndices[1], 0)
        : DateTime(currentTime.year, currentTime.month, currentTime.day, hour, _currentIndices[1], 0);
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
  DateTime finalTime() {
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
        ? DateTime.utc(time.year, time.month, time.day, hour, minute)
        : DateTime(time.year, time.month, time.day, hour, minute);
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

class FullDateTimePickerModel extends CommonPickerModel {
  DateTime maxTime;
  DateTime minTime;

  @override
  int columnLength = 5;

  FullDateTimePickerModel({DateTime currentTime, DateTime maxTime, DateTime minTime, LocaleType locale}) : super(locale: locale) {
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

    //init date
    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentIndices[0] = this.currentTime.year - this.minTime.year;
    _currentIndices[1] = this.currentTime.month - minMonth;
    _currentIndices[2] = this.currentTime.day - minDay;

    //init time
    _currentIndices[3] = this.currentTime.hour;
    _currentIndices[4] = this.currentTime.minute;
    if (this.minTime != null && isAtSameDay(this.minTime, this.currentTime)) {
      _currentIndices[3] = this.currentTime.hour - this.minTime.hour;
      if (_currentIndices[3] == 0) {
        _currentIndices[4] = this.currentTime.minute - this.minTime.minute;
      }
    }
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

  String _hourStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
      if (isAtSameDay(minTime, time)) {
        if (index >= 0 && index < 24 - minTime.hour) {
          return digits(minTime.hour + index, 2) + _localHour();
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time)) {
        if (index >= 0 && index <= maxTime.hour) {
          return digits(index, 2) +_localHour();
        } else {
          return null;
        }
      }
      return digits(index, 2) +_localHour();
    }

    return null;
  }

  String _minuteStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      DateTime time = currentTime.add(Duration(days: _currentIndices[0]));
      if (isAtSameDay(minTime, time) && _currentIndices[1] == 0) {
        if (index >= 0 && index < 60 - minTime.minute) {
          return digits(minTime.minute + index, 2) + _localMinute();
        } else {
          return null;
        }
      } else if (isAtSameDay(maxTime, time) && _currentIndices[1] >= maxTime.hour) {
        if (index >= 0 && index <= maxTime.minute) {
          return digits(index, 2)+ _localMinute();
        } else {
          return null;
        }
      }
      return digits(index, 2)+ _localMinute();
    }

    return null;
  }

  @override
  String getStringAtIndex(int column, int index) {
    if (column == 3) return _hourStringAtIndex(index);
    if (column == 4) return _minuteStringAtIndex(index);

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

  String _localHour() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '时';
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
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, currentTime.day, _currentIndices[3], _currentIndices[4])
        : DateTime(currentTime.year, currentTime.month, currentTime.day, _currentIndices[3], _currentIndices[4]);
  }

  @override
  List<int> layoutProportions() {
    return [3, 2, 2, 2, 2];
  }
}
