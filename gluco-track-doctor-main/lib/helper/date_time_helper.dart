import 'package:intl/intl.dart';

class DateTimeHelper {
  static String getDayName(int day) {
    switch (day) {
      case 1:
        {
          return "Thứ Hai";
        }
      case 2:
        {
          return "Thứ Ba";
        }
      case 3:
        {
          return "Thứ Tư";
        }
      case 4:
        {
          return "Thứ Năm";
        }
      case 5:
        {
          return "Thứ Sáu";
        }
      case 6:
        {
          return "Thứ Bảy";
        }
      case 7:
        {
          return "Chủ Nhật";
        }
      default:
        {
          return "--";
        }
    }
  }

  static getDataFormatWithTime(String? createdAt) {
    String dateString = "";
    final newData = DateTime.parse(createdAt ?? "");
    dateString =
        "${newData.day} ${getMonthName(newData.month)}, ${newData.year} ${formattedTime(newData)}";
    return dateString;
  }

  static String formattedTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  static String convertTo12HourFormat(String time24) {
    List<String> parts = time24.split(":");
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    String period = hour < 12 ? 'SA' : 'CH';
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  static String getDataFormat(String? createdAt) {
    String dateString = "";
    final newData = DateTime.parse(createdAt ?? "");
    dateString = "${newData.day} ${getMonthName(newData.month)}, ${newData.year}";
    return dateString;
  }

  static String getYYYMMDDFormatDate(String dateString) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(dateString);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    return formattedDate; // Output: 2024-02-13
  }

  static String getMonthName(int monthCode) {
    switch (monthCode) {
      case 1:
        {
          return "Tháng 1";
        }
      case 2:
        {
          return "Tháng 2";
        }
      case 3:
        {
          return "Tháng 3";
        }
      case 4:
        {
          return "Tháng 4";
        }
      case 5:
        {
          return "Tháng 5";
        }
      case 6:
        {
          return "Tháng 6";
        }
      case 7:
        {
          return "Tháng 7";
        }
      case 8:
        {
          return "Tháng 8";
        }
      case 9:
        {
          return "Tháng 9";
        }
      case 10:
        {
          return "Tháng 10";
        }
      case 11:
        {
          return "Tháng 11";
        }
      case 12:
        {
          return "Tháng 12";
        }
      default:
        {
          return "";
        }
    }
  }

  static String getTodayDateInString() {
    final dateParse = DateFormat('yyyy-MM-dd').parse((DateTime.now().toString()));
    return getYYYMMDDFormatDate(dateParse.toString());
  }

  static String getTodayTimeInString() {
    return DateFormat('hh:mm').format(DateTime.now());
  }

  static int calculateAge(String dob) {
    DateTime birthDate = DateTime.parse(dob);
    DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;

    // Check if birthday has occurred this year or not
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
