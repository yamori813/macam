//
//  USBVisionDriver.m
//
//  macam - webcam app and QuickTime driver component
//  USBVisionDriver - an example to show how to implement a macam driver
//
//  Created by hxr on 3/21/06.
//  Copyright (C) 2006 HXR (hxr@users.sourceforge.net). 
//  Copyright (C) 2021-2022 Hiroki Mori. 
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

#import "USBVisionDriver.h"

#include "USB_VendorProductIDs.h"

#import "yuv2rgb.h"

@implementation USBVisionDriver


//static int saa7111_write(struct i2c_client *client, unsigned char subaddr,
//						 unsigned char data)
- (int) saa7111Write:(unsigned char)subaddr data:(unsigned char)data
{
	char buf[2];

	buf[0] = subaddr;
	buf[1] = data;
	[self i2cWrite:0x48 buf:buf len:2];
}

//static int saa7111_read(struct i2c_client *client, unsigned char subaddr)
- (int) saa7111Read:subaddr
{
	unsigned char buf[1];
	
	buf[0] = subaddr;
	[self i2cWrite:0x48 buf:buf len:1];
	[self i2cRead:0x49 buf:buf len:1];
	return buf[0];
}

// usbvision_i2c_write_max4
- (int) i2cWriteMax4:(unsigned char)addr buf:(char *)buf len:(short)len
{
	int rc, retries;
	int i;
	unsigned char value[6];
	unsigned char ser_cont;
	
	ser_cont = (len & 0x07) | 0x10;

	value[0] = addr;
	value[1] = ser_cont;
	for (i = 0; i < len; i++)
		value[i + 2] = buf[i];
	
	for (retries = 5;;) {
		BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_SER_ADRS
									buf:value
									len:len + 2];
		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07) | 0x10];
		if (rc == -1)
			return rc;

		do {
			/* USBVISION_SER_CONT -> d4 == 0 busy */
			rc = [self getRegister:USBVISION_SER_CONT];
		} while (rc > 0 && ((rc & 0x10) != 0));
		
		/* USBVISION_SER_CONT -> d5 == 1 Not ack */
		if ((rc & 0x20) == 0)	/* Ack? */
			break;
		
		/* I2C abort */
		rc = [self setRegister:USBVISION_SER_CONT toValue:0x00];
		if (rc < 0)
			return rc;
		
		if (--retries < 0) {
			NSLog(@"i2cWriteMax4 error");
			return -1;
		}
	}
	return len;
}	

// usbvision_i2c_write
- (int) i2cWrite:(unsigned char)addr buf:(char *)buf len:(short)len
{
	char *bufPtr = buf;
	int retval;
	int wrcount = 0;
	int count;
	int maxLen = 2;
	
	while (len > 0) {
		count = (len > maxLen) ? maxLen : len;
		retval = [self i2cWriteMax4:addr buf:bufPtr len:count];
		if (retval > 0) {
			len -= count;
			bufPtr += count;
			wrcount += count;
		} else
			return (retval < 0) ? retval : -EFAULT;
	}
	return wrcount;
	
}

// usbvision_i2c_read_max4
- (int) i2cReadMax4:(unsigned char)addr buf:(char *)buf len:(short)len
{
	int rc, retries;
	
	for (retries = 5;;) {
		rc = [self setRegister:USBVISION_SER_ADRS toValue:addr];
		if (rc == -1)
			return rc;

		/* Initiate byte read cycle                    */
		/* USBVISION_SER_CONT <- d0-d2 n. of bytes to r/w */
		/*                    d3 0=Wr 1=Rd             */	
		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07) | 0x18];
		if (rc == -1)
			return rc;

		do {
			/* USBVISION_SER_CONT -> d4 == 0 busy */
			rc = [self getRegister:USBVISION_SER_CONT];
		} while (rc > 0 && ((rc & 0x10) != 0));
		
		/* USBVISION_SER_CONT -> d5 == 1 Not ack */
		if ((rc & 0x20) == 0)	/* Ack? */
			break;
		
		/* I2C abort */
		rc = [self setRegister:USBVISION_SER_CONT toValue:0x00];
		if (rc < 0)
			return rc;
		
		if (--retries < 0) {
			NSLog(@"i2cReadMax4 error");
			return -1;
		}
	}

	switch (len) {
		case 4:
			buf[3] = [self getRegister:USBVISION_SER_DAT4];
		case 3:
			buf[2] = [self getRegister:USBVISION_SER_DAT3];
		case 2:
			buf[1] = [self getRegister:USBVISION_SER_DAT2];
		case 1:
			buf[0] = [self getRegister:USBVISION_SER_DAT1];
			break;
	}

	return len;	
}
// usbvision_i2c_read
- (int) i2cRead:(unsigned char)addr buf:(char *)buf len:(short)len
{
	char temp[4];
	int retval, i;
	int rdcount = 0;
	int count;

	while (len > 0) {
		count = (len > 3) ? 4 : len;
		retval = [self i2cReadMax4:addr buf:temp len:count];
		if (retval > 0) {
			for (i = 0; i < len; i++)
				buf[rdcount + i] = temp[i];
			len -= count;
			rdcount += count;
		} else
			return (retval < 0) ? retval : -1;
	}
	return rdcount;
	
}

