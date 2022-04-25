# ENV GEN

This is a CLI tool used to generate environment based variable files and file substitutions for Dart projects.

You can define multiple environments and utilize substitution to dynamically generate an environment variable file for your Dart projects during development and during your CI/CD pipelines.

## Getting Started
```
pub global activate env_gen
```

## Initializing
Running `env_gen initialize` in the root of your Dart project will publish a template env.json file as well as some directory structures.
Feel free to change the name of environments or add more - just make sure to change the folder names as well if you are substiting files.

## Environment Variable Substitution
When using this tool in a CI pipeline you may want to use Secrets available in the runner - simply add a environment variable with the same name as
one defined in the env.json and it will be pulled in. If it is environment specific prepend the environment name to the variable:
```
// Example for an APP_KEY variable
APP_KEY=<appkeyhere>
PRODUCTION_APP_KEY=<productionappkeyhere>
```

## File Substitution
Drop files into any of the environment folders created on initialization and put their destinations in the env.json to have them copied over.
The destination is relative to your projects root directory.
```
// In env.json
"files": {
  "GoogleService-Info.plist": "ios/Runner/GoogleService-Info.plist"
}
```

## Env File
If you need a traditional .env file, use the `-e` flag.

## Publishing Changes
In order to generate a new env.dart file use `env_gen <environment>` for example `env_gen production`.