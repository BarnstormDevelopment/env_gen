import 'dart:convert' as convert;

class Config {
  late ConfigEnvironment defaults;
  late Map<String, ConfigEnvironment> environments;

  Config.fromJson(Map<String, dynamic> json) {
    defaults = ConfigEnvironment.fromJson(json['default']);
    environments = Map.from(json['environments']).map((key, value) => MapEntry(key, ConfigEnvironment.fromJson(value)));
  }

  Map<String, dynamic> toJson() =>
      {'default': defaults.toJson(), 'environments': environments.map((key, value) => MapEntry(key, value.toJson()))};

  Config.template(String name) {
    Map<String, dynamic> json = {
      "default": {
        "vars": {"APP_NAME": name, "VERSION": "1.0.0"},
        "files": {}
      },
      "environments": {
        "development": {
          "vars": {"APP_NAME": '$name DEVELOPMENT'},
          "files": {}
        },
        "staging": {
          "vars": {"APP_NAME": '$name STAGING'}
        },
        "production": {}
      }
    };
    defaults = ConfigEnvironment.fromJson(json['default']);
    environments = Map.from(json['environments']).map((key, value) => MapEntry(key, ConfigEnvironment.fromJson(value)));
  }
}

class ConfigEnvironment {
  late Map<String, String?> vars;
  late Map<String, String>? files;

  ConfigEnvironment.fromJson(Map<dynamic, dynamic> json) {
    vars = Map<String, String>.from(json['vars'] ?? {});
    files = Map<String, String>.from(json['files'] ?? {});
  }

  Map<String, dynamic> toJson() => {
        'vars': vars,
        'files': files,
      };
}
