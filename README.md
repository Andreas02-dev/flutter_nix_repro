# Reproduction steps for working example

- `cd working/test`
- Run `direnv allow` or `nix develop`
- Get dependencies by running `flutter pub get`
- Run `dart run build_runner doctor -v`
- Notice the output shows `build_runner` is working.

# Reproduction steps for failing example

- `cd failing/test`
- Run `direnv allow` or `nix develop`
- Get dependencies by running `flutter pub get`
- Run `dart run build_runner doctor -v`
- Notice the output shows `build_runner` is failing because the Flutter SDK is not available.

# Meaningful differences

- Only the flake.nix and flake.lock have been updated to 24.05 in `failing`.
