//
//  KworldTV300UDriver.m
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


#import "KworldTV300UDriver.h"

#include "unistd.h"
#include "yuv2rgb.h"
#include "USB_VendorProductIDs.h"
#import "yuv2rgb.h"
#import "saa711x_regs.h"

enum em28xx_decoder {
	EM28XX_NODECODER = 0,
	EM28XX_TVP5150,
	EM28XX_SAA711X,
};

@implementation KworldTV300UDriver
//
// Specify which Vendor and Product IDs this driver will work for
// Add these to the USB_VendorProductIDs.h file
//
+ (NSArray *) cameraUsbDescriptions 
{
    return [NSArray arrayWithObjects:

        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:0xe300], @"idProduct", // KWORLD TV-300U (em2861)
            [NSNumber numberWithUnsignedShort:0xeb1a], @"idVendor", // Empia Technology, Inc
            @"KWORLD PVR-TV 300U", @"name", NULL], 
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithUnsignedShort:0x2821], @"idProduct", // EM2820 default
			 [NSNumber numberWithUnsignedShort:0xeb1a], @"idVendor", // Empia Technology, Inc
			 @"EMPIA EM2820", @"name", NULL], 
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithUnsignedShort:0x0515], @"idProduct",
			 [NSNumber numberWithUnsignedShort:0x04bb], @"idVendor",
			 @"IO-Data GV-MVP/SZ", @"name", NULL],
		/* eb1a:5006 Honestech VIDBOX NW03
		 * Empia EM2860, Philips SAA7113, Empia EMP202, No Tuner */
		[NSDictionary dictionaryWithObjectsAndKeys:
			 [NSNumber numberWithUnsignedShort:0x5006], @"idProduct",
			 [NSNumber numberWithUnsignedShort:0xeb1a], @"idVendor",
			 @"Honestech Vidbox NW03", @"name", NULL],
			
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
    */

    // Allocate memory
    // Initialize variable and other structures
    
    // Again, use if needed
    MALLOC(decodingBuffer, UInt8 *, 356 * 292 + 1000, "decodingBuffer");

	compressionType = gspcaCompression;
	
	return self;
}

