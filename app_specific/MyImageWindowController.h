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
 $Id: MyImageWindowController.h,v 1.2 2002/05/22 05:40:58 dirkx Exp $
 */


#import <AppKit/AppKit.h>


@interface MyImageWindowController : NSWindowController {

}

//startup
- (void) windowDidLoad;

//Connection from the document
- (void) documentChanged:(NSNotification*)notification;

//Delegate from window
- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame;

//Zoom stuff
- (void) resizeWindowToContent;
- (void) magnify50:(id)sender;
- (void) magnify100:(id)sender;
- (void) magnify200:(id)sender;
- (void) magnifyLarger:(id)sender;
- (void) magnifySmaller:(id)sender;

//Toolbar specific stuff
- (void) setupToolbar;
- (NSToolbarItem*) toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*) itemIdent willBeInsertedIntoToolbar:(BOOL)willBeInserted;
- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
- (BOOL) validateToolbarItem: (NSToolbarItem *) toolbarItem;
    
@end
