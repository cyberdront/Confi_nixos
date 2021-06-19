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
  services.fwupd.enable = true;
  nix.binaryCaches = [ "https://nixcache.reflex-frp.org" ];
  nix.binaryCachePublicKeys = [ "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" ];
  nix.trustedUsers = [ "root" "cyberdront" ];
  nixpkgs =
    let
      withUnstable =
        let
          unstableTar = builtins.fetchTarball http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz;
          masterTar = builtins.fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz;
        in
        self: super: {
          unstable = import unstableTar { config = config.nixpkgs.config; };
          master = import masterTar { config = config.nixpkgs.config; };
        };
    in
    {
      overlays = [ withUnstable ];
      config = {
        allowUnfree = true;
        allowUnfreePredicate = (pkg: true);
        allowBroken = true;
        permittedInsecurePackages = ["openssl-1.0.2u" "adobe-reader-9.5.5-1"];
      };
    };
  networking.hostName = "BStation"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.useDHCP = false;
  networking.interfaces.enp7s0.useDHCP = true;
  networking.timeServers = [ "ntp1.vniiftri.ru" ];

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
    wget mc htop
    testdisk-qt slock
    baobab dia libreoffice slack gnucash fbreader calibre blender gimp firefox
    tdesktop vlc remmina google-chrome translate-shell
    transmission-gtk vivaldi-widevine discord freecad
    screen avidemux ffmpeg-full lame
    imagemagick
    zeroad
    steam protontricks 
    steamPackages.steam steamPackages.steamcmd steamPackages.steam-fonts steamPackages.steam-runtime
    sc-controller 
    logitech-udev-rules    
    wineWowPackages.full winetricks playonlinux
    openttd
    audacity ardour FIL-plugins lmms mixxx
    atom vscodium
    sunxi-tools
    clisp sbcl gcc cmake llvm autobuild autoconf automake binutils
    git nix-prefetch-github git-lfs
    coreutils-full patchelf
    ghc ghcid stack cabal-install
    haskellPackages.haskell-language-server

    mtpfs jmtpfs pavucontrol microcodeIntel ntfs3g btrfs-progs zfs zfstools firmwareLinuxNonfree
    gparted psmisc bcache-tools debianutils p7zip unzip unrar gzip zstd
    drive

    mono #msbuild #monodevelop
    unity3d
    dotnet-netcore

    xits-math skypeforlinux

    #python
    python38
    python38Packages.virtualenv
    python38Packages.pip python38Packages.pip-tools python38Packages.pipdate

    x264 openh264 #gstreamer

  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  #Steam
  programs.steam.enable = true;
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

  programs.java.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
    extraPackages= with pkgs; [ vaapiVdpau libvdpau-va-gl ];
    extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  };


  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.displayManager.defaultSession = "xfce";
  services.picom = {
    enable          = true;
    fade            = true;
    inactiveOpacity = 0.9;
    shadow          = false;
    fadeDelta       = 4;
  };

  users.users.cyberdront = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/cyberdront";
    createHome = true;
    extraGroups = [ "wheel" "disk" "audio" "dialout" "users" "adm" "networkmanager" "adbusers" "nixbld" "input" "docker" ];
    description = "Marat Yanchurin";
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    enableTCPIP = true;
    dataDir = "/datastor/PostgresqlDB";
    authentication = pkgs.lib.mkOverride 12 ''
      local all all trust
      host all all 192.168.95.0/24 trust
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

  system.stateVersion = "20.09";

}
