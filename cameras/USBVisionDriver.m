//
//  USBVisionDriver.m
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

#import "USBVisionDriver.h"

#include "USB_VendorProductIDs.h"


@implementation USBVisionDriver


//static int saa7111_write(struct i2c_client *client, unsigned char subaddr,
//						 unsigned char data)
- (int) saa7111Write:(unsigned char)subaddr date:(unsigned char)data
{
	char buf[2];

	buf[0] = subaddr;
	buf[1] = data;
	[self i2cWrite:0x48>>1 buf:buf len:2];
}

//static int saa7111_read(struct i2c_client *client, unsigned char subaddr)
- (int) saa7111Read:subaddr
{
	char buf[2];
	
	buf[0] = subaddr;
	[self i2cWrite:0x48>>1 buf:buf len:2];
	[self i2cRead:0x48>>1 buf:buf len:1];
	return buf[1];
}

// usbvision_i2c_write_max4
- (int) i2cWriteMax4:(unsigned char)addr buf:(char *)buf len:(short)len
{
	int rc, retries;
	int i;
	unsigned char value[6];
	unsigned char ser_cont;
	
//	ser_cont = (len & 0x07) | 0x10;
	ser_cont = (len & 0x07);

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
//		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07) | 0x10];
		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07)];
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
		
		if (--retries < 0)
			return -1;
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
		NSLog(@"I2CMAX 1 %d", len);
		/* Initiate byte read cycle                    */
		/* USBVISION_SER_CONT <- d0-d2 n. of bytes to r/w */
		/*                    d3 0=Wr 1=Rd             */	
//		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07) | 0x18];
		rc = [self setRegister:USBVISION_SER_CONT toValue:(len & 0x07) | 0x08];
		if (rc == -1)
			return rc;

		do {
			/* USBVISION_SER_CONT -> d4 == 0 busy */
			rc = [self getRegister:USBVISION_SER_CONT];
		} while (rc > 0 && ((rc & 0x10) != 0));
		NSLog(@"I2CMAX 2 %d", rc);
		
		/* USBVISION_SER_CONT -> d5 == 1 Not ack */
		if ((rc & 0x20) == 0)	/* Ack? */
			break;
		
		/* I2C abort */
		rc = [self setRegister:USBVISION_SER_CONT toValue:0x00];
		if (rc < 0)
			return rc;
		
		if (--retries < 0)
			return -1;
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
	NSLog(@"I2CMAX 3");

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
    
    return (ok) ? buffer[0] : -1;
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
	return self;
}

//
// Provide feedback about which resolutions and rates are supported
//
- (BOOL) supportsResolution: (CameraResolution) res fps: (short) rate 
{
 
	[self setRegister:USBVISION_PWR_REG toValue:USBVISION_SSPND_EN | USBVISION_RES2];
    int i;
	for(i = 0; i <= 0x10; ++i) {
		NSLog(@"MORIMORI %x %d", i, [self getRegister:i]);
	}
	[self setRegister:USBVISION_SER_MODE toValue:USBVISION_IIC_LRNACK];

	[self saa7111Write:0x02 date:0x01];
	NSLog(@"MORIMORI I2C %x %x", 2, [self saa7111Read:0x02]);
	[self saa7111Write:0x03 date:0x07];
	NSLog(@"MORIMORI I2C %x %x", 2, [self saa7111Read:0x02]);
    switch (res) 
    {
        case ResolutionCIF:
            if (rate > 18) 
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
        *rate = 5;
    
	return ResolutionCIF;
}

//
// Returns the pipe used for grabbing
//
- (UInt8) getGrabbingPipe
{
    return 1;
}

//
// Put in the alt-interface with the highest bandwidth (instead of 8)
// This attempts to provide the highest bandwidth
//
- (BOOL) setGrabInterfacePipe
{
    return [self usbSetAltInterfaceTo:8 testPipe:[self getGrabbingPipe]];
}

//
// This is an example that will have to be tailored to the specific camera or chip
// Scan the frame and return the results
//
IsocFrameResult  USBVisionIsocFrameScanner(IOUSBIsocFrame * frame, UInt8 * buffer, 
                                         UInt32 * dataStart, UInt32 * dataLength, 
                                         UInt32 * tailStart, UInt32 * tailLength, 
                                         GenericFrameInfo * frameInfo)
{
    int position, frameLength = frame->frActCount;
	NSLog(@"ST");
    
    *dataStart = 0;
    *dataLength = frameLength;
    
    *tailStart = frameLength;
    *tailLength = 0;
    
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
    grabContext.isocFrameScanner = USBVisionIsocFrameScanner;
    grabContext.isocDataCopier = genericIsocDataCopier;
}

//
// This is the key method that starts up the stream
//
- (BOOL) startupGrabStream 
{
    CameraError error = CameraErrorOK;
	
	NSLog(@"MORIMORI start");

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

//
// This is the method that takes the raw chunk data and turns it into an image
//
- (BOOL) decodeBuffer: (GenericChunkBuffer *) buffer
{
    BOOL ok = YES;
	short rawWidth  = [self width];
	short rawHeight = [self height];
    
	// Decode the bytes
    
//  Much decoding to be done here
    
    // Turn the Bayer data into an RGB image
    
    [bayerConverter setSourceFormat:3]; // This is probably different
    [bayerConverter setSourceWidth:rawWidth height:rawHeight];
    [bayerConverter setDestinationWidth:rawWidth height:rawHeight];
    [bayerConverter convertFromSrc:decodingBuffer
                            toDest:nextImageBuffer
                       srcRowBytes:rawWidth
                       dstRowBytes:nextImageBufferRowBytes
                            dstBPP:nextImageBufferBPP
                              flip:hFlip
                         rotate180:rotate]; // This might be different too
    
    return ok;
}


@end