//
// Provide feedback about which resolutions and rates are supported
//
- (BOOL) supportsResolution: (CameraResolution) res fps: (short) rate 
{
	int val = [self em28xxReadRegister:0x0a];
    
	printf("MORI MORI chip id %d\n", val);
	unsigned char buf[8];
	buf[0] = EM28XX_I2C_CLK_WAIT_ENABLE;
	[self em28xxWriteRegisters:EM28XX_R06_I2C_CLK withBuffer:buf ofLength:1];
	
	if ([cameraInfo vendorID] == 0x04bb && [cameraInfo productID] == 0x0515) {
		driver_info = EM2820_BOARD_IODATA_GVMVP_SZ;
		decoder = EM28XX_TVP5150;
	}
	if ([cameraInfo vendorID] == 0xeb1a && [cameraInfo productID] == 0x5006) {
		driver_info = EM2860_BOARD_HT_VIDBOX_NW03;
		decoder = EM28XX_SAA711X;
	}
	
	if (decoder == EM28XX_TVP5150) {
		buf[0] = TVP5150_MSB_DEV_ID;
		[self em28xxI2cSendBytes:0xb8 buf:buf len:1 stop:0];
		[self em28xxI2cRecvBytes:0xb8 buf:buf len:1];
		buf[0] = TVP5150_LSB_DEV_ID;
		[self em28xxI2cSendBytes:0xb8 buf:buf len:1 stop:0];
		[self em28xxI2cRecvBytes:0xb8 buf:buf len:1];
	}
	
	int i, reg;
/*
	for (i = 0;i < 256; ++i) {
		buf[0] = i;
		[self em28xxI2cSendBytes:0xb8 buf:buf len:1 stop:0];
		reg = [self em28xxI2cRecvBytes:0xb9 buf:buf len:1];
		printf("TVP5150 %02x %02x\n", i, reg);
	}
 */
	/*
	for (i = 0; i < 0x40; ++i) {
		val = [self em28xxReadRegister:i];
		printf("EM2820 %02x %02x\n", i, val);
	}
	 */
	
    switch (res) 
    {
        case ResolutionVGA:
            if (rate > 30) 
                return NO;
            return YES;
            break;
            
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
        *rate = 20;
    
	return ResolutionVGA;
}

// Return the size needed for an isochronous frame
// Depends on whether it is high-speed device on a high-speed hub

- (int) usbGetIsocFrameSize
{
//    return 3072;
	return kUSBMaxHSIsocEndpointReqCount;
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
	return [self usbSetAltInterfaceTo:7 testPipe:[self getGrabbingPipe]];
}

int frsize = 0;
int frcount = 0;
int allcount = 0;
//
// This is an example that will have to be tailored to the specific camera or chip
// Scan the frame and return the results
//
IsocFrameResult  empiaIsocFrameScanner(IOUSBIsocFrame * frame, UInt8 * buffer, 
                                       UInt32 * dataStart, UInt32 * dataLength, 
                                       UInt32 * tailStart, UInt32 * tailLength, 
                                       GenericFrameInfo * frameInfo)
{
//  int position;
    int frameLength = frame->frActCount;
    
    
	*dataStart = 4;
	*dataLength = frameLength - 4;
    *tailStart = frameLength;
    *tailLength = 0;
    
//	if (frameLength)
//    printf("buffer[0] = 0x%02x (length = %d) 0x%02x 0x%02x 0x%02x 0x%02x 0x%02x\n", buffer[0], frameLength, buffer[1], buffer[2], buffer[3], buffer[4], buffer[5]);
	if (frameLength >= 4) {
		if (buffer[0] == 0x22 && buffer[1] == 0x5a && (buffer[2] & 1) == 0) {
//			if (buffer[0] == 0x22 && buffer[1] == 0x5a) {
//				if((buffer[2] & 1 && frsize != 312324) || ((buffer[2] & 1) == 0 && frsize != 311044))
//			printf("MORI MORI %d %d %d %d\n", frsize, frcount, buffer[2] & 1, buffer[3]);
			frsize = frameLength - 4;
			frcount = 1;
			return newChunkFrame;
//		} else if (buffer[0] == 0x88 && buffer[1] == 0x88 && buffer[2] == 0x88 && buffer[3] == 0x88) {
		} else {
			frsize += frameLength - 4;
			/* Interless second freme aliment */
			if(frsize == 312324)
				*dataLength -= 4;
			++frcount;
		}
	}

    if (frameLength < 1) {
		// GenericDriver bug workaround
		*dataLength = 0;
        return invalidFrame;
	}

    return validFrame;
}

//
// These are the C functions to be used for scanning the frames
//
- (void) setIsocFrameFunctions
{
	printf("MORI MORI setIsocFrameFunctions\n");
    grabContext.isocFrameScanner = empiaIsocFrameScanner;
    grabContext.isocDataCopier = genericIsocDataCopier;
}


- (int) em28xxReadRequest: (UInt8) rqst  withRegister: (UInt16) rgstr
{
    UInt8 value;
    
    if (![self usbReadCmdWithBRequest:rqst wValue:0x0000 wIndex:rgstr buf:&value len:1]) 
        return -1;
    
    return value;
}


- (int) em28xxWriteRequest: (UInt8) rqst  withRegister: (UInt16) rgstr  andBuffer: (unsigned char *) buffer  ofLength: (int) length
{
    BOOL ok = [self usbWriteCmdWithBRequest:rqst wValue:0x0000 wIndex:rgstr buf:buffer len:length];
    
    usleep(5000); // 5 ms
    
    return (ok) ? 0 : -1;
}


- (int) em28xxReadRegister: (UInt16) rgstr
{
    return [self em28xxReadRequest:0x00 withRegister:rgstr];  // USB_REQ_GET_STATUS = 0x00
}


- (int) em28xxWriteRegisters: (UInt16) rgstr  withBuffer: (unsigned char *) buffer  ofLength: (int) length
{
    return [self em28xxWriteRequest:0x00 withRegister:rgstr andBuffer:buffer ofLength:length];
}


- (int) em28xxWriteRegister: (UInt16) rgstr  withValue: (UInt8) value  andBitmask: (UInt8) bitmask
{
    int oldValue = [self em28xxReadRegister:rgstr];
    
    if (oldValue < 0) 
        return oldValue; 
    
    UInt8 newValue = (((UInt8) oldValue) & ~bitmask) | (value & bitmask);
    
    return [self em28xxWriteRegisters:rgstr withBuffer:&newValue ofLength:1];
}

// em28xx_read_reg_req_len
- (int) em28xxI2cRecvBytes:(int)addr buf:(unsigned char*)buf len:(int)len 
{

	BOOL ok = [self usbReadCmdWithBRequest:2 wValue:0 wIndex:addr buf:buf len:len];

	usleep(200); // 200 us
	int res = [self em28xxReadRegister:0x05];

//	printf("MORI MORI i2c %d %d %x\n", ok, addr, buf[0]);

	return buf[0];
}

// em28xx_i2c_send_bytes
- (int) em28xxI2cSendBytes:(int)addr buf:(unsigned char*)buf len:(int)len stop:(int)stop
{

	BOOL ok = [self usbWriteCmdWithBRequest:stop ? 2 : 3 wValue:0 wIndex:addr buf:buf len:len];
	
	usleep(200); // 200 us
	int res = [self em28xxReadRegister:0x05];
	
//	printf("MORI MORI i2c %d %d\n", ok, res);
	
	return 0;
}

//
// This is the key method that starts up the stream
//
- (int) saa711x_writeregs:(const unsigned char *) regs
{
	unsigned char reg, data;
	char buf[2];
	
	while (*regs != 0x00) {
		buf[0] = *(regs++);
		buf[1] = *(regs++);
	
		[self em28xxI2cSendBytes:0x4a buf:buf len:2 stop:1];
	}
	
	return 0;
}

- (BOOL) startupGrabStream 
{
    CameraError error = CameraErrorOK;
	unsigned char buf[8];
	struct i2c_reg tvp5150[] = {

		{TVP5150_VD_IN_SRC_SEL_1, 0x02},
		{TVP5150_VIDEO_STD, 0x02},
		{TVP5150_ANAL_CHL_CTL, 0x15},
		{TVP5150_MISC_CTL, 0x2f},
		{0xff, 0xff},
	};

	unsigned char reginit2[] = {
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7f,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x00c6,1,0x38,
		1,0x0005,1,0x00,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000e,1,0x80,
		1,0x0043,1,0x00,
		0,0x0040,2,0x06,0x06,
		0,0x0042,1,0x10,
		1,0x0043,1,0x00,
		0,0x0040,2,0x10,0x90,
		0,0x0042,1,0x14,
		1,0x0043,1,0x00,
		0,0x0040,2,0x10,0x90,
		0,0x0042,1,0x16,
		1,0x0043,1,0x00,
		0,0x0040,2,0x10,0x90,
		0,0x0042,1,0x0e,
		1,0x0000,1,0x18,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		0,0x0020,1,0x00,
		0,0x0022,1,0x00,
		1,0x0012,1,0x24,
		0,0x0012,1,0x24,
		1,0x000c,1,0x00,
		0,0x000c,1,0x00,
		1,0x0000,1,0x18,
		1,0x0008,1,0x7e,
		0,0x0008,1,0xfe,
		1,0x0000,1,0x18,
		1,0x0008,1,0xfe,
		0,0x0008,1,0x7e,
		0,0x0006,1,0x40,
		0,0x0015,1,0x20,
		0,0x0016,1,0x20,
		0,0x0017,1,0x20,
		0,0x0018,1,0x00,
		0,0x0019,1,0x00,
		0,0x001a,1,0x00,
		0,0x0023,1,0x00,
		0,0x0024,1,0x00,
		0,0x0026,1,0x00,
		0,0x0013,1,0x08,
		1,0x0012,1,0x24,
		0,0x0012,1,0x27,
		0,0x000c,1,0x10,
		0,0x0027,1,0x00,
		0,0x0010,1,0x00,
		1,0x0011,1,0x00,
		0,0x0011,1,0x11,
		0,0x0028,1,0x01,
		0,0x0029,1,0xb3,
		0,0x002a,1,0x01,
		0,0x002b,1,0x3b,
		0,0x001c,1,0x00,
		0,0x001d,1,0x0d,
		0,0x001e,1,0xb4,
		0,0x001f,1,0x3c,
		1,0x001b,1,0x00,
		0,0x001b,1,0x00,
		1,0x001b,1,0x00,
		0,0x001b,1,0x00,
		0,0x00b8,2,0x0f,0x02,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x27,0x20,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x1a,0x0c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x04,0xc0,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x1b,0x14,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x0d,0x47,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x28,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,1,0x02,
		1,0x0005,1,0x00,
		1,0x00b8,1,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x02,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xda,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdc,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdd,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xde,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdf,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xea,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xeb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xec,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xed,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xee,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xef,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xfa,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xfb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcf,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc4,0x20,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc5,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x38,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x3f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x71,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x6e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x43,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x69,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x7c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x08,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x39,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x38,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x3f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x71,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x6e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x43,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x69,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x7c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x08,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x39,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xec,0x09,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xed,0x09,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcd,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcb,0x4e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcc,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x30,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x03,0x6f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x00,0x02,
		1,0x0005,1,0x00,
		0,0x0021,1,0x08,
		0,0x0020,1,0x10,
		0,0x00b8,2,0x0b,0x00,
		1,0x0005,1,0x00,
		0,0x0022,1,0x10,
		0,0x0014,1,0x32,
		0,0x0025,1,0x00,
		1,0x0026,1,0x00,
		0,0x0026,1,0x00,
		0,0x00b8,1,0x88,
		1,0x0005,1,0x00,
		1,0x00b8,1,0x11,
		1,0x0005,1,0x00,
		1,0x0027,1,0x00,
		0,0x0027,1,0x00,
		1,0x000c,1,0x10,
		0,0x000c,1,0x10,
		1,0x0012,1,0x27,
		0,0x0012,1,0x67,
		0,0x0022,1,0x10,
		0,0x0020,1,0x10,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		0,0x0021,1,0x08,
		0,0x0020,1,0x10,
		0,0x00b8,2,0x0b,0x00,
		1,0x0005,1,0x00,
		0,0x0022,1,0x10,
		0,0x0014,1,0x32,
		0,0x0025,1,0x00,
		1,0x000f,1,0x07,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7e,
		0,0x0021,1,0x08,
		0,0x0020,1,0x10,
		0,0x00b8,2,0x0b,0x00,
		1,0x0005,1,0x00,
		0,0x0022,1,0x10,
		0,0x0025,1,0x00,
		1,0x0000,1,0x18,
		1,0x000e,1,0x80,
		1,0x0043,1,0x00,
		0,0x0042,1,0x90,
		1,0x0040,2,0x06,0x06,
		1,0x000e,1,0x80,
		0,0x000e,1,0x80,
		1,0x000f,1,0x07,
		0,0x000f,1,0x87,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7c,
		1,0x000f,1,0x87,
		0,0x000f,1,0x07,
		1,0x0008,1,0x7c,
		0,0x0008,1,0x7e,
		0,0x0020,1,0x00,
		0,0x0022,1,0x00,
		1,0x0012,1,0x67,
		0,0x0012,1,0x27,
		1,0x000c,1,0x10,
		0,0x000c,1,0x00,
		1,0x0000,1,0x18,
		1,0x0008,1,0x7e,
		0,0x0008,1,0xfe,
		1,0x0000,1,0x18,
		1,0x0008,1,0xfe,
		0,0x0008,1,0x7e,
		0,0x0006,1,0x40,
		0,0x0015,1,0x20,
		0,0x0016,1,0x20,
		0,0x0017,1,0x20,
		0,0x0018,1,0x00,
		0,0x0019,1,0x00,
		0,0x001a,1,0x00,
		0,0x0023,1,0x00,
		0,0x0024,1,0x00,
		0,0x0026,1,0x00,
		0,0x0013,1,0x08,
		1,0x0012,1,0x27,
		0,0x0012,1,0x27,
		0,0x000c,1,0x10,
		0,0x0027,1,0x34,
		0,0x0010,1,0x00,
		1,0x0011,1,0x11,
		0,0x0011,1,0x11,
		0,0x0028,1,0x01,
		0,0x0029,1,0xaf,
		0,0x002a,1,0x01,
		0,0x002b,1,0x3b,
		0,0x001c,1,0x08,
		0,0x001d,1,0x0d,
		0,0x001e,1,0xb0,
		0,0x001f,1,0x3c,
		1,0x001b,1,0x00,
		0,0x001b,1,0x00,
		1,0x001b,1,0x00,
		0,0x001b,1,0x00,
		1,0x0026,1,0x00,
		0,0x0026,1,0x10,
		0,0x0030,2,0x99,0x01,
		0,0x00b8,2,0x0f,0x02,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x27,0x20,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x1a,0x0c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x04,0xc0,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x1b,0x14,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x0d,0x47,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x28,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,1,0x02,
		1,0x0005,1,0x00,
		1,0x00b8,1,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x02,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xd9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xda,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdc,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdd,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xde,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xdf,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xe9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xea,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xeb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xec,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xed,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xee,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xef,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf0,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf1,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf2,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf3,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf4,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf5,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf6,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf7,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf8,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xf9,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xfa,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xfb,0xff,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcf,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc4,0x20,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc5,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x38,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x3f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x71,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x6e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x43,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x69,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x7c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x08,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x39,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x38,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x3f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x71,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x6e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x43,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x69,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x7c,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x08,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x39,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xc3,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xec,0x09,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xed,0x09,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcd,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcb,0x4e,
		1,0x0005,1,0x00,
		0,0x00b8,2,0xcc,0x00,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x30,0x01,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x03,0x6f,
		1,0x0005,1,0x00,
		0,0x00b8,2,0x00,0x02,
		1,0x0005,1,0x00,
		0,0x0021,1,0x08,
		0,0x0020,1,0x10,
		0,0x00b8,2,0x0b,0x00,
		1,0x0005,1,0x00,
		0,0x0022,1,0x10,
		0,0x0014,1,0x32,
		0,0x0025,1,0x00,
		1,0x0026,1,0x10,
		0,0x0026,1,0x10,
		0,0x00b8,1,0x88,
		1,0x0005,1,0x00,
		1,0x00b8,1,0x1e,
		1,0x0005,1,0x00,
		1,0x0027,1,0x34,
		0,0x0027,1,0x34,
		1,0x000c,1,0x10,
		0,0x000c,1,0x10,
		1,0x0012,1,0x27,
		0,0x0012,1,0x67,
		0,0x0022,1,0x10,
		0,0x0020,1,0x10,
		1,0x000e,1,0x85,
		1,0x0043,1,0x00,
		0,0x0042,1,0x90,
		1,0x0040,2,0x08,0x08,
		1,0x000e,1,0x85,
		0,0x000e,1,0x85,
		1,0x000f,1,0x07,
		0,0x000f,1,0x87,
		1,0x0008,1,0x7e,
		0,0x0008,1,0x7c,
		1,0x000c,1,0x10,
		0,0x000c,1,0x10,
		0xff
	};
	
	/* SAA7113 init codes */
	static const unsigned char saa7113_init[] = {
		R_01_INC_DELAY, 0x08,

		R_02_INPUT_CNTL_1, 0xc2,
		R_03_INPUT_CNTL_2, 0x30,
		R_04_INPUT_CNTL_3, 0x00,
		R_05_INPUT_CNTL_4, 0x00,
 
		R_06_H_SYNC_START, 0x89,
		R_07_H_SYNC_STOP, 0x0d,
		R_08_SYNC_CNTL, 0x88,

		R_09_LUMA_CNTL, 0x01,
		R_0A_LUMA_BRIGHT_CNTL, 0x80,
		R_0B_LUMA_CONTRAST_CNTL, 0x47,

		R_0C_CHROMA_SAT_CNTL, 0x40,
		R_0D_CHROMA_HUE_CNTL, 0x00,
		R_0E_CHROMA_CNTL_1, 0x01,
		R_0F_CHROMA_GAIN_CNTL, 0x2a,
		R_10_CHROMA_CNTL_2, 0x08,

		R_11_MODE_DELAY_CNTL, 0x0c,

		R_12_RT_SIGNAL_CNTL, 0x07,
		R_13_RT_X_PORT_OUT_CNTL, 0x00,
		R_14_ANAL_ADC_COMPAT_CNTL, 0x00,
		
		R_15_VGATE_START_FID_CHG, 0x00,
		R_16_VGATE_STOP, 0x00,
		R_17_MISC_VGATE_CONF_AND_MSB, 0x00,

		0x00, 0x00
	};

	static const unsigned char saa7115_init_misc[] = {
		R_81_V_SYNC_FLD_ID_SRC_SEL_AND_RETIMED_V_F, 0x01,
		R_83_X_PORT_I_O_ENA_AND_OUT_CLK, 0x01,
		R_84_I_PORT_SIGNAL_DEF, 0x20,
		R_85_I_PORT_SIGNAL_POLAR, 0x21,
		R_86_I_PORT_FIFO_FLAG_CNTL_AND_ARBIT, 0xc5,
		R_87_I_PORT_I_O_ENA_OUT_CLK_AND_GATED, 0x01,
		
		/* Task A */
		R_A0_A_HORIZ_PRESCALING, 0x01,
		R_A1_A_ACCUMULATION_LENGTH, 0x00,
		R_A2_A_PRESCALER_DC_GAIN_AND_FIR_PREFILTER, 0x00,
		
		/* Configure controls at nominal value*/
		R_A4_A_LUMA_BRIGHTNESS_CNTL, 0x80,
		R_A5_A_LUMA_CONTRAST_CNTL, 0x40,
		R_A6_A_CHROMA_SATURATION_CNTL, 0x40,
		
		/* note: 2 x zoom ensures that VBI lines have same length as video lines. */
		R_A8_A_HORIZ_LUMA_SCALING_INC, 0x00,
		R_A9_A_HORIZ_LUMA_SCALING_INC_MSB, 0x02,
		
		R_AA_A_HORIZ_LUMA_PHASE_OFF, 0x00,
		
		/* must be horiz lum scaling / 2 */
		R_AC_A_HORIZ_CHROMA_SCALING_INC, 0x00,
		R_AD_A_HORIZ_CHROMA_SCALING_INC_MSB, 0x01,
		
		/* must be offset luma / 2 */
		R_AE_A_HORIZ_CHROMA_PHASE_OFF, 0x00,
		
		R_B0_A_VERT_LUMA_SCALING_INC, 0x00,
		R_B1_A_VERT_LUMA_SCALING_INC_MSB, 0x04,
		
		R_B2_A_VERT_CHROMA_SCALING_INC, 0x00,
		R_B3_A_VERT_CHROMA_SCALING_INC_MSB, 0x04,
		
		R_B4_A_VERT_SCALING_MODE_CNTL, 0x01,
		
		R_B8_A_VERT_CHROMA_PHASE_OFF_00, 0x00,
		R_B9_A_VERT_CHROMA_PHASE_OFF_01, 0x00,
		R_BA_A_VERT_CHROMA_PHASE_OFF_10, 0x00,
		R_BB_A_VERT_CHROMA_PHASE_OFF_11, 0x00,
		
		R_BC_A_VERT_LUMA_PHASE_OFF_00, 0x00,
		R_BD_A_VERT_LUMA_PHASE_OFF_01, 0x00,
		R_BE_A_VERT_LUMA_PHASE_OFF_10, 0x00,
		R_BF_A_VERT_LUMA_PHASE_OFF_11, 0x00,
		
		/* Task B */
		R_D0_B_HORIZ_PRESCALING, 0x01,
		R_D1_B_ACCUMULATION_LENGTH, 0x00,
		R_D2_B_PRESCALER_DC_GAIN_AND_FIR_PREFILTER, 0x00,
		
		/* Configure controls at nominal value*/
		R_D4_B_LUMA_BRIGHTNESS_CNTL, 0x80,
		R_D5_B_LUMA_CONTRAST_CNTL, 0x40,
		R_D6_B_CHROMA_SATURATION_CNTL, 0x40,
		
		/* hor lum scaling 0x0400 = 1 */
		R_D8_B_HORIZ_LUMA_SCALING_INC, 0x00,
		R_D9_B_HORIZ_LUMA_SCALING_INC_MSB, 0x04,
		
		R_DA_B_HORIZ_LUMA_PHASE_OFF, 0x00,
		
		/* must be hor lum scaling / 2 */
		R_DC_B_HORIZ_CHROMA_SCALING, 0x00,
		R_DD_B_HORIZ_CHROMA_SCALING_MSB, 0x02,
		
		/* must be offset luma / 2 */
		R_DE_B_HORIZ_PHASE_OFFSET_CRHOMA, 0x00,
		
		R_E0_B_VERT_LUMA_SCALING_INC, 0x00,
		R_E1_B_VERT_LUMA_SCALING_INC_MSB, 0x04,
		
		R_E2_B_VERT_CHROMA_SCALING_INC, 0x00,
		R_E3_B_VERT_CHROMA_SCALING_INC_MSB, 0x04,
		
		R_E4_B_VERT_SCALING_MODE_CNTL, 0x01,
		
		R_E8_B_VERT_CHROMA_PHASE_OFF_00, 0x00,
		R_E9_B_VERT_CHROMA_PHASE_OFF_01, 0x00,
		R_EA_B_VERT_CHROMA_PHASE_OFF_10, 0x00,
		R_EB_B_VERT_CHROMA_PHASE_OFF_11, 0x00,
		
		R_EC_B_VERT_LUMA_PHASE_OFF_00, 0x00,
		R_ED_B_VERT_LUMA_PHASE_OFF_01, 0x00,
		R_EE_B_VERT_LUMA_PHASE_OFF_10, 0x00,
		R_EF_B_VERT_LUMA_PHASE_OFF_11, 0x00,
		
		R_F2_NOMINAL_PLL2_DTO, 0x50,		/* crystal clock = 24.576 MHz, target = 27MHz */
		R_F3_PLL_INCREMENT, 0x46,
		R_F4_PLL2_STATUS, 0x00,
		R_F7_PULSE_A_POS_MSB, 0x4b,		/* not the recommended settings! */
		R_F8_PULSE_B_POS, 0x00,
		R_F9_PULSE_B_POS_MSB, 0x4b,
		R_FA_PULSE_C_POS, 0x00,
		R_FB_PULSE_C_POS_MSB, 0x4b,
		
		/* PLL2 lock detection settings: 71 lines 50% phase error */
		R_FF_S_PLL_MAX_PHASE_ERR_THRESH_NUM_LINES, 0x88,
		
		/* Turn off VBI */
		R_40_SLICER_CNTL_1, 0x20,             /* No framing code errors allowed. */
		R_41_LCR_BASE, 0xff,
		R_41_LCR_BASE+1, 0xff,
		R_41_LCR_BASE+2, 0xff,
		R_41_LCR_BASE+3, 0xff,
		R_41_LCR_BASE+4, 0xff,
		R_41_LCR_BASE+5, 0xff,
		R_41_LCR_BASE+6, 0xff,
		R_41_LCR_BASE+7, 0xff,
		R_41_LCR_BASE+8, 0xff,
		R_41_LCR_BASE+9, 0xff,
		R_41_LCR_BASE+10, 0xff,
		R_41_LCR_BASE+11, 0xff,
		R_41_LCR_BASE+12, 0xff,
		R_41_LCR_BASE+13, 0xff,
		R_41_LCR_BASE+14, 0xff,
		R_41_LCR_BASE+15, 0xff,
		R_41_LCR_BASE+16, 0xff,
		R_41_LCR_BASE+17, 0xff,
		R_41_LCR_BASE+18, 0xff,
		R_41_LCR_BASE+19, 0xff,
		R_41_LCR_BASE+20, 0xff,
		R_41_LCR_BASE+21, 0xff,
		R_41_LCR_BASE+22, 0xff,
		R_58_PROGRAM_FRAMING_CODE, 0x40,
		R_59_H_OFF_FOR_SLICER, 0x47,
		R_5B_FLD_OFF_AND_MSB_FOR_H_AND_V_OFF, 0x83,
		R_5D_DID, 0xbd,
		R_5E_SDID, 0x35,
		
		R_02_INPUT_CNTL_1, 0xc0, /* input tuner -> input 4, amplifier active */
		
		R_80_GLOBAL_CNTL_1, 0x20,		/* enable task B */
		R_88_POWER_SAVE_ADC_PORT_CNTL, 0xd0,
		R_88_POWER_SAVE_ADC_PORT_CNTL, 0xf0,
		0x00, 0x00
	};
	
	int i, reg;

	if (decoder == EM28XX_TVP5150) {
		i = 0;
		while (reginit2[i] != 0xff) {
			int len = reginit2[i + 2];
			if (reginit2[i] == 0 && reginit2[i + 1] == 0xb8) {
				[self em28xxWriteRegisters:reginit2[i + 1] withBuffer:&reginit2[i+3] ofLength:len];
			} else {
//				reg = [self em28xxReadRegister:reginit2[i + 1]];
			}
			i = i + len + 3;
		}
		
		i = 0;
		while (tvp5150[i].addr != 0xff) {
			buf[0] = tvp5150[i].addr;
			buf[1] = tvp5150[i].val;
			++i;
			[self em28xxI2cSendBytes:0xb8 buf:buf len:2 stop:1];
		}
	}

	if (decoder == EM28XX_SAA711X) {
//		[self saa711x_writeregs:saa7113_init];
//		[self saa711x_writeregs:saa7115_init_misc];
	}

	buf[0] = EM28XX_XCLK_FREQUENCY_12MHZ;
	[self em28xxWriteRegisters:EM28XX_R0F_XCLK withBuffer:buf ofLength:1];

	if (driver_info == EM2820_BOARD_IODATA_GVMVP_SZ) {
		buf[0] = 0xff;
		[self em28xxWriteRegisters:EM28XX_R08_GPIO withBuffer:buf ofLength:1];
		usleep(50000);
		buf[0] = 0xf7;
		[self em28xxWriteRegisters:EM28XX_R08_GPIO withBuffer:buf ofLength:1];
		usleep(50000);
		buf[0] = 0xfe;
		[self em28xxWriteRegisters:EM28XX_R08_GPIO withBuffer:buf ofLength:1];
		usleep(50000);
		buf[0] = 0xfd;
		[self em28xxWriteRegisters:EM28XX_R08_GPIO withBuffer:buf ofLength:1];
		usleep(50000);
	}
	
	buf[0] = EM28XX_VINCTRL_INTERLACED | EM28XX_VINCTRL_CCIR656_ENABLE;
	[self em28xxWriteRegisters:EM28XX_R11_VINCTRL withBuffer:buf ofLength:1];
	usleep(50000);


	buf[0] = 1;
	[self em28xxWriteRegisters:EM28XX_R28_XMIN withBuffer:buf ofLength:2];
	buf[0] = (640 - 4) >> 2;
	[self em28xxWriteRegisters:EM28XX_R29_XMAX withBuffer:buf ofLength:2];
	buf[0] = 1;
	[self em28xxWriteRegisters:EM28XX_R2A_YMIN withBuffer:buf ofLength:2];
	buf[0] = (480 - 4) >> 2;
	[self em28xxWriteRegisters:EM28XX_R2B_YMAX withBuffer:buf ofLength:2];

	
	buf[0] = 0;
	[self em28xxWriteRegisters:EM28XX_R1C_HSTART withBuffer:buf ofLength:2];
	buf[0] = 0;
	[self em28xxWriteRegisters:EM28XX_R1D_VSTART withBuffer:buf ofLength:2];
	buf[0] = 0xff & (640 >> 2);
	[self em28xxWriteRegisters:EM28XX_R1E_CWIDTH withBuffer:buf ofLength:2];
	buf[0] = 0xff & (480 >> 2);
	[self em28xxWriteRegisters:EM28XX_R1F_CHEIGHT withBuffer:buf ofLength:2];
	buf[0] = 0;
	[self em28xxWriteRegisters:EM28XX_R1B_OFLOW withBuffer:buf ofLength:2];
	
	int hs = (640 << 12) / 640 + 4096;
	int vs = (480 << 12) / 480 + 4096;
	buf[0] = hs & 0xff;
	buf[1] = hs >> 8;
	[self em28xxWriteRegisters:EM28XX_R30_HSCALELOW withBuffer:buf ofLength:2];
	buf[0] = vs & 0xff;
	buf[1] = vs >> 8;
	[self em28xxWriteRegisters:EM28XX_R32_VSCALELOW withBuffer:buf ofLength:2];
	
	buf[0] = 0x00;
	[self em28xxWriteRegisters:EM28XX_R26_COMPR withBuffer:buf ofLength:1];
	usleep(50000);
	
	buf[0] = EM28XX_OUTFMT_RGB_16_656;
	[self em28xxWriteRegisters:EM28XX_R27_OUTFMT withBuffer:buf ofLength:1];

    if ([self em28xxWriteRegister:EM28XX_R0C_USBSUSP withValue:0x10 andBitmask:0x10] < 0)  // USBSUSP_REG = 0x0c
        error = CameraErrorUSBProblem;

    if ([self em28xxWriteRegisters:0x48 withBuffer:(unsigned char *) "\x00" ofLength:1] < 0)  // enable video capture
        error = CameraErrorUSBProblem;
    
    if ([self em28xxWriteRegisters:EM28XX_R12_VINENABLE withBuffer:(unsigned char *) "\x67" ofLength:1] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;

	buf[0] = 0x99;
	buf[0] = 0x01;
	if ([self em28xxWriteRegisters:0x30 withBuffer:buf ofLength:2] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;

    if ([self em28xxWriteRegisters:0x0e withBuffer:(unsigned char *) "\x85" ofLength:1] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;
    if ([self em28xxWriteRegisters:0x0f withBuffer:(unsigned char *) "\x87" ofLength:1] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;
    if ([self em28xxWriteRegisters:0x08 withBuffer:(unsigned char *) "\x7c" ofLength:1] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;
    if ([self em28xxWriteRegisters:0x0c withBuffer:(unsigned char *) "\x10" ofLength:1] < 0)  // VINENABLE_REG = 0x12
        error = CameraErrorUSBProblem;

	printf("MORI MORI startup %d\n", error);
    return error == CameraErrorOK;
}

//
// The key routine for shutting down the stream
//
- (void) shutdownGrabStream 
{
    [self em28xxWriteRegister:0x0c withValue:0x00 andBitmask:0x10];
    
    [self em28xxWriteRegisters:0x12 withBuffer:(unsigned char *) "\x27" ofLength:1];
    
    [self usbSetAltInterfaceTo:0 testPipe:[self getGrabbingPipe]];
}

//
// This is the method that takes the raw chunk data and turns it into an image
//
//- (BOOL) decodeBuffer: (GenericChunkBuffer *) buffer
- (BOOL) decodeBufferGSPCA: (GenericChunkBuffer *) buffer
{
//    printf("Need to decode a buffer with %ld bytes.\n", buffer->numBytes);

	long w, h;
//    UInt8 * src = buffer->buffer;
    UInt16 * src = buffer->buffer;
    UInt8 * dst;
    
	short numColumns  = [self width];
	short numRows = [self height];
	int r, g, b;

	if (buffer->numBytes != 623368 - 4) {
		printf("invalid frame data size %d\n", buffer->numBytes);
		return NO;
	}
#define USE_SSE
#if 1
//	printf("nextImageBufferRowBytes %d %d\n", nextImageBufferRowBytes, nextImageBufferBPP);
	// dst[0] = R, dst[1] = G, dst[2] = B
    for (h = 0; h < numRows / 2; h++) 
    {
		dst = nextImageBuffer + h * nextImageBufferRowBytes * 2;        
#ifdef USE_SSE
		rgb565(src, dst, numColumns);
		src += numColumns;
#else
        for (w = 0; w < numColumns; w++) 
		{
            r = (*src & 0x1f);
            g = (*src >> 5) & 0x3f;
            b = (*src >> 11);
            dst[0] = r * 0xff / 0x1f;
            dst[1] = g * 0xff / 0x3f;
            dst[2] = b * 0xff / 0x1f;
            src += 1;
            dst += nextImageBufferBPP;
        }
#endif
	}
	src = buffer->buffer + 312320;
	for (h = 0; h < numRows / 2; h++) 
    {
		dst = nextImageBuffer + h * nextImageBufferRowBytes * 2 + nextImageBufferRowBytes;
#ifdef USE_SSE
		rgb565(src, dst, numColumns);
		src += numColumns;
#else
        for (w = 0; w < numColumns; w++) 
		{
            r = (*src & 0x1f);
            g = (*src >> 5) & 0x3f;
            b = (*src >> 11);
            dst[0] = r * 0xff / 0x1f;
            dst[1] = g * 0xff / 0x3f;
            dst[2] = b * 0xff / 0x1f;
            src += 1;
            dst += nextImageBufferBPP;
        }
#endif
	}
#else
	yuv2rgb (640,240,YUVCPIA422Style,src,nextImageBuffer,nextImageBufferBPP,0,nextImageBufferRowBytes,0);
	yuv2rgb (640,240,YUVCPIA422Style,src + 312324,nextImageBuffer + nextImageBufferRowBytes,nextImageBufferBPP,0,nextImageBufferRowBytes,0);
#endif

    return YES;
}

int rgb565(uint16_t *rgb565buf, uint8_t *rgb888buf, size_t buf_size) { 
    // Create a small test buffer
    // We process 16 pixels at a time, so size must be a multiple of 16
	
    // Fill it with recognizable data
	int i;
		
    // Masks for extracting RGB channels
    const __m128i mask_r = _mm_set1_epi32(0x00F80000);
    const __m128i mask_g = _mm_set1_epi32(0x0000FC00);
    const __m128i mask_b = _mm_set1_epi32(0x000000F8);
	
    // Masks for extracting 24bpp pixels for the first 128b write
    const __m128i mask_0_1st  = _mm_set_epi32(0,          0,          0,          0x00FFFFFF);
    const __m128i mask_0_2nd  = _mm_set_epi32(0,          0,          0x0000FFFF, 0xFF000000);
    const __m128i mask_0_3rd  = _mm_set_epi32(0,          0x000000FF, 0xFFFF0000, 0         );
    const __m128i mask_0_4th  = _mm_set_epi32(0,          0xFFFFFF00, 0,          0         );
    const __m128i mask_0_5th  = _mm_set_epi32(0x00FFFFFF, 0,          0,          0         );
    const __m128i mask_0_6th  = _mm_set_epi32(0xFF000000, 0,          0,          0         ); 
    // Masks for the second write
    const __m128i mask_1_6th  = _mm_set_epi32(0,          0,          0,          0x0000FFFF);
    const __m128i mask_1_7th  = _mm_set_epi32(0,          0,          0x000000FF, 0xFFFF0000);
    const __m128i mask_1_8th  = _mm_set_epi32(0,          0,          0xFFFFFF00, 0         );
    const __m128i mask_1_9th  = _mm_set_epi32(0,          0x00FFFFFF, 0,          0         );
    const __m128i mask_1_10th = _mm_set_epi32(0x0000FFFF, 0xFF000000, 0,          0         );
    const __m128i mask_1_11th = _mm_set_epi32(0xFFFF0000, 0,          0,          0         );
    // Masks for the third write
    const __m128i mask_2_11th = _mm_set_epi32(0,          0,          0,          0x000000FF);
    const __m128i mask_2_12th = _mm_set_epi32(0,          0,          0,          0xFFFFFF00);
    const __m128i mask_2_13th = _mm_set_epi32(0,          0,          0x00FFFFFF, 0         );
    const __m128i mask_2_14th = _mm_set_epi32(0,          0x0000FFFF, 0xFF000000, 0         );
    const __m128i mask_2_15th = _mm_set_epi32(0x000000FF, 0xFFFF0000, 0,          0         );
    const __m128i mask_2_16th = _mm_set_epi32(0xFFFFFF00, 0,          0,          0         );
	
    // Convert the RGB565 data into RGB888 data
    __m128i *packed_rgb888_buf = (__m128i*)rgb888buf;
    for (i = 0; i < buf_size; i += 16) {
        // Need to do 16 pixels at a time -> least number of 24bpp pixels that fit evenly in XMM register
        __m128i rgb565pix0_raw = _mm_load_si128((__m128i *)(&rgb565buf[i]));
        __m128i rgb565pix1_raw = _mm_load_si128((__m128i *)(&rgb565buf[i+8]));
		
        // Extend the 16b ints to 32b ints
        __m128i rgb565pix0lo_32b = _mm_unpacklo_epi16(rgb565pix0_raw, _mm_setzero_si128());
        __m128i rgb565pix0hi_32b = _mm_unpackhi_epi16(rgb565pix0_raw, _mm_setzero_si128());
        // Shift each color channel into the correct position and mask off the other bits
        __m128i rgb888pix0lo_r = _mm_and_si128(mask_r, _mm_slli_epi32(rgb565pix0lo_32b, 8)); // Block 0 low pixels
        __m128i rgb888pix0lo_g = _mm_and_si128(mask_g, _mm_slli_epi32(rgb565pix0lo_32b, 5));
        __m128i rgb888pix0lo_b = _mm_and_si128(mask_b, _mm_slli_epi32(rgb565pix0lo_32b, 3));
        __m128i rgb888pix0hi_r = _mm_and_si128(mask_r, _mm_slli_epi32(rgb565pix0hi_32b, 8)); // Block 0 high pixels
        __m128i rgb888pix0hi_g = _mm_and_si128(mask_g, _mm_slli_epi32(rgb565pix0hi_32b, 5));
        __m128i rgb888pix0hi_b = _mm_and_si128(mask_b, _mm_slli_epi32(rgb565pix0hi_32b, 3));
        // Combine each color channel into a single vector of four 32bpp pixels
        __m128i rgb888pix0lo_32b = _mm_or_si128(rgb888pix0lo_r, _mm_or_si128(rgb888pix0lo_g, rgb888pix0lo_b));
        __m128i rgb888pix0hi_32b = _mm_or_si128(rgb888pix0hi_r, _mm_or_si128(rgb888pix0hi_g, rgb888pix0hi_b));
		
        // Same thing as above for the next block of pixels
        __m128i rgb565pix1lo_32b = _mm_unpacklo_epi16(rgb565pix1_raw, _mm_setzero_si128());
        __m128i rgb565pix1hi_32b = _mm_unpackhi_epi16(rgb565pix1_raw, _mm_setzero_si128());
        __m128i rgb888pix1lo_r = _mm_and_si128(mask_r, _mm_slli_epi32(rgb565pix1lo_32b, 8)); // Block 1 low pixels
        __m128i rgb888pix1lo_g = _mm_and_si128(mask_g, _mm_slli_epi32(rgb565pix1lo_32b, 5));
        __m128i rgb888pix1lo_b = _mm_and_si128(mask_b, _mm_slli_epi32(rgb565pix1lo_32b, 3));
        __m128i rgb888pix1hi_r = _mm_and_si128(mask_r, _mm_slli_epi32(rgb565pix1hi_32b, 8)); // Block 1 high pixels
        __m128i rgb888pix1hi_g = _mm_and_si128(mask_g, _mm_slli_epi32(rgb565pix1hi_32b, 5));
        __m128i rgb888pix1hi_b = _mm_and_si128(mask_b, _mm_slli_epi32(rgb565pix1hi_32b, 3));
        __m128i rgb888pix1lo_32b = _mm_or_si128(rgb888pix1lo_r, _mm_or_si128(rgb888pix1lo_g, rgb888pix1lo_b));
        __m128i rgb888pix1hi_32b = _mm_or_si128(rgb888pix1hi_r, _mm_or_si128(rgb888pix1hi_g, rgb888pix1hi_b));
		
        // At this point, rgb888pix_32b contains the pixel data in 32bpp format, need to compress it to 24bpp
        // Use the _mm_bs*li_si128(__m128i, int) intrinsic to shift each 24bpp pixel into it's final position
        // ...then mask off the other pixels and combine the result together with or
        __m128i pix_0_1st = _mm_and_si128(mask_0_1st,                 rgb888pix0lo_32b     ); // First 4 pixels
        __m128i pix_0_2nd = _mm_and_si128(mask_0_2nd, _mm_srli_si128(rgb888pix0lo_32b, 1 ));
        __m128i pix_0_3rd = _mm_and_si128(mask_0_3rd, _mm_srli_si128(rgb888pix0lo_32b, 2 ));
        __m128i pix_0_4th = _mm_and_si128(mask_0_4th, _mm_srli_si128(rgb888pix0lo_32b, 3 ));
        __m128i pix_0_5th = _mm_and_si128(mask_0_5th, _mm_slli_si128(rgb888pix0hi_32b, 12)); // Second 4 pixels
        __m128i pix_0_6th = _mm_and_si128(mask_0_6th, _mm_slli_si128(rgb888pix0hi_32b, 11));
        // Combine each piece of 24bpp pixel data into a single 128b variable
        __m128i pix128_0 = _mm_or_si128(_mm_or_si128(_mm_or_si128(pix_0_1st, pix_0_2nd), pix_0_3rd), 
                                        _mm_or_si128(_mm_or_si128(pix_0_4th, pix_0_5th), pix_0_6th));
        _mm_store_si128(packed_rgb888_buf, pix128_0);
		
        // Repeat the same for the second 128b write
        __m128i pix_1_6th  = _mm_and_si128(mask_1_6th,  _mm_srli_si128(rgb888pix0hi_32b, 5 ));
        __m128i pix_1_7th  = _mm_and_si128(mask_1_7th,  _mm_srli_si128(rgb888pix0hi_32b, 6 ));
        __m128i pix_1_8th  = _mm_and_si128(mask_1_8th,  _mm_srli_si128(rgb888pix0hi_32b, 7 ));
        __m128i pix_1_9th  = _mm_and_si128(mask_1_9th,  _mm_slli_si128(rgb888pix1lo_32b, 8 )); // Third 4 pixels
        __m128i pix_1_10th = _mm_and_si128(mask_1_10th, _mm_slli_si128(rgb888pix1lo_32b, 7 ));
        __m128i pix_1_11th = _mm_and_si128(mask_1_11th, _mm_slli_si128(rgb888pix1lo_32b, 6 ));
        __m128i pix128_1 = _mm_or_si128(_mm_or_si128(_mm_or_si128(pix_1_6th, pix_1_7th),  pix_1_8th ), 
                                        _mm_or_si128(_mm_or_si128(pix_1_9th, pix_1_10th), pix_1_11th));
        _mm_store_si128(packed_rgb888_buf+1, pix128_1);
		
        // And again for the third 128b write
        __m128i pix_2_11th = _mm_and_si128(mask_2_11th, _mm_srli_si128(rgb888pix1lo_32b, 10));
        __m128i pix_2_12th = _mm_and_si128(mask_2_12th, _mm_srli_si128(rgb888pix1lo_32b, 11));
        __m128i pix_2_13th = _mm_and_si128(mask_2_13th, _mm_slli_si128(rgb888pix1hi_32b,  4)); // Fourth 4 pixels
        __m128i pix_2_14th = _mm_and_si128(mask_2_14th, _mm_slli_si128(rgb888pix1hi_32b,  3));
        __m128i pix_2_15th = _mm_and_si128(mask_2_15th, _mm_slli_si128(rgb888pix1hi_32b,  2));
        __m128i pix_2_16th = _mm_and_si128(mask_2_16th, _mm_slli_si128(rgb888pix1hi_32b,  1));
        __m128i pix128_2 = _mm_or_si128(_mm_or_si128(_mm_or_si128(pix_2_11th, pix_2_12th), pix_2_13th), 
                                        _mm_or_si128(_mm_or_si128(pix_2_14th, pix_2_15th), pix_2_16th));
        _mm_store_si128(packed_rgb888_buf+2, pix128_2);
		
        // Update pointer for next iteration
        packed_rgb888_buf += 3;
    }

    return EXIT_SUCCESS;
}

@end
