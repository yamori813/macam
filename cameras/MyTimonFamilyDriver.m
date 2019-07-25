/*
 macam - webcam app and QuickTime driver component
 Copyright (C) 2002 Matthias Krauss (macam@matthias-krauss.de)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 $Id: MyTimonFamilyDriver.m,v 1.4 2005/08/16 21:27:59 hxr Exp $
 */

#import "MyTimonFamilyDriver.h"

#include "USB_VendorProductIDs.h"


typedef struct _VestaFormatEntry {
    CameraResolution res;
    short frameRate;
    short usbFrameBytes;
    short altInterface;
    unsigned char camInit[13];
} VestaFormatEntry;



static VestaFormatEntry formats[]={
    {ResolutionSQSIF, 5,140,1,{0x05, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x8C, 0xFC, 0x80, 0x02}},
    {ResolutionSQSIF,10,280,2,{0x04, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x18, 0xA9, 0x80, 0x02}},
    {ResolutionSQSIF,15,410,3,{0x03, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x9A, 0x71, 0x80, 0x02}},
    {ResolutionSQSIF,20,559,4,{0x02, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x2F, 0x56, 0x80, 0x02}},
    {ResolutionSQSIF,25,659,5,{0x01, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x93, 0x46, 0x80, 0x02}},
    {ResolutionSQSIF,30,838,7,{0x00, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x13, 0x00, 0x46, 0x3B, 0x80, 0x02}},
    {ResolutionQSIF , 5,146,1,{0x2D, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x92, 0xFC, 0xC0, 0x02}},
    {ResolutionQSIF ,10,291,2,{0x2C, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x23, 0xA1, 0xC0, 0x02}},
    {ResolutionQSIF ,15,437,3,{0x2B, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xB5, 0x6D, 0xC0, 0x02}},
    {ResolutionQSIF ,20,588,4,{0x2A, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x4C, 0x52, 0xC0, 0x02}},
    {ResolutionQSIF ,25,703,5,{0x29, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0xBF, 0x42, 0xC0, 0x02}},
    {ResolutionQSIF ,30,873,8,{0x28, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x69, 0x37, 0xC0, 0x02}},
    {ResolutionQCIF , 5,193,1,{0x0D, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0xC1, 0xF4, 0xC0, 0x02}},
    {ResolutionQCIF ,10,385,3,{0x0C, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x81, 0x79, 0xC0, 0x02}},
    {ResolutionQCIF ,15,577,4,{0x0B, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x41, 0x52, 0xC0, 0x02}},
    {ResolutionQCIF ,20,776,6,{0x0A, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0x08, 0x3F, 0xC0, 0x02}},
    {ResolutionQCIF ,25,928,8,{0x09, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x12, 0x00, 0xA0, 0x33, 0xC0, 0x02}},
    {ResolutionSIF  , 5,582,4,{0x35, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x04, 0x00, 0x46, 0x52, 0x60, 0x02}},
    {ResolutionCIF  , 5,771,6,{0x15, 0xF4, 0x04, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x03, 0x3F, 0x80, 0x02}}
 };

static long numFormats=19;

@implementation MyTimonFamilyDriver

+ (NSArray*) cameraUsbDescriptions 
{
    NSDictionary* dict1=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedShort:PRODUCT_VESTA],@"idProduct",
        [NSNumber numberWithUnsignedShort:VENDOR_PHILIPS],@"idVendor",
        @"Philips Vesta",@"name",NULL];
    
    NSDictionary* dict2=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedShort:PRODUCT_VESTA_PRO],@"idProduct",
        [NSNumber numberWithUnsignedShort:VENDOR_PHILIPS],@"idVendor",
        @"Philips Vesta Pro",@"name",NULL];
    
    NSDictionary* dict3=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedShort:PRODUCT_VESTA_SCAN],@"idProduct",
        [NSNumber numberWithUnsignedShort:VENDOR_PHILIPS],@"idVendor",
        @"Philips Vesta Scan",@"name",NULL];
    
    NSDictionary* dict4=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedShort:PRODUCT_MPC_C10],@"idProduct",
        [NSNumber numberWithUnsignedShort:VENDOR_SAMSUNG],@"idVendor",
        @"Samsung MPC-C10",@"name",NULL];
    
    NSDictionary* dict5=[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedShort:PRODUCT_MPC_C30],@"idProduct",
        [NSNumber numberWithUnsignedShort:VENDOR_SAMSUNG],@"idVendor",
        @"Samsung MPC-C30",@"name",NULL];
    
    return [NSArray arrayWithObjects:dict1,dict2,dict3,dict4,dict5,NULL];
}

- (CameraError) startupWithUsbLocationId:(UInt32)usbLocationId {
    return [super startupWithUsbLocationId:usbLocationId];
}

- (BOOL) canSetSaturation {	//Override for specific behaviour: Vesta cannot set saturation (or at least, I don't know about it)
    return NO;
}

- (BOOL) supportsResolution:(CameraResolution)r fps:(short)fr {	//Returns if this combination is supported
    short i=0;
    BOOL found=NO;
    while ((i<numFormats)&&(!found)) {
        if ((formats[i].res==r)&&(formats[i].frameRate==fr)) found=YES;
        else i++;
    }
    return found;
}

- (void) setResolution:(CameraResolution)r fps:(short)fr {	//Set a resolution and frame rate.
    short i=0;
    BOOL found=NO;
    [super setResolution:r fps:fr];	//Update resoplution and fps if state and format is ok
    while ((i<numFormats)&&(!found)) {
        if ((formats[i].res==resolution)&&(formats[i].frameRate==fps)) found=YES;
        else i++;
    }
    if (!found) {
#ifdef VERBOSE
        NSLog(@"MyTimonFamilyDriver:setResolution: format not found");
#endif
    }
    [stateLock lock];
    if (!isGrabbing) {
        [self usbWriteCmdWithBRequest:GRP_SET_STREAM wValue:SEL_FORMAT wIndex:INTF_VIDEO buf:formats[i].camInit len:13];
        usbFrameBytes=formats[i].usbFrameBytes;
        usbAltInterface=formats[i].altInterface;
    }
    [stateLock unlock];
    }

- (CameraResolution) defaultResolutionAndRate:(short*)dFps {
    if (dFps) *dFps=5;
    return ResolutionCIF;
}

@end
