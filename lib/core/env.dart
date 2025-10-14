enum AppEnvironment { dev, prod }

class Env {
  static AppEnvironment current = AppEnvironment.dev;

  static String get baseUrl {
    switch (current) {
      case AppEnvironment.dev:
        return 'http://31.220.82.177:9097/api/v1';
      case AppEnvironment.prod:
        return 'https://your-prod-domain.com/api/v1';
    }
  }

  static bool get isDebug => current == AppEnvironment.dev;
}
