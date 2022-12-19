#!/bin/bash
set -e

# ----------------------
# Advanced configuration
# ----------------------

# shellcheck disable=SC2154
if [[ "${fail_safe}" == "true" || "${fail_safe}" == "yes" ]]; then
  set +e
fi

# shellcheck disable=SC2154
if [[ "${debug}" == "true" || "${debug}" == "yes" ]]; then
  set -x
fi

if [[ -n ${entry_file} ]]; then
  export ENTRY_FILE="${entry_file}"
fi

# Obtain vm boot time
ps_command=$([[ "$(uname)" == "Darwin" ]] && echo "ps -eo lstart,command" || echo "ps -eo lstart,cmd")
date_command=$([[ "$(uname)" == "Darwin" ]] && echo "gdate" || echo "date")

bitrise_process_started_at=$(${ps_command} | grep "bitrise run" | grep -v grep | sed -e 's/^\(.\{24\}\).*/\1/' | head -1)
bitrise_process_started_at_ms=$(${date_command} -d "${bitrise_process_started_at:=$(date)}" "+%s%3N")

# Set environment variables
export NITRO_BOOTED_AT_TIMESTAMP="${bitrise_process_started_at_ms}"

# Build command arguments
args=("android")
args+=("--tracking-provider" "nitro-on-premise")

args+=("--build-id" "${BITRISE_BUILD_SLUG}")
args+=("--repo-path" "${BITRISE_SOURCE_DIR}")

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

if [[ -n ${keystore_url} ]]; then
  args+=("--keystore-url" "${keystore_url}")
fi

if [[ -n ${keystore_password} ]]; then
  args+=("--keystore-password" "${keystore_password}")
fi

if [[ -n ${keystore_key_alias} ]]; then
  args+=("--keystore-key-alias" "${keystore_key_alias}")
fi

if [[ -n ${keystore_key_password} ]]; then
  args+=("--keystore-key-password" "${keystore_key_password}")
fi

# -------
# Caching
# -------

if [[ -n ${cache_provider} ]]; then
  args+=("--cache-provider" "${cache_provider}")
fi

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

# shellcheck disable=SC2154
if [[ "${disable_metro_cache}" == "true" || "${disable_metro_cache}" == "yes" ]]; then
  args+=("--disable-metro-cache")
fi

if [[ -n ${aws_s3_access_key_id} ]]; then
  args+=("--aws-s3-access-key-id" "$aws_s3_access_key_id")
fi

if [[ -n ${aws_s3_secret_access_key} ]]; then
  args+=("--aws-s3-secret-access-key" "$aws_s3_secret_access_key")
fi

if [[ -n ${aws_s3_region} ]]; then
  args+=("--aws-s3-region" "$aws_s3_region")
fi

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BITRISE_STEP_VERSION=$(cat < "${SCRIPT_DIR}/package.json" | jq -r '.version')

MACOS_BIN_FILE="nitro-macos"
LINUX_BIN_FILE="nitro-linux"

BIN_FILE=$([[ "$(uname)" == "Darwin" ]] && echo "${MACOS_BIN_FILE}" || echo "${LINUX_BIN_FILE}")
BIN_FILE_PATH="${SCRIPT_DIR}/nitro"

# Download cli release
wget -q "https://github.com/nitro-build/bitrise-step-nitro-android/releases/download/${BITRISE_STEP_VERSION}/${BIN_FILE}" -O "${BIN_FILE_PATH}"
chmod +x "${BIN_FILE_PATH}"
${BIN_FILE_PATH} "${args[@]}"

exit_code=$?

if [[ exit_code -ne 0 ]]; then
  echo "⚠️ Nitro has thrown a '${exit_code}' error code while running on fail-safe mode. You can check 'NITRO_BUILD_FAILED' value in further steps."
  envman add --key "NITRO_BUILD_FAILED" --value "true"
  envman add --key "NITRO_BUILD_STATUS" --value "failed"
else
  envman add --key "NITRO_BUILD_FAILED" --value "false"
  envman add --key "NITRO_BUILD_STATUS" --value "success"
fi
