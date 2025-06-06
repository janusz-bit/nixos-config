# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
  g14_patches = builtins.fetchTree "gitlab:asus-linux/fedora-kernel/4846e5cf0d61eda1aa03e767fc8ef4a2b87a6be0";
in
{
  imports = [
    <nixos-hardware/asus/fa507nv>
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./nix-alien.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      hplip
      splix
    ];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.dinosaur = {
    isNormalUser = true;
    description = "dinosaur";
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbusers"
    ];
    packages = with pkgs; [
      # vesktop # bcs of no sound in some games, I dont use it
      brave

      #  thunderbird
    ];
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "dinosaur";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kdePackages.kate
    nixfmt-rfc-style
    nixd
    vscodium-fhs
    git
    mangohud
    protonup-qt
    vlc
    discord
    heroic
    signal-desktop
    handbrake
    obsidian
    unstable.pandoc
    unstable.kdePackages.wallpaper-engine-plugin
    betterdiscordctl
    libreoffice-qt
    hunspell
    hunspellDicts.pl_PL

    neovim
    lazygit
    curl
    fzf
    ripgrep
    fd

    qbittorrent

    clang
    gcc

    clamav
    clamtk

    rustup
    python314Full

    unzip

    emacs

    nil

    wine64
    winetricks

    universal-android-debloater
  ];

  services.clamav.daemon.enable = true;
  services.clamav.updater.enable = true;

  fonts.packages = with pkgs; [ nerd-fonts._0xproto ];

  security.pam.services.sddm.kwallet.enable = true;
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      gamescopeSession.enable = true;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
      ];
    };
    direnv.enable = true;
    firefox.enable = true;
    gamemode.enable = true;
    partition-manager.enable = true;
  };

  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "~/.local/share/Steam/compatibilitytools.d";
  };

  programs.steam.extraCompatPackages = [
    pkgs.proton-ge-bin
  ];

  services.asusd.package = pkgs.asusctl.overrideAttrs {
    src = builtins.fetchTree "gitlab:asus-linux/asusctl/685345d6567bc366e93bbc3d7321f9d9a719a7ed";
  };
  services.supergfxd.enable = true;

  services.asusd.asusdConfig.text = ''
    (
        charge_control_end_threshold: 80,
        panel_od: false,
        boot_sound: false,
        mini_led_mode: false,
        disable_nvidia_powerd_on_battery: true,
        ac_command: "",
        bat_command: "",
        throttle_policy_linked_epp: true,
        throttle_policy_on_battery: Quiet,
        change_throttle_policy_on_battery: true,
        throttle_policy_on_ac: Performance,
        change_throttle_policy_on_ac: true,
        throttle_quiet_epp: Power,
        throttle_balanced_epp: BalancePower,
        throttle_performance_epp: Performance,
        ppt_pl1_spl: 105,
        ppt_pl2_sppt: 140,
        ppt_fppt: 140,
        nv_dynamic_boost: 5,
        nv_temp_target: 87,
    )
  '';

  services.syncthing = rec {
    enable = true;
    openDefaultPorts = true;
    user = "dinosaur";
    dataDir = "/home/${user}";
    configDir = "/home/${user}/.config/syncthing";
  };

  system.autoUpgrade = {
    enable = true;
    dates = "7d";

  };

  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # Add any missing dynamic libraries for unpackaged
  #   # programs here, NOT in environment.systemPackages
  # ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # hardware.graphics.enable32Bit = true;

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_13;
  boot.kernelPatches = [
    {
      name = "asus-patch-series.patch";
      patch = "${g14_patches}/asus-patch-series.patch";
    }
  ];

  programs.adb.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
