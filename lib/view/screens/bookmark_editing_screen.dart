import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:history_of_me/controller/database/hive_db_service.dart';
import 'package:history_of_me/data/constants.dart';
import 'package:history_of_me/lit_route_controller/focus/route_controller.dart';
import 'package:history_of_me/lit_ui_kit_temp/lit_draggable.dart';
import 'package:history_of_me/model/user_created_color.dart';
import 'package:history_of_me/model/user_data.dart';
import 'package:history_of_me/view/widgets/shared/bookmark_back_preview.dart';
import 'package:history_of_me/view/widgets/shared/bookmark_front_preview.dart';
import 'package:history_of_me/lit_ui_kit_temp/lit_toggle_button_group.dart';
import 'package:history_of_me/view/widgets/edit_bookmark_screen/user_created_color_card.dart';
import 'package:history_of_me/view/widgets/edit_bookmark_screen/pattern_config_card.dart';
import 'package:history_of_me/view/widgets/edit_bookmark_screen/quote_card.dart';
import 'package:history_of_me/view/widgets/shared/confirm_discard_draft_dialog.dart';
import 'package:history_of_me/view/widgets/shared/editable_item_meta_info.dart';
import 'package:hive/hive.dart';
import 'package:lit_ui_kit/lit_ui_kit.dart';

class BookmarkEditingScreen extends StatefulWidget {
  final UserData initialUserDataModel;
  const BookmarkEditingScreen({
    Key key,
    @required this.initialUserDataModel,
  }) : super(key: key);
  @override
  _BookmarkEditingScreenState createState() => _BookmarkEditingScreenState();
}

