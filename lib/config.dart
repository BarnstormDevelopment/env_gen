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
    defaults = ConfigEnvironment.fromJson({
      "vars": {"APP_NAME": name, "VERSION": "1.0.0"},
      "files": {}
    });
    environments = Map.from({
      "development": {"APP_NAME": '$name DEVELOPMENT'},
      "staging": {"APP_NAME": '$name STAGING'},
      "production": {}
    }).map((key, value) => MapEntry(key, ConfigEnvironment.fromJson(value)));
  }
}

class ConfigEnvironment {
  late Map<String, String?> vars;
  late Map<String, String>? files;

  ConfigEnvironment.fromJson(Map<String, dynamic> json) {
    vars = convert.json.decode(json['vars']);
    var jsonFiles = json['files'];
    if (jsonFiles != null) {
      files = convert.json.decode(jsonFiles);
    }
  }

  Map<String, dynamic> toJson() => {
        'vars': vars,
        'files': files,
      };
}
