//
//  KworldTV300UDriver.h
//
//  macam - webcam app and QuickTime driver component
//  KworldTV300UDriver - driver for the KWORLD TV-PVR 300U
//
//  Created by HXR on 4/4/06.
//  Copyright (C) 2006 HXR (hxr@users.sourceforge.net). 
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA
//

#import <GenericDriver.h>

/* copy from em28xx-reg.h at Linux source code. */

/* Boards supported by driver */
#define EM2800_BOARD_UNKNOWN			  0
#define EM2820_BOARD_UNKNOWN			  1
#define EM2820_BOARD_TERRATEC_CINERGY_250	  2
#define EM2820_BOARD_PINNACLE_USB_2		  3
#define EM2820_BOARD_HAUPPAUGE_WINTV_USB_2	  4
#define EM2820_BOARD_MSI_VOX_USB_2		  5
#define EM2800_BOARD_TERRATEC_CINERGY_200	  6
#define EM2800_BOARD_LEADTEK_WINFAST_USBII	  7
#define EM2800_BOARD_KWORLD_USB2800		  8
#define EM2820_BOARD_PINNACLE_DVC_90		  9
#define EM2880_BOARD_HAUPPAUGE_WINTV_HVR_900	  10
#define EM2880_BOARD_TERRATEC_HYBRID_XS		  11
#define EM2820_BOARD_KWORLD_PVRTV2800RF		  12
#define EM2880_BOARD_TERRATEC_PRODIGY_XS	  13
#define EM2820_BOARD_PROLINK_PLAYTV_USB2	  14
#define EM2800_BOARD_VGEAR_POCKETTV		  15
#define EM2883_BOARD_HAUPPAUGE_WINTV_HVR_950	  16
#define EM2880_BOARD_PINNACLE_PCTV_HD_PRO	  17
#define EM2880_BOARD_HAUPPAUGE_WINTV_HVR_900_R2	  18
#define EM2860_BOARD_SAA711X_REFERENCE_DESIGN	  19
#define EM2880_BOARD_AMD_ATI_TV_WONDER_HD_600	  20
#define EM2800_BOARD_GRABBEEX_USB2800		  21
#define EM2750_BOARD_UNKNOWN			  22
#define EM2750_BOARD_DLCW_130			  23
#define EM2820_BOARD_DLINK_USB_TV		  24
#define EM2820_BOARD_GADMEI_UTV310		  25
#define EM2820_BOARD_HERCULES_SMART_TV_USB2	  26
#define EM2820_BOARD_PINNACLE_USB_2_FM1216ME	  27
#define EM2820_BOARD_LEADTEK_WINFAST_USBII_DELUXE 28
#define EM2860_BOARD_TVP5150_REFERENCE_DESIGN	  29
#define EM2820_BOARD_VIDEOLOGY_20K14XUSB	  30
#define EM2821_BOARD_USBGEAR_VD204		  31
#define EM2821_BOARD_SUPERCOMP_USB_2		  32
#define EM2860_BOARD_ELGATO_VIDEO_CAPTURE	  33
#define EM2860_BOARD_TERRATEC_HYBRID_XS		  34
#define EM2860_BOARD_TYPHOON_DVD_MAKER		  35
#define EM2860_BOARD_NETGMBH_CAM		  36
#define EM2860_BOARD_GADMEI_UTV330		  37
#define EM2861_BOARD_YAKUMO_MOVIE_MIXER		  38
#define EM2861_BOARD_KWORLD_PVRTV_300U		  39
#define EM2861_BOARD_PLEXTOR_PX_TV100U		  40
#define EM2870_BOARD_KWORLD_350U		  41
#define EM2870_BOARD_KWORLD_355U		  42
#define EM2870_BOARD_TERRATEC_XS		  43
#define EM2870_BOARD_TERRATEC_XS_MT2060		  44
#define EM2870_BOARD_PINNACLE_PCTV_DVB		  45
#define EM2870_BOARD_COMPRO_VIDEOMATE		  46
#define EM2880_BOARD_KWORLD_DVB_305U		  47
#define EM2880_BOARD_KWORLD_DVB_310U		  48
#define EM2880_BOARD_MSI_DIGIVOX_AD		  49
#define EM2880_BOARD_MSI_DIGIVOX_AD_II		  50
#define EM2880_BOARD_TERRATEC_HYBRID_XS_FR	  51
#define EM2881_BOARD_DNT_DA2_HYBRID		  52
#define EM2881_BOARD_PINNACLE_HYBRID_PRO	  53
#define EM2882_BOARD_KWORLD_VS_DVBT		  54
#define EM2882_BOARD_TERRATEC_HYBRID_XS		  55
#define EM2882_BOARD_PINNACLE_HYBRID_PRO_330E	  56
#define EM2883_BOARD_KWORLD_HYBRID_330U		  57
#define EM2820_BOARD_COMPRO_VIDEOMATE_FORYOU	  58
#define EM2883_BOARD_HAUPPAUGE_WINTV_HVR_850	  60
#define EM2820_BOARD_PROLINK_PLAYTV_BOX4_USB2	  61
#define EM2820_BOARD_GADMEI_TVR200		  62
#define EM2860_BOARD_KAIOMY_TVNPC_U2		  63
#define EM2860_BOARD_EASYCAP			  64
#define EM2820_BOARD_IODATA_GVMVP_SZ		  65
#define EM2880_BOARD_EMPIRE_DUAL_TV		  66
#define EM2860_BOARD_TERRATEC_GRABBY		  67
#define EM2860_BOARD_TERRATEC_AV350		  68
#define EM2882_BOARD_KWORLD_ATSC_315U		  69
#define EM2882_BOARD_EVGA_INDTUBE		  70
#define EM2820_BOARD_SILVERCREST_WEBCAM		  71
#define EM2861_BOARD_GADMEI_UTV330PLUS		  72
#define EM2870_BOARD_REDDO_DVB_C_USB_BOX	  73
#define EM2800_BOARD_VC211A			  74
#define EM2882_BOARD_DIKOM_DK300		  75
#define EM2870_BOARD_KWORLD_A340		  76
#define EM2874_BOARD_LEADERSHIP_ISDBT		  77
#define EM28174_BOARD_PCTV_290E			  78
#define EM2884_BOARD_TERRATEC_H5		  79
#define EM28174_BOARD_PCTV_460E			  80
#define EM2884_BOARD_HAUPPAUGE_WINTV_HVR_930C	  81
#define EM2884_BOARD_CINERGY_HTC_STICK		  82
#define EM2860_BOARD_HT_VIDBOX_NW03		  83
#define EM2874_BOARD_MAXMEDIA_UB425_TC		  84
#define EM2884_BOARD_PCTV_510E			  85
#define EM2884_BOARD_PCTV_520E			  86
#define EM2884_BOARD_TERRATEC_HTC_USB_XS	  87
#define EM2884_BOARD_C3TECH_DIGITAL_DUO		  88

