import 'package:flutter/material.dart';
import 'package:history_of_me/controller/database/hive_db_service.dart';
import 'package:history_of_me/localization.dart';
import 'package:history_of_me/model/user_data.dart';
import 'package:leitmotif/leitmotif.dart';

class ChangeNameDialog extends StatefulWidget {
  final UserData? userData;

  const ChangeNameDialog({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _ChangeNameDialogState createState() => _ChangeNameDialogState();
}

class _ChangeNameDialogState extends State<ChangeNameDialog> {
  late TextEditingController _nameController;
  late FocusNode _focusNode;
  late String _updatedName;

  void _onCancel() {
    LitRouteController(context).closeDialog();
  }

  bool get _isChanged {
    return _nameController.text != widget.userData!.name;
  }

  void _defocus() {
    LitFocusController(context).defocus();
    _onChange();
  }

  void _onChange() {
    setState(() {
      _updatedName = _nameController.text;
    });
  }

  void _onSubmit() {
    HiveDBService().updateUsername(widget.userData!, _updatedName);
    LitRouteController(context).closeDialog();
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.userData!.name,
    )..addListener(_onChange);

    _updatedName = widget.userData!.name;
    _focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return LitTitledDialog(
      titleText: AppLocalizations.of(context).changeYourNameLabel,
      actionButtons: [
        DialogActionButton(
          data: ActionButtonData(
            title: LeitmotifLocalizations.of(context).cancelLabel,
            onPressed: _onCancel,
          ),
        ),
        DialogActionButton(
          data: ActionButtonData(
            title: LeitmotifLocalizations.of(context).applyLabel,
            accentColor: Color(0xFFEDDEC0),
            backgroundColor: Color(0xFFEAEACA),
            disabled: !_isChanged,
            onPressed: _onSubmit,
          ),
        ),
      ],
      child: CleanInkWell(
        onTap: _defocus,
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: LitGradientCard(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      16.0,
                    ),
                  ),
                  colors: [
                    Color(0xFFF2ECE1),
                    Color(0xFFEDE7DD),
                  ],
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8.0,
                      color: Colors.black12,
                      offset: Offset(-2, 4),
                      spreadRadius: 1.0,
                    )
                  ],
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 64.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            EditableText(
                              style: LitSansSerifStyles.body1,
                              controller: _nameController,
                              focusNode: _focusNode,
                              cursorColor: LitColors.mediumGrey,
                              backgroundCursorColor: Colors.black,
                              cursorRadius: Radius.circular(32.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 4.0,
                              ),
                              child: Container(
                                height: 3.0,
                                decoration: BoxDecoration(
                                  color: LitColors.mediumGrey.withOpacity(0.4),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
