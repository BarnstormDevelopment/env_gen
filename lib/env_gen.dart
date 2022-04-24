import 'dart:convert';
import 'dart:io';
import 'config.dart';

void createEnvFile(Config config, String environment, bool verbose, {String output = 'lib/env.dart'}) {
  Map<String, String?> envVars = {...(config.defaults.vars), ...(config.environments[environment]?.vars ?? {})};
  var platEnv = Platform.environment;
  for (var key in envVars.keys) {
    String? val;
    // Override with platform env
    val = platEnv[key] ?? val;
    val = platEnv['${environment.toUpperCase()}_$key'];
    envVars[key] = val ?? envVars[key];
  }
  if (verbose) {
    stdout.writeln('Using $environment environment:\n$envVars');
    // envVars.forEach((k, v) {
    //   if (v == null) stdout.writeln('WARN: $k is null');
    // });
  }

  File(output).writeAsString('final environment = ${json.encode(config.toJson())};');
  if (verbose) stdout.writeln('Environment configuration written to \'$output\'');
}

void createEnvTemplate() {
  final filename = 'env.json';
  final envDir = Directory('${Directory.current.path}/env_files')..createSync();

  final name = Platform.script.path.split('/').last;
  var template = Config.template(name);
  File('$envDir/$filename').writeAsString('final environment = ${json.encode(template)};');

  Directory('${envDir.path}/default').createSync();
  for (MapEntry<String, ConfigEnvironment> env in template.environments.entries) {
    Directory('${envDir.path}/${env.key}').createSync();
  }
}

void copyFiles(Config config, String environment, bool verbose) {
  final envDir = Directory('${Directory.current.path}/env_files');
  final defaultFiles = config.defaults.files?.map((key, value) => MapEntry('${envDir.path}/default/$key', value));
  final envFiles =
      config.environments[environment]?.files?.map((key, value) => MapEntry('${envDir.path}/$environment/$key', value));

  // Remove redundant values from default.
  if (defaultFiles?.entries != null && envFiles?.entries != null) {
    for (var entry in envFiles!.entries) {
      defaultFiles!.removeWhere((key, value) => value == entry.value);
    }
  }
  var combinedFiles = {...(defaultFiles ?? {}), ...(envFiles ?? {})};
  if (combinedFiles.isEmpty) {
    if (verbose) stdout.writeln('No files to copy.');
    return;
  }
  if (!envDir.existsSync()) {
    stdout.writeln('WARNING: No env_files directory.');
    return;
  }
  if (verbose) stdout.writeln('Using $environment environment, copying files:\n$combinedFiles');

  for (var entry in combinedFiles.entries) {
    //Key is source, value is dest
    File(entry.key).copy(entry.value);
  }
}

Config readConfig(String configPath) {
  var configRaw = json.decode(File(configPath).readAsStringSync());

  // Verify config integrity
  assert(configRaw is Map<String, dynamic>);
  assert(configRaw["default"] != null);
  assert(configRaw["default"]["vars"] != null);
  assert(configRaw["environments"] is Map<String, dynamic>);

  var config = Config.fromJson(configRaw);

  return config;
}

void usage() {
  stdout.writeln('Usage:\n\tenv-gen <cmd> [flags]'
      '\n\tcmd'
      '\n\t\tinitialize\t\tcreates template env file and corresponding directories'
      '\n\t\t<environment>\t\tstring representing an environment from the env.json'
      '\n\t\thelp\t\toutputs this usage help'
      '\n\n\tflags'
      '\n\t\t-v\t\tturns on verbose logs'
      '\n\t\t-f <path>\t\tdefine alternate env.json file to use'
      '\n\t\t-o <path>\t\tdefine alternate output filepath for env.dart'
      '\n\t\t-h\t\toutputs this usage help');
}
