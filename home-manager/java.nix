{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gradle_7
    groovy
    java-language-server
    kotlin
    kotlin-language-server
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };
}
