{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    java
    gradle_6
    groovy
    java-language-server
    jdk11
    kotlin
    kotlin-language-server
  ];
}
