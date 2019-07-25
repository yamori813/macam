
/****************************************************************************
#	 	Connexant Cx11646    library                                #
# 		Copyright (C) 2004 Michel Xhaard   mxhaard@magic.fr         #
#                                                                           #
# This program is free software; you can redistribute it and/or modify      #
# it under the terms of the GNU General Public License as published by      #
# the Free Software Foundation; either version 2 of the License, or         #
# (at your option) any later version.                                       #
#                                                                           #
# This program is distributed in the hope that it will be useful,           #
# but WITHOUT ANY WARRANTY; without even the implied warranty of            #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             #
# GNU General Public License for more details.                              #
#                                                                           #
# You should have received a copy of the GNU General Public License         #
# along with this program; if not, write to the Free Software               #
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA #
#                                                                           #
****************************************************************************/
static __u8 cx_sensor_init[][4] = {
    {0x88, 0x11, 0x01, 0x01},
    {0x88, 0x12, 0x70, 0x01},
    {0x88, 0x0f, 0x00, 0x01},
    {0x88, 0x05, 0x01, 0x01},
    {0, 0, 0, 0}
};
static void cx11646_init1(struct usb_spca50x *spca50x)
{
    __u8 val = 0;
    int i = 0;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0053, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0052, &val, 1);
    val = 0x2f;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x009b, &val, 1);
    val = 0x10;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x009c, &val, 1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0098, &val, 1);
    val = 0x40;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0098, &val, 1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0099, &val, 1);
    val = 0x07;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0099, &val, 1);
    val = 0x40;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0039, &val, 1);
    val = 0xff;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x003c, &val, 1);
    val = 0x1f;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x003f, &val, 1);
    val = 0x40;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x003d, &val, 1);
//val= 0x60;
//spca5xxRegWrite(spca50x->dev,0x00,0x00,0x003d,&val,1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0099, &val, 1);	//->0x07

    while (cx_sensor_init[i][0]) {
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5,
			cx_sensor_init[i], 1);
	spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// -> 0x00
	if (i == 1) {
	    val = 1;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00ed, &val, 1);
	    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00ed, &val, 1);	//-> 0x01
	}
	i++;
    }
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c3, &val, 1);
}
static __u8 cx11646_fw1[][3] = {
    {0x00, 0x02, 0x00},
    {0x01, 0x43, 0x00},
    {0x02, 0xA7, 0x00},
    {0x03, 0x8B, 0x01},
    {0x04, 0xE9, 0x02},
    {0x05, 0x08, 0x04},
    {0x06, 0x08, 0x05},
    {0x07, 0x07, 0x06},
    {0x08, 0xE7, 0x06},
    {0x09, 0xC6, 0x07},
    {0x0A, 0x86, 0x08},
    {0x0B, 0x46, 0x09},
    {0x0C, 0x05, 0x0A},
    {0x0D, 0xA5, 0x0A},
    {0x0E, 0x45, 0x0B},
    {0x0F, 0xE5, 0x0B},
    {0x10, 0x85, 0x0C},
    {0x11, 0x25, 0x0D},
    {0x12, 0xC4, 0x0D},
    {0x13, 0x45, 0x0E},
    {0x14, 0xE4, 0x0E},
    {0x15, 0x64, 0x0F},
    {0x16, 0xE4, 0x0F},
    {0x17, 0x64, 0x10},
    {0x18, 0xE4, 0x10},
    {0x19, 0x64, 0x11},
    {0x1A, 0xE4, 0x11},
    {0x1B, 0x64, 0x12},
    {0x1C, 0xE3, 0x12},
    {0x1D, 0x44, 0x13},
    {0x1E, 0xC3, 0x13},
    {0x1F, 0x24, 0x14},
    {0x20, 0xA3, 0x14},
    {0x21, 0x04, 0x15},
    {0x22, 0x83, 0x15},
    {0x23, 0xE3, 0x15},
    {0x24, 0x43, 0x16},
    {0x25, 0xA4, 0x16},
    {0x26, 0x23, 0x17},
    {0x27, 0x83, 0x17},
    {0x28, 0xE3, 0x17},
    {0x29, 0x43, 0x18},
    {0x2A, 0xA3, 0x18},
    {0x2B, 0x03, 0x19},
    {0x2C, 0x63, 0x19},
    {0x2D, 0xC3, 0x19},
    {0x2E, 0x22, 0x1A},
    {0x2F, 0x63, 0x1A},
    {0x30, 0xC3, 0x1A},
    {0x31, 0x23, 0x1B},
    {0x32, 0x83, 0x1B},
    {0x33, 0xE2, 0x1B},
    {0x34, 0x23, 0x1C},
    {0x35, 0x83, 0x1C},
    {0x36, 0xE2, 0x1C},
    {0x37, 0x23, 0x1D},
    {0x38, 0x83, 0x1D},
    {0x39, 0xE2, 0x1D},
    {0x3A, 0x23, 0x1E},
    {0x3B, 0x82, 0x1E},
    {0x3C, 0xC3, 0x1E},
    {0x3D, 0x22, 0x1F},
    {0x3E, 0x63, 0x1F},
    {0x3F, 0xC1, 0x1F},
    {0, 0, 0}
};
static void cx11646_fw(struct usb_spca50x *spca50x)
{
    __u8 val = 0;
    int i = 0;
    val = 0x02;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x006a, &val, 1);
    while (cx11646_fw1[i][1]) {
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x006b, cx11646_fw1[i],
			3);
	i++;
    }
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x006a, &val, 1);
}
static __u8 cxsensor[] = {
    0x88, 0x12, 0x70, 0x01,
    0x88, 0x0d, 0x02, 0x01,
    0x88, 0x0f, 0x00, 0x01,
    0x88, 0x03, 0x71, 0x01, 0x88, 0x04, 0x00, 0x01,	//3
    0x88, 0x02, 0x10, 0x01,
    0x88, 0x00, 0xD4, 0x01, 0x88, 0x01, 0x01, 0x01,	//5
    0x88, 0x0B, 0x00, 0x01,
    0x88, 0x0A, 0x0A, 0x01,
    0x88, 0x00, 0x08, 0x01, 0x88, 0x01, 0x00, 0x01,	//8
    0x88, 0x05, 0x01, 0x01,
    0xA1, 0x18, 0x00, 0x01,
    0x00
};
static __u8 reg20[] = { 0x10, 0x42, 0x81, 0x19, 0xd3, 0xff, 0xa7, 0xff };
static __u8 reg28[] = { 0x87, 0x00, 0x87, 0x00, 0x8f, 0xff, 0xea, 0xff };
static __u8 reg10[] = { 0xb1, 0xb1 };
static __u8 reg71a[] = { 0x08, 0x18, 0x0a, 0x1e };	// 640
static __u8 reg71b[] = { 0x04, 0x0c, 0x05, 0x0f };	// 352{0x04,0x0a,0x06,0x12}; //352{0x05,0x0e,0x06,0x11}; //352
static __u8 reg71c[] = { 0x02, 0x07, 0x03, 0x09 };	// 320{0x04,0x0c,0x05,0x0f}; //320
static __u8 reg71d[] = { 0x02, 0x07, 0x03, 0x09 };	// 176
static __u8 reg71e[] = { 0x02, 0x07, 0x03, 0x09 };	// 160
static __u8 reg7b[] = { 0x00, 0xff, 0x00, 0xff, 0x00, 0xff };