// usbvision_write_reg
- (int) setRegister:(UInt16)reg toValue:(UInt16)val
{
    UInt8 buffer[8];
    
	buffer[0] = val;
	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
										  bRequest:USBVISION_OP_CODE
											wValue:0
											wIndex:reg
											   buf:buffer
											   len:1];
    return (ok);
}

// usbvision_read_reg
- (int) getRegister:(UInt16) reg
{
    UInt8 buffer[8];
    
	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBIn, kUSBVendor, kUSBEndpoint)
						bRequest:USBVISION_OP_CODE
						  wValue:0
						  wIndex:reg
							 buf:buffer
							 len:1];
    
    return (ok) ? buffer[0] : -1;
}

// usbvision_set_video_format
- (int) setVideoFormat:(int)format
{
	unsigned char value[2];

	value[0] = 0x0A;  //TODO: See the effect of the filter
	value[1] = format;

	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_FILT_CONT
									buf:value
									len:2];
	return ok;
}

// usbvision_set_dram_settings
- (int) setDramSettings
{
	unsigned char value[8];

	value[0] = 0x42;
	value[1] = 0x00;
	value[2] = 0xff;
	value[3] = 0x00;
	value[4] = 0x00;
	value[5] = 0x00;
	value[6] = 0x00;
	value[7] = 0xff;
	
	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_DRM_PRM1
									buf:value
									len:8];

	/* Restart the video buffer logic */
	[self setRegister:USBVISION_DRM_CONT toValue:USBVISION_RES_UR | USBVISION_RES_FDL | USBVISION_RES_VDW];

	[self setRegister:USBVISION_DRM_CONT toValue:0];

	return ok;
}

// usbvision_set_input
- (int) setInput
{
	unsigned char value[8];
	
	value[0] = USBVISION_16_422_SYNC;
	
	[self setRegister:USBVISION_VIN_REG1 toValue:value[0]];

	value[0] = 0xD0;
	value[1] = 0x02;	//0x02D0 -> 720 Input video line length
	value[2] = 0xF0;
	value[3] = 0x00;	//0x00F0 -> 240 Input video number of lines
	value[4] = 0x50;
	value[5] = 0x00;	//0x0050 -> 80 Input video h offset
	value[6] = 0x10;
	value[7] = 0x00;	//0x0010 -> 16 Input video v offset
	
	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_LXSIZE_I
									buf:value
									len:8];
	
	[self setRegister:USBVISION_DVI_YUV toValue:0];

	return ok;
}


// usbvision_set_output
- (int) setOutput:(int)width height:(int)height
{
	unsigned char value[4];

	value[0] = width & 0xff;		//LSB
	value[1] = (width >> 8) & 0x03;	//MSB
	value[2] = height & 0xff;		//LSB
	value[3] = (height >> 8) & 0x03;	//MSB

	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_LXSIZE_O
									buf:value
									len:4];

	[self setRegister:USBVISION_FRM_RATE toValue:FRAMERATE_MAX];
	
	return ok;
}

