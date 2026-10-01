#!/usr/bin/env bash
# Reads the live Royal Seed version from each store and rewrites version.json.
# A store that cannot be read, or that reports an older version than the one
# already recorded (Apple's lookup cache can lag), keeps its current value.
set -uo pipefail

BUNDLE_ID=biz.royalseed.app
SEMVER='^[0-9]+\.[0-9]+(\.[0-9]+)?$'
fail=0

# resolve <platform> <fetched version>: sets RESULT to the version to record.
resolve() {
  local current
  current=$(jq -r ".$1" version.json)
  RESULT=$current
  if ! [[ $2 =~ $SEMVER ]]; then
    echo "::error::$1: could not read store version (got '$2')"
    fail=1
  elif [[ $(printf '%s\n' "$current" "$2" | sort -V | tail -n1) == "$2" ]]; then
    RESULT=$2
  else
    echo "::warning::$1: store reports $2, older than recorded $current"
  fi
}

ios=$(curl -fsS -m 30 --retry 3 \
  "https://itunes.apple.com/lookup?bundleId=$BUNDLE_ID&t=$(date +%s)" |
  jq -r '.results[0].version // empty')

# The Play Store has no public version API; the version sits in the page data.
android=$(curl -fsS -m 30 --retry 3 \
  "https://play.google.com/store/apps/details?id=$BUNDLE_ID&hl=en&gl=US" |
  grep -oE '\[\[\["[0-9]+\.[0-9]+(\.[0-9]+)?"\]\]' | head -n1 | grep -oE '[0-9.]+')

resolve android "$android"
android=$RESULT
resolve ios "$ios"
ios=$RESULT

jq -n --arg android "$android" --arg ios "$ios" '{android: $android, ios: $ios}' \
  >version.json
cat version.json
exit $fail