#define EM_GPIO_0  (1 << 0)
#define EM_GPIO_1  (1 << 1)
#define EM_GPIO_2  (1 << 2)
#define EM_GPIO_3  (1 << 3)
#define EM_GPIO_4  (1 << 4)
#define EM_GPIO_5  (1 << 5)
#define EM_GPIO_6  (1 << 6)
#define EM_GPIO_7  (1 << 7)

#define EM_GPO_0   (1 << 0)
#define EM_GPO_1   (1 << 1)
#define EM_GPO_2   (1 << 2)
#define EM_GPO_3   (1 << 3)

/* em28xx endpoints */
/* 0x82:   (always ?) analog */
#define EM28XX_EP_AUDIO		0x83
/* 0x84:   digital or analog */

/* em2800 registers */
#define EM2800_R08_AUDIOSRC 0x08

/* em28xx registers */

#define EM28XX_R00_CHIPCFG	0x00

/* em28xx Chip Configuration 0x00 */
#define EM28XX_CHIPCFG_VENDOR_AUDIO		0x80
#define EM28XX_CHIPCFG_I2S_VOLUME_CAPABLE	0x40
#define EM28XX_CHIPCFG_I2S_5_SAMPRATES		0x30
#define EM28XX_CHIPCFG_I2S_3_SAMPRATES		0x20
#define EM28XX_CHIPCFG_AC97			0x10
#define EM28XX_CHIPCFG_AUDIOMASK		0x30

