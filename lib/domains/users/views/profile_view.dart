import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/components/custom_app_bar.dart';
import 'package:fruit_measure_app/components/account_end_drawer.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/users/components/language_selector.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/domains/users/services/delete_user.dart';
import 'package:fruit_measure_app/domains/users/services/edit_user.dart';
import 'package:fruit_measure_app/domains/users/services/export_user.dart';
import 'package:fruit_measure_app/domains/users/services/get_user_avatar_name.dart';
import 'package:fruit_measure_app/domains/users/services/user_log_out.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.user});

  final User user;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with UpdateState<ProfileView> {
  bool isEditing = false;

  late bool _deletePhotosAfterMeasure;
  late final TextEditingController _userNameController;
  late final TextEditingController _emailController;
  late TextEditingController _supportDistanceController;
  late double _confidenceThreshold;

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.confirmDeleteProfileTitle,
            ),
            content: Text(
              AppLocalizations.of(context)!.confirmDeleteProfileMessage,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () {
                  deleteUser(widget.user.id);
                  userLogOut();
                  Navigator.of(context).pop();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (_) => false);
                },
                child: Text(
                  AppLocalizations.of(context)!.confirm,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _confirmSaveChanges() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(loc.confirmChangesTitle),
            content: Text(loc.confirmChangesMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () {
                  isEditing = false;
                  widget.user.userName = _userNameController.value.text;
                  widget.user.email = _emailController.value.text;
                  widget.user.deletePhotosAfterMeasure =
                      _deletePhotosAfterMeasure;
                  widget.user.supportDistance =
                      double.tryParse(_supportDistanceController.text) ??
                      widget.user.supportDistance;
                  widget.user.confidenceThreshold = _confidenceThreshold;

                  editUser(widget.user);
                  Navigator.of(context).pop();
                  updateState();
                  customSnackBar(
                    context: context,
                    message: loc.actionDone,
                    type: SnackbarType.success,
                  );
                },
                child: Text(loc.confirm),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    _deletePhotosAfterMeasure = widget.user.deletePhotosAfterMeasure;
    _userNameController = TextEditingController(text: widget.user.userName);
    _emailController = TextEditingController(text: widget.user.email);
    _supportDistanceController = TextEditingController(
      text: widget.user.supportDistance.toString(),
    );
    _confidenceThreshold = widget.user.confidenceThreshold;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _supportDistanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final user = widget.user;

    return Scaffold(
      appBar: CustomAppBar(title: loc.profileMenuItem),
      endDrawer: const AccountEndDrawer(),
      drawerBarrierDismissible: false,
      endDrawerEnableOpenDragGesture: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary.withAlpha(30),
                          radius: 30,
                          child: Text(
                            getUserAvatarName(widget.user),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.usernameLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _userNameController,
                      enabled: isEditing,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp(r'[ÁÉÍÓÚÑáéíóúñ]'),
                        ),
                        LengthLimitingTextInputFormatter(20),
                      ],
                      decoration: InputDecoration(
                        helperText: loc.max20Characters,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.email_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.emailLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      enabled: isEditing,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      textCapitalization: TextCapitalization.none,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          RegExp(r'[ÁÉÍÓÚÑáéíóúñ]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        helperText: loc.emailRecommended,
                        helperMaxLines: 3,
                      ),
                      controller: _emailController,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.settings_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.optionsLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      enabled: isEditing,
                      controller: _supportDistanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.supportDistance,
                      ),
                    ),

                    const SizedBox(height: 8),

                    StatefulBuilder(
                      builder: (context, setState) {
                        return CheckboxListTile(
                          title: Text(loc.deletePhotosOption),
                          dense: true,
                          value: _deletePhotosAfterMeasure,
                          onChanged:
                              isEditing
                                  ? (bool? value) {
                                    if (value == null) return;
                                    _deletePhotosAfterMeasure = value;
                                    updateState();
                                  }
                                  : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.tune_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.confidenceThresholdLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${(_confidenceThreshold * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  loc.confidenceThresholdDescription,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _confidenceThreshold,
                              min: 0.50,
                              max: 0.95,
                              divisions: 9,
                              label: '${(_confidenceThreshold * 100).toInt()}%',
                              onChanged:
                                  isEditing
                                      ? (value) {
                                        setState(() {
                                          _confidenceThreshold = value;
                                        });
                                        updateState();
                                      }
                                      : null,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '50%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '95%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.language_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            loc.language,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    LanguageSelector(enabled: isEditing),

                    const SizedBox(height: 16),

                    const Spacer(),
                    if (!isEditing) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnBlueLight,
                        ),
                        onPressed: () {
                          isEditing = true;
                          updateState();
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: btnBlueDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.editProfile,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnBlueDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreyLight,
                        ),
                        icon: const Icon(
                          Icons.upload,
                          color: btnGreyDark,
                          size: 18,
                        ),
                        onPressed: () async {
                          try {
                            final filePath = await exportUser(widget.user);
                            if (filePath == null) return;
                            customSnackBar(
                              context: context,
                              message: loc.actionDone,
                              type: SnackbarType.success,
                            );
                          } catch (e) {
                            customSnackBar(
                              context: context,
                              message: loc.errorExportFailed,
                              type: SnackbarType.error,
                            );
                          }
                        },
                        label: Text(
                          loc.exportProfile,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreyDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnRedLight,
                        ),
                        onPressed: _confirmDeleteProfile,
                        icon: const Icon(
                          Icons.delete,
                          color: btnRedDark,
                          size: 18,
                        ),
                        label: Text(
                          loc.deleteProfile,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnRedDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreenLight,
                        ),
                        icon: const Icon(
                          Icons.save,
                          color: btnGreenDark,
                          size: 18,
                        ),
                        onPressed: _confirmSaveChanges,
                        label: Text(
                          loc.saveChanges,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreenDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: btnGreyLight,
                        ),
                        icon: const Icon(
                          Icons.cancel,
                          color: btnGreyDark,
                          size: 18,
                        ),

                        onPressed: () {
                          isEditing = false;
                          _confidenceThreshold =
                              widget.user.confidenceThreshold;
                          updateState();
                        },
                        label: Text(
                          loc.cancel,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            color: btnGreyDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
