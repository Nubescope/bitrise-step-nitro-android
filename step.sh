#!/bin/bash

# Do not exit on errors. If "safe mode" is not enabled it will exit properly at the end.
set +e

# ----------------------
# Advanced configuration
# ----------------------

# shellcheck disable=SC2154
if [[ "${debug}" == "true" || "${debug}" == "yes" ]]; then
  set -x
fi

entry_file="${entry_file:-${ENTRY_FILE}}"
if [[ -n ${entry_file} ]]; then
  export ENTRY_FILE="${entry_file}"
fi

# Build command arguments
args=("android")
args+=("--output-format" "json")
args+=("--repo-path" "${BITRISE_SOURCE_DIR}")

api_key="${api_key:-${NITRO_API_KEY}}"
args+=("--api-key" "${api_key}")

# -------------------
# Basic configuration
# -------------------

if [[ -n ${root_directory} ]]; then
  args+=("--root-directory" "${root_directory}")
fi

if [[ -n ${flavor} ]]; then
  args+=("--flavor" "${flavor}")
fi

# --------------
# App Versioning
# --------------

if [[ -n ${version_name} ]]; then
  args+=("--version-name" "${version_name}")
fi

if [[ -n ${version_code} ]]; then
  args+=("--version-code" "${version_code}")
fi

# shellcheck disable=SC2154
if [[ "${disable_version_name_from_package_json}" == "true" || "${disable_version_name_from_package_json}" == "yes" ]]; then
  args+=("--disable-version-name-from-package-json")
fi

# shellcheck disable=SC2154
if [[ "${disable_version_code_auto_generation}" == "true" || "${disable_version_code_auto_generation}" == "yes" ]]; then
  args+=("--disable-version-code-auto-generation")
fi

# -----------
# App Signing
# -----------

keystore_url="${keystore_url:-${BITRISEIO_ANDROID_KEYSTORE_URL}}"
if [[ -n ${keystore_url} ]]; then
  args+=("--keystore-url" "${keystore_url}")
fi

keystore_password="${keystore_password:-${BITRISEIO_ANDROID_KEYSTORE_PASSWORD}}"
if [[ -n ${keystore_password} ]]; then
  args+=("--keystore-password" "${keystore_password}")
fi

keystore_key_alias="${keystore_key_alias:-${BITRISEIO_ANDROID_KEYSTORE_ALIAS}}"
if [[ -n ${keystore_key_alias} ]]; then
  args+=("--keystore-key-alias" "${keystore_key_alias}")
fi

keystore_key_password="${keystore_key_password:-${BITRISEIO_ANDROID_KEYSTORE_PRIVATE_KEY_PASSWORD}}"
if [[ -n ${keystore_key_password} ]]; then
  args+=("--keystore-key-password" "${keystore_key_password}")
fi

# -------
# Caching
# -------

if [[ -n ${cache_provider} ]]; then
  args+=("--cache-provider" "${cache_provider}")
fi

disable_cache="${disable_cache:-${NITRO_DISABLE_CACHE}}"
# shellcheck disable=SC2154
if [[ "${disable_cache}" == "true" || "${disable_cache}" == "yes" ]]; then
  args+=("--disable-cache")
fi

if [[ -n ${cache_env_var_lookup_keys} ]]; then
  IFS='|' cache_env_var_lookup_keys_value=("${cache_env_var_lookup_keys}")
  # shellcheck disable=SC2206
  args+=("--cache-env-var-lookup-keys" ${cache_env_var_lookup_keys_value[@]})
fi

if [[ -n ${cache_file_lookup_paths} ]]; then
  IFS='|' cache_file_lookup_paths_value=("${cache_file_lookup_paths}")
  # shellcheck disable=SC2206
  args+=("--cache-file-lookup-paths" ${cache_file_lookup_paths_value[@]})
fi

