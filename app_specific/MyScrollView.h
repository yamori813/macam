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
 $Id: MyScrollView.h,v 1.2 2002/05/22 05:40:58 dirkx Exp $
 */

/* MyScrollView - just a subclass of NSScrollView that adds a zoom field and handles an BitmapImageRep */

#import <Cocoa/Cocoa.h>

@interface MyScrollView : NSScrollView
{
    float zoomFactor;
    NSImageView* imageView;
    NSBitmapImageRep* imageRep;
    id zoomField;
    NSSize imageSize;
}


- (void) awakeFromNib;
- (void) dealloc;

- (void) zoomChanged:(id) sender;
- (void) tile;
- (float) zoomFactor;
- (void) setZoomFactor:(float)zoom;
- (BOOL) setImageRep:(NSBitmapImageRep*)newRep;
- (BOOL) updateSize;
- (void)resizeSubviewsWithOldSize:(NSSize)oldSize;

@end