static void cx_sensor(struct usb_spca50x *spca50x)
{
    __u8 val = 0;
    int i = 0;
    __u8 bufread[] = { 0, 0, 0, 0, 0, 0, 0, 0 };
    int length = 0;
    __u8 *ptsensor = cxsensor;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0020, reg20, 8);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0028, reg28, 8);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 8);
    val = 0x03;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0092, &val, 1);
    PDEBUG(3, "spca50x->mode cx11646 %d", spca50x->mode);
    switch (spca50x->mode) {
    case 0:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71a, 4);
	break;
    case 1:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71b, 4);
	break;
    case 2:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71c, 4);
	break;
    case 3:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71d, 4);
	break;
    case 4:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71e, 4);
	break;
    default:
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0071, reg71c, 4);
	break;
    }
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x007b, reg7b, 6);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00f8, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 8);
    val = 0x41;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0098, &val, 1);
    for (i = 0; i < 11; i++) {
	if ((i == 3) || (i == 5) || (i == 8)) {
	    length = 8;
	} else {
	    length = 4;
	}
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, ptsensor,
			length);
	if (length == 4) {
	    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);
	} else {
	    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, bufread,
			   length);
	}
	ptsensor += length;
    }
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e7, bufread, 8);
}
static __u8 cx_inits_160[] = {
    0x81, 0x81, 0xa0, 0x00, 0x78, 0x00, 0x04, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x10, 0x00, 0x04, 0x01,
    0x65, 0x45, 0x13, 0x1a, 0x2c, 0xdf, 0xb9, 0x81,
    0x30, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    0xe2, 0xff, 0xf1, 0xff, 0xc2, 0xff, 0xbc, 0xff,
    0xf5, 0xff, 0x6b, 0xff, 0xf2, 0x01, 0x43, 0x02,
    0xe4, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static __u8 cx_inits_176[] = {
    0x33, 0x81, 0xB0, 0x00, 0x90, 0x00, 0x0A, 0x03,	//176x144
    0x00, 0x03, 0x03, 0x03, 0x1B, 0x05, 0x30, 0x03,
    0x65, 0x15, 0x18, 0x25, 0x03, 0x25, 0x08, 0x30,
    0x3B, 0x25, 0x10, 0x00, 0x04, 0x00, 0x00, 0x00,
    0xDC, 0xFF, 0xEE, 0xFF, 0xC5, 0xFF, 0xBF, 0xFF,
    0xF7, 0xFF, 0x88, 0xFF, 0x66, 0x02, 0x28, 0x02,
    0x1E, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static __u8 cx_inits_320[] = {
    0x7f, 0x7f, 0x40, 0x01, 0xf0, 0x00, 0x02, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x10, 0x00, 0x02, 0x01,
    0x65, 0x45, 0xfa, 0x4c, 0x2c, 0xdf, 0xb9, 0x81,
    0x30, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    0xe2, 0xff, 0xf1, 0xff, 0xc2, 0xff, 0xbc, 0xff,
    0xf5, 0xff, 0x6d, 0xff, 0xf6, 0x01, 0x43, 0x02,
    0xd3, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static __u8 cx_inits_352[] = {
    0x2e, 0x7c, 0x60, 0x01, 0x20, 0x01, 0x05, 0x03,
    0x00, 0x06, 0x03, 0x06, 0x1b, 0x10, 0x05, 0x3b,
    0x30, 0x25, 0x18, 0x25, 0x08, 0x30, 0x03, 0x25,
    0x3b, 0x30, 0x25, 0x1b, 0x10, 0x05, 0x00, 0x00,
    0xe3, 0xff, 0xf1, 0xff, 0xc2, 0xff, 0xbc, 0xff,
    0xf5, 0xff, 0x6b, 0xff, 0xee, 0x01, 0x43, 0x02,
    0xe4, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};
static __u8 cx_inits_640[] = {
    0x7e, 0x7e, 0x80, 0x02, 0xe0, 0x01, 0x01, 0x01,
    0x00, 0x02, 0x01, 0x02, 0x10, 0x30, 0x01, 0x01,
    0x65, 0x45, 0xf7, 0x52, 0x2c, 0xdf, 0xb9, 0x81,
    0x30, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    0xe2, 0xff, 0xf1, 0xff, 0xc2, 0xff, 0xbc, 0xff,
    0xf6, 0xff, 0x7b, 0xff, 0x01, 0x02, 0x43, 0x02,
    0x77, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
};

static int cx11646_initsize(struct usb_spca50x *spca50x)
{
    int i;
    __u8 reg12[] = { 0x08, 0x05, 0x07, 0x04, 0x24 };
    __u8 reg17[] = { 0x0a, 0x00, 0xf2, 0x01, 0x0f, 0x00, 0x97, 0x02 };
    __u8 *cxinit;
    __u8 val = 0;
    switch (spca50x->mode) {
    case 0:
	cxinit = cx_inits_640;
	break;
    case 1:
	cxinit = cx_inits_352;
	break;
    case 2:
	cxinit = cx_inits_320;
	break;
    case 3:
	cxinit = cx_inits_176;
	break;
    case 4:
	cxinit = cx_inits_160;
	break;
    default:
	cxinit = cx_inits_320;
	break;
    }
    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x009a, &val, 1);
    val = 0x10;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0012, reg12, 5);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0017, reg17, 8);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c0, &val, 1);
    val = 0x04;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c1, &val, 1);
    val = 0x04;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c2, &val, 1);
    for (i = 0; i < 7; i++) {
	switch (i) {
	case 0:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0061, cxinit, 8);
	    break;
	case 1:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00ca, cxinit, 8);
	    break;
	case 2:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00d2, cxinit, 8);
	    break;
	case 3:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00da, cxinit, 6);
	    break;
	case 4:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0041, cxinit, 8);
	    break;
	case 5:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0049, cxinit, 8);
	    break;
	case 6:
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0051, cxinit, 2);
	    break;
	}
	if (i < 6)
	    cxinit += 8;	//surf trought the table
    }
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0010, &val, 1);
    return (int) val;
}