// usbvision_set_compress_params
- (int) setCompressParams
{
	unsigned char value[4];
	
	value[0] = 0x0F;    // Intra-Compression cycle
	value[1] = 0x01;    // Reg.45 one line per strip
	value[2] = 0x00;    // Reg.46 Force intra mode on all new frames
	value[3] = 0x00;    // Reg.47 FORCE_UP <- 0 normal operation (not force)
	value[4] = 0xA2;    // Reg.48 BUF_THR I'm not sure if this does something in not compressed mode.
	value[5] = 0x00;    // Reg.49 DVI_YUV This has nothing to do with compression

	BOOL ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_INTRA_CYC
									buf:value
									len:5];	
	
	value[0] =  20; // PCM Threshold 1
	value[1] =  12; // PCM Threshold 2
	value[2] = 255; // Distorsion Threshold d7-d0
	value[3] =   0; // Distorsion Threshold d11-d8
	value[4] =  43; // Max Distorsion d7-d0
	value[5] =   0; // Max Distorsion d8
	
	ok = [self usbControlCmdOnPipe:1 withBRequestType:USBmakebmRequestType(kUSBOut, kUSBVendor, kUSBEndpoint)
							   bRequest:USBVISION_OP_CODE
								 wValue:0
								 wIndex:USBVISION_PCM_THR1
									buf:value
									len:6];	
}

// usbvision_begin_streaming
- (void) beginStreaming
{

	[self setRegister:USBVISION_VIN_REG2 toValue:USBVISION_NOHVALID];

	while ([self getRegister:USBVISION_STATUS_REG] == 0x01)
		;
	NSLog(@"MORIMORI NT1003 STATUS_REG %x", [self getRegister:USBVISION_STATUS_REG]);
}

// usbvision_restart_isoc
- (void) restartIsoc
{

	[self setRegister:USBVISION_PWR_REG toValue:USBVISION_SSPND_EN | USBVISION_PWR_VID];
	
	[self setRegister:USBVISION_PWR_REG toValue:USBVISION_SSPND_EN | USBVISION_PWR_VID | USBVISION_RES2];
	
	[self setRegister:USBVISION_VIN_REG2 toValue:USBVISION_KEEP_BLANK | USBVISION_NOHVALID];

//	while (([self getRegister:USBVISION_STATUS_REG] && 0x01) != 1)
//		;
}

//
// Specify which Vendor and Product IDs this driver will work for
// Add these to the USB_VendorProductIDs.h file
//
+ (NSArray *) cameraUsbDescriptions 
{
    return [NSArray arrayWithObjects:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:0xc000], @"idProduct",
            [NSNumber numberWithUnsignedShort:0x0573], @"idVendor",
            @"USBVision", @"name", NULL], 
        
        // More entries can easily be added for more cameras
        NULL];
}

//
// Initialize the driver
//
- (id) initWithCentral: (id) c 
{
	self = [super initWithCentral:c];
	if (self == NULL) 
        return NULL;
    
    /* this might be useful
    bayerConverter = [[BayerConverter alloc] init];
	if (bayerConverter == NULL) 
        return NULL;
    
    or
    
    LUT = [[LookUpTable alloc] init];
	if (LUT == NULL) 
        return NULL;
    */
    
    // Allocate memory
    // Initialize variable and other structures
	MALLOC(decodingBuffer, UInt8 *, 356 * 292 + 1000, "decodingBuffer");
	
	compressionType = gspcaCompression;
	
	return self;
}

//
// Provide feedback about which resolutions and rates are supported
//
- (BOOL) supportsResolution: (CameraResolution) res fps: (short) rate 
{

	switch (res) 
    {
        case ResolutionSIF:
			if (rate > 10) 
                return NO;

            return YES;
            
        default: 
            return NO;
    }

}

//
// Return the default resolution and rate
//
- (CameraResolution) defaultResolutionAndRate: (short *) rate
{
	if (rate) 
        *rate = 5;
    
	return ResolutionSIF;
}

//
// Returns the pipe used for grabbing
//
- (UInt8) getGrabbingPipe
{

    return 2;
}

//
// Put in the alt-interface with the highest bandwidth (instead of 8)
// This attempts to provide the highest bandwidth
//
- (BOOL) setGrabInterfacePipe
{

	return [self usbMaximizeBandwidth:[self getGrabbingPipe]  suggestedAltInterface:-1  numAltInterfaces:9];
}

//
// This is an example that will have to be tailored to the specific camera or chip
// Scan the frame and return the results
//

int lastLength;

