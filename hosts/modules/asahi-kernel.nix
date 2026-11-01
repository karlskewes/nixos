{ lib, ... }:
let
  disable = symbols: lib.genAttrs symbols (_: lib.mkForce lib.kernel.no);

  # Options that nixpkgs sets and that have no parent after the cuts below.
  orphaned = symbols: lib.genAttrs symbols (_: lib.mkForce (lib.kernel.option lib.kernel.no));

  # Kept on purpose:
  # - IIO, the Apple AOP ambient light sensor driver needs it.
  # - NET_VENDOR_{BROADCOM,INTEL,REALTEK,AQUANTIA,MARVELL}, Thunderbolt dock NICs.
  # - USB_NET_*, USB ethernet.
  # - WLAN_VENDOR_* with a USB driver, USB wifi dongles.
  # NET_VENDOR_{ACTIONS,ALLWINNER,FREESCALE} and SND_SOC_{QCOM,SAMSUNG,SPRD}
  # go away with the ARCH_* cuts, so they are not listed.
  netVendors = map (v: "NET_VENDOR_${v}") [
    "3COM"
    "ADAPTEC"
    "ADI"
    "AGERE"
    "ALACRITECH"
    "AMAZON"
    "AMD"
    "ARC"
    "ASIX"
    "ATHEROS"
    "BROCADE"
    "CADENCE"
    "CAVIUM"
    "CHELSIO"
    "CISCO"
    "CORTINA"
    "DAVICOM"
    "DEC"
    "DLINK"
    "EMULEX"
    "ENGLEDER"
    "EZCHIP"
    "FUNGIBLE"
    "GOOGLE"
    "HISILICON"
    "HUAWEI"
    "I825XX"
    "LITEX"
    "MEDIATEK"
    "MELLANOX"
    "META"
    "MICREL"
    "MICROCHIP"
    "MICROSEMI"
    "MICROSOFT"
    "MUCSE"
    "MYRI"
    "NATSEMI"
    "NETRONOME"
    "NI"
    "NVIDIA"
    "OKI"
    "PENSANDO"
    "QLOGIC"
    "QUALCOMM"
    "RDC"
    "RENESAS"
    "ROCKER"
    "SAMSUNG"
    "SEEQ"
    "SILAN"
    "SIS"
    "SMSC"
    "SOCIONEXT"
    "SOLARFLARE"
    "STMICRO"
    "SUN"
    "SYNOPSYS"
    "TEHUTI"
    "TI"
    "VERTEXCOM"
    "VIA"
    "WANGXUN"
    "WIZNET"
    "XILINX"
  ];

  wlanVendors = map (v: "WLAN_VENDOR_${v}") [
    "ADMTEK"
    "INTEL"
    "MICROCHIP"
    "QUANTENNA"
    "SILABS"
    "ST"
    "TI"
  ];

  # SoC platforms other than Apple.
  archs = map (v: "ARCH_${v}") [
    "ACTIONS"
    "AXIADO"
    "BCM"
    "BERLIN"
    "BLAIZE"
    "CIX"
    "EXYNOS"
    "HISI"
    "INTEL_SOCFPGA"
    "K3"
    "KEEMBAY"
    "LG1K"
    "MA35"
    "MEDIATEK"
    "MESON"
    "MVEBU"
    "NPCM"
    "NXP"
    "QCOM"
    "REALTEK"
    "RENESAS"
    "ROCKCHIP"
    "SEATTLE"
    "SOPHGO"
    "SPARX5"
    "SPRD"
    "STM32"
    "SUNXI"
    "SYNQUACER"
    "TEGRA"
    "THUNDER"
    "THUNDER2"
    "UNIPHIER"
    "VEXPRESS"
    "VISCONTI"
    "XGENE"
    "ZYNQMP"
  ];
in
{
  boot.kernelPatches = [
    {
      name = "asahi-trim-unused";
      patch = null;
      structuredExtraConfig =
        orphaned [
          "DRM_AMD_ACP"
          "DRM_AMD_DC_FP"
          "DRM_AMD_DC_SI"
          "DRM_AMD_ISP"
          "DRM_AMD_SECURE_DISPLAY"
          "DRM_AMDGPU_CIK"
          "DRM_AMDGPU_SI"
          "DRM_AMDGPU_USERPTR"
          "DRM_NOUVEAU_SVM"
          "DRM_VC4_HDMI_CEC"
          "FSL_MC_UAPI_SUPPORT"
          "HMM_MIRROR"
          "HSA_AMD"
          "HSA_AMD_P2P"
          "INFINIBAND_IPOIB"
          "INFINIBAND_IPOIB_CM"
          "MEDIA_ATTACH"
          "MT798X_WMAC"
          "ROCKCHIP_DW_HDMI_QP"
          "ROCKCHIP_DW_MIPI_DSI2"
          "SCSI_LOWLEVEL_PCMCIA"
          "STAGING_MEDIA"
          "SUN8I_DE2_CCU"
          "USB_XHCI_TEGRA"
        ]
        // disable (
          [
            # media
            "MEDIA_ANALOG_TV_SUPPORT"
            "MEDIA_DIGITAL_TV_SUPPORT"
            "MEDIA_PCI_SUPPORT"
            "MEDIA_SDR_SUPPORT"

            # buses and protocols without Apple hardware
            "ATM"
            "CAN"
            "COMEDI"
            "FIREWIRE"
            "INFINIBAND"
            "NFC"
            "PARPORT"
            "PCMCIA"
            "SCSI_CXGB3_ISCSI"
            "SCSI_CXGB4_ISCSI"
            "STAGING"

            # PCI GPUs
            "DRM_AMDGPU"
            "DRM_NOUVEAU"
            "DRM_RADEON"
            "DRM_VMWGFX"

            # sound
            "SND_PCI"
            "SND_SOC_AMD_ACP"
            "SND_SOC_SOF_TOPLEVEL"
          ]
          ++ archs
          ++ netVendors
          ++ wlanVendors
        );
    }
  ];
}
