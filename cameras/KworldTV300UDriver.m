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
	buf[0] = TVP5150_MSB_DEV_ID;
	[self em28xxI2cSendBytes:0xb8 buf:buf len:1 stop:0];
	[self em28xxI2cRecvBytes:0xb8 buf:buf len:1];
	buf[0] = TVP5150_LSB_DEV_ID;
	[self em28xxI2cSendBytes:0xb8 buf:buf len:1 stop:0];
	[self em28xxI2cRecvBytes:0xb8 buf:buf len:1];

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
//				if((buffer[2] & 1 && frcount != 312324) || ((buffer[2] & 1) == 0 && frcount != 311044))
//			printf("MORI MORI %d %d %d\n", frcount, buffer[2] & 1, buffer[3]);
			frcount = frameLength - 4;
			return newChunkFrame;
//		} else if (buffer[0] == 0x88 && buffer[1] == 0x88 && buffer[2] == 0x88 && buffer[3] == 0x88) {
		} else {
			frcount += frameLength - 4;
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

	int i, reg;

	i = 0;
	while (reginit2[i] != 0xff) {
		int len = reginit2[i + 2];
		if (reginit2[i] == 0) {
			[self em28xxWriteRegisters:reginit2[i + 1] withBuffer:&reginit2[i+3] ofLength:len];
		} else {
			reg = [self em28xxReadRegister:reginit2[i + 1]];
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

	buf[0] = EM28XX_XCLK_FREQUENCY_12MHZ;
	[self em28xxWriteRegisters:EM28XX_R0F_XCLK withBuffer:buf ofLength:1];

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
    UInt8 * src = buffer->buffer;
    UInt8 * dst;
    
	short numColumns  = [self width];
	short numRows = [self height];
    
	
	if (buffer->numBytes != 623368) {
		printf("invalid frame data size %d\n", buffer->numBytes);
		return NO;
	}
#if 1
//	printf("nextImageBufferRowBytes %d %d\n", nextImageBufferRowBytes, nextImageBufferBPP);
	// dst[0] = R, dst[1] = G, dst[2] = B
	int r, g, b;
    for (h = 0; h < numRows / 2; h++) 
    {
        dst = nextImageBuffer + h * nextImageBufferRowBytes * 2;
        
        for (w = 0; w < numColumns; w++) 
		{
            r = (src[0] & 0x1f);
            g = ((src[0] >> 5) | ((src[1] & 0x07) << 3));
            b = (src[1] >> 3);
            dst[0] = r * 0xff / 0x1f;
            dst[1] = g * 0xff / 0x3f;
            dst[2] = b * 0xff / 0x1f;
            src += 2;
            dst += nextImageBufferBPP;
        }

	}

	src = buffer->buffer + 312324;
	for (h = 0; h < numRows / 2; h++) 
    {
        dst = nextImageBuffer + h * nextImageBufferRowBytes * 2 + nextImageBufferRowBytes;
        
        for (w = 0; w < numColumns; w++) 
		{
            r = (src[0] & 0x1f);
            g = ((src[0] >> 5) | ((src[1] & 0x07) << 3));
            b = (src[1] >> 3);
            dst[0] = r * 0xff / 0x1f;
            dst[1] = g * 0xff / 0x3f;
            dst[2] = b * 0xff / 0x1f;
            src += 2;
            dst += nextImageBufferBPP;
        }
		
	}
#else
	yuv2rgb (640,240,YUVCPIA422Style,src,nextImageBuffer,nextImageBufferBPP,0,nextImageBufferRowBytes,0);
	yuv2rgb (640,240,YUVCPIA422Style,src + 312324,nextImageBuffer + nextImageBufferRowBytes,nextImageBufferBPP,0,nextImageBufferRowBytes,0);
#endif

    return YES;
}

@end
