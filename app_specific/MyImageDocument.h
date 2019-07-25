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
 $Id: MyImageDocument.h,v 1.3 2002/11/12 15:55:34 mattik Exp $
 */

#import <Cocoa/Cocoa.h>
#import "MyScrollView.h"

@interface MyImageDocument : NSDocument
{
    NSBitmapImageRep* imageRep;
    BOOL started;
    NSBitmapImageRep* deferredOpenImageRep;
    float quality;		//Only used for JPEG
}
- (void) dealloc;
- (void)makeWindowControllers;
- (void)windowControllerDidLoadNib:(NSWindowController *) aController;
- (NSData *)dataRepresentationOfType:(NSString *)aType;
- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType;
- (void) setImageRep:(NSBitmapImageRep*) newRep;
- (NSBitmapImageRep*) imageRep;
- (void) rotateCW:(id)sender;
- (void) rotateCCW:(id)sender;
- (float) quality;
- (void) setQuality:(float)quality;
@end
