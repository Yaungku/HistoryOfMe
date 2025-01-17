import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:history_of_me/controller/database/hive_db_service.dart';
import 'package:history_of_me/controller/database/hive_query_controller.dart';
import 'package:history_of_me/controller/routes/hom_navigator.dart';
import 'package:history_of_me/localization.dart';
import 'package:history_of_me/model/backdrop_photo.dart';
import 'package:history_of_me/model/diary_entry.dart';
import 'package:history_of_me/view/shared/art/ellipse_icon.dart';
import 'package:hive/hive.dart';
import 'package:leitmotif/leitmotif.dart';

import 'backdrop_photo_overlay.dart';
import 'change_photo_dialog.dart';
import 'entry_detail_backdrop.dart';
import 'entry_detail_card.dart';

class EntryDetailScreen extends StatefulWidget {
  //final int index;
  //final DiaryEntry diaryEntry;
  final int listIndex;
  final String? diaryEntryUid;
  // final double portraitPhotoHeight;
  // final double landscapePhotoHeight;

  const EntryDetailScreen({
    Key? key,
    required this.listIndex,
    required this.diaryEntryUid,

    //@required this.index,
    //@required this.diaryEntry,
    // this.portraitPhotoHeight = 2.9,
    // this.landscapePhotoHeight = 1.5,
  }) : super(key: key);

