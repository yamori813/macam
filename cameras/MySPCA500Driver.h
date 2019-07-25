/*
 macam - webcam app and QuickTime driver component
 MySPCA500ADriver - Driver for Sunplus SPCA500A-based cameras
 
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
 $Id: MySPCA500Driver.h,v 1.8 2008/04/10 05:40:58 hxr Exp $
 */

#import <Cocoa/Cocoa.h>
#import "MyCameraDriver.h"
#import "JFIFHeaderTemplate.h"

#define SPCA500_NUM_TRANSFERS 10
#define SPCA500_FRAMES_PER_TRANSFER 50
#define SPCA500_NUM_CHUNK_BUFFERS 5

typedef struct SPCA500TransferContext {	//Everything a usb completion callback need to know
    IOUSBIsocFrame frameList[SPCA500_FRAMES_PER_TRANSFER];	//The results of the usb frames I received
    UInt8* buffer;		//This is the place the transfer goes to
} SPCA500TransferContext;

typedef struct SPCA500ChunkBuffer {
    unsigned char* buffer;		//The data
    long numBytes;			//The amount of valid data filled in
} SPCA500ChunkBuffer;

typedef struct SPCA500GrabContext {
    UInt64 initiatedUntil;		//next usb frame number to initiate a transfer for
    short bytesPerFrame;		//So many bytes are at max transferred per usb frame
    short finishedTransfers;		//So many transfers have already finished (for cleanup)
    SPCA500TransferContext transferContexts[SPCA500_NUM_TRANSFERS];	//The transfer contexts
    IOUSBInterfaceInterface** intf;	//Just a copy from our interface interface so the callback can issue usb
    BOOL* shouldBeGrabbing;		//Ref to the global indicator if the grab should go on
    CameraError err;			//Return value for common errors during grab
    long framesSinceLastChunk;		//Watchdog counter to detect invalid isoc data stream
    long chunkBufferLength;		//The size of the chunk buffers
    short numEmptyBuffers;		//The number of empty (ready-to-fill) buffers in the array below
    SPCA500ChunkBuffer emptyChunkBuffers[SPCA500_NUM_CHUNK_BUFFERS];	//The pool of empty (ready-to-fill) chunk buffers
    short numFullBuffers;		//The number of full (ready-to-decode) buffers in the array below
    SPCA500ChunkBuffer fullChunkBuffers[SPCA500_NUM_CHUNK_BUFFERS];	//The queue of full (ready-to-decode) chunk buffers (oldest=last)
    bool fillingChunk;			//If we're currently filling a buffer
    SPCA500ChunkBuffer fillingChunkBuffer;	//The chunk buffer currently filling up (if fillingChunk==true)
    NSLock* chunkListLock;		//The lock for access to the empty buffer pool/ full chunk queue
    BOOL compressed;			//If YES, it's JPEG, otherwise YUV420
} SPCA500GrabContext;


@interface MySPCA500Driver : MyCameraDriver {
    IOUSBInterfaceInterface** dscIntf;
    SPCA500GrabContext grabContext;
    BOOL grabbingThreadRunning;
    ImageDescriptionHandle pccamImgDesc;		//Image Description for JFIF decompress (PC Cam video)

    NSMutableArray* storedFileInfo;
    
    BOOL horizontallyFlipped;
}

//Get info about the camera specifics
+ (NSArray*) cameraUsbDescriptions;

- (CameraError) startupWithUsbLocationId:(UInt32)usbLocationId;
- (void) shutdown;

- (BOOL) supportsResolution:(CameraResolution)r fps:(short)fr;
- (void) setResolution:(CameraResolution)r fps:(short)fr;
- (CameraResolution) defaultResolutionAndRate:(short*)dFps;
- (short) maxCompression;
- (void) setCompression:(short)v;
- (BOOL) canSetBrightness;
- (void) setBrightness:(float)v;
- (BOOL) canSetContrast;
- (void) setContrast:(float)v;
- (BOOL) canSetSaturation;
- (void) setSaturation:(float)v;

- (CameraError) decodingThread;

- (BOOL) canStoreMedia;
- (long) numberOfStoredMediaObjects;
- (NSDictionary*) getStoredMediaObject:(long)idx;

@end


@interface MyAiptekPocketDV : MySPCA500Driver {}

+ (NSArray*) cameraUsbDescriptions;

@end
