#ifndef SPCA50X_H
#define SPCA50X_H

/*
 * Header file for SPCA50x based camera driver. Originally copied from ov511 driver.
 * Originally by Mark W. McClelland
 * SPCA50x version by Joel Crisp; all bugs are mine, all nice features are his.
 */

#ifdef __KERNEL__
#include <asm/uaccess.h>
#include <linux/videodev.h>
#include <linux/smp_lock.h>
#include <linux/usb.h>
#include <linux/version.h>

#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,20) && LINUX_VERSION_CODE < KERNEL_VERSION(2,5,0)

#define urb_t struct urb
#endif				/* LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,20) */
#endif /* __KERNEL__ */

#if defined(MACAM)

typedef unsigned char u8;
typedef unsigned char __u8;
typedef unsigned short __u16;
typedef unsigned int __u32;

typedef struct semaphore {} spinlock_t;
        struct tasklet_struct {};
typedef struct wait_queue_head_t {} wait_queue_head_t;	

void udelay(int delay_time_probably_micro_seconds);
void wait_ms(int delay_time_in_milli_seconds);

void spin_lock(spinlock_t * lock);
void spin_unlock(spinlock_t * lock);
void spin_lock_irqsave(spinlock_t * lock, long flags);
void spin_unlock_irqrestore(spinlock_t * lock, long flags);

// This is a kludge since code from other Linux drivers is also used in some places... Hopefully OK
#if !defined(VIDEO_PALETTE_RGB565)
enum 
{
    VIDEO_PALETTE_RGB565, 
    VIDEO_PALETTE_RGB32, 
    VIDEO_PALETTE_RGB24, 
    VIDEO_PALETTE_YUV420P, 
    VIDEO_PALETTE_YUYV, 
};
#endif

#if DEBUG
#define SPCA50X_ENABLE_DEBUG
#define info(args...) { printf(args); printf("\n"); }
extern int debug;
#endif

#endif // defined(MACAM)

//static const char SPCA50X_H_CVS_VERSION[]="$Id: spca5xx.h,v 1.7 2006/10/19 22:33:00 hxr Exp $";

#if defined(__KERNEL__) || defined(MACAM)

/* V4L API extension for raw JPEG (=JPEG without header) and JPEG with header   
 */
#define VIDEO_PALETTE_RAW_JPEG  20
#define VIDEO_PALETTE_JPEG 21

#ifdef SPCA50X_ENABLE_DEBUG

