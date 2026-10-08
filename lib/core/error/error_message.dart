import 'package:learning_dashboard/core/error/app_exception.dart';
import 'package:learning_dashboard/l10n/l10n.dart';

extension AppExceptionMessage on AppException {
  String localizedMessage(AppLocalizations l10n) => switch (this) {
    NetworkException() => l10n.errorNetwork,
    ServerException() => l10n.errorServer,
    CacheException() => l10n.errorCache,
    InvalidCredentialsException() => l10n.errorInvalidCredentials,
    NotFoundException() => l10n.errorNotFound,
  };
}