static __u8 cx_jpeg_init[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x15},	// 1
    {0x0F, 0x10, 0x12, 0x10, 0x0D, 0x15, 0x12, 0x11},
    {0x12, 0x18, 0x16, 0x15, 0x19, 0x20, 0x35, 0x22},
    {0x20, 0x1D, 0x1D, 0x20, 0x41, 0x2E, 0x31, 0x26},
    {0x35, 0x4D, 0x43, 0x51, 0x4F, 0x4B, 0x43, 0x4A},
    {0x49, 0x55, 0x5F, 0x79, 0x67, 0x55, 0x5A, 0x73},
    {0x5B, 0x49, 0x4A, 0x6A, 0x90, 0x6B, 0x73, 0x7D},
    {0x81, 0x88, 0x89, 0x88, 0x52, 0x66, 0x95, 0xA0},
    {0x94, 0x84, 0x9E, 0x79, 0x85, 0x88, 0x83, 0x01},
    {0x15, 0x0F, 0x10, 0x12, 0x10, 0x0D, 0x15, 0x12},
    {0x11, 0x12, 0x18, 0x16, 0x15, 0x19, 0x20, 0x35},
    {0x22, 0x20, 0x1D, 0x1D, 0x20, 0x41, 0x2E, 0x31},
    {0x26, 0x35, 0x4D, 0x43, 0x51, 0x4F, 0x4B, 0x43},
    {0x4A, 0x49, 0x55, 0x5F, 0x79, 0x67, 0x55, 0x5A},
    {0x73, 0x5B, 0x49, 0x4A, 0x6A, 0x90, 0x6B, 0x73},
    {0x7D, 0x81, 0x88, 0x89, 0x88, 0x52, 0x66, 0x95},
    {0xA0, 0x94, 0x84, 0x9E, 0x79, 0x85, 0x88, 0x83},
    {0xFF, 0xC4, 0x01, 0xA2, 0x00, 0x00, 0x01, 0x05},
    {0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02},
    {0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A},
    {0x0B, 0x01, 0x00, 0x03, 0x01, 0x01, 0x01, 0x01},
    {0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05},
    {0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x10, 0x00},
    {0x02, 0x01, 0x03, 0x03, 0x02, 0x04, 0x03, 0x05},
    {0x05, 0x04, 0x04, 0x00, 0x00, 0x01, 0x7D, 0x01},
    {0x02, 0x03, 0x00, 0x04, 0x11, 0x05, 0x12, 0x21},
    {0x31, 0x41, 0x06, 0x13, 0x51, 0x61, 0x07, 0x22},
    {0x71, 0x14, 0x32, 0x81, 0x91, 0xA1, 0x08, 0x23},
    {0x42, 0xB1, 0xC1, 0x15, 0x52, 0xD1, 0xF0, 0x24},
    {0x33, 0x62, 0x72, 0x82, 0x09, 0x0A, 0x16, 0x17},
    {0x18, 0x19, 0x1A, 0x25, 0x26, 0x27, 0x28, 0x29},
    {0x2A, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A},
    {0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4A},
    {0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5A},
    {0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A},
    {0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A},
    {0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A},
    {0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99},
    {0x9A, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8},
    {0xA9, 0xAA, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7},
    {0xB8, 0xB9, 0xBA, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6},
    {0xC7, 0xC8, 0xC9, 0xCA, 0xD2, 0xD3, 0xD4, 0xD5},
    {0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xE1, 0xE2, 0xE3},
    {0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xF1},
    {0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9},
    {0xFA, 0x11, 0x00, 0x02, 0x01, 0x02, 0x04, 0x04},
    {0x03, 0x04, 0x07, 0x05, 0x04, 0x04, 0x00, 0x01},
    {0x02, 0x77, 0x00, 0x01, 0x02, 0x03, 0x11, 0x04},
    {0x05, 0x21, 0x31, 0x06, 0x12, 0x41, 0x51, 0x07},
    {0x61, 0x71, 0x13, 0x22, 0x32, 0x81, 0x08, 0x14},
    {0x42, 0x91, 0xA1, 0xB1, 0xC1, 0x09, 0x23, 0x33},
    {0x52, 0xF0, 0x15, 0x62, 0x72, 0xD1, 0x0A, 0x16},
    {0x24, 0x34, 0xE1, 0x25, 0xF1, 0x17, 0x18, 0x19},
    {0x1A, 0x26, 0x27, 0x28, 0x29, 0x2A, 0x35, 0x36},
    {0x37, 0x38, 0x39, 0x3A, 0x43, 0x44, 0x45, 0x46},
    {0x47, 0x48, 0x49, 0x4A, 0x53, 0x54, 0x55, 0x56},
    {0x57, 0x58, 0x59, 0x5A, 0x63, 0x64, 0x65, 0x66},
    {0x67, 0x68, 0x69, 0x6A, 0x73, 0x74, 0x75, 0x76},
    {0x77, 0x78, 0x79, 0x7A, 0x82, 0x83, 0x84, 0x85},
    {0x86, 0x87, 0x88, 0x89, 0x8A, 0x92, 0x93, 0x94},
    {0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0xA2, 0xA3},
    {0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xB2},
    {0xB3, 0xB4, 0xB5, 0xB6, 0xB7, 0xB8, 0xB9, 0xBA},
    {0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9},
    {0xCA, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8},
    {0xD9, 0xDA, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7},
    {0xE8, 0xE9, 0xEA, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6},
    {0xF7, 0xF8, 0xF9, 0xFA, 0xFF, 0x20, 0x00, 0x1F},
    {0x02, 0x0C, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00},
    {0x00, 0x00, 0x11, 0x00, 0x11, 0x22, 0x00, 0x22},
    {0x22, 0x11, 0x22, 0x22, 0x11, 0x33, 0x33, 0x11},
    {0x44, 0x66, 0x22, 0x55, 0x66, 0xFF, 0xDD, 0x00},
    {0x04, 0x00, 0x14, 0xFF, 0xC0, 0x00, 0x11, 0x08},
    {0x00, 0xF0, 0x01, 0x40, 0x03, 0x00, 0x21, 0x00},
    {0x01, 0x11, 0x01, 0x02, 0x11, 0x01, 0xFF, 0xDA},
    {0x00, 0x0C, 0x03, 0x00, 0x00, 0x01, 0x11, 0x02},
    {0x11, 0x00, 0x3F, 0x00, 0xFF, 0xD9, 0x00, 0x00}	//79
};


