{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.memtest86.enable = true;

  nix.buildCores = 0;
  security.wrappers.slock.source = "${pkgs.slock.out}/bin/slock";

  virtualisation.libvirtd.enable = true;
  services.qemuGuest.enable = true;
  programs.adb.enable = true;

  #nixpkgs.pkgs = import (builtins.fetchTarball https://github.com/nixos/nixpkgs/archive/master.tar.gz) {inherit (config.nixpkgs) config overlays; };
  #nixpkgs.crossSystem = { system = "aarch64-linux"; config = aarch64-unknown-linux-gnu"; };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.permittedInsecurePackages = ["openssl-1.0.2u"];
  networking.hostName = "BStation"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;

  i18n.defaultLocale = "ru_RU.UTF-8";
  time.timeZone = "Europe/Samara";

  environment.systemPackages = with pkgs; [
    #default
    wget mc htop

    #util
    testdisk-qt slock

    #bluetooth
    bluez-tools

    #application
    adobe-reader baobab dia libreoffice slack gnucash fbreader blender gimp firefox
    tdesktop vlc pgadmin remmina protontricks
    google-chrome chromium translate-shell
    transmission transmission-gtk xits-math skypeforlinux

    #sound maker
    audacity ardour FIL-plugins lmms mixxx

    #language
    clisp sbcl clojure mono stack cabal-install cmake
    gcc ghc atom clang gitAndTools.gitFull llvm autobuild autoconf automake binutils
    coreutils-full
    #monodevelop unity3d

    #tools
    mtpfs jmtpfs slock pavucontrol microcodeIntel ntfs3g btrfs-progs zfs zfstools firmwareLinuxNonfree
    gparted psmisc bcache-tools debianutils p7zip
    drive

    #develop
    jetbrains.pycharm-community android-studio vscodium

    #game
    steam (wine.override { wineBuild = "wineWow"; })
    steam-run steam-run-native playonlinux samba

    #yandex-disk

    #fonts
    hack-font

    #emul
    #anbox

    #python
    python3
    python37
    python38
    python
    #python37Packages.binwalk
    #python37Packages.folium python37Packages.pandas python37Packages.geojson
    #python37Packages.geopandas python37Packages.pgsanity python37Packages.six
    #python37Packages.virtualenv python37Packages.markupsafe python37Packages.jinja2
    #python37Packages.branca python37Packages.numpy python37Packages.requests
    #python37Packages.urllib3 python37Packages.pytz python37Packages.dateutil
    #python37Packages.chardet python37Packages.certifi python37Packages.idna
    #python37Packages.pycairo python37Packages.django
    #python37Packages.flask
    #python38Packages.binwalk
    #conda pew

    #library
    musl libunwind
    x264 openh264 gstreamer pitivi

    #mobile-nixos
    mesa wayland wayland-protocols pkg-configUpstream pkg-config
    meson
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.support32Bit = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us,ru(winkeys)";
  services.xserver.xkbOptions = "grp:ctrl_shift_toggle";
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";

  services.compton.enable = true;
  services.compton.fade = true;
  services.compton.inactiveOpacity = "0.9";
  services.compton.shadow = true;
  services.compton.fadeDelta = 4;

  #services.samba.enable = true;

  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    enableTCPIP = true;
    dataDir = "/datastor/PostgresqlDB";
    authentication = pkgs.lib.mkOverride 11 ''
      local all all trust
      host all all 192.168.95.1/24 trust
      host all all ::1/128 trust
    '';
  };

  nix.gc = {
    automatic = true;
    dates = "21:00";
    options = "-d";
  };
  nix.optimise = {
    automatic = true;
    dates = [ "20:00" ];
  };

}