  @override
  _EntryDetailScreenState createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen>
    with TickerProviderStateMixin {
  bool? backdropPhotosLoading;
  List<BackdropPhoto> backdropPhotos = [];
  ScrollController? _scrollController;
  late LitSettingsPanelController _settingsPanelController;
  HiveQueryController? _hiveQueryController;
  late HOMNavigator _screenRouter;

  // final List<String> imageNames = [
  //   "assets/images/niilo-isotalo--BZc9Ee1qo0-unsplash.jpg",
  //   "assets/images/peiwen-yu-Etpd8Le6b8E-unsplash.jpg"
  // ];

  void parseBackdropPhotos(String assetData) {
    final parsed = jsonDecode(assetData).cast<Map<String, dynamic>>();
    parsed.forEach((json) =>
        setState(() => backdropPhotos.add(BackdropPhoto.fromJson(json))));
    print(backdropPhotos.length);
    setState(() {
      backdropPhotosLoading = false;
    });
    // return parsed
    //     .map<void>((json) => backdropPhotos.add(BackdropPhoto.fromJson(json)));
  }

  Future<void> loadPhotosFromJson() async {
    String data =
        await rootBundle.loadString('assets/json/image_collection_data.json');

    return parseBackdropPhotos(data);
  }

  void _showChangePhotoDialog(DiaryEntry diaryEntry) {
    showDialog(
      context: context,
      builder: (_) => ChangePhotoDialog(
        backdropPhotos: backdropPhotos,
        diaryEntry: diaryEntry,
        // imageNames: imageNames,
      ),
    );
  }

  void _onDeleteEntry() {
    LitRouteController(context).clearNavigationStack();
    HiveDBService().deleteDiaryEntry(widget.diaryEntryUid);
  }

  void _showConfirmDeleteDialog() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        onDelete: _onDeleteEntry,
      ),
      // ConfirmDeleteEntryDialog(
      //   //index: widget.index,
      //   diaryEntryUid: widget.diaryEntryUid,
      // ),
    );
  }

  bool _shouldShowNextButton(DiaryEntry diaryEntry) {
    return _hiveQueryController!.nextEntryExistsByUID(diaryEntry.uid);
  }

  bool _shouldShowPreviousButton(DiaryEntry diaryEntry) {
    return _hiveQueryController!.previousEntryExistsByUID(diaryEntry.uid);
  }

  void _onEdit(DiaryEntry diaryEntry) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => EntryEditingScreen(
    //       diaryEntry: diaryEntry,
    //       //index: widget.index,
    //     ),
    //   ),
    // );
    // Widget widget = EntryEditingScreen(
    //   diaryEntry: diaryEntry,
    //   //index: widget.index,
    // );
    // _routeController.pushWidgetToStack(widget);
    _screenRouter.toEntryEditingScreen(diaryEntry: diaryEntry);
  }

  void _onNextPressed(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) {
        LitRouteController(context).replaceCurrentCupertinoWidget(
          newWidget: EntryDetailScreen(
            // Decrease the index by one to artificially lower the total entries count
            // and therefore increase the entries number on the label text.
            listIndex: widget.listIndex,
            diaryEntryUid:
                _hiveQueryController!.getNextDiaryEntry(diaryEntry).uid,
          ),
        );
      },
    );
  }

  void _onPreviousPressed(DiaryEntry diaryEntry) {
    Future.delayed(LitAnimationDurations.button).then(
      (_) {
        LitRouteController(context).replaceCurrentCupertinoWidget(
          newWidget: EntryDetailScreen(
            // Increase the index by one to artificially higher the total entries count
            // and therefore lower the entries number on the label text.
            listIndex: widget.listIndex,
            diaryEntryUid:
                _hiveQueryController!.getPreviousDiaryEntry(diaryEntry).uid,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    backdropPhotosLoading = true;
    loadPhotosFromJson();

    _scrollController = ScrollController();
    _settingsPanelController = LitSettingsPanelController();
    _hiveQueryController = HiveQueryController();
    _screenRouter = HOMNavigator(context);
  }

  @override
  void dispose() {
    _scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(backdropPhotosLoading);
    return ValueListenableBuilder(
      valueListenable: HiveDBService().getDiaryEntries(),
      builder: (BuildContext context, Box<DiaryEntry> entriesBox, Widget? _) {
        final DiaryEntry? diaryEntry = entriesBox.get(widget.diaryEntryUid);

        /// Verify the entry has not been deleted yet.
        if (diaryEntry != null) {
          final int lastIndex = (entriesBox.length - 1);

          final bool _isFirst = entriesBox.getAt(0)!.uid == diaryEntry.uid;
          final bool _isLast =
              entriesBox.getAt(lastIndex)!.uid == diaryEntry.uid;

          return LitScaffold(
            // wrapInSafeArea: false,
            appBar: FixedOnScrollTitledAppbar(
              scrollController: _scrollController,
              title: diaryEntry.title != ""
                  ? diaryEntry.title
                  : AppLocalizations.of(context).untitledLabel,
            ),
            settingsPanel: LitSettingsPanel(
              height: 128.0,
              controller: _settingsPanelController,
              title: AppLocalizations.of(context).optionsLabel,
              children: [
                // LitPushedThroughButton(
                //   accentColor: LitColors.red400,
                //   backgroundColor: LitColors.red200,
                //   child: ClippedText(
                //     HOMLocalizations(context).delete.toUpperCase(),
                //     style: LitTextStyles.sansSerifStyles[button].copyWith(
                //       color: Colors.white,
                //     ),
                //   ),
                //   onPressed: _showConfirmEntryDeletionCallback,
                // ),
                LitDeleteButton(
                  onPressed: _showConfirmDeleteDialog,
                ),
              ],
            ),
            body: LayoutBuilder(builder: (context, constraints) {
              return Container(
                child: Stack(
                  children: [
                    EntryDetailBackdrop(
                      backdropPhotos: backdropPhotos,
                      loading: backdropPhotosLoading,
                      diaryEntry: diaryEntry,
                    ),
                    LitScrollbar(
                      child: ScrollableColumn(
                        controller: _scrollController,
                        children: [
                          BackdropPhotoOverlay(
                            scrollController: _scrollController,
                            showChangePhotoDialogCallback: () =>
                                _showChangePhotoDialog(diaryEntry),
                            backdropPhotos: backdropPhotos,
                            loading: backdropPhotosLoading,
                            diaryEntry: diaryEntry,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          EntryDetailCard(
                            boxLength: entriesBox.length,
                            listIndex: widget.listIndex,
                            isFirst: _isFirst,
                            isLast: _isLast,
                            diaryEntry: diaryEntry,
                            onEdit: () => _onEdit(diaryEntry),
                            queryController: _hiveQueryController,
                          ),
                          _EntryDetailFooter(
                            showNextButton: _shouldShowNextButton(diaryEntry),
                            showPreviousButton:
                                _shouldShowPreviousButton(diaryEntry),
                            onPreviousPressed: () =>
                                _onPreviousPressed(diaryEntry),
                            onNextPressed: () => _onNextPressed(diaryEntry),
                            moreOptionsPressed:
                                _settingsPanelController.showSettingsPanel,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class _EntryDetailFooter extends StatelessWidget {
  final void Function() moreOptionsPressed;
  final bool showPreviousButton;
  final bool showNextButton;
  final void Function() onPreviousPressed;
  final void Function() onNextPressed;
  final List<BoxShadow> buttonBoxShadow;
  const _EntryDetailFooter({
    Key? key,
    required this.moreOptionsPressed,
    required this.showPreviousButton,
    required this.showNextButton,
    required this.onPreviousPressed,
    required this.onNextPressed,
    this.buttonBoxShadow = const [
      const BoxShadow(
        blurRadius: 6.0,
        color: Colors.black26,
        offset: Offset(2, 2),
        spreadRadius: -1.0,
      )
    ],
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 72.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            LitColors.lightGrey,
            Colors.white,
          ],
          stops: [
            0.00,
            0.87,
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            offset: Offset(0, -2),
            color: Colors.black12,
            spreadRadius: 1.0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                showPreviousButton
                    ? _BottomNavButton(
                        isPrevious: true,
                        onPressed: onPreviousPressed,
                      )
                    : SizedBox(),
                showNextButton
                    ? Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                        ),
                        child: _BottomNavButton(
                          isPrevious: false,
                          onPressed: onNextPressed,
                        ))
                    : SizedBox()
              ],
            ),
            LitPushedThroughButton(
              boxShadow: buttonBoxShadow,

              margin: LitEdgeInsets.button * 1.5,
              child: EllipseIcon(
                animated: false,
                dotColor: Colors.white,
              ),
              accentColor: LitColors.grey200,
              //baackgroundColor: HexColor('#CCCCCC'),
              backgroundColor: LitColors.grey100,
              onPressed: moreOptionsPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// A button enabling to navigate between all available diary entries.
class _BottomNavButton extends StatelessWidget {
  final bool isPrevious;
  final void Function() onPressed;

  const _BottomNavButton({
    Key? key,
    required this.isPrevious,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8.0,
      ),
      child: LitPushedThroughButton(
        // boxShadow: const [
        //   const BoxShadow(
        //     blurRadius: 6.0,
        //     color: Colors.black26,
        //     offset: Offset(2, 2),
        //     spreadRadius: -1.0,
        //   )
        // ],
        // padding: const EdgeInsets.symmetric(
        //   vertical: 12.0,
        //   horizontal: 16.0,
        // ),
        child: Row(
          children: [
            isPrevious
                ? Padding(
                    padding: const EdgeInsets.only(
                      right: 4.0,
                    ),
                    child: LinearNavigationIcon(
                      mode: LitLinearNavigationMode.previous,
                    ),
                  )
                : SizedBox(),
            Text(
              isPrevious
                  ? AppLocalizations.of(context).previousLabel.toUpperCase()
                  : AppLocalizations.of(context).nextLabel.toUpperCase(),
              style: LitSansSerifStyles.button,
            ),
            !isPrevious
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 4.0,
                    ),
                    child: LinearNavigationIcon(
                      mode: LitLinearNavigationMode.next,
                    ),
                  )
                : SizedBox(),
          ],
        ),
        accentColor: Colors.grey[200]!,
        onPressed: onPressed,
      ),
    );
  }
}