#define EM28XX_R01_CHIPCFG2	0x01

/* em28xx Chip Configuration 2 0x01 */
#define EM28XX_CHIPCFG2_TS_PRESENT		0x10
#define EM28XX_CHIPCFG2_TS_REQ_INTERVAL_MASK	0x0c /* bits 3-2 */
#define EM28XX_CHIPCFG2_TS_REQ_INTERVAL_1MF	0x00
#define EM28XX_CHIPCFG2_TS_REQ_INTERVAL_2MF	0x04
#define EM28XX_CHIPCFG2_TS_REQ_INTERVAL_4MF	0x08
#define EM28XX_CHIPCFG2_TS_REQ_INTERVAL_8MF	0x0c
#define EM28XX_CHIPCFG2_TS_PACKETSIZE_MASK	0x03 /* bits 0-1 */
#define EM28XX_CHIPCFG2_TS_PACKETSIZE_188	0x00
#define EM28XX_CHIPCFG2_TS_PACKETSIZE_376	0x01
#define EM28XX_CHIPCFG2_TS_PACKETSIZE_564	0x02
#define EM28XX_CHIPCFG2_TS_PACKETSIZE_752	0x03


/* GPIO/GPO registers */
#define EM2880_R04_GPO	0x04    /* em2880-em2883 only */
#define EM28XX_R08_GPIO	0x08	/* em2820 or upper */

#define EM28XX_R06_I2C_CLK	0x06

/* em28xx I2C Clock Register (0x06) */
#define EM28XX_I2C_CLK_ACK_LAST_READ	0x80
#define EM28XX_I2C_CLK_WAIT_ENABLE	0x40
#define EM28XX_I2C_EEPROM_ON_BOARD	0x08
#define EM28XX_I2C_EEPROM_KEY_VALID	0x04
#define EM2874_I2C_SECONDARY_BUS_SELECT	0x04 /* em2874 has two i2c busses */
#define EM28XX_I2C_FREQ_1_5_MHZ		0x03 /* bus frequency (bits [1-0]) */
#define EM28XX_I2C_FREQ_25_KHZ		0x02
#define EM28XX_I2C_FREQ_400_KHZ		0x01
#define EM28XX_I2C_FREQ_100_KHZ		0x00


#define EM28XX_R0A_CHIPID	0x0a
#define EM28XX_R0C_USBSUSP	0x0c	/* */

#define EM28XX_R0E_AUDIOSRC	0x0e
#define EM28XX_R0F_XCLK	0x0f

/* em28xx XCLK Register (0x0f) */
#define EM28XX_XCLK_AUDIO_UNMUTE	0x80 /* otherwise audio muted */
#define EM28XX_XCLK_I2S_MSB_TIMING	0x40 /* otherwise standard timing */
#define EM28XX_XCLK_IR_RC5_MODE		0x20 /* otherwise NEC mode */
#define EM28XX_XCLK_IR_NEC_CHK_PARITY	0x10
#define EM28XX_XCLK_FREQUENCY_30MHZ	0x00 /* Freq. select (bits [3-0]) */
#define EM28XX_XCLK_FREQUENCY_15MHZ	0x01
#define EM28XX_XCLK_FREQUENCY_10MHZ	0x02
#define EM28XX_XCLK_FREQUENCY_7_5MHZ	0x03
#define EM28XX_XCLK_FREQUENCY_6MHZ	0x04
#define EM28XX_XCLK_FREQUENCY_5MHZ	0x05
#define EM28XX_XCLK_FREQUENCY_4_3MHZ	0x06
#define EM28XX_XCLK_FREQUENCY_12MHZ	0x07
#define EM28XX_XCLK_FREQUENCY_20MHZ	0x08
#define EM28XX_XCLK_FREQUENCY_20MHZ_2	0x09
#define EM28XX_XCLK_FREQUENCY_48MHZ	0x0a
#define EM28XX_XCLK_FREQUENCY_24MHZ	0x0b

