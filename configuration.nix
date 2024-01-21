# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

let
  userPkgs = pkgs: with pkgs; [
    # CLI utils, services, daemons, stuff
    tldr vim nano bat file
    usbutils pciutils fwupd clinfo glxinfo vulkan-tools wayland-utils
    wget curl git nmap
    socat libqmi uqmi
    htop neofetch
    speechd translate-shell
    nodejs
    mesa libdrm xorg.xf86videoamdgpu
    xsettingsd
    crawl
    nvd

    # Bluetooth
    bluez bluez-tools libsForQt5.bluedevil libsForQt5.bluez-qt

    # GUI Apps
    libsForQt5.powerdevil
    libsForQt5.kcalc
    libsForQt5.yakuake kate firefox
    filelight ark partition-manager
    krita aseprite-unfree shotcut obs-studio inkscape
    blockbench-electron
    maliit-keyboard
    vlc mpv gwenview songrec pavucontrol
    jetbrains.rider mono dotnet-sdk jetbrains.datagrip jetbrains.idea-community
    openvpn keepass remmina opensnitch-ui
    lutris bottles protonup-qt protontricks winePackages.waylandFull
    ppsspp-sdl-wayland
    lact scrcpy

    # KDE Plasma customization
    lightly-boehs
  ];
  desktopPkgs = pkgs: with pkgs; [
    lsb-release pciutils xorg.xrandr which perl xdg-utils iana-etc python3 procps usbutils xdg-user-dirs mesa sqlite
    xorg.libXcomposite xorg.libXtst xorg.libXrandr xorg.libXext xorg.libX11 xorg.libXfixes libGL libva
    harfbuzz libthai pango lsof file mesa.llvmPackages.llvm.lib vulkan-loader
    expat wayland xorg.libxcb xorg.libXdamage xorg.libxshmfence xorg.libXxf86vm libelf (lib.getLib elfutils)
    xorg.libXinerama xorg.libXcursor xorg.libXrender xorg.libXScrnSaver xorg.libXi xorg.libSM xorg.libICE
    gnome2.GConf curlWithGnuTls nspr nss cups libcap SDL2 libusb1 dbus-glib gsettings-desktop-schemas ffmpeg libudev0-shim
    fontconfig freetype xorg.libXt xorg.libXmu libogg libvorbis SDL SDL2_image glew110 libdrm libidn tbb zlib
    udev dbus
    glib gtk2 bzip2 flac freeglut libjpeg
    libpng libpng12 libsamplerate libmikmod libtheora libtiff pixman speex SDL_image SDL_ttf SDL_mixer SDL2_ttf SDL2_mixer
    libappindicator-gtk2 libdbusmenu-gtk2 libindicator-gtk2 libcaca libcanberra libgcrypt libvpx librsvg xorg.libXft libvdpau
    attr
    at-spi2-atk at-spi2-core gst_all_1.gstreamer gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-base json-glib
    libdrm libxkbcommon libvorbis libxcrypt mono ncurses openssl xorg.xkeyboardconfig xorg.libpciaccess xorg.libXScrnSaver
    icu gtk3 zlib atk cairo freetype gdk-pixbuf fontconfig libGLU libuuid libbsd alsa-lib libidn2 libpsl nghttp2.lib rtmpdump
    egl-wayland libglvnd
  ];
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix ./zfs.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nix.gc.automatic = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  system.stateVersion = "23.05";

  boot.zfs.forceImportRoot = false;
  boot.zfs.allowHibernation = true;

  zramSwap.enable = true;


#######################################################################################################################
#     Networking                                                                                                      #
#######################################################################################################################

  networking.hostName = "gwm9";
  networking.networkmanager.enable = true;

  services.resolved.enable = true;


