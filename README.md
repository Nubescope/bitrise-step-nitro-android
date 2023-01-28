# Nitro for Android

[![Step changelog](https://shields.io/github/v/release/nitro-build/bitrise-step-nitro-android?include_prereleases&label=changelog&color=blueviolet)](https://github.com/nitro-build/bitrise-step-nitro-android/releases)

Build your React Native app faster than ever with Nitro


<details>
<summary>Description</summary>

This step builds your React Native app for Android using [Nitro](https://nitro.build). Get your **API key** on our [website](https://nitro.build).

</details>

## 🧩 Get started

Add this step directly to your workflow in the [Bitrise Workflow Editor](https://devcenter.bitrise.io/steps-and-workflows/steps-and-workflows-index/).

You can also run this step directly with [Bitrise CLI](https://github.com/bitrise-io/bitrise).

## ⚙️ Configuration

<details>
<summary>Inputs</summary>

| Key | Description | Flags | Default |
| --- | --- | --- | --- |
| `root_directory` | The directory within your project, in which your code is located. Leave this field empty if your code is not located in a subdirectory |  | `./` |
| `flavor` | Set product flavor for Gradle build variant |  |  |
| `version_name` | The version name for the app |  |  |
| `version_code` | The version code for the app |  |  |
| `disable_version_name_from_package_json` | By default will get the 'version' field from package.json and set the version name |  | `no` |
| `disable_version_code_auto_generation` | By default will generate a timestamp based number and set the version code |  | `no` |
| `keystore_url` | Keystore url |  | `$BITRISEIO_ANDROID_KEYSTORE_URL` |
| `keystore_password` | Keystore password | sensitive | `$BITRISEIO_ANDROID_KEYSTORE_PASSWORD` |
| `keystore_key_alias` | Keystore alias |  | `$BITRISEIO_ANDROID_KEYSTORE_ALIAS` |
| `keystore_key_password` | Keystore key password | sensitive | `$BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD` |
| `cache_provider` | Choose the provider where cache artifacts will be persisted: - `fs`: File system - `s3`: Amazon - Simple Storage Service |  | `s3` |
| `disable_cache` | When setting this option to `yes` build cache optimizations won't be performed |  | `$NITRO_DISABLE_CACHE` |
| `cache_env_var_lookup_keys` | A list of `\|` separated values with env variable keys to lookup to determine whether the build should be cached or not |  |  |
| `cache_file_lookup_paths` | A list of `\|` separated value paths (relative to the root of the repo or absolute) to lookup in order to determine whether the build should be cached or not |  |  |
| `disable_metro_cache` | Setting this field to yes will disable the React Native Metro cache feature |  | `$NITRO_DISABLE_METRO_CACHE` |
| `aws_s3_access_key_id` | AWS access key ID for S3 bucket build caching |  | `$NITRO_AWS_S3_ACCESS_KEY_ID` |
| `aws_s3_secret_access_key` | AWS secret access key for S3 bucket build caching |  | `$NITRO_AWS_S3_SECRET_ACCESS_KEY` |
| `aws_s3_region` | AWS region where S3 bucket for build caching is located |  | `$NITRO_AWS_S3_REGION` |
| `aws_s3_bucket` | AWS bucket name for S3 bucket build caching |  | `$NITRO_AWS_S3_BUCKET` |
| `pre_install_command` | Run command prior to install project dependencies (e.g. `rm -rf ./some-folder`) |  |  |
| `pre_build_command` | Run command prior to start building the app (e.g. `yarn tsc && yarn test`) |  |  |
| `post_build_command` | Run command once build successfully finished (e.g. `yarn publish`) |  |  |
| `detox_configuration` | Select a device configuration from your defined configurations. |  |  |
| `output_directory` | The path to the directory where to place all of Nitro's output files |  | `$BITRISE_DEPLOY_DIR` |
| `entry_file` | The entry file for bundle generation |  | `$ENTRY_FILE` |
| `verbose` | Enable verbose logs |  | `no` |
| `debug` | Enable step debugging |  | `no` |
| `fail_safe` | Runing the app in this mode allows you to prevent the build to fail but you can check the status in further steps |  | `$NITRO_FAIL_SAFE` |
| `api_key` | The API key provided by Nitro. It should be defined by setting NITRO_API_KEY secret. | sensitive | `$NITRO_API_KEY` |
</details>

<details>
<summary>Outputs</summary>

| Environment Variable | Description |
| --- | --- |
| `NITRO_BUILD_STATUS` | The status of the latest build (success / failed) |
| `NITRO_OUTPUT_DIR` | The path to the directory where to place all of Nitro's output files |
| `NITRO_LOGS_PATH` | The full path to access the build log |
| `NITRO_SUMMARY_PATH` | The full path to access the build summary report |
| `NITRO_APP_PATH` | The full path to access the Android package (.apk) |
| `NITRO_DEPLOY_PATH` | The full path to access the Android package (.apk) |
</details>

## 🙋 Contributing

We welcome [pull requests](https://github.com/nitro-build/bitrise-step-nitro-android/pulls) and [issues](https://github.com/nitro-build/bitrise-step-nitro-android/issues) against this repository.

For pull requests, work on your changes in a forked repository and use the Bitrise CLI to [run step tests locally](https://devcenter.bitrise.io/bitrise-cli/run-your-first-build/).

Learn more about developing steps:

- [Create your own step](https://devcenter.bitrise.io/contributors/create-your-own-step/)
- [Testing your Step](https://devcenter.bitrise.io/contributors/testing-and-versioning-your-steps/)
