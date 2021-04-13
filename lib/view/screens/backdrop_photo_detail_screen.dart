import 'package:flutter/material.dart';
import 'package:history_of_me/model/backdrop_photo.dart';
import 'package:lit_ui_kit/lit_ui_kit.dart';

/// A screen widget to display additional information about a provided backdrop
/// photo.
///
/// The details include the photo's photographer, the location, and the
/// publishing date.
class BackdropPhotoDetailScreen extends StatelessWidget {
  final BackdropPhoto backdropPhoto;

  /// Creates a [BackdropPhotoDetailScreen].
  ///
  /// * [backdropPhoto] is the backdrop photo whose details will be displayed.
  const BackdropPhotoDetailScreen({
    Key? key,
    required this.backdropPhoto,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LitScaffold(
      appBar: MinimalistAppBar(
        backButtonBackgroundColor: Colors.white24,
      ),
      body: Stack(
        children: [
          _Background(backdropPhoto: backdropPhoto),
          ScrollableColumn(
            children: [
              SizedBox(
                height: MinimalistAppBar.height,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Image(
                  image: AssetImage(
                    "${backdropPhoto.assetUrl}",
                  ),
                  fit: BoxFit.scaleDown,

                  //color: Colors.black,
                ),
              ),
              Transform(
                transform: Matrix4.translationValues(0, -12.0, 0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _DetailsCard(
                    backdropPhoto: backdropPhoto,
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

/// The card widget to display the text-based information.
class _DetailsCard extends StatelessWidget {
  final BackdropPhoto backdropPhoto;

  const _DetailsCard({
    Key? key,
    required this.backdropPhoto,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LitElevatedCard(
      borderRadius: BorderRadius.all(
        Radius.circular(
          16.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Details",
                textAlign: TextAlign.left,
                style: LitTextStyles.sansSerifHeader,
              ),
              _BackdropCardDetailItem(
                icon: LitIcons.person,
                detailLabel: "Photographer",
                detailValue: "${backdropPhoto.photographer}",
                constraints: constraints,
              ),
              _BackdropCardDetailItem(
                icon: LitIcons.map_marker,
                detailLabel: "Location",
                detailValue: "${backdropPhoto.location}",
                constraints: constraints,
              ),
              _BackdropCardDetailItem(
                detailLabel: "Published",
                detailValue:
                    "${DateTime.parse(backdropPhoto.published!).formatAsLocalizedDateWithWeekday()}",
                constraints: constraints,
              ),
              backdropPhoto.description != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "${backdropPhoto.photographer} is telling us about this image:\n",
                              style: LitTextStyles.sansSerifSmallHeader,
                            ),
                            TextSpan(
                              text: "${backdropPhoto.description}",
                              style: LitTextStyles.sansSerifBody,
                            )
                          ],
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

/// The background layer of the screen, which includes a blurred version of the
/// backdrop photo.
class _Background extends StatefulWidget {
  final BackdropPhoto backdropPhoto;

  const _Background({
    Key? key,
    required this.backdropPhoto,
  }) : super(key: key);
  @override
  __BackgroundState createState() => __BackgroundState();
}

class __BackgroundState extends State<_Background> {
  Size get _deviceSize {
    return MediaQuery.of(context).size;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: _deviceSize.height,
          width: _deviceSize.width,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: alternativeBoxFit(
                _deviceSize,
                portraitBoxFit: BoxFit.fitHeight,
                landscapeBoxFit: BoxFit.fitWidth,
              ),
              image: AssetImage(
                "${widget.backdropPhoto.assetUrl}",
              ),
            ),
          ),
        ),
        BluredBackgroundContainer(
          child: Container(
            color: Colors.white10,
            height: _deviceSize.height,
            width: _deviceSize.width,
          ),
          blurRadius: 8.0,
        ),
        Container(
          height: _deviceSize.height,
          width: _deviceSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white24,
                Colors.black26,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A card item to display information. The information can also be visualized
/// using an optional icon.
class _BackdropCardDetailItem extends StatelessWidget {
  final IconData? icon;
  final String detailLabel;
  final String detailValue;
  final BoxConstraints constraints;
  const _BackdropCardDetailItem({
    Key? key,
    this.icon,
    required this.detailLabel,
    required this.detailValue,
    required this.constraints,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          icon != null
              ? SizedBox(
                  width: constraints.maxWidth * 0.05,
                  child: Icon(
                    icon,
                    size: 16.0,
                    color: LitColors.mediumGrey,
                  ),
                )
              : SizedBox(),
          SizedBox(
            width: constraints.maxWidth * 0.35,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: ClippedText(
                "$detailLabel",
                maxLines: 1,
                textAlign: TextAlign.left,
                style: LitTextStyles.sansSerifSmallHeader,
              ),
            ),
          ),
          SizedBox(
            width: constraints.maxWidth * (icon != null ? 0.60 : 0.65),
            child: ClippedText(
              "$detailValue",
              maxLines: 1,
              textAlign: TextAlign.right,
              style: LitTextStyles.sansSerifBody,
            ),
          ),
        ],
      ),
    );
  }
}