#define EM28XX_R10_VINMODE	0x10

#define EM28XX_R11_VINCTRL	0x11

/* em28xx Video Input Control Register 0x11 */
#define EM28XX_VINCTRL_VBI_SLICED	0x80
#define EM28XX_VINCTRL_VBI_RAW		0x40
#define EM28XX_VINCTRL_VOUT_MODE_IN	0x20 /* HREF,VREF,VACT in output */
#define EM28XX_VINCTRL_CCIR656_ENABLE	0x10
#define EM28XX_VINCTRL_VBI_16BIT_RAW	0x08 /* otherwise 8-bit raw */
#define EM28XX_VINCTRL_FID_ON_HREF	0x04
#define EM28XX_VINCTRL_DUAL_EDGE_STROBE	0x02
#define EM28XX_VINCTRL_INTERLACED	0x01

#define EM28XX_R12_VINENABLE	0x12	/* */

#define EM28XX_R14_GAMMA	0x14
#define EM28XX_R15_RGAIN	0x15
#define EM28XX_R16_GGAIN	0x16
#define EM28XX_R17_BGAIN	0x17
#define EM28XX_R18_ROFFSET	0x18
#define EM28XX_R19_GOFFSET	0x19
#define EM28XX_R1A_BOFFSET	0x1a

#define EM28XX_R1B_OFLOW	0x1b
#define EM28XX_R1C_HSTART	0x1c
#define EM28XX_R1D_VSTART	0x1d
#define EM28XX_R1E_CWIDTH	0x1e
#define EM28XX_R1F_CHEIGHT	0x1f

#define EM28XX_R20_YGAIN	0x20 /* contrast [0:4]   */
#define   CONTRAST_DEFAULT	0x10

#define EM28XX_R21_YOFFSET	0x21 /* brightness       */	/* signed */
#define   BRIGHTNESS_DEFAULT	0x00

#define EM28XX_R22_UVGAIN	0x22 /* saturation [0:4] */
#define   SATURATION_DEFAULT	0x10

#define EM28XX_R23_UOFFSET	0x23 /* blue balance     */	/* signed */
#define   BLUE_BALANCE_DEFAULT	0x00

#define EM28XX_R24_VOFFSET	0x24 /* red balance      */	/* signed */
#define   RED_BALANCE_DEFAULT	0x00

#define EM28XX_R25_SHARPNESS	0x25 /* sharpness [0:4]  */
#define   SHARPNESS_DEFAULT	0x00

#define EM28XX_R26_COMPR	0x26
#define EM28XX_R27_OUTFMT	0x27

/* em28xx Output Format Register (0x27) */
#define EM28XX_OUTFMT_RGB_8_RGRG	0x00
#define EM28XX_OUTFMT_RGB_8_GRGR	0x01
#define EM28XX_OUTFMT_RGB_8_GBGB	0x02
#define EM28XX_OUTFMT_RGB_8_BGBG	0x03
#define EM28XX_OUTFMT_RGB_16_656	0x04
#define EM28XX_OUTFMT_RGB_8_BAYER	0x08 /* Pattern in Reg 0x10[1-0] */
#define EM28XX_OUTFMT_YUV211		0x10
#define EM28XX_OUTFMT_YUV422_Y0UY1V	0x14
#define EM28XX_OUTFMT_YUV422_Y1UY0V	0x15
#define EM28XX_OUTFMT_YUV411		0x18


#define EM28XX_R28_XMIN	0x28
#define EM28XX_R29_XMAX	0x29
#define EM28XX_R2A_YMIN	0x2a
#define EM28XX_R2B_YMAX	0x2b

#define EM28XX_R30_HSCALELOW	0x30
#define EM28XX_R31_HSCALEHIGH	0x31
#define EM28XX_R32_VSCALELOW	0x32
#define EM28XX_R33_VSCALEHIGH	0x33
#define   EM28XX_HVSCALE_MAX	0x3fff /* => 20% */

