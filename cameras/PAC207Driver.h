//
//  PAC207Driver.h
//
//  macam - webcam app and QuickTime driver component
//  PAC207Driver - driver for the Pixart PAC207 chip
//
//  Created by HXR on 3/24/06.
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
#import <Histogram.h>


@class RGBScaler;

@interface PAC207Driver : GenericDriver 
{
    UInt8 * decodingBuffer;  // Need an intermediate buffer for decompression
	struct code_table codeTable[256];
    
    CameraResolution rawResolution;
    RGBScaler * scaler;
    UInt8 * rgbBuffer;
}

+ (NSArray *) cameraUsbDescriptions;

- (id) initWithCentral: (id) c;
- (BOOL) supportsResolution: (CameraResolution) res fps: (short) rate;
- (UInt8) getGrabbingPipe;
- (BOOL) setGrabInterfacePipe;
- (void) setIsocFrameFunctions;

- (BOOL) initializeCamera;

@end


@interface PAC207DriverRotated : PAC207Driver 

+ (NSArray *) cameraUsbDescriptions;

- (id) initWithCentral: (id) c;

@end