IsocFrameResult  USBVisionIsocFrameScanner(IOUSBIsocFrame * frame, UInt8 * buffer, 
                                         UInt32 * dataStart, UInt32 * dataLength, 
                                         UInt32 * tailStart, UInt32 * tailLength, 
                                         GenericFrameInfo * frameInfo)
{
    int position, frameLength = frame->frActCount;
    
//	NSLog(@"MORIMORI USBVisionIsocFrameScanner %d %02x", frameLength, buffer[0]);
	if (lastLength == 0 &&  buffer[0] == 0x55 && buffer[1] == 0xaa && buffer[2] == 12) {   // Start of Video-Frame Pattern
//		NSLog(@"MORIMORI Start of Video-Frame Pattern");
		*dataStart = 12;
		*dataLength = frameLength - 12;
		*tailStart = frameLength;
		*tailLength = 0;
		return newChunkFrame;
	} else {
		*dataStart = 0;
		*dataLength = frameLength;
		*tailStart = frameLength;
		*tailLength = 0;
	}
	lastLength = frameLength;
    
    if (frameLength < 1) 
        return invalidFrame;
	/*
    if (something or other) 
    {
        *dataStart = 10; // Skip a 10 byte header for example
        *dataLength = frameLength - 10;
        
        return newChunkFrame;
    }
      */      
	
    return validFrame;
}

//
// These are the C functions to be used for scanning the frames
//
- (void) setIsocFrameFunctions
{

	lastLength = 0;
	
    grabContext.isocFrameScanner = USBVisionIsocFrameScanner;
    grabContext.isocDataCopier = genericIsocDataCopier;
}

//
// This is the key method that starts up the stream
//
- (BOOL) startupGrabStream 
{
    CameraError error = CameraErrorOK;
	
	
	NSLog(@"MORIMORI startup");
	
	int stat = [self saa7111Read:0x1f];
	NSLog(@"MORIMORI initSAA7111 %02x CODE = %d, FIDT = %d, HLCK = %d, STTC = %d", stat,
		  stat & 1, (stat >> 5) & 1, (stat >> 6) & 1, (stat >> 7) & 1);

	[self beginStreaming];

    return error == CameraErrorOK;
}

//
// The key routine for shutting down the stream
//
- (void) shutdownGrabStream 
{
//  More of the same
//  [self usbWriteVICmdWithBRequest:0x00 wValue:0x00 wIndex:0x40 buf:NULL len:0];
    
    [self usbSetAltInterfaceTo:0 testPipe:[self getGrabbingPipe]]; // Must set alt interface to normal
}

- (void) startupCamera
{
	/*
    NSLog(@"MORIMORI startupCamera");
	int i, j;
	printf("NT1003 Register\n");
	for(j = 0; j < 5; ++j) {
		for(i = 0; i <= 0x10; ++i) {
			printf("%02x ", [self getRegister:i + j * 0x10]);
		}
		printf("\n");
	}
	 */
	
	[self setVideoFormat:ISOC_MODE_YUV422];
	[self setDramSettings];
	[self setCompressParams];
	[self setInput];
	[self setOutput:MAX_USB_WIDTH height:MAX_USB_HEIGHT];
	
	[self restartIsoc];
	[self setRegister:USBVISION_SER_MODE toValue:USBVISION_IIC_LRNACK_MODE];
	/*
	 printf("SAA7111 Register\n");
	 for(j = 0; j < 2; ++j) {
	 for(i = 0; i <= 0x10; ++i) {
	 printf("%02x ", [self saa7111Read:i + j * 0x10]);
	 }
	 printf("\n");
	 }
	 */
	
	[self initSAA7111];
	
    [super startupCamera];
}

//
// This is the method that takes the raw chunk data and turns it into an image
//
//- (BOOL) decodeBuffer: (GenericChunkBuffer *) buffer
- (BOOL) decodeBufferGSPCA: (GenericChunkBuffer *) buffer
{
	long w, h;
    UInt8 * src = buffer->buffer;
    UInt8 * dst;
    
	short numColumns  = [self width];
	short numRows = [self height];
    
	if (buffer->numBytes != 153600) {
		printf("invalid frame data size %d\n", buffer->numBytes);
		return NO;
	}

	yuv2rgb (numColumns,numRows,YUVCPIA422Style,src,nextImageBuffer,nextImageBufferBPP,0,0,0);

    return YES;
}

- (BOOL) canSetBrightness { return YES; }
- (void) setBrightness:(float)v{
    UInt8 b;
    if (![self canSetBrightness]) return;
	b=SAA7111A_BRIGHTNESS(CLAMP_UNIT(v));
	if ((b!=SAA7111A_BRIGHTNESS(brightness)))
		[self saa7111Write:0x0a data:b];
    [super setBrightness:v];
}

