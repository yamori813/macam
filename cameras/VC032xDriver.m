//
//  VC032xDriver.m
//
//  macam - webcam app and QuickTime driver component
//  VC032xDriver - driver for VC032x controllers
//
//  Created by HXR on 2/23/07.
//  Copyright (C) 2007 HXR (hxr@users.sourceforge.net). 
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


#import "VC032xDriver.h"

#include "MiscTools.h"
#include "USB_VendorProductIDs.h"


@implementation VC0321Driver

+ (NSArray *) cameraUsbDescriptions 
{
    return [NSArray arrayWithObjects:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_ORBICAM_A], @"idProduct",  // SENSOR_OV7660
            [NSNumber numberWithUnsignedShort:VENDOR_LOGITECH], @"idVendor",
            @"Logitech Orbicam [A]", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_ORBICAM_B], @"idProduct",  // SENSOR_OV7660
            [NSNumber numberWithUnsignedShort:VENDOR_LOGITECH], @"idVendor",
            @"Logitech Orbicam [B]", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_VIMICRO_GENERIC_321], @"idProduct",  // SENSOR_OV7660
            [NSNumber numberWithUnsignedShort:VENDOR_Z_STAR_MICRO], @"idVendor",
            @"Vimicro Generic VC0321", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:0x0328], @"idProduct",  // SENSOR_MI1320
            [NSNumber numberWithUnsignedShort:VENDOR_Z_STAR_MICRO], @"idVendor",  // variant needed?
            @"A4Tech PK-130MG", @"name", NULL], 
        
        //  "Sony Visual Communication VGP-VCC1"

        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_SONY_C001], @"idProduct",  // SENSOR_OV7660
            [NSNumber numberWithUnsignedShort:VENDOR_Z_STAR_MICRO], @"idVendor",
            @"Sony Embedded Notebook Webcam (C001)", @"name", NULL], 
        
        //  "Motion Eye Webcamera in Sony Vaio FE11M"
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_SONY_C002], @"idProduct",  // SENSOR_OV7660
            [NSNumber numberWithUnsignedShort:VENDOR_Z_STAR_MICRO], @"idVendor",
            @"Sony Embedded Notebook Webcam (C002)", @"name", NULL], 
        
        NULL];
}


#undef CLAMP

#include "vc032x.h"


//
// Initialize the driver
//
- (id) initWithCentral: (id) c 
{
	self = [super initWithCentral:c];
	if (self == NULL) 
        return NULL;
    
    // Don't know if these work yet
    
//  hardwareBrightness = YES;
//  hardwareContrast = YES;
    
    cameraOperation = &fvc0321;
    
    decodingSkipBytes = 46;
    
//    +#define V4L2_PIX_FMT_YVYU    v4l2_fourcc('Y', 'V', 'Y', 'U') /* 16  YVU 4:2:2     */

    spca50x->cameratype = YUY2;
    spca50x->bridge = BRIDGE_VC0321;
    spca50x->sensor = SENSOR_OV7660;
    
    compressionType = gspcaCompression;
    
	return self;
}

//
// Scan the frame and return the results
//
IsocFrameResult  vc032xIsocFrameScanner(IOUSBIsocFrame * frame, UInt8 * buffer, 
                                          UInt32 * dataStart, UInt32 * dataLength, 
                                          UInt32 * tailStart, UInt32 * tailLength, 
                                          GenericFrameInfo * frameInfo)
{
    int frameLength = frame->frActCount;
    
    *dataStart = 0;
    *dataLength = frameLength;
    
    *tailStart = frameLength;
    *tailLength = 0;
    
    
    if (frameLength < 2) 
    {
        *dataLength = 0;
        
#if REALLY_VERBOSE
        printf("Invalid packet.\n");
#endif
        return invalidFrame;
    }
    
#if REALLY_VERBOSE
    printf("buffer[0] = 0x%02x (length = %d) 0x%02x ... [129] = 0x%02x ... 0x%02x 0x%02x 0x%02x 0x%02x\n", 
            buffer[0], frameLength, buffer[1], buffer[129], buffer[frameLength-4], buffer[frameLength-3], buffer[frameLength-2], buffer[frameLength-1]);
#endif
    
    if (buffer[0] == 0xff && buffer[1] == 0xd8) // start a new image
    {
#if REALLY_VERBOSE
        printf("New image start!\n");
#endif
        return newChunkFrame;
    }
    
    return validFrame;
}


- (void) setIsocFrameFunctions
{
    grabContext.isocFrameScanner = vc032xIsocFrameScanner;
    grabContext.isocDataCopier = genericIsocDataCopier;
}


- (UInt8) getGrabbingPipe
{
    return 2;
}

@end



@implementation VC0323Driver : VC0321Driver 

+ (NSArray *) cameraUsbDescriptions 
{
    return [NSArray arrayWithObjects:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_VIMICRO_GENERIC_323], @"idProduct",  // SENSOR_OV7670
            [NSNumber numberWithUnsignedShort:VENDOR_Z_STAR_MICRO], @"idVendor",
            @"Vimicro Generic VC0323", @"name", NULL], 
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithUnsignedShort:PRODUCT_LENOVO_USB_WEBCAM], @"idProduct",  // SENSOR_MI1310_SOC
            [NSNumber numberWithUnsignedShort:VENDOR_LENOVO], @"idVendor",
            @"Lenovo USB Webcam (40Y8519)", @"name", NULL], 
        
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
    
    cameraOperation = &fvc0321;
    
    decodingSkipBytes = 0;
    
    spca50x->cameratype = JPGV;
    spca50x->bridge = BRIDGE_VC0323;
    spca50x->sensor = SENSOR_OV7670;  // Sensor detection may override this
    
    compressionType = gspcaCompression;
    
	return self;
}

@end
