//
//  USBVisionDriver.h
//
//  macam - webcam app and QuickTime driver component
//  USBVisionDriver - an example to show how to implement a macam driver
//
//  Created by hxr on 3/21/06.
//  Copyright (C) 2006 HXR (hxr@users.sourceforge.net). 
//  Copyright (C) 2021 Hiroki Mori. 
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

/*
 Here is the simplest way of adding a driver to macam:
 - Copy the USBVisionDriver.[h|m] files 
 - Rename them to something that makes sense for your camera or chip
 - Fill in the methods with the information specific to your camera
 - Add your driver to MyCameraCentral
 That's it!
 
 OK, so some of the information you need to write the methods can be hard 
 to come by, but at least this example shows you exactly what you need.
 */

#import <GenericDriver.h>

#define USBVISION_PWR_REG		0x00
#define USBVISION_SSPND_EN		(1 << 1)
#define USBVISION_RES2			(1 << 2)
#define USBVISION_PWR_VID		(1 << 5)
#define USBVISION_E2_EN			(1 << 7)
#define USBVISION_CONFIG_REG		0x01
#define USBVISION_ADRS_REG		0x02
#define USBVISION_ALTER_REG		0x03
#define USBVISION_FORCE_ALTER_REG	0x04
#define USBVISION_STATUS_REG		0x05
#define USBVISION_IOPIN_REG		0x06
#define USBVISION_IO_1			(1 << 0)
#define USBVISION_IO_2			(1 << 1)
#define USBVISION_AUDIO_IN		0
#define USBVISION_AUDIO_TV		1
#define USBVISION_AUDIO_RADIO		2
#define USBVISION_AUDIO_MUTE		3
#define USBVISION_SER_MODE		0x07
#define USBVISION_SER_ADRS		0x08
#define USBVISION_SER_CONT		0x09
#define USBVISION_SER_DAT1		0x0A
#define USBVISION_SER_DAT2		0x0B
#define USBVISION_SER_DAT3		0x0C
#define USBVISION_SER_DAT4		0x0D
#define USBVISION_EE_DATA		0x0E
#define USBVISION_EE_LSBAD		0x0F
#define USBVISION_EE_CONT		0x10
#define USBVISION_DRM_CONT			0x12
#define USBVISION_REF			(1 << 0)
#define USBVISION_RES_UR		(1 << 2)
#define USBVISION_RES_FDL		(1 << 3)
#define USBVISION_RES_VDW		(1 << 4)
#define USBVISION_DRM_PRM1		0x13
#define USBVISION_DRM_PRM2		0x14
#define USBVISION_DRM_PRM3		0x15
#define USBVISION_DRM_PRM4		0x16
#define USBVISION_DRM_PRM5		0x17
#define USBVISION_DRM_PRM6		0x18
#define USBVISION_DRM_PRM7		0x19
#define USBVISION_DRM_PRM8		0x1A
#define USBVISION_VIN_REG1		0x1B
#define USBVISION_8_422_SYNC		0x01
#define USBVISION_16_422_SYNC		0x02
#define USBVISION_VSNC_POL		(1 << 3)
#define USBVISION_HSNC_POL		(1 << 4)
#define USBVISION_FID_POL		(1 << 5)
#define USBVISION_HVALID_PO		(1 << 6)
#define USBVISION_VCLK_POL		(1 << 7)
#define USBVISION_VIN_REG2		0x1C
#define USBVISION_AUTO_FID		(1 << 0)
#define USBVISION_NONE_INTER		(1 << 1)
#define USBVISION_NOHVALID		(1 << 2)
#define USBVISION_UV_ID			(1 << 3)
#define USBVISION_FIX_2C		(1 << 4)
#define USBVISION_SEND_FID		(1 << 5)
#define USBVISION_KEEP_BLANK		(1 << 7)
#define USBVISION_LXSIZE_I		0x1D
#define USBVISION_MXSIZE_I		0x1E
#define USBVISION_LYSIZE_I		0x1F
#define USBVISION_MYSIZE_I		0x20
#define USBVISION_LX_OFFST		0x21
#define USBVISION_MX_OFFST		0x22
#define USBVISION_LY_OFFST		0x23
#define USBVISION_MY_OFFST		0x24
#define USBVISION_FRM_RATE		0x25
#define USBVISION_LXSIZE_O		0x26
#define USBVISION_MXSIZE_O		0x27
#define USBVISION_LYSIZE_O		0x28
#define USBVISION_MYSIZE_O		0x29
#define USBVISION_FILT_CONT		0x2A
#define USBVISION_VO_MODE		0x2B
#define USBVISION_INTRA_CYC		0x2C
#define USBVISION_STRIP_SZ		0x2D
#define USBVISION_FORCE_INTRA		0x2E
#define USBVISION_FORCE_UP		0x2F
#define USBVISION_BUF_THR		0x30
#define USBVISION_DVI_YUV		0x31
#define USBVISION_AUDIO_CONT		0x32
#define USBVISION_AUD_PK_LEN		0x33
#define USBVISION_BLK_PK_LEN		0x34
#define USBVISION_PCM_THR1		0x38
#define USBVISION_PCM_THR2		0x39
#define USBVISION_DIST_THR_L		0x3A
#define USBVISION_DIST_THR_H		0x3B
#define USBVISION_MAX_DIST_L		0x3C
#define USBVISION_MAX_DIST_H		0x3D
#define USBVISION_OP_CODE		0x33

#define FRAMERATE_MIN	0
#define FRAMERATE_MAX	31

#define USBVISION_IIC_LRACK                     0x20
#define USBVISION_IIC_LRNACK                    0x30

enum {
	ISOC_MODE_YUV422 = 0x03,
	ISOC_MODE_YUV420 = 0x14,
	ISOC_MODE_COMPRESS = 0x60,
};

@interface USBVisionDriver : GenericDriver 
{
    // Add any data structure that you need to keep around
    // i.e. decoding buffers, decoding structures etc
	UInt8 * decodingBuffer;
}

+ (NSArray *) cameraUsbDescriptions;

- (int) USBVisionReadRequest: (UInt8) rqst  withRegister: (UInt16) rgstr;

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