#define EM28XX_R34_VBI_START_H	0x34
#define EM28XX_R35_VBI_START_V	0x35
/*
 * NOTE: the EM276x (and EM25xx, EM277x/8x ?) (camera bridges) use these
 * registers for a different unknown purpose.
 *   => register 0x34 is set to capture width / 16
 *   => register 0x35 is set to capture height / 16
 */

#define EM28XX_R36_VBI_WIDTH	0x36
#define EM28XX_R37_VBI_HEIGHT	0x37

#define EM28XX_R40_AC97LSB	0x40
#define EM28XX_R41_AC97MSB	0x41
#define EM28XX_R42_AC97ADDR	0x42
#define EM28XX_R43_AC97BUSY	0x43

#define EM28XX_R45_IR		0x45
/* 0x45  bit 7    - parity bit
 bits 6-0 - count
 0x46  IR brand
 0x47  IR data
 */

/* em2874 registers */
#define EM2874_R50_IR_CONFIG    0x50
#define EM2874_R51_IR           0x51
#define EM2874_R5F_TS_ENABLE    0x5f
#define EM2874_R80_GPIO         0x80

/* em2874 IR config register (0x50) */
#define EM2874_IR_NEC           0x00
#define EM2874_IR_NEC_NO_PARITY 0x01
#define EM2874_IR_RC5           0x04
#define EM2874_IR_RC6_MODE_0    0x08
#define EM2874_IR_RC6_MODE_6A   0x0b

/* em2874 Transport Stream Enable Register (0x5f) */
#define EM2874_TS1_CAPTURE_ENABLE (1 << 0)
#define EM2874_TS1_FILTER_ENABLE  (1 << 1)
#define EM2874_TS1_NULL_DISCARD   (1 << 2)
#define EM2874_TS2_CAPTURE_ENABLE (1 << 4)
#define EM2874_TS2_FILTER_ENABLE  (1 << 5)
#define EM2874_TS2_NULL_DISCARD   (1 << 6)

/* register settings */
#define EM2800_AUDIO_SRC_TUNER  0x0d
#define EM2800_AUDIO_SRC_LINE   0x0c
#define EM28XX_AUDIO_SRC_TUNER	0xc0
#define EM28XX_AUDIO_SRC_LINE	0x80

/* FIXME: Need to be populated with the other chip ID's */
enum em28xx_chip_id {
	CHIP_ID_EM2800 = 7,
	CHIP_ID_EM2710 = 17,
	CHIP_ID_EM2820 = 18,	/* Also used by some em2710 */
	CHIP_ID_EM2840 = 20,
	CHIP_ID_EM2750 = 33,
	CHIP_ID_EM2860 = 34,
	CHIP_ID_EM2870 = 35,
	CHIP_ID_EM2883 = 36,
	CHIP_ID_EM2765 = 54,
	CHIP_ID_EM2874 = 65,
	CHIP_ID_EM2884 = 68,
	CHIP_ID_EM28174 = 113,
};

/*
 * Registers used by em202
 */

/* EMP202 vendor registers */
#define EM202_EXT_MODEM_CTRL     0x3e
#define EM202_GPIO_CONF          0x4c
#define EM202_GPIO_POLARITY      0x4e
#define EM202_GPIO_STICKY        0x50
#define EM202_GPIO_MASK          0x52
#define EM202_GPIO_STATUS        0x54
#define EM202_SPDIF_OUT_SEL      0x6a
#define EM202_ANTIPOP            0x72
#define EM202_EAPD_GPIO_ACCESS   0x74


/*
 * tvp5150 - Texas Instruments TVP5150A/AM1 video decoder registers
 *
 * Copyright (c) 2005,2006 Mauro Carvalho Chehab (mchehab@infradead.org)
 * This code is placed under the terms of the GNU General Public License v2
 */

