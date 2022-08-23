#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CREATE_TMP_DIR_CMD=$([[ "$(uname)" == "Darwin" ]] && echo "mktemp -d -t nitro" || echo "mktemp -d -t")
TMP_DIR=$($CREATE_TMP_DIR_CMD)
NITRO_SOURCE_DIR="$SCRIPT_DIR/node_modules/nitro"
NITRO_SOURCE_TMP_DIR="$TMP_DIR/nitro"
NITRO_CLI_TMP_DIR="$NITRO_SOURCE_TMP_DIR/packages/cli"

cp -R "$NITRO_SOURCE_DIR" "$TMP_DIR"

# Install Nitro dependencies
cd "$NITRO_SOURCE_TMP_DIR"
yarn

# Update default configuration
default_config_path="$NITRO_CLI_TMP_DIR/src/config/default.ts"

if [[ -n ${NITRO_API_HOST} ]]; then
  sed -i'' 's,\(apiHost:\).*,\1 '\'"$NITRO_API_HOST"\'\\,',g' "$default_config_path"
fi
if [[ -n ${NITRO_AWS_ACCESS_KEY_ID} ]]; then
  sed -i'' 's,\(awsS3AccessKeyId:\).*,\1 '\'"$NITRO_AWS_ACCESS_KEY_ID"\'\\,',g' "$default_config_path"
fi
if [[ -n ${NITRO_AWS_SECRET_ACCESS_KEY} ]]; then
  sed -i'' 's,\(awsS3SecretAccessKey:\).*,\1 '\'"$NITRO_AWS_SECRET_ACCESS_KEY"\'\\,',g' "$default_config_path"
fi
if [[ -n ${NITRO_AWS_S3_REGION} ]]; then
  sed -i'' 's,\(awsS3Region:\).*,\1 '\'"$NITRO_AWS_S3_REGION"\'\\,',g' "$default_config_path"
fi
if [[ -n ${NITRO_AWS_S3_BUCKET} ]]; then
  sed -i'' 's,\(awsS3Bucket:\).*,\1 '\'"$NITRO_AWS_S3_BUCKET"\'\\,',g' "$default_config_path"
fi

# Build Nitro cli
cd "$NITRO_CLI_TMP_DIR"
yarn dist

# Copy Nitro binaries to publish a new release
cd "$SCRIPT_DIR"
rm -rf "$SCRIPT_DIR/dist"
cp -R "$NITRO_CLI_TMP_DIR/dist" "$SCRIPT_DIR"

# Remove temp dir
rm -rf "$TMP_DIR"
