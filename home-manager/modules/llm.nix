{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.llm;
in
{
  options.custom.llm.claude-code = {
    enable = lib.mkEnableOption "claude-code wrapped with extra packages on PATH";

    package = lib.mkOption {
      description = "claude-code package to wrap";
      type = lib.types.package;
      default = pkgs.claude-code;
    };

    defaultPackages = lib.mkOption {
      description = "packages on claude-code's PATH, e.g: plugins required LSP's";
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        gopls
        pyright
        rust-analyzer
        typescript-language-server
      ];
    };
    extraPackages = lib.mkOption {
      description = "additional packages on claude-code's PATH";
      type = lib.types.listOf lib.types.package;
      default = [ ];
    };
  };

  config = {

    home.packages = with pkgs; [
      codex
      opencode

      (pkgs.symlinkJoin {
        name = "claude-code";
        paths = [ cfg.claude-code.package ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/claude \
          --prefix PATH : ${
            lib.makeBinPath (cfg.claude-code.defaultPackages ++ cfg.claude-code.extraPackages)
          }
        '';
      })
    ];
  };
}
