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
 $Id: MyCameraInspector.m,v 1.3 2002/10/24 18:20:30 mattik Exp $
 */

#import "MyCameraInspector.h"
#import "MyCameraDriver.h"
#import "MyCameraCentral.h"


@implementation MyCameraInspector

- (id) initWithCamera:(MyCameraDriver*)c {
    self=[super init];
    if (!self) return NULL;
    camera=c;
    if (![NSBundle loadNibNamed:@"DefaultCameraInspector" owner:self]) return NULL;
    [camName setStringValue:[[camera central] nameForDriver:c]];
    return self;
}

- (void) dealloc {
    [contentView removeFromSuperview];
    [contentView release];
    [super dealloc];
}

- (NSView*) contentView {
    return contentView;
}

@end
