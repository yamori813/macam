/****************************************************************************
#			OV7620 library	                                    #
#	  	Automatically produced from ZS211.inf 		    	    #
#		by zc030x.inf2gspca.sh v0.02		    		    #
# 	    Copyright (C) 2004 Michel Xhaard  mxhaard@magic.fr              #
#  	Copyright (C) 2007 Serge Suchkov  Serge.A.S@tochka.ru		    #
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
static __u16 OV7620_InitialScale[][3] = { 
	{0xa0, 0x0001, 0x0000}, //00,00,01,cc
	{0xa0, 0x0040, 0x0002}, //00,02,40,cc
		{0xa0, 0x0003, 0x0008}, //00,08,00,cc
	{0xa0, 0x0001, 0x0001}, //00,01,01,cc
	{0xa0, 0x0006, 0x0010}, //00,10,06,cc
	{0xa0, 0x0002, 0x0083}, //00,83,02,cc
	{0xa0, 0x0001, 0x0085}, //00,85,01,cc
	{0xa0, 0x0080, 0x0086}, //00,86,80,cc
	{0xa0, 0x0081, 0x0087}, //00,87,81,cc
	{0xa0, 0x0010, 0x0088}, //00,88,10,cc
	{0xa0, 0x00a1, 0x008b}, //00,8b,a1,cc
	{0xa0, 0x0008, 0x008d}, //00,8d,08,cc
		{0xa0, 0x0002, 0x0003}, //00,03,02,cc
		{0xa0, 0x0080, 0x0004}, //00,04,80,cc
		{0xa0, 0x0001, 0x0005}, //00,05,01,cc
		{0xa0, 0x00d8, 0x0006}, //00,06,d8,cc
	{0xa0, 0x0003, 0x0012}, //00,12,03,cc
	{0xa0, 0x0001, 0x0012}, //00,12,01,cc
	{0xa0, 0x0000, 0x0098}, //00,98,00,cc
	{0xa0, 0x0000, 0x009a}, //00,9a,00,cc
	{0xa0, 0x0000, 0x011a}, //01,1a,00,cc
	{0xa0, 0x0000, 0x011c}, //01,1c,00,cc
	{0xa0, 0x00de, 0x009c}, //00,9c,de,cc
	{0xa0, 0x0086, 0x009e}, //00,9e,86,cc
	{0xa0, 0x0012, 0x0092}, //00,12,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0012, 0x0092}, //00,12,48,aa
	{0xa0, 0x0048, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0013, 0x0092}, //00,13,a3,aa
	{0xa0, 0x00a3, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0004, 0x0092}, //00,04,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0005, 0x0092}, //00,05,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0014, 0x0092}, //00,14,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0015, 0x0092}, //00,15,04,aa
	{0xa0, 0x0004, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0017, 0x0092}, //00,17,18,aa
	{0xa0, 0x0018, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0018, 0x0092}, //00,18,ba,aa
	{0xa0, 0x00ba, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0019, 0x0092}, //00,19,02,aa
	{0xa0, 0x0002, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x001a, 0x0092}, //00,1a,f1,aa
	{0xa0, 0x00f1, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0020, 0x0092}, //00,20,40,aa
	{0xa0, 0x0040, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0024, 0x0092}, //00,24,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0025, 0x0092}, //00,25,78,aa
	{0xa0, 0x0078, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0027, 0x0092}, //00,27,f6,aa
	{0xa0, 0x00f6, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0028, 0x0092}, //00,28,a0,aa
	{0xa0, 0x00a0, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0021, 0x0092}, //00,21,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002a, 0x0092}, //00,2a,83,aa
	{0xa0, 0x0083, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,96,aa
	{0xa0, 0x0096, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0074, 0x0092}, //00,74,20,aa
	{0xa0, 0x0020, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0061, 0x0092}, //00,61,68,aa
	{0xa0, 0x0068, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0064, 0x0092}, //00,64,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0092}, //00,00,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0006, 0x0092}, //00,06,80,aa
	{0xa0, 0x0080, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0001, 0x0092}, //00,01,90,aa
	{0xa0, 0x0090, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0002, 0x0092}, //00,02,30,aa
	{0xa0, 0x0030, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0077, 0x0101}, //01,01,77,cc
	{0xa0, 0x0005, 0x0012}, //00,12,05,cc
	{0xa0, 0x000d, 0x0100}, //01,00,0d,cc
	{0xa0, 0x0006, 0x0189}, //01,89,06,cc
	{0xa0, 0x0000, 0x01ad}, //01,ad,00,cc
	{0xa0, 0x0003, 0x01c5}, //01,c5,03,cc
	{0xa0, 0x0013, 0x01cb}, //01,cb,13,cc
	{0xa0, 0x0008, 0x0250}, //02,50,08,cc
	{0xa0, 0x0008, 0x0301}, //03,01,08,cc
	{0xa0, 0x0068, 0x0116}, //01,16,68,cc
	{0xa0, 0x0052, 0x0118}, //01,18,52,cc
	{0xa0, 0x0040, 0x011d}, //01,1d,40,cc
	{0xa0, 0x0002, 0x0180}, //01,80,02,cc
	{0xa0, 0x0050, 0x01a8}, //01,a8,50,cc
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_Initial[][3] = { 
	{0xa0, 0x0001, 0x0000}, //00,00,01,cc
	{0xa0, 0x0050, 0x0002}, //00,02,50,cc
		{0xa0, 0x0003, 0x0008}, //00,08,00,cc
	{0xa0, 0x0001, 0x0001}, //00,01,01,cc
	{0xa0, 0x0006, 0x0010}, //00,10,06,cc
	{0xa0, 0x0002, 0x0083}, //00,83,02,cc
	{0xa0, 0x0001, 0x0085}, //00,85,01,cc
	{0xa0, 0x0080, 0x0086}, //00,86,80,cc
	{0xa0, 0x0081, 0x0087}, //00,87,81,cc
	{0xa0, 0x0010, 0x0088}, //00,88,10,cc
	{0xa0, 0x00a1, 0x008b}, //00,8b,a1,cc
	{0xa0, 0x0008, 0x008d}, //00,8d,08,cc
	{0xa0, 0x0002, 0x0003}, //00,03,02,cc
	{0xa0, 0x0080, 0x0004}, //00,04,80,cc
	{0xa0, 0x0001, 0x0005}, //00,05,01,cc
	{0xa0, 0x00d0, 0x0006}, //00,06,d0,cc
	{0xa0, 0x0003, 0x0012}, //00,12,03,cc
	{0xa0, 0x0001, 0x0012}, //00,12,01,cc
	{0xa0, 0x0000, 0x0098}, //00,98,00,cc
	{0xa0, 0x0000, 0x009a}, //00,9a,00,cc
	{0xa0, 0x0000, 0x011a}, //01,1a,00,cc
	{0xa0, 0x0000, 0x011c}, //01,1c,00,cc
	{0xa0, 0x00d6, 0x009c}, //00,9c,d6,cc
	{0xa0, 0x0088, 0x009e}, //00,9e,88,cc
	{0xa0, 0x0012, 0x0092}, //00,12,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0012, 0x0092}, //00,12,48,aa
	{0xa0, 0x0048, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0013, 0x0092}, //00,13,a3,aa
	{0xa0, 0x00a3, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0004, 0x0092}, //00,04,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0005, 0x0092}, //00,05,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0014, 0x0092}, //00,14,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0015, 0x0092}, //00,15,04,aa
	{0xa0, 0x0004, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0024, 0x0092}, //00,24,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0025, 0x0092}, //00,25,78,aa
	{0xa0, 0x0078, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0017, 0x0092}, //00,17,18,aa
	{0xa0, 0x0018, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0018, 0x0092}, //00,18,ba,aa
	{0xa0, 0x00ba, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0019, 0x0092}, //00,19,02,aa
	{0xa0, 0x0002, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x001a, 0x0092}, //00,1a,f2,aa
	{0xa0, 0x00f2, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0020, 0x0092}, //00,20,40,aa
	{0xa0, 0x0040, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0027, 0x0092}, //00,27,f6,aa
	{0xa0, 0x00f6, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0028, 0x0092}, //00,28,a0,aa
	{0xa0, 0x00a0, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0021, 0x0092}, //00,21,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002a, 0x0092}, //00,2a,83,aa
	{0xa0, 0x0083, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,96,aa
	{0xa0, 0x0096, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0074, 0x0092}, //00,74,20,aa
	{0xa0, 0x0020, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0061, 0x0092}, //00,61,68,aa
	{0xa0, 0x0068, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0064, 0x0092}, //00,64,88,aa
	{0xa0, 0x0088, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0092}, //00,00,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0006, 0x0092}, //00,06,80,aa
	{0xa0, 0x0080, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0001, 0x0092}, //00,01,90,aa
	{0xa0, 0x0090, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0002, 0x0092}, //00,02,30,aa
	{0xa0, 0x0030, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0077, 0x0101}, //01,01,77,cc
	{0xa0, 0x0005, 0x0012}, //00,12,05,cc
	{0xa0, 0x000d, 0x0100}, //01,00,0d,cc
	{0xa0, 0x0006, 0x0189}, //01,89,06,cc
	{0xa0, 0x0000, 0x01ad}, //01,ad,00,cc
	{0xa0, 0x0003, 0x01c5}, //01,c5,03,cc
	{0xa0, 0x0013, 0x01cb}, //01,cb,13,cc
	{0xa0, 0x0008, 0x0250}, //02,50,08,cc
	{0xa0, 0x0008, 0x0301}, //03,01,08,cc
	{0xa0, 0x0068, 0x0116}, //01,16,68,cc
	{0xa0, 0x0052, 0x0118}, //01,18,52,cc
	{0xa0, 0x0050, 0x011d}, //01,1d,50,cc
	{0xa0, 0x0002, 0x0180}, //01,80,02,cc
	{0xa0, 0x0050, 0x01a8}, //01,a8,50,cc
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_50HZ[][3] = { 
	{0xa0, 0x0013, 0x0092}, //00,13,a3,aa
	{0xa0, 0x00a3, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	{0xa0, 0x002b, 0x0092}, //00,2b,96,aa
	{0xa0, 0x0096, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0083, 0x0197}, //01,97,83,cc
	{0xa0, 0x0010, 0x0092}, //00,10,82,aa
	{0xa0, 0x0082, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0076, 0x0092}, //00,76,03,aa
	{0xa0, 0x0003, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0040, 0x0002}, //00,02,40,cc
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_50HZScale[][3] = { 
	{0xa0, 0x0013, 0x0092}, //00,13,a3,aa
	{0xa0, 0x00a3, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	{0xa0, 0x002b, 0x0092}, //00,2b,96,aa
	{0xa0, 0x0096, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0083, 0x0197}, //01,97,83,cc
	{0xa0, 0x0010, 0x0092}, //00,10,82,aa
	{0xa0, 0x0082, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0076, 0x0092}, //00,76,03,aa
	{0xa0, 0x0003, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
		{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_60HZ[][3] = { 
	{0xa0, 0x0000, 0x0092}, //01,00,dd,aa
	{0xa0, 0x00dd, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0083, 0x0197}, //01,97,83,cc
	{0xa0, 0x0010, 0x0092}, //00,10,20,aa
	{0xa0, 0x0020, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0076, 0x0092}, //00,76,03,aa
	{0xa0, 0x0003, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0040, 0x0002}, //00,02,40,cc
		{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_60HZScale[][3] = { 
	{0xa0, 0x0000, 0x0092}, //01,00,dd,aa
	{0xa0, 0x00dd, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8a,aa
	{0xa0, 0x008a, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,05,aa
	{0xa0, 0x0005, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0083, 0x0197}, //01,97,83,cc
	{0xa0, 0x0010, 0x0092}, //00,10,20,aa
	{0xa0, 0x0020, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0076, 0x0092}, //00,76,03,aa
	{0xa0, 0x0003, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
		{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_NoFliker[][3] = { 
	{0xa0, 0x0000, 0x0092}, //01,00,dd,aa
	{0xa0, 0x00dd, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8e,aa
	{0xa0, 0x008e, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,01,aa
	{0xa0, 0x0001, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0001, 0x0197}, //01,97,01,cc
	{0xa0, 0x0044, 0x0002}, //00,02,44,cc
	{0xa0, 0x0000, 0x0039}, //00,00,00,dd 
	{0xa1, 0x0001, 0x0037}, //            
	/************************/
	{0, 0, 0}
};

static __u16 OV7620_NoFlikerScale[][3] = { 
	{0xa0, 0x0000, 0x0092}, //01,00,dd,aa
	{0xa0, 0x00dd, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002b, 0x0092}, //00,2b,00,aa
	{0xa0, 0x0000, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0075, 0x0092}, //00,75,8e,aa
	{0xa0, 0x008e, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x002d, 0x0092}, //00,2d,01,aa
	{0xa0, 0x0001, 0x0093}, //
	{0xa0, 0x0000, 0x0094}, //
	{0xa0, 0x0001, 0x0090}, //
	{0xa1, 0x0001, 0x0091}, //
	{0xa0, 0x0000, 0x0190}, //01,90,00,cc
	{0xa0, 0x0004, 0x0191}, //01,91,04,cc
	{0xa0, 0x0018, 0x0192}, //01,92,18,cc
	{0xa0, 0x0000, 0x0195}, //01,95,00,cc
	{0xa0, 0x0000, 0x0196}, //01,96,00,cc
	{0xa0, 0x0001, 0x0197}, //01,97,01,cc
	/************************/
	{0, 0, 0}
};

