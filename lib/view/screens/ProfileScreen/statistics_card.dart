import 'package:flutter/material.dart';
import 'package:history_of_me/controller/database/hive_query_controller.dart';
import 'package:history_of_me/controller/localization/hom_localizations.dart';
import 'package:lit_ui_kit/lit_ui_kit.dart';

class StatisticsCard extends StatefulWidget {
  @override
  _StatisticsCardState createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  late HiveQueryController queryController;

  @override
  void initState() {
    queryController = HiveQueryController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isAvailable = queryController.totalDiaryEntries > 0;
    return LitGradientCard(
      margin: EdgeInsets.symmetric(
        horizontal: isAvailable ? 18.0 : 24.0,
        vertical: isAvailable ? 12.0 : 16.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isAvailable ? 18.0 : 24.0,
        vertical: isAvailable ? 12.0 : 16.0,
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(
          15.0,
        ),
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: 8.0,
          color: Colors.black26,
          offset: Offset(
            2.0,
            2.0,
          ),
          spreadRadius: 1.0,
        ),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        isAvailable ? Colors.white : HexColor('#FFFBF4'),
        isAvailable ? HexColor('#F1F0F0') : HexColor('#FFFBFB'),
      ],
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 192.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledDownText(
              HOMLocalizations(context).statistics,
              textAlign: TextAlign.start,
              style: LitTextStyles.sansSerif.copyWith(
                fontSize: 22.0,
                color: HexColor('#878787'),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.35,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 16.0,
              ),
              child: isAvailable
                  ? _StatisticDataList(
                      queryController: queryController,
                    )
                  : _NoDataAvailableInfo(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDataAvailableInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                ExclamationRectangle(
                  width: constraints.maxWidth * 0.25,
                  height: constraints.maxWidth * 0.25,
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.75,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: Text(
                      HOMLocalizations(context).statisticsFallbackDescr,
                      textAlign: TextAlign.left,
                      style: LitTextStyles.sansSerif.copyWith(
                        color: HexColor('#8A8A8A'),
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                HOMLocalizations(context).statisticsFallbackAdv,
                textAlign: TextAlign.left,
                style: LitTextStyles.sansSerif.copyWith(
                  color: HexColor('#8A8A8A'),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatisticDataList extends StatelessWidget {
  final HiveQueryController queryController;

  const _StatisticDataList({
    Key? key,
    required this.queryController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EntryStatisticText(
          label: HOMLocalizations(context).diaryEntries,
          value: "${queryController.totalDiaryEntries}",
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).wordsWritten,
          value: "${queryController.totalWordsWritten}",
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).wordsPerEntry,
          value: "${queryController.avgWordWritten.toStringAsFixed(2)}",
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).mostWordsWrittenAtOnce,
          value: "${queryController.mostWordsWrittenAtOnce}",
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).fewestWordsAtOnce,
          value: "${queryController.leastWordsWrittenAtOnce}",
        ),
        _EntryStatisticRichText(
          label: HOMLocalizations(context).entriesThisWeek,
          value: "${queryController.entriesThisWeek}",
          maxValue: "7",
        ),
        _EntryStatisticRichText(
          label: HOMLocalizations(context).entriesThisMonth,
          value: "${queryController.entriesThisMonth}",
          maxValue: "${DateTime.now().lastDayOfMonth()}",
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).latestEntry,
          value: queryController.latestEntryDate.formatAsLocalizedDate(context),
        ),
        _EntryStatisticText(
          label: HOMLocalizations(context).firstEntry,
          value: queryController.firstEntryDate.formatAsLocalizedDate(context),
        ),
      ],
    );
  }
}

class _EntryStatistic extends StatelessWidget {
  final String label;
  final Widget value;

  const _EntryStatistic({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 2.2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClippedText(
            label,
            textAlign: TextAlign.start,
            style: LitTextStyles.sansSerif.copyWith(
              fontSize: 16.0,
              color: HexColor('#cccccc'),
            ),
          ),
          value,
        ],
      ),
    );
  }
}

class _EntryStatisticText extends StatelessWidget {
  final String label;
  final String value;

  const _EntryStatisticText({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _EntryStatistic(
      label: label,
      value: ClippedText(
        value,
        textAlign: TextAlign.start,
        style: LitTextStyles.sansSerif.copyWith(
          fontSize: 16.0,
          color: HexColor('#878787'),
        ),
      ),
    );
  }
}

class _EntryStatisticRichText extends StatelessWidget {
  final String label;
  final String value;
  final String maxValue;
  const _EntryStatisticRichText({
    Key? key,
    required this.label,
    required this.value,
    required this.maxValue,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _EntryStatistic(
      label: label,
      value: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            value,
            style: LitTextStyles.sansSerif.copyWith(
              fontSize: 16.0,
              color: HexColor('#878787'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 2.0,
            ),
            child: Text(
              "/",
              style: LitTextStyles.sansSerif.copyWith(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: HexColor('#CEC8CF'),
              ),
            ),
          ),
          Text(
            maxValue,
            style: LitTextStyles.sansSerif.copyWith(
              fontSize: 16.0,
              color: HexColor('#BEBABF'),
            ),
          ),
        ],
      ),
    );
  }
}