disable_metro_cache="${disable_metro_cache:-${NITRO_DISABLE_METRO_CACHE}}"
# shellcheck disable=SC2154
if [[ "${disable_metro_cache}" == "true" || "${disable_metro_cache}" == "yes" ]]; then
  args+=("--disable-metro-cache")
fi

aws_s3_access_key_id="${aws_s3_access_key_id:-${NITRO_AWS_S3_ACCESS_KEY_ID}}"
if [[ -n ${aws_s3_access_key_id} ]]; then
  args+=("--aws-s3-access-key-id" "$aws_s3_access_key_id")
fi

aws_s3_secret_access_key="${aws_s3_secret_access_key:-${NITRO_AWS_S3_SECRET_ACCESS_KEY}}"
if [[ -n ${aws_s3_secret_access_key} ]]; then
  args+=("--aws-s3-secret-access-key" "$aws_s3_secret_access_key")
fi

aws_s3_region="${aws_s3_region:-${NITRO_AWS_S3_REGION}}"
if [[ -n ${aws_s3_region} ]]; then
  args+=("--aws-s3-region" "$aws_s3_region")
fi

aws_s3_bucket="${aws_s3_bucket:-${NITRO_AWS_S3_BUCKET}}"
if [[ -n ${aws_s3_bucket} ]]; then
  args+=("--aws-s3-bucket" "$aws_s3_bucket")
fi

# -----
# Hooks
# -----

if [[ -n ${pre_install_command} ]]; then
  args+=("--pre-install-command" "${pre_install_command}")
fi

if [[ -n ${pre_build_command} ]]; then
  args+=("--pre-build-command" "${pre_build_command}")
fi

if [[ -n ${post_build_command} ]]; then
  args+=("--post-build-command" "${post_build_command}")
fi

# --------
# Advanced
# --------

if [[ -n ${detox_configuration} ]]; then
  args+=("--detox-configuration" "${detox_configuration}")
fi

output_directory="${output_directory:-${BITRISE_DEPLOY_DIR}}"
if [[ -n ${output_directory} ]]; then
  args+=("--output-directory" "${output_directory}")
fi

# shellcheck disable=SC2154
if [[ "${verbose}" == "true" || "${verbose}" == "yes" ]]; then
  args+=("--verbose")
fi

# -------------------
# Nitro Cli execution
# -------------------

NITRO_OUTPUT_JSON_PATH="$(pwd)/nitro-output.json"
npx @nitro-build/cli@^0.11.0 "${args[@]}"
exit_code=$?

# Set environment variables using envman
if [[ exit_code -ne 0 ]]; then
  envman add --key "NITRO_BUILD_STATUS" --value "failed"
else
  envman add --key "NITRO_BUILD_STATUS" --value "success"
fi

if [ -f "${NITRO_OUTPUT_JSON_PATH}" ]; then
  output=$(cat < "${NITRO_OUTPUT_JSON_PATH}")

  echo "${output}" | jq -r '.appPath' | xargs -I{} echo -n {} | envman add --key NITRO_APP_PATH
  echo "${output}" | jq -r '.outputDir' | xargs -I{} echo -n {} | envman add --key NITRO_OUTPUT_DIR
  echo "${output}" | jq -r '.summaryPath' | xargs -I{} echo -n {} | envman add --key NITRO_SUMMARY_PATH
  echo "${output}" | jq -r '.logsPath' | xargs -I{} echo -n {} | envman add --key NITRO_LOGS_PATH
else
  echo "File not found: ${NITRO_OUTPUT_JSON_PATH}"
fi

fail_safe="${fail_safe:-${FAIL_SAFE}}"
# shellcheck disable=SC2154
if [[ "${fail_safe}" == "true" || "${fail_safe}" == "yes" ]]; then
  if [[ exit_code -ne 0 ]]; then
    echo "⚠️ Nitro has thrown a '${exit_code}' error code while running on fail-safe mode. You can check 'NITRO_BUILD_STATUS' value in further steps."
  fi
else
  # If not running in "safe mode" exit with captured exit_code
  set -e
  exit $exit_code
fi
