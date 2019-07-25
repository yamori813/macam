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
 $Id: MyCameraInspector.h,v 1.2 2002/05/22 05:40:58 dirkx Exp $
 */

#import <Cocoa/Cocoa.h>

@class MyCameraDriver;

@interface MyCameraInspector : NSObject {
    MyCameraDriver* camera;
    IBOutlet NSView* contentView;
    IBOutlet NSTextField* camName;
}

- (id) initWithCamera:(MyCameraDriver*)c;
- (void) dealloc;
- (NSView*) contentView;

@end
