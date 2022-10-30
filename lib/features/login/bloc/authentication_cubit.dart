import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_paperless_mobile/core/model/error_message.dart';
import 'package:flutter_paperless_mobile/core/store/local_vault.dart';
import 'package:flutter_paperless_mobile/di_initializer.dart';
import 'package:flutter_paperless_mobile/features/login/model/authentication_information.dart';
import 'package:flutter_paperless_mobile/features/login/model/client_certificate.dart';
import 'package:flutter_paperless_mobile/features/login/model/user_credentials.model.dart';
import 'package:flutter_paperless_mobile/features/login/services/authentication.service.dart';
import 'package:flutter_paperless_mobile/features/settings/model/application_settings_state.dart';
import 'package:injectable/injectable.dart';

const authenticationKey = "authentication";

@singleton
class AuthenticationCubit extends Cubit<AuthenticationState> {
  final LocalVault localStore;
  final AuthenticationService authenticationService;

  AuthenticationCubit(this.localStore, this.authenticationService)
      : super(AuthenticationState.initial);

  Future<void> initialize() {
    return restoreSessionState();
  }

  Future<void> login({
    required UserCredentials credentials,
    required String serverUrl,
    ClientCertificate? clientCertificate,
  }) async {
    assert(credentials.username != null && credentials.password != null);
    try {
      registerSecurityContext(clientCertificate);
    } on TlsException catch (_) {
      throw const ErrorMessage(ErrorCode.invalidClientCertificateConfiguration);
    }
    emit(
      AuthenticationState(
        isAuthenticated: false,
        wasLoginStored: false,
        authentication: AuthenticationInformation(
          username: credentials.username!,
          password: credentials.password!,
          serverUrl: serverUrl,
          token: "",
          clientCertificate: clientCertificate,
        ),
      ),
    );
    final token = await authenticationService.login(
      username: credentials.username!,
      password: credentials.password!,
      serverUrl: serverUrl,
    );
    final auth = AuthenticationInformation(
      username: credentials.username!,
      password: credentials.password!,
      token: token,
      serverUrl: serverUrl,
      clientCertificate: clientCertificate,
    );

    await localStore.storeAuthenticationInformation(auth);

    emit(AuthenticationState(
      isAuthenticated: true,
      wasLoginStored: false,
      authentication: auth,
    ));
  }

  Future<void> restoreSessionState() async {
    final storedAuth = await localStore.loadAuthenticationInformation();
    final appSettings =
        await localStore.loadApplicationSettings() ?? ApplicationSettingsState.defaultSettings;

    if (storedAuth == null || !storedAuth.isValid) {
      emit(AuthenticationState(isAuthenticated: false, wasLoginStored: false));
    } else {
      if (!appSettings.isLocalAuthenticationEnabled ||
          await authenticationService.authenticateLocalUser("Authenticate to log back in")) {
        registerSecurityContext(storedAuth.clientCertificate);
        emit(
          AuthenticationState(
            isAuthenticated: true,
            wasLoginStored: true,
            authentication: storedAuth,
          ),
        );
      } else {
        emit(AuthenticationState(isAuthenticated: false, wasLoginStored: true));
      }
    }
  }

  Future<void> logout() async {
    await localStore.clear();
    emit(AuthenticationState.initial);
  }
}

class AuthenticationState {
  final bool wasLoginStored;
  final bool isAuthenticated;
  final AuthenticationInformation? authentication;

  static final AuthenticationState initial = AuthenticationState(
    wasLoginStored: false,
    isAuthenticated: false,
  );

  AuthenticationState({
    required this.isAuthenticated,
    required this.wasLoginStored,
    this.authentication,
  });

  AuthenticationState copyWith({
    bool? wasLoginStored,
    bool? isAuthenticated,
    AuthenticationInformation? authentication,
  }) {
    return AuthenticationState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      wasLoginStored: wasLoginStored ?? this.wasLoginStored,
      authentication: authentication ?? this.authentication,
    );
  }
}