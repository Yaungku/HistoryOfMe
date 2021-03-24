import 'package:flutter/material.dart';
import 'package:history_of_me/lit_relative_date_time_temp/relative_date_time.dart';
import 'package:history_of_me/lit_relative_date_time_temp/lit_relative_date_time_localization.dart';
import 'package:history_of_me/view/widgets/shared/updated_label_text.dart';
import 'package:lit_ui_kit/lit_ui_kit.dart';

class AnimatedUpdatedLabel extends StatefulWidget {
  final int lastUpdateTimestamp;
  final EdgeInsets padding;

  const AnimatedUpdatedLabel({
    Key key,
    @required this.lastUpdateTimestamp,
    this.padding = const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 16.0,
    ),
  }) : super(key: key);

  @override
  _AnimatedUpdatedLabelState createState() => _AnimatedUpdatedLabelState();
}

class _AnimatedUpdatedLabelState extends State<AnimatedUpdatedLabel>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget _) {
        return Padding(
          padding: widget.padding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedOpacity(
              opacity: 0.35 + (0.65 * _animationController.value),
              duration: _animationController.duration,
              child: UpdatedLabelText(
                lastUpdateTimestamp: widget.lastUpdateTimestamp,
              ),
            ),
          ),
        );
      },
    );
  }
}
