{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flutter-nix = {
      url = "github:maximoffua/flutter.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, devenv, systems, ... } @ inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in
    {
      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
      });

      devShells = forEachSystem
        (system:
          let
            pkgs = import nixpkgs { system = "${system}"; config.allowUnfree = true; };
          in
          {
            default =
              let
                inherit (inputs) flutter-nix android-nixpkgs;
                flutter-sdk = flutter-nix.packages.${system};
                sdk = (import android-nixpkgs { }).sdk (sdkPkgs:
                  with sdkPkgs; [
                    build-tools-30-0-3
                    build-tools-34-0-0
                    cmdline-tools-latest
                    emulator
                    platform-tools
                    platforms-android-34
                    platforms-android-33
                    platforms-android-31
                    platforms-android-28
                    system-images-android-34-google-apis-playstore-x86-64
                  ]);
              in
              devenv.lib.mkShell {
                inherit inputs pkgs;
                modules = [
                  ({ pkgs, config, ... }:
                    {
                      # https://devenv.sh/basics/
                      # dotenv.enable = true;
                      env.ANDROID_AVD_HOME = "${config.env.DEVENV_ROOT}/.android/avd";
                      env.ANDROID_SDK_ROOT = "${sdk}/share/android-sdk";
                      env.ANDROID_HOME = config.env.ANDROID_SDK_ROOT;
                      env.CHROME_EXECUTABLE = "chromium";
                      env.FLUTTER_SDK = "${pkgs.flutter}";
                      env.GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${sdk}/share/android-sdk/build-tools/34.0.0/aapt2";

                      # https://devenv.sh/packages/
                      packages = [
                        flutter-sdk.flutter
                        pkgs.git
                        pkgs.lazygit
                        pkgs.chromium
                        pkgs.cmake
                        pkgs.ninja
                        # General dependencies
                        pkgs.python3
                        pkgs.just
                        # Flutter-rust-bridge dependencies
                        pkgs.cargo
                        pkgs.rustc
                        # Media_Kit dependencies
                        pkgs.mpv-unwrapped.dev
			                  pkgs.gnumake
                        pkgs.libass
                        pkgs.mimalloc
                        pkgs.ffmpeg
                        pkgs.libdvdnav
                        pkgs.libdvdread
                        pkgs.mujs
                        pkgs.lcms
                        pkgs.libbluray
                        pkgs.lua
                        pkgs.rubberband
                        pkgs.SDL2.dev
                        pkgs.libuchardet
                        pkgs.zimg
                        pkgs.alsa-lib
                        pkgs.openal
                        pkgs.pipewire
                        pkgs.libpulseaudio
                        pkgs.libcaca
                        pkgs.libdrm
                        pkgs.mesa.dev
                        pkgs.libplacebo
                        pkgs.libunwind
                        pkgs.shaderc
                        pkgs.vulkan-headers
                        pkgs.vulkan-loader
                        pkgs.libdovi
                        pkgs.xorg.libXScrnSaver
                        pkgs.xorg.libXpresent
                        pkgs.xorg.libXv
                        pkgs.nv-codec-headers-12
                        pkgs.libva
                        pkgs.libvdpau
                        pkgs.libepoxy.dev
                        pkgs.pkg-config
                        pkgs.libglvnd.dev
                        pkgs.wayland.dev
                      ];

                      # https://devenv.sh/scripts/
                      # Create the initial AVD that's needed by the emulator
                      scripts.create-avd.exec = "avdmanager create avd --force --name tablet --package 'system-images;android-34;google_apis_playstore;x86_64' --device 'pixel_tablet'";
                      scripts.start-avd.exec = "emulator -avd tablet";
                      scripts.generate.exec = "dart run build_runner watch";

                      # https://devenv.sh/processes/
                      # These processes will all run whenever we run `devenv run`
                      # processes.grovero-app.exec = "flutter run lib/main.dart";
                      
                      enterShell = ''
                        mkdir -p $ANDROID_AVD_HOME
                        export PATH="${sdk}/bin:$PATH"
                        export FLUTTER_GRADLE_PLUGIN_BUILDDIR="''${XDG_CACHE_HOME:-$HOME/.cache}/flutter/gradle-plugin";
                        export CUSTOM_EGLPLATFORM_HEADER_PATH="${pkgs.libglvnd.dev}/include"
                        export CUSTOM_WAYLAND_CLIENT_HEADER_PATH="${pkgs.wayland.dev}/include"
                      '';

                      # https://devenv.sh/languages/
                      languages.dart = {
                        enable = true;
                        package = flutter-sdk.flutter;
                      };
                      languages.java = {
                        enable = true;
                        gradle.enable = false;
                        jdk.package = pkgs.jdk;
                      };

                      # See full reference at https://devenv.sh/reference/options/
                    })
                ];
              };
          });
    };
}