#######################################################################################################################
#     IO                                                                                                              #
#######################################################################################################################

  services.udev.extraRules = ''
    # blacklist for usb autosuspend
    # BT.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="8087", ATTR{idProduct}=="0032", GOTO="power_usb_rules_end"

    # LTE.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2c7c", ATTR{idProduct}=="0125", GOTO="power_usb_rules_end"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2c7c", ATTR{idProduct}=="0125", ATTR{power/autosuspend}="-1"

    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    LABEL="power_usb_rules_end"

    # USB mouse
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3299", ATTR{idProduct}=="000b", ATTR{power/autosuspend}="-1"
  '';


#######################################################################################################################
#     Region, locales, fonts and stuff                                                                                #
#######################################################################################################################

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT    = "pl_PL.UTF-8";
    LC_MONETARY       = "pl_PL.UTF-8";
    LC_NAME           = "pl_PL.UTF-8";
    LC_NUMERIC        = "pl_PL.UTF-8";
    LC_PAPER          = "pl_PL.UTF-8";
    LC_TELEPHONE      = "pl_PL.UTF-8";
    LC_TIME           = "pl_PL.UTF-8";
  };

  fonts.fontconfig.defaultFonts.monospace = [ "JetBrains Mono" ];
  fonts.packages = with pkgs; [
    corefonts jetbrains-mono
  ];

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
    keyMap = "pl2";
  };


#######################################################################################################################
#     Graphical environment and stuff                                                                                 #
#######################################################################################################################

  services.xserver.enable = true;

  services.xserver.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.xserver.desktopManager.plasma5.enable = true;

  services.xserver.displayManager.defaultSession = "plasmawayland";

  programs.dconf.enable = true;

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
  };

  xdg.portal.enable = true;
  
  hardware.opengl.enable = true;


  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };


#######################################################################################################################
#     Users                                                                                                           #
#######################################################################################################################

  users.users.green = {
    description = "Green";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };


#######################################################################################################################
#     Programs & Services                                                                                             #
#######################################################################################################################

  environment.systemPackages = userPkgs pkgs ++ desktopPkgs pkgs;

  # Automatically creates a loader in /lib/* to avoid patching stuff
  programs.nix-ld = {
    enable = true;
    libraries = desktopPkgs pkgs;
  };

  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  services.fwupd.enable = true;

  programs.fish = {
    enable = true;
    shellInit = "ssh-add $HOME/.keys/gwm9";
  };

  programs.thefuck.enable = true;

  programs.xwayland.enable = true;

  services.netdata.enable = true;

  services.power-profiles-daemon.enable = true;
  /*services.tlp.enable = true;
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75; # DOESNT WORK ON GPD???
    STOP_CHARGE_THRESH_BAT0  = 80; # DOESNT WORK ON GPD???

    USB_AUTOSUSPEND  = 0;
    USB_EXCLUDE_WWAN = 1;
  };*/

  programs.kdeconnect.enable = true;

  programs.adb.enable = true;

  programs.npm.enable = true;

  programs = {
    ssh.startAgent = true;
  };

  programs.firefox.languagePacks = [ "en-US" "pl" ];
  nixpkgs.config.firefox.speechSynthesisSupport = true;

  nixpkgs.config.permittedInsecurePackages = [
    "python-2.7.18.6"
    "electron-25.9.0"
  ];

  programs.partition-manager.enable = true;

  programs.gamemode.enable = true;
  programs.steam.enable = true;

  services.openssh.enable = true;

  # Firewall manager
  services.opensnitch = {
    enable = true;
    rules = {
      systemd-timesyncd = {
        name = "systemd-timesyncd";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type ="simple";
          sensitive = false;
          operand = "process.path";
          data = "${pkgs.systemd}/lib/systemd/systemd-timesyncd";
        };
      };
      systemd-resolved = {
        name = "systemd-resolved";
        enabled = true;
        action = "allow";
        duration = "always";
        operator = {
          type ="simple";
          sensitive = false;
          operand = "process.path";
          data = "${pkgs.systemd}/lib/systemd/systemd-resolved";
        };
      };
    };
  };

  # End :)
}