class _BookmarkEditingScreenState extends State<BookmarkEditingScreen>
    with TickerProviderStateMixin {
  // int selectedPattern;
  //int stripeCount;
  // int dotSize;

  //UserData _userDataModel;

  String _name;
  int _bookmarkColor;
  int _stripeCount;
  int _dotSize;
  String _quote;
  bool _animated;

  int _designPattern;

  String _quoteAuthor;

  AnimationController _appearAnimation;

  LitSnackbarController _snackbarController;

  List<Color> _colors;

  ScrollController _scrollController;

  LitRouteController _routeController;

  void setDesignPattern(int value) {
    setState(
      () {
        // selectedPattern = value;
        // _userDataModel = UserData(
        //   name: _userDataModel.name,
        //   bookmarkColor: _userDataModel.bookmarkColor,
        //   stripeCount: _userDataModel.stripeCount,
        //   dotSize: _userDataModel.dotSize,
        //   quote: _userDataModel.quote,
        //   displayQuote: _userDataModel.displayQuote,
        //   designPatternIndex: value,
        //   animated: _userDataModel.animated,
        //   quoteAuthor: _userDataModel.quoteAuthor,
        // );
        _designPattern = value;
      },
    );
  }

  void onStripeSliderChange(double value) {
    setState(() {
      // stripeCount = value.round();
      // _userDataModel = UserData(
      //   name: _userDataModel.name,
      //   bookmarkColor: _userDataModel.bookmarkColor,
      //   stripeCount: value.round(),
      //   dotSize: _userDataModel.dotSize,
      //   quote: _userDataModel.quote,
      //   displayQuote: _userDataModel.displayQuote,
      //   designPatternIndex: _userDataModel.designPatternIndex,
      //   animated: _userDataModel.animated,
      //   quoteAuthor: _userDataModel.quoteAuthor,
      // );
      _stripeCount = value.round();
    });
    print("stripe slider $value");
  }

  void onDotsSliderChange(double value) {
    setState(() {
      // stripeCount = value.round();
      // _userDataModel = UserData(
      //   name: _userDataModel.name,
      //   bookmarkColor: _userDataModel.bookmarkColor,
      //   stripeCount: _userDataModel.stripeCount,
      //   dotSize: value.round(),
      //   quote: _userDataModel.quote,
      //   displayQuote: _userDataModel.displayQuote,
      //   designPatternIndex: _userDataModel.designPatternIndex,
      //   animated: _userDataModel.animated,
      //   quoteAuthor: _userDataModel.quoteAuthor,
      // );
      _dotSize = value.round();
    });
    print("stripe slider $value");
  }

  void setBookmarkColor(Color color) {
    setState(() {
      // _userDataModel = UserData(
      //   name: _userDataModel.name,
      //   bookmarkColor: color.value,
      //   stripeCount: _userDataModel.stripeCount,
      //   dotSize: _userDataModel.dotSize,
      //   quote: _userDataModel.quote,
      //   displayQuote: _userDataModel.displayQuote,
      //   designPatternIndex: _userDataModel.designPatternIndex,
      //   animated: _userDataModel.animated,
      //   quoteAuthor: _userDataModel.quoteAuthor,
      // );
      _bookmarkColor = color.value;
    });
  }

  void setQuote(String quote) {
    // _userDataModel = UserData(
    //   name: _userDataModel.name,
    //   bookmarkColor: _userDataModel.bookmarkColor,
    //   stripeCount: _userDataModel.stripeCount,
    //   dotSize: _userDataModel.dotSize,
    //   quote: quote,
    //   displayQuote: _userDataModel.displayQuote,
    //   designPatternIndex: _userDataModel.designPatternIndex,
    //   animated: _userDataModel.animated,
    //   quoteAuthor: _userDataModel.quoteAuthor,
    // );
    _quote = quote;
  }

  void setQuoteAuthor(String author) {
    // _userDataModel = UserData(
    //   name: _userDataModel.name,
    //   bookmarkColor: _userDataModel.bookmarkColor,
    //   stripeCount: _userDataModel.stripeCount,
    //   dotSize: _userDataModel.dotSize,
    //   quote: _userDataModel.quote,
    //   displayQuote: _userDataModel.displayQuote,
    //   designPatternIndex: _userDataModel.designPatternIndex,
    //   animated: _userDataModel.animated,
    //   quoteAuthor: author,
    // );
    _quoteAuthor = author;
  }

  UserData _mapUserData(int lastUpdated) {
    return UserData(
      name: _name,
      bookmarkColor: _bookmarkColor,
      stripeCount: _stripeCount,
      dotSize: _dotSize,
      animated: _animated,
      quote: _quote,
      designPatternIndex: _designPattern,
      quoteAuthor: _quoteAuthor,
      lastUpdated: lastUpdated,
    );
  }

  bool _userDataChanged(UserData other) {
    //_userDataModel != widget.initialUserDataModel;
    // ||
    //     !listEquals(_colors, widget.initialColors
    //     );

    if (_bookmarkColor != other.bookmarkColor) {
      print("changed bookmark color");
      return true;
    }
    if (_designPattern != other.designPatternIndex) {
      print("changed design pattern");
      return true;
    }
    if (_dotSize != other.dotSize) {
      print("changed dotsize");
      return true;
    }
    if (_stripeCount != other.stripeCount) {
      print("changed stripe count");
      return true;
    }
    if (_name != other.name) {
      print("changed name");
      return true;
    }
    if (_quote != other.quote) {
      print("changed quote");
      return true;
    }
    if (_quoteAuthor != other.quoteAuthor) {
      print("changed quote author");
      return true;
    }
    return false;
  }

  // UserData get _mappedUserData {
  //   return UserData(
  //     name: _name,
  //     bookmarkColor: _bookmarkColor,
  //     stripeCount: _stripeCount,
  //     dotSize: _dotSize,
  //     animated: _animated,
  //     quote: _quote,
  //     designPatternIndex: _designPattern,
  //     quoteAuthor: _quoteAuthor,
  //     lastUpdated: widget.initialUserDataModel.lastUpdated,
  //   );
  // }

  // void _handleAddColor(Color color) {
  //   // if (_colors.contains(color)) {
  //   //   _handleColorDuplicate();
  //   //   return false;
  //   // } else {
  //   //   setState(() {
  //   //     _colors.add(color);
  //   //   });
  //   //   return true;
  //   // }
  //   return HiveDBService(debug: debug)
  //       .addUserCreatedColor(color.alpha, color.red, color.green, color.blue);
  // }

  void _onSaveChanges() {
    HiveDBService(debug: debug)
        .updateUserData(_mapUserData(DateTime.now().millisecondsSinceEpoch));
  }

  void _handleDiscardDraft() {
    showDialog(
      context: context,
      builder: (_) => ConfirmDiscardDraftDialog(
        unsavedChangesDetectedText:
            "There have been changes made to your bookmark.",
        onDiscardCallback: () {
          _routeController.closeDialog();
          _routeController.navigateBack();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // selectedPattern = 1;
    //stripeCount = 1;
    // _colors = [];
    // widget.initialColors.forEach((color) {
    //   _colors.add(color);
    // });
    _snackbarController = LitSnackbarController();
    _scrollController = ScrollController();
    _routeController = LitRouteController(context);
    _appearAnimation = AnimationController(
        duration: Duration(
          milliseconds: 230,
        ),
        vsync: this);
    //_userDataModel = widget.initialUserDataModel;
    _name = widget.initialUserDataModel.name;
    _animated = widget.initialUserDataModel.animated;
    _bookmarkColor = widget.initialUserDataModel.bookmarkColor;
    _stripeCount = widget.initialUserDataModel.stripeCount;
    _dotSize = widget.initialUserDataModel.dotSize;
    _quote = widget.initialUserDataModel.quote;
    _quoteAuthor = widget.initialUserDataModel.quoteAuthor;
    _designPattern = widget.initialUserDataModel.designPatternIndex;
    _appearAnimation.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveDBService().getUserData(),
      builder: (BuildContext context, Box<UserData> userDataBox, Widget _) {
        UserData updatedUserData = userDataBox.getAt(0);
        return LitScaffold(
          appBar: FixedOnScrollAppbar(
            scrollController: _scrollController,
            backgroundColor: Colors.white,
            height: 50.0,
            child: EditableItemMetaInfo(
              lastUpdateTimestamp: updatedUserData.lastUpdated,
              showUnsavedBadge: _userDataChanged(updatedUserData),
            ),
            shouldNavigateBack: !_userDataChanged(updatedUserData),
            onInvalidNavigation: _handleDiscardDraft,
          ),
          snackBar: IconSnackbar(
            litSnackBarController: _snackbarController,
            text: "This color does already exist",
            iconData: LitIcons.info,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  ScrollableColumn(
                    controller: _scrollController,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16.0,
                        ),
                        child: Column(
                          children: [
                            IndexedPageView(
                              height: 150.0,
                              indicatorSpacingTop: 0.0,
                              indicatorColor: LitColors.mediumGrey,
                              children: [
                                BookmarkFrontPreview(
                                  transformed: false,
                                  userData:
                                      _mapUserData(updatedUserData.lastUpdated),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                ),
                                BookmarkBackPreview(
                                  transformed: false,
                                  userData:
                                      _mapUserData(updatedUserData.lastUpdated),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                )
                              ],
                            ),
                            LitToggleButtonGroup(
                              selectedValue: _designPattern,
                              onSelectCallback: setDesignPattern,
                              items: [
                                LitToggleButtonGroupItemData(
                                    label: "Striped", value: 0),
                                LitToggleButtonGroupItemData(
                                    label: "Dotted", value: 1),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Text("stripe count $stripeCount"),
                      ValueListenableBuilder(
                        valueListenable: HiveDBService().getUserCreatedColors(),
                        builder: (BuildContext context,
                            Box<UserCreatedColor> colorsBox, Widget _) {
                          // List<UserCreatedColor> userColors = colorsBox.values
                          //     .toList()
                          //     .cast<UserCreatedColor>();
                          List<UserCreatedColor> userColors =
                              colorsBox.values.toList();
                          print(userColors);
                          return ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight:
                                    MediaQuery.of(context).size.height - 64.0),
                            child: Column(
                              children: [
                                _designPattern == 0
                                    ? PatternConfigCard(
                                        patternLabel: "Stripes",
                                        patternValue: _stripeCount,
                                        onPatternSliderChange:
                                            onStripeSliderChange,
                                        min: 1,
                                        max: 32,
                                      )
                                    : PatternConfigCard(
                                        patternLabel: "Dotes",
                                        patternValue: _dotSize,
                                        onPatternSliderChange:
                                            onDotsSliderChange,
                                        min: 12,
                                        max: 32,
                                      ),
                                UserCreatedColorCard(
                                  selectedColorValue: _bookmarkColor,
                                  onSelectColorCallback: setBookmarkColor,
                                  userCreatedColors: userColors,
                                  //colors: _colors,
                                  //addColor: _handleAddColor,
                                  onAddColorError: () =>
                                      _snackbarController.showSnackBar(),
                                ),
                                QuoteCard(
                                  initialAuthor: _quoteAuthor,
                                  initialQuote: _quote,
                                  onAuthorChanged: setQuoteAuthor,
                                  onQuoteChanged: setQuote,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  _userDataChanged(updatedUserData)
                      ? LitDraggable(
                          initialDragOffset: Offset(
                            MediaQuery.of(context).size.width - 90.0,
                            MediaQuery.of(context).size.height - 90.0,
                          ),
                          child: LitGradientButton(
                            accentColor: const Color(0xFFDE8FFA),
                            color: const Color(0xFFFA72AA),
                            child: Icon(LitIcons.disk,
                                size: 28.0, color: Colors.white),
                            onPressed: _onSaveChanges,
                          ),
                        )
                      : SizedBox(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