static __u8 cxjpeg_640[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x10},	//1
    {0x0B, 0x0C, 0x0E, 0x0C, 0x0A, 0x10, 0x0E, 0x0D},
    {0x0E, 0x12, 0x11, 0x10, 0x13, 0x18, 0x28, 0x1A},
    {0x18, 0x16, 0x16, 0x18, 0x31, 0x23, 0x25, 0x1D},
    {0x28, 0x3A, 0x33, 0x3D, 0x3C, 0x39, 0x33, 0x38},
    {0x37, 0x40, 0x48, 0x5C, 0x4E, 0x40, 0x44, 0x57},
    {0x45, 0x37, 0x38, 0x50, 0x6D, 0x51, 0x57, 0x5F},
    {0x62, 0x67, 0x68, 0x67, 0x3E, 0x4D, 0x71, 0x79},
    {0x70, 0x64, 0x78, 0x5C, 0x65, 0x67, 0x63, 0x01},
    {0x10, 0x0B, 0x0C, 0x0E, 0x0C, 0x0A, 0x10, 0x0E},
    {0x0D, 0x0E, 0x12, 0x11, 0x10, 0x13, 0x18, 0x28},
    {0x1A, 0x18, 0x16, 0x16, 0x18, 0x31, 0x23, 0x25},
    {0x1D, 0x28, 0x3A, 0x33, 0x3D, 0x3C, 0x39, 0x33},
    {0x38, 0x37, 0x40, 0x48, 0x5C, 0x4E, 0x40, 0x44},
    {0x57, 0x45, 0x37, 0x38, 0x50, 0x6D, 0x51, 0x57},
    {0x5F, 0x62, 0x67, 0x68, 0x67, 0x3E, 0x4D, 0x71},
    {0x79, 0x70, 0x64, 0x78, 0x5C, 0x65, 0x67, 0x63},
    {0xFF, 0x20, 0x00, 0x1F, 0x00, 0x83, 0x00, 0x00},
    {0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00},
    {0x11, 0x22, 0x00, 0x22, 0x22, 0x11, 0x22, 0x22},
    {0x11, 0x33, 0x33, 0x11, 0x44, 0x66, 0x22, 0x55},
    {0x66, 0xFF, 0xDD, 0x00, 0x04, 0x00, 0x28, 0xFF},
    {0xC0, 0x00, 0x11, 0x08, 0x01, 0xE0, 0x02, 0x80},
    {0x03, 0x00, 0x21, 0x00, 0x01, 0x11, 0x01, 0x02},
    {0x11, 0x01, 0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x00},
    {0x00, 0x01, 0x11, 0x02, 0x11, 0x00, 0x3F, 0x00},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}	//27
};
static __u8 cxjpeg_352[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x0D},
    {0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B, 0x0A},
    {0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F, 0x14},
    {0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D, 0x17},
    {0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28, 0x2C},
    {0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35, 0x44},
    {0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44, 0x4A},
    {0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58, 0x5F},
    {0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D, 0x01},
    {0x0D, 0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B},
    {0x0A, 0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F},
    {0x14, 0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D},
    {0x17, 0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28},
    {0x2C, 0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35},
    {0x44, 0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44},
    {0x4A, 0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58},
    {0x5F, 0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D},
    {0xFF, 0x20, 0x00, 0x1F, 0x01, 0x83, 0x00, 0x00},
    {0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00},
    {0x11, 0x22, 0x00, 0x22, 0x22, 0x11, 0x22, 0x22},
    {0x11, 0x33, 0x33, 0x11, 0x44, 0x66, 0x22, 0x55},
    {0x66, 0xFF, 0xDD, 0x00, 0x04, 0x00, 0x16, 0xFF},
    {0xC0, 0x00, 0x11, 0x08, 0x01, 0x20, 0x01, 0x60},
    {0x03, 0x00, 0x21, 0x00, 0x01, 0x11, 0x01, 0x02},
    {0x11, 0x01, 0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x00},
    {0x00, 0x01, 0x11, 0x02, 0x11, 0x00, 0x3F, 0x00},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
};
static __u8 cxjpeg_320[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x05},
    {0x03, 0x04, 0x04, 0x04, 0x03, 0x05, 0x04, 0x04},
    {0x04, 0x05, 0x05, 0x05, 0x06, 0x07, 0x0C, 0x08},
    {0x07, 0x07, 0x07, 0x07, 0x0F, 0x0B, 0x0B, 0x09},
    {0x0C, 0x11, 0x0F, 0x12, 0x12, 0x11, 0x0F, 0x11},
    {0x11, 0x13, 0x16, 0x1C, 0x17, 0x13, 0x14, 0x1A},
    {0x15, 0x11, 0x11, 0x18, 0x21, 0x18, 0x1A, 0x1D},
    {0x1D, 0x1F, 0x1F, 0x1F, 0x13, 0x17, 0x22, 0x24},
    {0x22, 0x1E, 0x24, 0x1C, 0x1E, 0x1F, 0x1E, 0x01},
    {0x05, 0x03, 0x04, 0x04, 0x04, 0x03, 0x05, 0x04},
    {0x04, 0x04, 0x05, 0x05, 0x05, 0x06, 0x07, 0x0C},
    {0x08, 0x07, 0x07, 0x07, 0x07, 0x0F, 0x0B, 0x0B},
    {0x09, 0x0C, 0x11, 0x0F, 0x12, 0x12, 0x11, 0x0F},
    {0x11, 0x11, 0x13, 0x16, 0x1C, 0x17, 0x13, 0x14},
    {0x1A, 0x15, 0x11, 0x11, 0x18, 0x21, 0x18, 0x1A},
    {0x1D, 0x1D, 0x1F, 0x1F, 0x1F, 0x13, 0x17, 0x22},
    {0x24, 0x22, 0x1E, 0x24, 0x1C, 0x1E, 0x1F, 0x1E},
    {0xFF, 0x20, 0x00, 0x1F, 0x02, 0x0C, 0x00, 0x00},
    {0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00},
    {0x11, 0x22, 0x00, 0x22, 0x22, 0x11, 0x22, 0x22},
    {0x11, 0x33, 0x33, 0x11, 0x44, 0x66, 0x22, 0x55},
    {0x66, 0xFF, 0xDD, 0x00, 0x04, 0x00, 0x14, 0xFF},
    {0xC0, 0x00, 0x11, 0x08, 0x00, 0xF0, 0x01, 0x40},
    {0x03, 0x00, 0x21, 0x00, 0x01, 0x11, 0x01, 0x02},
    {0x11, 0x01, 0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x00},
    {0x00, 0x01, 0x11, 0x02, 0x11, 0x00, 0x3F, 0x00},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}	//27
};
static __u8 cxjpeg_176[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x0D},
    {0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B, 0x0A},
    {0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F, 0x14},
    {0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D, 0x17},
    {0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28, 0x2C},
    {0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35, 0x44},
    {0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44, 0x4A},
    {0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58, 0x5F},
    {0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D, 0x01},
    {0x0D, 0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B},
    {0x0A, 0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F},
    {0x14, 0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D},
    {0x17, 0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28},
    {0x2C, 0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35},
    {0x44, 0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44},
    {0x4A, 0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58},
    {0x5F, 0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D},
    {0xFF, 0x20, 0x00, 0x1F, 0x03, 0xA1, 0x00, 0x00},
    {0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00},
    {0x11, 0x22, 0x00, 0x22, 0x22, 0x11, 0x22, 0x22},
    {0x11, 0x33, 0x33, 0x11, 0x44, 0x66, 0x22, 0x55},
    {0x66, 0xFF, 0xDD, 0x00, 0x04, 0x00, 0x0B, 0xFF},
    {0xC0, 0x00, 0x11, 0x08, 0x00, 0x90, 0x00, 0xB0},
    {0x03, 0x00, 0x21, 0x00, 0x01, 0x11, 0x01, 0x02},
    {0x11, 0x01, 0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x00},
    {0x00, 0x01, 0x11, 0x02, 0x11, 0x00, 0x3F, 0x00},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}
};
static __u8 cxjpeg_160[][8] = {
    {0xFF, 0xD8, 0xFF, 0xDB, 0x00, 0x84, 0x00, 0x0D},	//1
    {0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B, 0x0A},
    {0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F, 0x14},
    {0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D, 0x17},
    {0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28, 0x2C},
    {0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35, 0x44},
    {0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44, 0x4A},
    {0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58, 0x5F},
    {0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D, 0x01},
    {0x0D, 0x09, 0x09, 0x0B, 0x09, 0x08, 0x0D, 0x0B},
    {0x0A, 0x0B, 0x0E, 0x0D, 0x0D, 0x0F, 0x13, 0x1F},
    {0x14, 0x13, 0x11, 0x11, 0x13, 0x26, 0x1B, 0x1D},
    {0x17, 0x1F, 0x2D, 0x28, 0x30, 0x2F, 0x2D, 0x28},
    {0x2C, 0x2B, 0x32, 0x38, 0x48, 0x3D, 0x32, 0x35},
    {0x44, 0x36, 0x2B, 0x2C, 0x3F, 0x55, 0x3F, 0x44},
    {0x4A, 0x4D, 0x50, 0x51, 0x50, 0x30, 0x3C, 0x58},
    {0x5F, 0x58, 0x4E, 0x5E, 0x48, 0x4F, 0x50, 0x4D},
    {0xFF, 0x20, 0x00, 0x1F, 0x03, 0xB1, 0x00, 0x00},
    {0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x11, 0x00},
    {0x11, 0x22, 0x00, 0x22, 0x22, 0x11, 0x22, 0x22},
    {0x11, 0x33, 0x33, 0x11, 0x44, 0x66, 0x22, 0x55},
    {0x66, 0xFF, 0xDD, 0x00, 0x04, 0x00, 0x0A, 0xFF},
    {0xC0, 0x00, 0x11, 0x08, 0x00, 0x78, 0x00, 0xA0},
    {0x03, 0x00, 0x21, 0x00, 0x01, 0x11, 0x01, 0x02},
    {0x11, 0x01, 0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x00},
    {0x00, 0x01, 0x11, 0x02, 0x11, 0x00, 0x3F, 0x00},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}	//27
};

