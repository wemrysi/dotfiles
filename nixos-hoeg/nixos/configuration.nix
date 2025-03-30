# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.fontSize = 18;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  # Enable networking
  networking.hostName = "hoeg"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
    };
  };

  # Power
  powerManagement.enable = true;
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Fonts
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];

  # X11
  services.xserver = {
    enable = true;

    dpi = 220;
    upscaleDefaultCursor = true;

    windowManager.xmonad.enable = true;
    windowManager.xmonad.enableContribAndExtras = true;
    displayManager.lightdm.enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "emrys";

  services.actkbd = {
    enable = true;
    bindings = [
      # "Mute" media key
      { keys = [ 113 ]; events = [ "key" ]; command = "${pkgs.alsa-utils}/bin/amixer -q -c 0 set Master toggle"; }
      # "Lower Volume" media key
      { keys = [ 114 ]; events = [ "key" "rep" ]; command = "${pkgs.alsa-utils}/bin/amixer -q -c 0 set Master 1%- unmute"; }
      # "Raise Volume" media key
      { keys = [ 115 ]; events = [ "key" "rep" ]; command = "${pkgs.alsa-utils}/bin/amixer -q -c 0 set Master 1%+ unmute"; }
      # "Dim" media key
      { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -s sysfs/backlight/intel_backlight -U 5"; }
      # "Brighten" media key
      { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.light}/bin/light -s sysfs/backlight/intel_backlight -A 5"; }
    ];
  };

  # Key remapping
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            # tap = esc, hold = ctl
            capslock = "overload(control, esc)";
            insert = "S-insert";
          };
        };
      };
    };
  };

  # Ensure palm rejection works with keyd
  # https://github.com/rvaiya/keyd/issues/723
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd virtual keyboard
    AttrKeyboardIntegration=internal
  '';

  services.libinput.touchpad.disableWhileTyping = true;
  services.libinput.touchpad.naturalScrolling = true;

  users.users.emrys = {
    isNormalUser = true;
    description = "Emrys Ingersoll";
    extraGroups = [ "networkmanager" "video" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    alacritty
    alsa-utils
    autojump
    blueman
    discord
    dmenu-rs
    helix
    i3lock-color
    pasystray
    stalonetray
    stow
    tmux
    xmobar
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.4";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    XCURSOR_SIZE = "64";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "emrys" ];
  };
  programs.gnupg.agent = {
    enable = true;
    settings = {
      default-cache-ttl = 14400;
    };
  };
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.light.enable = true;
  programs.nm-applet.enable = true;
  programs.ssh.startAgent = true;
  programs.xss-lock = {
    enable = true;
    extraOptions = [ "--transfer-sleep-lock" ];
    lockerCommand = "${pkgs.i3lock-color}/bin/i3lock --nofork --clock --indicator";
  };
  programs.zsh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