#define TVP5150_VD_IN_SRC_SEL_1      0x00 /* Video input source selection #1 */
#define TVP5150_ANAL_CHL_CTL         0x01 /* Analog channel controls */
#define TVP5150_OP_MODE_CTL          0x02 /* Operation mode controls */
#define TVP5150_MISC_CTL             0x03 /* Miscellaneous controls */
#define TVP5150_AUTOSW_MSK           0x04 /* Autoswitch mask: TVP5150A / TVP5150AM */

/* Reserved 05h */

#define TVP5150_COLOR_KIL_THSH_CTL   0x06 /* Color killer threshold control */
#define TVP5150_LUMA_PROC_CTL_1      0x07 /* Luminance processing control #1 */
#define TVP5150_LUMA_PROC_CTL_2      0x08 /* Luminance processing control #2 */
#define TVP5150_BRIGHT_CTL           0x09 /* Brightness control */
#define TVP5150_SATURATION_CTL       0x0a /* Color saturation control */
#define TVP5150_HUE_CTL              0x0b /* Hue control */
#define TVP5150_CONTRAST_CTL         0x0c /* Contrast control */
#define TVP5150_DATA_RATE_SEL        0x0d /* Outputs and data rates select */
#define TVP5150_LUMA_PROC_CTL_3      0x0e /* Luminance processing control #3 */
#define TVP5150_CONF_SHARED_PIN      0x0f /* Configuration shared pins */

/* Reserved 10h */

#define TVP5150_ACT_VD_CROP_ST_MSB   0x11 /* Active video cropping start MSB */
#define TVP5150_ACT_VD_CROP_ST_LSB   0x12 /* Active video cropping start LSB */
#define TVP5150_ACT_VD_CROP_STP_MSB  0x13 /* Active video cropping stop MSB */
#define TVP5150_ACT_VD_CROP_STP_LSB  0x14 /* Active video cropping stop LSB */
#define TVP5150_GENLOCK              0x15 /* Genlock/RTC */
#define TVP5150_HORIZ_SYNC_START     0x16 /* Horizontal sync start */

/* Reserved 17h */

#define TVP5150_VERT_BLANKING_START 0x18 /* Vertical blanking start */
#define TVP5150_VERT_BLANKING_STOP  0x19 /* Vertical blanking stop */
#define TVP5150_CHROMA_PROC_CTL_1   0x1a /* Chrominance processing control #1 */
#define TVP5150_CHROMA_PROC_CTL_2   0x1b /* Chrominance processing control #2 */
#define TVP5150_INT_RESET_REG_B     0x1c /* Interrupt reset register B */
#define TVP5150_INT_ENABLE_REG_B    0x1d /* Interrupt enable register B */
#define TVP5150_INTT_CONFIG_REG_B   0x1e /* Interrupt configuration register B */

/* Reserved 1Fh-27h */

#define TVP5150_VIDEO_STD           0x28 /* Video standard */

/* Reserved 29h-2bh */

#define TVP5150_CB_GAIN_FACT        0x2c /* Cb gain factor */
#define TVP5150_CR_GAIN_FACTOR      0x2d /* Cr gain factor */
#define TVP5150_MACROVISION_ON_CTR  0x2e /* Macrovision on counter */
#define TVP5150_MACROVISION_OFF_CTR 0x2f /* Macrovision off counter */
#define TVP5150_REV_SELECT          0x30 /* revision select (TVP5150AM1 only) */

/* Reserved	31h-7Fh */

#define TVP5150_MSB_DEV_ID          0x80 /* MSB of device ID */
#define TVP5150_LSB_DEV_ID          0x81 /* LSB of device ID */
#define TVP5150_ROM_MAJOR_VER       0x82 /* ROM major version */
#define TVP5150_ROM_MINOR_VER       0x83 /* ROM minor version */
#define TVP5150_VERT_LN_COUNT_MSB   0x84 /* Vertical line count MSB */
#define TVP5150_VERT_LN_COUNT_LSB   0x85 /* Vertical line count LSB */
#define TVP5150_INT_STATUS_REG_B    0x86 /* Interrupt status register B */
#define TVP5150_INT_ACTIVE_REG_B    0x87 /* Interrupt active register B */
#define TVP5150_STATUS_REG_1        0x88 /* Status register #1 */
#define TVP5150_STATUS_REG_2        0x89 /* Status register #2 */
#define TVP5150_STATUS_REG_3        0x8a /* Status register #3 */
#define TVP5150_STATUS_REG_4        0x8b /* Status register #4 */
#define TVP5150_STATUS_REG_5        0x8c /* Status register #5 */
/* Reserved	8Dh-8Fh */
/* Closed caption data registers */
#define TVP5150_CC_DATA_INI         0x90
#define TVP5150_CC_DATA_END         0x93