static __u8 cxjpeg_qtable[][8] = {	// 640 take with the zcx30x part
    {0xff, 0xd8, 0xff, 0xdb, 0x00, 0x84, 0x00, 0x08},
    {0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07},
    {0x07, 0x09, 0x09, 0x08, 0x0a, 0x0c, 0x14, 0x0a},
    {0x0c, 0x0b, 0x0b, 0x0c, 0x19, 0x12, 0x13, 0x0f},
    {0x14, 0x1d, 0x1a, 0x1f, 0x1e, 0x1d, 0x1a, 0x1c},
    {0x1c, 0x20, 0x24, 0x2e, 0x27, 0x20, 0x22, 0x2c},
    {0x23, 0x1c, 0x1c, 0x28, 0x37, 0x29, 0x2c, 0x30},
    {0x31, 0x34, 0x34, 0x34, 0x1f, 0x27, 0x39, 0x3d},
    {0x38, 0x32, 0x3c, 0x2e, 0x33, 0x34, 0x32, 0x01},
    {0x09, 0x09, 0x09, 0x0c, 0x0b, 0x0c, 0x18, 0x0a},
    {0x0a, 0x18, 0x32, 0x21, 0x1c, 0x21, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32, 0x32},
    {0xFF, 0xD9, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}	//18
};