- (BOOL) canSetContrast { return YES; }
- (void) setContrast:(float)v {
    UInt8 b;
    if (![self canSetContrast]) return;
	b=SAA7111A_CONTRAST(CLAMP_UNIT(v));
	if (b!=SAA7111A_CONTRAST(contrast))
		[self saa7111Write:0x0b data:b];
    [super setContrast:v];
}

- (BOOL) canSetSaturation { return YES; }
- (void) setSaturation:(float)v {
    UInt8 b;
    if (![self canSetSaturation]) return;
	b=SAA7111A_SATURATION(CLAMP_UNIT(v));
	if (b!=SAA7111A_SATURATION(saturation))
		[self saa7111Write:0x0c data:b];
    [super setSaturation:v];
}

- (BOOL) canSetHue { return YES; }
- (void) setHue:(float)v {
    UInt8 b;
    if (![self canSetHue]) return;
	b=SAA7111A_HUE(CLAMP_UNIT(v));
	[self saa7111Write:0x0d data:b];
    [super setHue:v];
}


- (void) initSAA7111
{
	int i;

	static const unsigned char init[] = {
//		0x00, 0x00,	/* 00 - ID byte */
//		0x01, 0x00,	/* 01 - reserved */
		/*front end */
		0x02, 0xc0,	/* 02 - FUSE=3, GUDL=2, MODE=0 */
		0x03, 0x23,	/* 03 - HLNRS=0, VBSL=1, WPOFF=0, HOLDG=0, GAFIX=0, GAI1=256, GAI2=256 */
		0x04, 0x00,	/* 04 - GAI1=256 */
		0x05, 0x00,	/* 05 - GAI2=256 */
		/* decoder */
		// WARNING: This comment isn't correct (refers to 06:f3, 07:13 I think)
//		0x06, 0xEC, 	/* 06 - HSB at  13(50Hz) /  17(60Hz) pixels after end of last line */
		0x06, 0xED, 	/* 06 - HSB at  13(50Hz) /  17(60Hz) pixels after end of last line */
		0x07, 0x00, 	/* 07 - HSS at 113(50Hz) / 117(60Hz) pixels after end of last line */
		0x08, 0xc8,	/* 08 - AUFD=1, FSEL=1, EXFIL=0, VTRC=1, HPLL=0, VNOI=0 */
		0x09, 0x01,	/* 09 - BYPS=0, PREF=0, BPSS=0, VBLB=0, UPTCV=0, APER=1 */
//		0x0a, 0x80,	/* 0a - BRIG=128 */
//		0x0b, 0x47,	/* 0b - CONT=1.109 */
//		0x0c, 0x40,	/* 0c - SATN=1.0 */
//		0x0d, 0x00,	/* 0d - HUE=0 */
		0x0e, 0x01,	/* 0e - CDTO=0, CSTD=0, DCCF=0, FCTC=0, CHBW=1 */
		0x0f, 0x00,	/* 0f - reserved */
		0x10, 0x44,	/* 10 - OFTS=1, HDEL=0, VRLN=1, YDEL=0 */
		0x11, 0x0c,	/* 11 - GPSW=0, CM99=0, FECO=0, COMPO=1, OEYC=1, OEHV=1, VIPB=0, COLO=0 */
		0x12, 0x00,	/* 12 - output control 2 */
		0x13, 0x00,	/* 13 - output control 3 */
		0x14, 0x00,	/* 14 - reserved */
		0x15, 0x00,	/* 15 - VBI */
		0x16, 0x00,	/* 16 - VBI */
		0x17, 0x00,	/* 17 - VBI */
	};
	
	int stat = [self saa7111Read:0x1f];
	NSLog(@"MORIMORI initSAA7111 %02x CODE = %d, FIDT = %d, HLCK = %d, STTC = %d", stat,
		  stat & 1, (stat >> 5) & 1, (stat >> 6) & 1, (stat >> 7) & 1);
//	udelay(1000000);

	for (i = 0; i < sizeof(init) / 2; ++i) {
		[self saa7111Write:init[i * 2] data:init[i * 2 + 1]];
	}
/*
	[self setBrightness:((1.0f / 256) * 0x95)];
	[self setContrast:((1.0f / 256) * 0x48)];
	[self setSaturation:((1.0f / 256) * 0x50)];
	[self setHue:((1.0f / 256) * 0x00)];	
*/
//	udelay(1000000);	
}

@end
