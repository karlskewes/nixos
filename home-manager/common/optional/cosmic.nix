{ pkgs, ... }: {
  imports = [ ./desktop.nix ./wayland.nix ];

  home.packages = with pkgs; [ cosmic-ext-calculator ];
}
