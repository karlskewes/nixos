{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gradle_6
    groovy
    java-language-server
    kotlin
    kotlin-language-server
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk11;
  };
}