static void cx11646_jpegInit(struct usb_spca50x *spca50x)
{
    __u8 val = 0;
    int i = 0;
    int length = 8;
    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c0, &val, 1);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c3, &val, 1);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c0, &val, 1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0001, &val, 1);
    for (i = 0; i < 79; i++) {
	if (i == 78)
	    length = 6;
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008, cx_jpeg_init[i],
			length);
    }
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0002, &val, 1);
    val = 0x14;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0055, &val, 1);
}

static __u8 reg12[] = { 0x0a, 0x05, 0x07, 0x04, 0x19 };
static __u8 regE5_8[] = { 0x88, 0x00, 0xd4, 0x01, 0x88, 0x01, 0x01, 0x01 };
static __u8 regE5a[] = { 0x88, 0x0a, 0x0c, 0x01 };
static __u8 regE5b[] = { 0x88, 0x0b, 0x12, 0x01 };
static __u8 regE5c[] = { 0x88, 0x05, 0x01, 0x01 };
static __u8 reg51[] = { 0x77, 0x03 };
static __u8 reg70 = 0x03;

static void cx11646_jpeg(struct usb_spca50x *spca50x)
{
    __u8 val = 0;
    int i = 0;
    int length = 8;
    __u8 Reg55 = 0x14;
    __u8 bufread[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
    int retry = 50;

    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c0, &val, 1);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c3, &val, 1);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00c0, &val, 1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0001, &val, 1);
    switch (spca50x->mode) {
    case 0:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_640[i], length);
	}
	Reg55 = 0x28;
	break;
    case 1:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_352[i], length);
	}
	Reg55 = 0x16;
	break;
    case 2:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_320[i], length);
	}
	Reg55 = 0x14;
	break;
    case 3:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_176[i], length);
	}
	Reg55 = 0x0B;
	break;
    case 4:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_160[i], length);
	}
	Reg55 = 0x0A;
	break;
    default:
	for (i = 0; i < 27; i++) {
	    if (i == 26)
		length = 2;
	    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008,
			    cxjpeg_320[i], length);
	}
	Reg55 = 0x14;
	break;
    }

    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0002, &val, 1);
    val = Reg55;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0055, &val, 1);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0002, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 2);
    val = 0x02;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0054, &val, 1);
    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0054, &val, 1);
    val = 0x94;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0000, &val, 1);
    val = 0xc0;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0053, &val, 1);
    val = 0xe1;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00fc, &val, 1);
    val = 0x00;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0000, &val, 1);
    // wait for completion 
    while (retry--) {
	spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0002, &val, 1);	// 0x07 until 0x00
	if (val == 0x00)
	    break;
	val = 0x00;
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0053, &val, 1);
    }
    if (retry == 0)
	PDEBUG(0, "Damned Errors sending jpeg Table");
    // send the qtable now
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0001, &val, 1);	// -> 0x18
    length = 8;
    for (i = 0; i < 18; i++) {
	if (i == 17)
	    length = 2;
	spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0008, cxjpeg_qtable[i],
			length);

    }
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0002, &val, 1);	// 0x00
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0053, &val, 1);	// 0x00
    val = 0x02;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0054, &val, 1);
    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0054, &val, 1);
    val = 0x94;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0000, &val, 1);
    val = 0xc0;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0053, &val, 1);

    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0038, &val, 1);	// 0x40
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x0038, &val, 1);	// 0x40
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x001f, &val, 1);	// 0x38
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0012, reg12, 5);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5_8, 8);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, bufread, 8);	// 
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5a, 4);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// 0x00
    val = 0x01;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x009a, &val, 1);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5b, 4);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// 0x00
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5c, 4);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// 0x00

    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0051, reg51, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0070, &reg70, 1);
}

