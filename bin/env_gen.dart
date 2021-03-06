import 'package:env_gen/env_gen.dart' as env_gen;
import 'dart:io';

void main(List<String> args) {
  // Prints usage
  if (args.contains('-h') || args.contains('help') || args.isEmpty) {
    env_gen.usage();
    return;
  }

  var envFilename = './env_files/env.json';

  // Runs initialization script
  if (args[0] == 'initialize') {
    stdout.writeln('Creating env-gen files and folders...');
    env_gen.createEnvTemplate();
    return;
  }

  // Checks for verbose flag
  var verbose = args.contains('-v');
  var envFile = args.contains('-e');
  // Checks for alternate env file flag
  if (args.contains('-f')) {
    var i = args.indexOf('-f');
    i++;
    if (args.length > i) {
      envFilename = args[i];
    } else {
      stderr.writeln('Error: file path must follow -f argument.');
      env_gen.usage();
      return;
    }
  }

  // Checks for alternate output file flag
  var outputPath = 'lib/env.dart';
  if (args.contains('-o')) {
    var i = args.indexOf('-o');
    i++;
    if (args.length > i) {
      outputPath = args[i];
    } else {
      stderr.writeln('Error: file path must follow -o argument.');
      env_gen.usage();
      return;
    }
  }

  // Open configuration file
  var config = env_gen.readConfig(envFilename);

  // Process env
  var availEnvs = config.environments.keys;
  if (!availEnvs.contains(args[0])) {
    stderr.writeln('Error: must pass valid environment\n\tEnvironments: $availEnvs');
    env_gen.usage();
    return;
  }
  var env = args[0];

  // Create env file
  env_gen.createEnvFile(config, env, verbose, output: outputPath, envFile: envFile);

  // Check for copy directories & mappers
  env_gen.copyFiles(config, env, verbose);

  // END
}
