/*
 MyQCExpressBDriver.h - macam camera driver class for QuickCam Express (STV602)

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
 $Id: MyQCExpressBDriver.h,v 1.3 2003/02/24 13:05:09 mattik Exp $
*/

#import <Cocoa/Cocoa.h>
#import "GlobalDefs.h"
#import "MyQCExpressADriver.h"

//The second revision of the QuickCam Express doesn't use a STV600, but a STV602AA bridge chip. Fortunately, this chip has an emulation mode of the STV600. Additionally, this model may have a snapshot button that will be handled. */

@interface MyQCExpressBDriver : MyQCExpressADriver {
    BOOL buttonThreadShouldBeRunning;
    BOOL buttonThreadRunning;
    NSConnection* mainToButtonThreadConnection;
    NSConnection* buttonToMainThreadConnection;
}

+ (unsigned short) cameraUsbProductID;
+ (unsigned short) cameraUsbVendorID;
+ (NSString*) cameraName;

- (CameraError) startupWithUsbLocationId:(UInt32)usbLocationId;
- (void) shutdown;

- (void) buttonThread:(id)data;
- (void) mergeCameraEventHappened:(CameraEvent)evt;


@end
