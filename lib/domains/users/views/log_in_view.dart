import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fruit_measure_app/components/custom_snackbar/custom_snackbar.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/domains/users/services/import_user.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:fruit_measure_app/utils/update_state.dart';
import 'package:hive_ce/hive.dart' show Hive, Box;
import 'package:uuid/uuid.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> with UpdateState<LogInView> {
  bool isRegisterMode = false;

  final userBox = Hive.box<User>(userBoxName);
  final sessionBox = Hive.box(sessionBoxName);
  String userName = '';

  @override
  void initState() {
    super.initState();
    final savedUserId = sessionBox.get('currentUserId');
    if (savedUserId != null) {
      final savedUser = userBox.get(savedUserId);
      if (savedUser != null) {
        currentUser = savedUser;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          }
        });
      }
    }
  }

  void _showDisclaimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _DisclaimerDialog(
          userName: userName,
          userBox: userBox,
          sessionBox: sessionBox,
          onProfileCreated: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          },
        );
      },
    );
  }

  void register() {
    if (userName.trim().isEmpty) return;
    _showDisclaimerDialog();
  }

  void logIn() {
    if (userName.trim().isEmpty) return;

    final existingUser = userBox.values.firstOrNullWhere(
      (e) => e.userName == userName,
    );
    if (existingUser != null) {
      currentUser = existingUser;
      sessionBox.put('currentUserId', existingUser.id);

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else {
      customSnackBar(
        context: context,
        message: AppLocalizations.of(context)!.userNotFound,
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final Widget userField = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.usernameLabel,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        Autocomplete<String>(
          onSelected: (value) {
            userName = value;
          },
          fieldViewBuilder: (
            context,
            textEditingController,
            focusNode,
            onFieldSubmitted,
          ) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (value) => userName = value,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.none,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[ÁÉÍÓÚÑáéíóúñ]')),
                LengthLimitingTextInputFormatter(20),
              ],
              maxLength: isRegisterMode ? 20 : null,
              decoration: InputDecoration(
                hintText: loc.usernameHint,
                helperText: isRegisterMode ? loc.max20Characters : null,
              ),
            );
          },
          // Autocomplete options
          optionsBuilder: (userInput) {
            if (userInput.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return userBox.values
                .where(
                  (user) => user.userName.toLowerCase().contains(
                    userInput.text.toLowerCase(),
                  ),
                )
                .map((user) => user.userName)
                .toList();
          },
          // Visual settings
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ), // Bordes para el contenido
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 16),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            size: 48,
                            color: Color(0xFF8A164C),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isRegisterMode ? loc.registerTitle : loc.loginTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/primary_logotype/FruitMeasureApp__logotip_primari_color.png',
                          fit: BoxFit.cover,
                          height: 350,
                        ),
                        userField,
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            if (isRegisterMode) {
                              register();
                            } else {
                              logIn();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8A164C),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Text(
                            isRegisterMode
                                ? loc.createProfile
                                : loc.startProfile,
                          ),
                        ),
                        if (!isRegisterMode) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () async {
                              try {
                                final user = await importUser();
                                if (user == null) {
                                  // User cancelled or error occurred
                                  return;
                                }

                                await userBox.put(user.id, user);
                                currentUser = user;
                                await sessionBox.put('currentUserId', user.id);
                                await Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/',
                                  (_) => false,
                                );
                              } catch (e) {
                                customSnackBar(
                                  context: context,
                                  message:
                                      AppLocalizations.of(
                                        context,
                                      )!.errorImportUserFailed,
                                  type: SnackbarType.error,
                                );
                              }
                            },
                            child: Text(
                              loc.importProfile,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF8A164C),
                              ),
                            ),
                          ),
                          const Divider(height: 10),
                        ],
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isRegisterMode = !isRegisterMode;
                            });
                          },
                          child: Text(
                            isRegisterMode
                                ? loc.startProfile
                                : loc.createProfile,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8A164C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: IconButton(
        tooltip: loc.creditsMenuItem,
        icon: const Icon(
          Icons.info_outline,
          size: 28,
          color: Color(0xFF8A164C),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/credits');
        },
      ),
    );
  }
}

class _DisclaimerDialog extends StatefulWidget {
  const _DisclaimerDialog({
    required this.userName,
    required this.userBox,
    required this.sessionBox,
    required this.onProfileCreated,
  });

  final String userName;
  final Box<User> userBox;
  final Box sessionBox;
  final VoidCallback onProfileCreated;

  @override
  State<_DisclaimerDialog> createState() => _DisclaimerDialogState();
}

class _DisclaimerDialogState extends State<_DisclaimerDialog> {
  bool disclaimerAccepted = false;
  bool isCreating = false;
  bool hasScrolledToBottom = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_checkScroll);

    // On larger screens the disclaimer may fit without scrolling.
    // In that case, enable acceptance immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0 && !hasScrolledToBottom) {
        setState(() {
          hasScrolledToBottom = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScroll() {
    if (!_scrollController.hasClients) return;

    final maxExtent = _scrollController.position.maxScrollExtent;
    // If there's nothing to scroll, consider it read.
    if (maxExtent <= 0) {
      if (!hasScrolledToBottom) {
        setState(() {
          hasScrolledToBottom = true;
        });
      }
      return;
    }

    if (_scrollController.position.pixels >= maxExtent - 10) {
      if (!hasScrolledToBottom) {
        setState(() {
          hasScrolledToBottom = true;
        });
      }
    }
  }

  void _createProfile() {
    if (!disclaimerAccepted) {
      customSnackBar(
        context: context,
        message: AppLocalizations.of(context)!.disclaimerMustBeAccepted,
        type: SnackbarType.error,
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    final existingUser = widget.userBox.values.any(
      (e) => e.userName == widget.userName,
    );
    if (existingUser) {
      customSnackBar(
        context: context,
        message: AppLocalizations.of(context)!.userAlreadyRegistered,
        type: SnackbarType.error,
      );
      setState(() {
        isCreating = false;
      });
      return;
    }

    final newUser = User(
      id: const Uuid().v4(),
      email: '',
      userName: widget.userName,
      deletePhotosAfterMeasure: false,
      supportDistance: 250.0,
      disclaimerAccepted: disclaimerAccepted,
    );

    widget.userBox.put(newUser.id, newUser);
    currentUser = newUser;
    widget.sessionBox.put('currentUserId', newUser.id);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onProfileCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Dialog(
      insetAnimationDuration: const Duration(milliseconds: 200),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF1F3F4),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1E1E1E)),
            onPressed: isCreating ? null : () => Navigator.of(context).pop(),
          ),
          title: Text(
            loc.createProfile,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  loc.disclaimer,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.8,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                if (!hasScrolledToBottom) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.disclaimerScrollContinue,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: disclaimerAccepted,
                    onChanged:
                        (isCreating || !hasScrolledToBottom)
                            ? null
                            : (value) {
                              setState(() {
                                disclaimerAccepted = value ?? false;
                              });
                            },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.disclaimerAcceptance,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                hasScrolledToBottom
                                    ? Colors.black
                                    : Colors.grey.shade400,
                          ),
                        ),
                        if (!hasScrolledToBottom)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              AppLocalizations.of(
                                context,
                              )!.disclaimerReadingText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  onPressed:
                      isCreating || !disclaimerAccepted ? null : _createProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A164C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child:
                      isCreating
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            loc.createProfile,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
