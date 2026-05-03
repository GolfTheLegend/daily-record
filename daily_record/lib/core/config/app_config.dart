enum AppEnvironment { dev, uat, prod }

extension AppEnvironmentExtension on AppEnvironment {
  String get name => toString().split('.').last;
}

class AppConfig {
  final AppEnvironment env;
  final String baseUrl;
  final bool useMockServices;

  AppConfig._({
    required this.env,
    required this.baseUrl,
    required this.useMockServices,
  });

  static late final AppConfig instance;

  static void init({
    required String environment,
    required String baseUrl,
    bool useMockServices = false,
  }) {
    instance = AppConfig._(
      env: _parse(environment),
      baseUrl: baseUrl,
      useMockServices: useMockServices,
    );
  }

  static AppEnvironment _parse(String value) {
    switch (value.toLowerCase()) {
      case 'uat':
        return AppEnvironment.uat;
      case 'prod':
        return AppEnvironment.prod;
      default:
        return AppEnvironment.dev;
    }
  }

  bool get isDev => env == AppEnvironment.dev;
  bool get isUat => env == AppEnvironment.uat;
  bool get isProd => env == AppEnvironment.prod;
}
