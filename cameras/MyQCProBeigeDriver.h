/*
 macam - webcam app and QuickTime driver component
 MyQCProBeigeDriver.h - Driver class for the Logitech QuickCam Pro (beige focus ring)
 This might be also useful for other cameras using the USS-720 bridge (e.g. the QuickCam VC)
 
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
 $Id: MyQCProBeigeDriver.h,v 1.5 2008/04/10 05:40:58 hxr Exp $
 */

#import <Cocoa/Cocoa.h>
#import "MyCameraDriver.h"
#import "BayerConverter.h"


@interface MyQCProBeigeDriver : MyCameraDriver {
    NSMutableArray* emptyChunks;	//Array of empty raw chunks (NSMutableData objects)
    NSMutableArray* fullChunks;		//Array of filled raw chunks (NSMutableData objects) - fifo queue: idx 0 = oldest
    NSLock* emptyChunkLock;		//Lock to access the empty chunk array
    NSLock* fullChunkLock;		//Lock to access the full chunk array
    long grabWidth;			//The real width the camera is sending (usually there's a border for interpolation)
    long grabHeight;			//The real height the camera is sending (usually there's a border for interpolation)
    unsigned long grabBufferSize;	//The number of bytes the cam will send in the bulk pipe for each chunk
    BayerConverter* bayerConverter;	//Our decoder for Bayer Matrix sensors
    CameraError grabbingError;		//The error code passed back from grabbingThread
    NSMutableData* fillingChunk;	//The Chunk currently filling up
    NSMutableData* collectingChunk;	//The Chunk collecting the depacketized data (in compressed mode)
    long collectingChunkBytes;		//The amount of valid, collected data currently in collectingChunk
    long videoBulkReadsPending;		//The number of USB bulk reads we still expect a read from - to see when we can stop grabbingThread
    BOOL grabbingThreadRunning;		//For active wait until grabbingThread has finished
    NSMutableData* decompressionBuffer;	//Buffer to hold the bit-decompressed image

    float lastGain;			//The last gain setting sent to the sensor
    float lastShutter;			//The last exposure setting sent to the sensor
    float aeGain;			//The computed auto gain value  
    float aeShutter;			//The computed auto exposure value
    
    BOOL rotate;            // "NO" for QCProBeige, "YES" for QCVC
}

#define QCPROBEIGE_NUM_CHUNKS 3

+ (unsigned short) cameraUsbProductID;
+ (unsigned short) cameraUsbVendorID;
+ (NSString*) cameraName;

- (id) initWithCentral:(id)c;
- (CameraError) startupWithUsbLocationId:(UInt32)usbLocationId;
- (void) dealloc;

- (BOOL) supportsResolution:(CameraResolution)res fps:(short)rate;
- (CameraResolution) defaultResolutionAndRate:(short*)rate;

- (BOOL) canSetSharpness;
- (void) setSharpness:(float)v;
- (BOOL) canSetBrightness;
- (void) setBrightness:(float)v;
- (BOOL) canSetContrast;
- (void) setContrast:(float)v;
- (BOOL) canSetSaturation;
- (void) setSaturation:(float)v;
- (BOOL) canSetGamma;
- (void) setGamma:(float)v;
- (BOOL) canSetWhiteBalanceMode;
- (BOOL) canSetWhiteBalanceModeTo:(WhiteBalanceMode)newMode;
- (void) setWhiteBalanceMode:(WhiteBalanceMode)newMode;
- (BOOL) canSetGain;
- (void) setGain:(float)val;
- (BOOL) canSetShutter;
- (void) setShutter:(float)val;
- (BOOL) canSetAutoGain;
- (void) setAutoGain:(BOOL)v;
- (BOOL) canSetHFlip;
- (short) maxCompression;

//Grabbing
- (CameraError) startupGrabbing;
- (void) shutdownGrabbing;
- (void) handleFullChunkWithReadBytes:(UInt32)readSize error:(IOReturn)err;
- (void) fillNextChunk;
- (void) grabbingThread:(id)data;
- (CameraError) decodingThread;

@end


@interface MyQCVCDriver : MyQCProBeigeDriver 
{
    CyYeGMgConverter * CYGM;
}

+ (NSArray*) cameraUsbDescriptions;

- (CameraError) startupWithUsbLocationId:(UInt32) usbLocationId;

@end