#  define PDEBUG(level, fmt, args...) \
if (debug >= level) info("[%s:%d] " fmt, __PRETTY_FUNCTION__, __LINE__ , ## args)
#else				/* SPCA50X_ENABLE_DEBUG */
#  define PDEBUG(level, fmt, args...) do {} while(0)
#endif				/* SPCA50X_ENABLE_DEBUG */

//#define FRAMES_PER_DESC               10      /* Default value, should be reasonable */
#define FRAMES_PER_DESC		16	/* Default value, should be reasonable */
#define MAX_FRAME_SIZE_PER_DESC 1024

#define SPCA50X_MAX_WIDTH 640
#define SPCA50X_MAX_HEIGHT 480

#define SPCA50X_ENDPOINT_ADDRESS 1	/* Isoc endpoint number */
#define PAC207_ENDPOINT_ADDRESS 5	/* Isoc endpoint number */
/* only 2 or 4 frames are allowed here !!! */
#define SPCA50X_NUMFRAMES	2
#define SPCA50X_NUMSBUF	2

#define BRIDGE_SPCA505 0
#define BRIDGE_SPCA506 1
#define BRIDGE_SPCA501 2
#define BRIDGE_SPCA508 3
#define BRIDGE_SPCA504 4
#define BRIDGE_SPCA500 5
#define BRIDGE_SPCA504B 6
#define BRIDGE_SPCA533 7
#define BRIDGE_SPCA504C 8
#define BRIDGE_SPCA561 9
#define BRIDGE_SPCA536 10
#define BRIDGE_SONIX 11
#define BRIDGE_ZC3XX 12
#define BRIDGE_CX11646 13
#define BRIDGE_TV8532 14
#define BRIDGE_ETOMS 15
#define BRIDGE_SN9CXXX 16
#define BRIDGE_MR97311 17
#define BRIDGE_PAC207 18

#define SENSOR_SAA7113 0
#define SENSOR_INTERNAL 1
#define SENSOR_HV7131B  2
#define SENSOR_HDCS1020 3
#define SENSOR_PB100_BA 4
#define SENSOR_PB100_92	5
#define SENSOR_PAS106_80 6
#define SENSOR_TAS5130C 7
#define SENSOR_ICM105A 8
#define SENSOR_HDCS2020 9
#define SENSOR_PAS106 10
#define SENSOR_PB0330 11
#define SENSOR_HV7131C 12
#define SENSOR_CS2102 13
#define SENSOR_HDCS2020b 14
#define SENSOR_HV7131R 15
#define SENSOR_OV7630 16
#define SENSOR_MI0360 17
#define SENSOR_TAS5110 18
#define SENSOR_PAS202 19
#define SENSOR_PAC207 20
#define SENSOR_OV7630C 21

/* Alternate interface transfer sizes */
#define SPCA50X_ALT_SIZE_0       0
#define SPCA50X_ALT_SIZE_128     1
#define SPCA50X_ALT_SIZE_256     1
#define SPCA50X_ALT_SIZE_384     2
#define SPCA50X_ALT_SIZE_512     3
#define SPCA50X_ALT_SIZE_640     4
#define SPCA50X_ALT_SIZE_768     5
#define SPCA50X_ALT_SIZE_896     6
#define SPCA50X_ALT_SIZE_1023    7

/* Sequence packet identifier for a dropped packet */
#define SPCA50X_SEQUENCE_DROP 0xFF


/* Offsets into the 10 byte header on the first ISO packet */
#define SPCA50X_OFFSET_SEQUENCE 0
#define SPCA50X_OFFSET_FRAMSEQ 6
#define SPCA50X_OFFSET_DATA 10

#define SPCA50X_REG_USB 0x2 // spca505 501


/* I2C interface on an SPCA505, SPCA506, SPCA508 */
#define SPCA50X_REG_I2C_CTRL 0x7
#define SPCA50X_I2C_DEVICE 0x4
#define SPCA50X_I2C_SUBADDR 0x1
#define SPCA50X_I2C_VALUE 0x0
#define SPCA50X_I2C_TRIGGER 0x2
#define SPCA50X_I2C_TRIGGER_BIT 0x1
#define SPCA50X_I2C_READ 0x0
#define SPCA50X_I2C_STATUS 0x3


/* Brightness autoadjustment parameters*/
#define NSTABLE_MAX 4
#define NUNSTABLE_MAX 600
#define MIN_BRIGHTNESS 10

/* Camera type jpeg yuvy yyuv yuyv grey gbrg*/
enum {
    JPEG = 0,			//Jpeg 4.1.1 Sunplus
    JPGH,			//jpeg 4.2.2 Zstar
    JPGC,			//jpeg 4.2.2 Conexant
    JPGS,			//jpeg 4.2.2 Sonix
    JPGM,			//jpeg 4.2.2 Mars-Semi
    YUVY,
    YYUV,
    YUYV,
    GREY,
    GBRG,
    SN9C,			// Sonix compressed stream
    GBGR,
    S561,			// Sunplus Compressed stream
    PGBRG,			// Pixart RGGB bayer
};

enum { QCIF = 1,
    QSIF,
    QPAL,
    CIF,
    SIF,
    PAL,
    VGA,
    CUSTOM,
    TOTMODE,
};

/* available palette */
#define P_RGB16  1
#define P_RGB24  (1 << 1)
#define P_RGB32  (1 << 2)
#define P_YUV420  (1 << 3)
#define P_YUV422 ( 1 << 4)
#define P_RAW  (1 << 5)
#define P_JPEG  (1 << 6)

struct mwebcam {
    int width;
    int height;
    __u16 t_palette;
    __u16 pipe;
    int method;
    int mode;
};
struct video_param {
    int chg_para;
#define CHGABRIGHT 1
#define CHGQUALITY 2
#define CHGTINTER  4
    __u8 autobright;
    __u8 quality;
    __u16 time_interval;
};
/* Our private ioctl */
#define SPCAGVIDIOPARAM _IOR('v',BASE_VIDIOCPRIVATE + 1,struct video_param)
#define SPCASVIDIOPARAM _IOW('v',BASE_VIDIOCPRIVATE + 2,struct video_param)

/* State machine for each frame in the frame buffer during capture */
enum {
    STATE_SCANNING,		/* Scanning for start */
    STATE_HEADER,		/* Parsing header */
    STATE_LINES,		/* Parsing lines */
};

/* Buffer states */
enum {
    BUF_NOT_ALLOCATED,
    BUF_ALLOCATED,
    BUF_PEND_DEALLOC,		/* spca50x->buf_timer is set */
};

struct usb_device;

/* One buffer for the USB ISO transfers */
struct spca50x_sbuf {
    char *data;
    struct urb *urb;
};

/* States for each frame buffer. */
enum {
    FRAME_UNUSED,		/* Unused (no MCAPTURE) */
    FRAME_READY,		/* Ready to start grabbing */
    FRAME_GRABBING,		/* In the process of being grabbed into */
    FRAME_DONE,			/* Finished grabbing, but not been synced yet */
    FRAME_ERROR,		/* Something bad happened while processing */
    FRAME_ABORTING,		/* Aborting everything. Caused by hot unplugging. */

};
/************************ decoding data  **************************/
struct pictparam {
    int change;
    int force_rgb;
    int gamma;
    int OffRed;
    int OffBlue;
    int OffGreen;
    int GRed;
    int GBlue;
    int GGreen;
};
#define MAXCOMP 4
struct dec_hufftbl;
struct enc_hufftbl;

union hufftblp {
    struct dec_hufftbl *dhuff;
    struct enc_hufftbl *ehuff;
};

struct scan {
    int dc;			/* old dc value */
    union hufftblp hudc;	/* pointer to huffman table dc */
    union hufftblp huac;	/* pointer to huffman table ac */
    int next;			/* when to switch to next scan */
    int cid;			/* component id */
    int hv;			/* horiz/vert, copied from comp */
    int tq;			/* quant tbl, copied from comp */
};

/*********************************/

#define DECBITS 10		/* seems to be the optimum */

struct dec_hufftbl {
    int maxcode[17];
    int valptr[16];
    unsigned char vals[256];
    unsigned int llvals[1 << DECBITS];
};

/*********************************/
struct in {
    unsigned char *p;
    unsigned int bits;
    int omitescape;
    int left;
    int marker;
};
struct jpginfo {
    int nc;			/* number of components */
    int ns;			/* number of scans */
    int dri;			/* restart interval */
    int nm;			/* mcus til next marker */
    int rm;			/* next restart marker */
};

struct comp {
    int cid;
    int hv;
    int tq;
};

/* Sonix decompressor struct B.S.(2004) */

struct code_table_t {
    int is_abs;
    int len;
    int val;
};

struct dec_data {
    struct in in;
    struct jpginfo info;
    struct comp comps[MAXCOMP];
    struct scan dscans[MAXCOMP];
    unsigned char quant[3][64];
    int dquant[3][64];
    struct code_table_t table[256];
    unsigned char Red[256];
    unsigned char Green[256];
    unsigned char Blue[256];
};
/*************************End decoding data ********************************/
struct spca50x_frame {
    unsigned char *data;	/* Frame buffer */
    unsigned char *tmpbuffer;	/* temporary buffer spca50x->tmpbuffer need for decoding */
    struct dec_data *decoder;
    /* Memory allocation for the jpeg decoders */
    int dcts[6 * 64 + 16];
    int out[6 * 64];
    int max[6];
	/*******************************************/
//    int seq;			/* Frame sequence number */
    int depth;			/* Bytes per pixel */
    int width;			/* Width application is expecting */
    int height;			/* Height */

    int hdrwidth;		/* Width the frame actually is */
    int hdrheight;		/* Height */
    int method;			/* The decoding method for that frame 0 nothing 1 crop 2 div 4 mult */
    int cropx1;			/* value to be send with the frame for decoding feature */
    int cropx2;
    int cropy1;
    int cropy2;
    int x;
    int y;

    unsigned int format;	/* Format asked by apps for this frame */
    int cameratype;		/* native in frame format */
    struct pictparam pictsetting;
    volatile int grabstate;	/* State of grabbing */
    int scanstate;		/* State of scanning */

    long scanlength;		/* uncompressed, raw data length of frame */
    int totlength;		/* length of the current reading byte in the Iso stream */

    wait_queue_head_t wq;	/* Processes waiting */

    int snapshot;		/* True if frame was a snapshot */
    int last_packet;		/* sequence number for last packet */
    unsigned char *highwater;	/* used for debugging */

};

struct usb_spca50x;

typedef void (*cam_ops)( struct usb_spca50x*);
typedef int (*intcam_ops)(struct usb_spca50x*);
typedef __u16 (*u16cam_ops)(struct usb_spca50x*);
typedef int (*intcam_detect)(struct usb_spca50x*,struct spca50x_frame*, unsigned char*, int*, int, int*);

struct cam_operation {
 	intcam_ops initialize;
	intcam_ops configure;
	cam_ops start;
	cam_ops stopN;
	cam_ops stop0;
	u16cam_ops get_bright;
	cam_ops set_bright;
	u16cam_ops get_contrast;
	cam_ops set_contrast;
	u16cam_ops get_colors;
	cam_ops set_colors;
	cam_ops set_autobright;
	cam_ops set_quality;
	cam_ops cam_shutdown;
	intcam_detect sof_detect;
 };
 
struct usb_spca50x {
    struct video_device *vdev;
    struct usb_device *dev;	/* Device structure */
    struct tasklet_struct spca5xx_tasklet;	/* use a tasklet per device */
    struct dec_data maindecode;
    unsigned long last_times;	//timestamp
    unsigned int dtimes;	//nexttimes to acquire
    unsigned char iface;	/* interface in use */
    int alt;			/* current alternate setting */
    int customid;		/* product id get by probe */
    int desc;			/* enum camera name */
    int ccd;			/* If true, using the CCD otherwise the external input */
    int chip_revision;		/* set when probe the camera spca561 zc0301p for vm303 */
    struct mwebcam mode_cam[TOTMODE];	/* all available mode registers by probe */
    int bridge;			/* Type of bridge (BRIDGE_SPCA505 or BRIDGE_SPCA506) */
    int sensor;			/* Type of image sensor chip */
    int packet_size;		/* Frame size per isoc desc */
    int header_len;
    /* Determined by sensor type */
    int maxwidth;
    int maxheight;
    int minwidth;
    int minheight;
    /* What we think the hardware is currently set to */
    int brightness;
    int colour;
    int contrast;
    int hue;
    int whiteness;
    int exposure;		// used by spca561 
    int autoexpo;
    int qindex;
    int width;			/* use here for the init of each frame */
    int height;
    int hdrwidth;
    int hdrheight;
    unsigned int format;
    int method;			/* method ask for output pict */
    int mode;			/* requested frame size */
    int pipe_size;		// requested pipe size set according to mode
    __u16 norme;		/* norme in use Pal Ntsc Secam */
    __u16 channel;		/* input composite video1 or svideo */
    int cameratype;		/* native in frame format */
    struct pictparam pictsetting;
    /* Statistics variables */
    spinlock_t v4l_lock;	/* lock to protect shared data between isoc and process context */
    int avg_lum;		//The average luminance (if available from theframe header)
    int avg_bg, avg_rg;		//The average B-G and R-G for white balancing 
    struct semaphore lock;
    int user;			/* user count for exclusive use */
    int present;		/* driver loaded */

    int streaming;		/* Are we streaming Isochronous? */
    int grabbing;		/* Are we grabbing? */
    int packet;
    int synchro;		/* set to 0 if usb packet length = 0 */
    int compress;		/* Should the next frame be compressed? */

    char *fbuf;			/* Videodev buffer area */
    int curframe;		/* Current receiving frame buffer */
    struct spca50x_frame frame[SPCA50X_NUMFRAMES];
    int cursbuf;		/* Current receiving sbuf */
    struct spca50x_sbuf sbuf[SPCA50X_NUMSBUF];
    /* Temporary jpeg decoder workspace */
    char *tmpBuffer;
    /* Framebuffer/sbuf management */
    int buf_state;
    struct semaphore buf_lock;

    wait_queue_head_t wq;	/* Processes waiting */
    /* proc interface */
    struct semaphore param_lock;	/* params lock for this camera */
    struct proc_dir_entry *proc_entry;	/* /proc/spca50x/videoX */
    struct proc_dir_entry *ctl_proc_entry;	/* /proc/spca50x/controlX */

    int lastFrameRead;
    uint i2c_ctrl_reg;		// Camera I2C control register
    uint i2c_base;		// Camera I2C address base
    char i2c_trigger_on_write;	//do trigger bit on write
    struct cam_operation funct;
    __u8 force_rgb;		//Read RGB instead of BGR
    __u8 min_bpp;		//The minimal color depth that may be set
    __u8 lum_level;		//Luminance level for brightness autoadjustment
};

struct cam_list {
    int id;
    const char *description;
};

struct palette_list {
    int num;
    const char *name;
};

struct bridge_list {
    int num;
    const char *name;
};

#endif				/* __KERNEL__ */


#endif				/* SPCA50X_H */
