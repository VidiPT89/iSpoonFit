#!/bin/sh
# Downloads the Firebase config for the iOS app into the app bundle sources.
# Run it again after enabling a new sign-in provider in the Firebase console:
# Google Sign-In only adds CLIENT_ID and REVERSED_CLIENT_ID once it is on.
#
#     sh scripts/fetch-firebase-config.sh
set -eu
cd "$(dirname "$0")/.."
firebase apps:sdkconfig IOS 1:618033728790:ios:9274fc716f916133b6d437 \
  --project ispoonfit-vidi \
  --out SpoonFit/Config/GoogleService-Info.plist