/* WSS data registers */
#define TVP5150_WSS_DATA_INI        0x94
#define TVP5150_WSS_DATA_END        0x99

/* VPS data registers */
#define TVP5150_VPS_DATA_INI        0x9a
#define TVP5150_VPS_DATA_END        0xa6

/* VITC data registers */
#define TVP5150_VITC_DATA_INI       0xa7
#define TVP5150_VITC_DATA_END       0xaf

#define TVP5150_VBI_FIFO_READ_DATA  0xb0 /* VBI FIFO read data */

/* Teletext filter 1 */
#define TVP5150_TELETEXT_FIL1_INI  0xb1
#define TVP5150_TELETEXT_FIL1_END  0xb5

/* Teletext filter 2 */
#define TVP5150_TELETEXT_FIL2_INI  0xb6
#define TVP5150_TELETEXT_FIL2_END  0xba

#define TVP5150_TELETEXT_FIL_ENA    0xbb /* Teletext filter enable */
/* Reserved	BCh-BFh */
#define TVP5150_INT_STATUS_REG_A    0xc0 /* Interrupt status register A */
#define TVP5150_INT_ENABLE_REG_A    0xc1 /* Interrupt enable register A */
#define TVP5150_INT_CONF            0xc2 /* Interrupt configuration */
#define TVP5150_VDP_CONF_RAM_DATA   0xc3 /* VDP configuration RAM data */
#define TVP5150_CONF_RAM_ADDR_LOW   0xc4 /* Configuration RAM address low byte */
#define TVP5150_CONF_RAM_ADDR_HIGH  0xc5 /* Configuration RAM address high byte */
#define TVP5150_VDP_STATUS_REG      0xc6 /* VDP status register */
#define TVP5150_FIFO_WORD_COUNT     0xc7 /* FIFO word count */
#define TVP5150_FIFO_INT_THRESHOLD  0xc8 /* FIFO interrupt threshold */
#define TVP5150_FIFO_RESET          0xc9 /* FIFO reset */
#define TVP5150_LINE_NUMBER_INT     0xca /* Line number interrupt */
#define TVP5150_PIX_ALIGN_REG_LOW   0xcb /* Pixel alignment register low byte */
#define TVP5150_PIX_ALIGN_REG_HIGH  0xcc /* Pixel alignment register high byte */
#define TVP5150_FIFO_OUT_CTRL       0xcd /* FIFO output control */
/* Reserved	CEh */
#define TVP5150_FULL_FIELD_ENA      0xcf /* Full field enable 1 */

/* Line mode registers */
#define TVP5150_LINE_MODE_INI       0xd0
#define TVP5150_LINE_MODE_END       0xfb

#define TVP5150_FULL_FIELD_MODE_REG 0xfc /* Full field mode register */
/* Reserved	FDh-FFh */

struct i2c_reg {
	unsigned char addr;
	unsigned char val;
};

@interface KworldTV300UDriver : GenericDriver 
{
	int driver_info;
	int decoder;
	UInt8 * decodingBuffer;
}

+ (NSArray *) cameraUsbDescriptions;

- (id) initWithCentral: (id) c;

- (BOOL) supportsResolution: (CameraResolution) res fps: (short) rate;
- (CameraResolution) defaultResolutionAndRate: (short *) rate;

- (UInt8) getGrabbingPipe;
- (BOOL) setGrabInterfacePipe;
- (void) setIsocFrameFunctions;

- (BOOL) startupGrabStream;
- (void) shutdownGrabStream;

- (BOOL) decodeBuffer: (GenericChunkBuffer *) buffer;

@end
