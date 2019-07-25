//
//  SPCA561ADriver.h
//
//  macam - webcam app and QuickTime driver component
//  SPCA561ADriver - driver for the Sunplus SPCA561A chip
//
//  Created by hxr on 1/19/06.
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


#import "SPCA5XXDriver.h"


@interface SPCA561ADriver : SPCA5XXDriver

+ (NSArray *) cameraUsbDescriptions;

- (id) initWithCentral: (id) c;
- (void) startupCamera;
- (void) setIsocFrameFunctions;
- (void) decodeBuffer:(GenericChunkBuffer *)buffer;

@end
