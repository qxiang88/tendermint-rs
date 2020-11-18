#!/bin/bash
set -e

ARGS="$@"
TODAY=$(date +%Y-%m-%d)
TMP_RELEASE_FOLDER="/tmp/tendermint-rs-release/${TODAY}"
mkdir -p "${TMP_RELEASE_FOLDER}"

# A space-separated list of all the crates we want to publish, in the order in
# which they must be published. It's important to respect this order, since
# each subsequent crate depends on one or more of the preceding ones.
DEFAULT_CRATES="proto tendermint rpc light-client light-node testgen"

# Allows us to override the crates we want to publish.
CRATES=${ARGS:-${DEFAULT_CRATES}}
read -ra CRATES_ARR <<< "${CRATES}"

publish() {
  echo "Publishing crate $1..."
  cargo publish --manifest-path "$1/Cargo.toml"
  echo ""

  # Remember that we've published this crate today
  touch "${TMP_RELEASE_FOLDER}/$1"
}

publish_dry_run() {
  echo "Attempting dry run of publishing crate $1..."
  cargo publish --dry-run --manifest-path "$1/Cargo.toml"
}

list_package_files() {
  cargo package --list --manifest-path "$1/Cargo.toml"
}

echo "Attempting to publish crate(s): ${CRATES}"

for crate in "${CRATES_ARR[@]}"; do
  if [ -f "${TMP_RELEASE_FOLDER}/${crate}" ]; then
    echo "Crate \"${crate}\" has already been published today."
    read -rp "Do you want to publish again? (type YES to publish, anything else to skip) " answer
    case $answer in
      YES ) ;;
      * ) echo "Skipping"; continue;;
    esac
  fi

  publish_dry_run "${crate}"
  list_package_files "${crate}"
  echo ""
  read -rp "Are you sure you want to publish crate \"${crate}\"? (type YES to publish, anything else to exit) " answer
  case $answer in
    YES ) publish "${crate}"; break;;
    * ) echo "Terminating"; exit;;
  esac
done
