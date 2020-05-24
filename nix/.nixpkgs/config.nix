{
  allowUnfree = true;

  neovim = {
    withJemalloc = true;

    withPython = true;
    extraPythonPackages = [
    ];

    withPython3 = true;
    extraPython3Packages = [
    ];
  };

  vim = {
    python = true;
  };

  packageOverrides = pkgs: rec {
    pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
      plugins = [ pkgs.pidginotr ];
    };
  };
}