static void cx_setcolors(struct usb_spca50x *spca50x)
{
// Nothing
}
static __u16 cx_getcontrast(struct usb_spca50x *spca50x)
{
   spca50x->contrast = 0x0c << 11;	// 0..0x1f
return spca50x->contrast;
}
static __u16 cx_getcolors(struct usb_spca50x *spca50x)
{
   spca50x->colour = 0x03 << 13;	// 0..7
return spca50x->colour;
}
static __u16 cx_getbrightness(struct usb_spca50x *spca50x)
{
/*FIXME hardcoded as we need to read register of the sensor */
    spca50x->brightness = 0xD4 << 8;	// 0..256
    spca50x->contrast = 0x0c << 11;	// 0..0x1f
    spca50x->colour = 0x03 << 13;	// 0..7
    return (0xD4 << 8);
}
static void cx_setbrightness(struct usb_spca50x *spca50x)
{
    __u8 regE5cbx[] = { 0x88, 0x00, 0xd4, 0x01, 0x88, 0x01, 0x01, 0x01 };
    __u8 reg51c[] = { 0x77, 0x03 };
    __u8 bright = 0;
    __u8 colors = 0;
    __u8 val = 0;
    __u8 bufread[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
    bright = (spca50x->brightness >> 8) & 0xff;
    colors = (spca50x->colour >> 13) & 0x07;
    regE5cbx[2] = bright;
    reg51c[1] = colors;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5cbx, 8);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, bufread, 8);	//
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5c, 4);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// 0x00

    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0051, reg51c, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0070, &reg70, 1);


}
static void cx_setcontrast(struct usb_spca50x *spca50x)
{

    __u8 regE5acx[] = { 0x88, 0x0a, 0x0c, 0x01 };	//seem MSB
    //__u8 regE5bcx[]={0x88,0x0b,0x12,0x01}; // LSB
    __u8 reg51c[] = { 0x77, 0x03 };
    __u8 contrast = 0;
    __u8 val = 0;
    __u8 colors = 0;
    colors = (spca50x->colour >> 13) & 0x07;
    reg51c[1] = colors;
    contrast = (spca50x->contrast >> 11) & 0x1f;
    if (contrast < 10)
	contrast = 10;
    regE5acx[2] = contrast;
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x00e5, regE5acx, 4);
    spca5xxRegRead(spca50x->dev, 0x00, 0x00, 0x00e8, &val, 1);	// 0x00
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0051, reg51c, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0010, reg10, 2);
    spca5xxRegWrite(spca50x->dev, 0x00, 0x00, 0x0070, &reg70, 1);

}

