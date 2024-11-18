import 'package:blisso_mobile/components/button_component.dart';
import 'package:blisso_mobile/components/loading_component.dart';
import 'package:blisso_mobile/components/snackbar_component.dart';
import 'package:blisso_mobile/components/text_input_component.dart';
import 'package:blisso_mobile/services/auth/user_service_provider.dart';
import 'package:blisso_mobile/utils/global_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String type;
  const RegisterScreen({super.key, required this.type});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final firstname = TextEditingController();
  final lastname = TextEditingController();

  final emailUsername = TextEditingController();
  final phoneUsername = TextEditingController(text: '+250 ');

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userServiceProviderImpl);

    TextScaler textScaler = MediaQuery.textScalerOf(context);
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: userState.isLoading
            ? const LoadingScreen()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Text(
                      AppLocalizations.of(context)!.registerTitle,
                      style: TextStyle(
                          color: GlobalColors.primaryColor,
                          fontSize: textScaler.scale(48),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      AppLocalizations.of(context)!.registerSubtitle,
                      style: TextStyle(fontSize: textScaler.scale(12)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextInputComponent(
                              controller: firstname,
                              labelText:
                                  '${AppLocalizations.of(context)!.firstname} *',
                              hintText:
                                  AppLocalizations.of(context)!.hintFirstname,
                              validatorFunction: (value) {
                                return (value!.isEmpty
                                    ? AppLocalizations.of(context)!
                                        .validatorFirstname
                                    : null);
                              }),
                          TextInputComponent(
                              controller: lastname,
                              labelText:
                                  '${AppLocalizations.of(context)!.lastname} *',
                              hintText:
                                  AppLocalizations.of(context)!.hintLastname,
                              validatorFunction: (value) {
                                return (value!.isEmpty
                                    ? AppLocalizations.of(context)!
                                        .validatorLastname
                                    : null);
                              }),
                          widget.type == 'EMAIL'
                              ? TextInputComponent(
                                  controller: emailUsername,
                                  labelText:
                                      '${AppLocalizations.of(context)!.email} *',
                                  hintText:
                                      AppLocalizations.of(context)!.hintEmail,
                                  validatorFunction: (value) {
                                    return (value!.isEmpty
                                        ? AppLocalizations.of(context)!
                                            .validatorEmail
                                        : null);
                                  })
                              : TextInputComponent(
                                  controller: phoneUsername,
                                  labelText:
                                      AppLocalizations.of(context)!.phoneNumber,
                                  hintText: AppLocalizations.of(context)!
                                      .hintPhoneNumber,
                                  validatorFunction: (value) {
                                    return (value!.isEmpty
                                        ? AppLocalizations.of(context)!
                                            .validatorPhoneNumber
                                        : null);
                                  }),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ButtonComponent(
                                        text: AppLocalizations.of(context)!
                                            .registerTitle,
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        onTap: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _formKey.currentState!.save();

                                            await ref
                                                .read(userServiceProviderImpl
                                                    .notifier)
                                                .registerUser(
                                                    widget.type == 'EMAIL'
                                                        ? emailUsername.text
                                                        : phoneUsername.text,
                                                    firstname.text,
                                                    lastname.text,
                                                    widget.type);

                                            final userState = ref
                                                .read(userServiceProviderImpl);
                                            if (userState.error != null) {
                                              showSnackBar(
                                                  context, userState.error!);
                                            } else {
                                              Routemaster.of(context)
                                                  .push('/password');
                                            }
                                          }
                                        })
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      )),
    );
  }
}
