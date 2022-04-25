import 'dart:convert';
import 'dart:io';
import 'config.dart';

void createEnvFile(Config config, String environment, bool verbose,
    {bool envFile = false, String output = 'lib/env.dart'}) {
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

  Directory('lib').createSync(recursive: true);
  var stringVars = '';
  for (var env in envVars.entries) {
    stringVars += '\tstatic String ${env.key} = "${env.value}";\n';
  }
  File(output).writeAsString('class Environment {\n' +
      stringVars +
      '\tfinal raw = ${json.encode(envVars)};\n'
          '}');
  if (verbose) stdout.writeln('Environment configuration written to \'$output\'');
  if (envFile) {
    stringVars = '';
    for (var env in envVars.entries) {
      if (env.value?.contains(' ') ?? false) {
        stringVars += '${env.key}="${env.value}"\n';
      } else {
        stringVars += '${env.key}=${env.value}\n';
      }
    }
    File('.env').writeAsString(stringVars);

    if (verbose) stdout.writeln('Env file written to .env');
  }
}

void createEnvTemplate() {
  final filename = 'env.json';
  final envDir = Directory('${Directory.current.path}/env_files')..createSync(recursive: true);
  final name = Directory.current.path.split('/').last;
  var template = Config.template(name);
  var encoder = JsonEncoder.withIndent('   ');
  File('${envDir.path}/$filename').writeAsString(encoder.convert(template.toJson()));

  Directory('${envDir.path}/default').createSync(recursive: true);
  for (MapEntry<String, ConfigEnvironment> env in template.environments.entries) {
    Directory('${envDir.path}/${env.key}').createSync(recursive: true);
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
    var path = (entry.value.split('/')..removeLast()).join('/');
    Directory(path).createSync(recursive: true);
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
  stdout.writeln('Usage:'
      '\nenv-gen <cmd> [flags]'
      '\ncmd'
      '\n\tinitialize\t\tcreates template env file and corresponding directories'
      '\n\t<environment>\t\tstring representing an environment from the env.json'
      '\n\thelp\t\t\toutputs this usage help'
      '\nflags'
      '\n\t-v\t\t\tturns on verbose logs'
      '\n\t-f <path>\t\tdefine alternate env.json file to use'
      '\n\t-e\t\tuse to output an additional .env file'
      '\n\t-o <path>\t\tdefine alternate output filepath for env.dart'
      '\n\t-h\t\t\toutputs this usage help');
}
