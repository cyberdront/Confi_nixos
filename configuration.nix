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

  programs.adb.enable = true;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.permittedInsecurePackages = ["openssl-1.0.2u" ]; #"adobe-reader-9.5.5-1"];

  networking.hostName = "BStation"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;

  services.teamviewer.enable = false;

  i18n.defaultLocale = "ru_RU.UTF-8";
  time.timeZone = "Europe/Samara";
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts
    dina-font
    proggyfonts
    hack-font
    nerdfonts
  ];

  environment.systemPackages = with pkgs; [
    #default
    wget mc htop

    #util
    testdisk-qt slock

    #application
    baobab dia libreoffice slack gnucash fbreader calibre blender gimp firefox
    tdesktop vlc pgadmin remmina google-chrome chromium translate-shell
    transmission-gtk vivaldi-widevine discord freecad
    screen avidemux ffmpeg-full lame
    cudatoolkit

    #wine
    steam winetricks protontricks steam-run steamcmd #linux-steam-integration
    steam-run playonlinux
    sc-controller #steamcontroller 
    
    # support both 32- and 64-bit applications
    #wineWowPackages.stable
    # support 32-bit only
    wine
    # support 64-bit only
    # (wine.override { wineBuild = "wine64"; })
    # wine-staging (version with experimental features)
    # wineWowPackages.staging

    #games
    #minecraft minecraft-server multimc

    #sound maker
    audacity ardour FIL-plugins lmms mixxx

    #develop
    atom #android-studio vscodium
    jetbrains.pycharm-community
    #ghcid

    #language
    clisp sbcl gcc cmake clang llvm autobuild autoconf automake binutils
    mono gitAndTools.gitFull coreutils-full

    #haskell
    ghc ghcid stack cabal-install

    #tools
    mtpfs jmtpfs pavucontrol microcodeIntel ntfs3g btrfs-progs zfs zfstools firmwareLinuxNonfree
    gparted psmisc bcache-tools debianutils p7zip unzip unrar gzip zstd
    drive

    msbuild #monodevelop unity3d aqbanking
    xits-math skypeforlinux
    #yandex-disk

    #fonts
    #hack-font

    #python
    python38
    python38Packages.virtualenv
    python38Packages.pip python38Packages.pip-tools #python37Packages.pip2nix
    python38Packages.pipdate
    python38Packages.pyudev python38Packages.evdev
    python38Packages.ds4drv

    #library
    #musl libunwind lit lld wllvm
    x264 openh264 #gstreamer

    #mesa wayland wayland-protocols pkg-configUpstream pkg-config meson
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  hardware.steam-hardware.enable = true;

  # Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;
  
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.support32Bit = true;
  hardware.pulseaudio.extraModules = [ pkgs.pulseaudio-modules-bt ];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us,ru(winkeys)";
  services.xserver.xkbOptions = "grp:ctrl_shift_toggle";
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };

  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";
  #services.xserver.desktopManager.xfce.thunarPlugins = [];
  services.picom = {
    enable          = true;
    fade            = true;
    inactiveOpacity = 0.9;
    shadow          = true;
    fadeDelta       = 4;
  };

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
