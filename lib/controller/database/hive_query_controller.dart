import 'package:history_of_me/controller/database/hive_db_service.dart';
import 'package:history_of_me/model/diary_entry.dart';
import 'package:history_of_me/lit_ui_kit_temp/util/datetime_validation.dart';

class HiveQueryController {
  /// The [HiveDBService] instance to query the database.
  final HiveDBService _service = HiveDBService();

  /// The cached [DiaryEntry] results.
  final List<DiaryEntry> _diaryEntries = List<DiaryEntry>();

  static const Pattern _pattern = " ";

  /// Query all [DiaryEntry] objects and store them in the [_diaryEntries] cache.
  void _queryDiaryEntries() {
    _service.getDiaryEntries().value.values.forEach((entry) {
      _diaryEntries.add(entry);
    });
  }

  /// Returns the total number of all diary entries.
  int get totalDiaryEntries {
    return _diaryEntries.length;
  }

  /// Returns the total number of words written in all diary entries.
  int get totalWordsWritten {
    String entryContentString = "";
    _diaryEntries.forEach((entry) {
      entryContentString = entryContentString + " ${entry.content}";
    });
    List<String> words = entryContentString.split(_pattern);
    return words.length;
  }

  /// Returns the calculated average number of words written per diary entry.
  double get avgWordWritten {
    return (totalWordsWritten / totalDiaryEntries);
  }

  String _getContentExtreme(bool max) {
    String content = _diaryEntries[0].content;

    _diaryEntries.forEach((entry) {
      bool maxCondition = entry.content.length > content.length;
      bool minCondition = entry.content.length < content.length;
      bool splitCondition = (entry.content.split(_pattern).length > 0);
      if ((max ? maxCondition : minCondition) && splitCondition) {
        content = entry.content;
      }
      if (!max) {
        print(entry.content.length);
      }
    });

    return content;
  }

  /// Returns the total number of words written on the largest diary entry.
  int get mostWordsWrittenAtOnce {
    return _getContentExtreme(true).split(_pattern).length;
  }

  /// Returns the total number of words written on the largest diary entry.
  int get leastWordsWrittenAtOnce {
    return _getContentExtreme(false).length;
  }

  int get entriesThisWeek {
    int entriesThisWeek = 0;
    DateTime now = DateTime.now();

    _diaryEntries.forEach((entry) {
      DateTime entryDate = DateTime.parse(entry.date);
      if (now.isSameCalendarWeek(entryDate)) {
        entriesThisWeek++;
      }
    });

    return entriesThisWeek;
  }

  int get entriesThisMonth {
    int entriesThisMonth = 0;

    DateTime now = DateTime.now();

    _diaryEntries.forEach((entry) {
      DateTime entryDate = DateTime.parse(entry.date);

      if (now.isSameCalendarMonth(entryDate)) {
        entriesThisMonth++;
      }
    });
    return entriesThisMonth;
  }

  DateTime get latestEntryDate {
    DateTime latest = DateTime.parse(_diaryEntries[0].date);
    _diaryEntries.forEach(
      (entry) {
        DateTime entryDate = DateTime.parse(entry.date);
        if (entryDate.isAfter(latest)) {
          latest = entryDate;
        }
      },
    );
    return latest;
  }

  DateTime get firstEntryDate {
    DateTime first = DateTime.parse(_diaryEntries[0].date);
    _diaryEntries.forEach(
      (entry) {
        DateTime entryDate = DateTime.parse(entry.date);
        if (entryDate.isBefore(first)) {
          first = entryDate;
        }
      },
    );
    return first;
  }

  int sortEntriesByDateAscending(dynamic a, dynamic b) {
    DateTime dateTimeA = DateTime.parse(a.date);
    DateTime dateTimeB = DateTime.parse(b.date);
    return dateTimeB.compareTo(dateTimeA);
  }

  int sortEntriesByDateDescending(dynamic a, dynamic b) {
    DateTime dateTimeA = DateTime.parse(a.date);
    DateTime dateTimeB = DateTime.parse(b.date);
    return dateTimeA.compareTo(dateTimeB);
  }

  List<dynamic> get diaryEntriesSorted {
    return _diaryEntries
      ..sort(HiveQueryController().sortEntriesByDateDescending);
  }

  int getIndexChronologically(DiaryEntry diaryEntry) {
    return diaryEntriesSorted.indexOf(diaryEntry);
  }

  int getIndexChronologicallyByUID(String diaryEntryUID) {
    dynamic diaryEntry = diaryEntriesSorted
        .where((dynamic element) => element.uid == diaryEntryUID)
        .first;
    return getIndexChronologically(diaryEntry);
  }

  // bool previousEntryExists(DiaryEntry diaryEntry) {
  //   return getIndexChronologically(diaryEntry) > 0;
  // }

  bool previousEntryExistsByUID(String diaryEntryUID) {
    return getIndexChronologicallyByUID(diaryEntryUID) > 0;
  }

  // bool nextEntryExists(DiaryEntry diaryEntry) {
  //   return getIndexChronologically(diaryEntry) <
  //       (diaryEntriesSorted.length - 1);
  // }

  bool nextEntryExistsByUID(String diaryEntryUID) {
    return getIndexChronologicallyByUID(diaryEntryUID) <
        (diaryEntriesSorted.length - 1);
  }

  // DiaryEntry getPreviousDiaryEntry(int currentIndex) {
  //   return diaryEntriesSorted[currentIndex - 1];
  // }

  DiaryEntry getPreviousDiaryEntry(DiaryEntry diaryEntry) {
    return previousEntryExistsByUID(diaryEntry.uid)
        ? diaryEntriesSorted[getIndexChronologicallyByUID(diaryEntry.uid) - 1]
        : diaryEntry;
  }

  DiaryEntry getNextDiaryEntry(DiaryEntry diaryEntry) {
    return nextEntryExistsByUID(diaryEntry.uid)
        ? diaryEntriesSorted[getIndexChronologicallyByUID(diaryEntry.uid) + 1]
        : diaryEntry;
  }

  /// Initializes the [HiveQueryController].
  void _init() {
    _queryDiaryEntries();
  }

  /// Creates a [HiveQueryController].
  ///
  /// The instance will query the [DiaryEntry] box on start.
  HiveQueryController() {
    _init();
  }
}
