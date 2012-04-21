typedef struct pdfapp pdfapp;

enum {
	PDFAPP_MINRES = 54,
	PDFAPP_MAXRES = 300
};

enum { 
	PDFAPP_ARROW, PDFAPP_HAND, PDFAPP_WAIT 
};

void winwarn(pdfapp*, char *s);
void winerror(pdfapp*, char *s);
void wintitle(pdfapp*, char *title);
void winresize(pdfapp*, int w, int h);
void winrepaint(pdfapp*);
void winrepaintsearch(pdfapp*);
char *winpassword(pdfapp*, char *filename);
void winopenuri(pdfapp*, char *s);
void wincursor(pdfapp*, int curs);
void windocopy(pdfapp*);
void winreloadfile(pdfapp*);
void windrawstring(pdfapp*, int x, int y, char *s);
void winclose(pdfapp*);
void winhelp(pdfapp*);
void winfullscreen(pdfapp*, int state);

typedef struct pdfapp {
	/* current document params */
	fz_document *doc;
	char *doctitle;
	fz_outline *outline;

	int pagecount;

	/* current view params */
	int resolution;
	int rotate;
	fz_pixmap *image;
	int grayscale;
	int invert;

	/* current page params */
	int pageno;
	fz_page *page;
	fz_rect page_bbox;
	fz_display_list *page_list;
	fz_text_page *page_text;
	fz_text_sheet *page_sheet;
	fz_link *page_links;

	/* snapback history */
	int hist[256];
	int histlen;
	int marks[10];

	/* window system sizes */
	int winw, winh;
	int scrw, scrh;
	int shrinkwrap;
	int fullscreen;

	/* event handling state */
	char number[256];
	int numberlen;

	int ispanning;
	int panx, pany;

	int iscopying;
	int selx, sely;
	/* TODO - While sely keeps track of the relative change in
	 * cursor position between two ticks/events, beyondy shall keep
	 * track of the relative change in cursor position from the
	 * point where the user hits a scrolling limit. This is ugly.
	 * Used in pdfapp.c:pdfapp_onmouse.
	 */
	int beyondy;
	fz_bbox selr;

	/* search state */
	int isediting;
	int searchdir;
	char search[512];
	int hit;
	int hitlen;

	/* client context storage */
	void *userdata;

	fz_context *ctx;
};

void  pdfapp_init(      fz_context *ctx, pdfapp *app);
void  pdfapp_open(      pdfapp *app, char *filename, int reload);
void  pdfapp_close(     pdfapp *app);
char *pdfapp_version(   pdfapp *app);
char *pdfapp_usage(     pdfapp *app);
void  pdfapp_onkey(     pdfapp *app, int c);
void  pdfapp_onmouse(   pdfapp *app, int x, int y, int btn, int modifiers, int state);
void  pdfapp_oncopy(    pdfapp *app, unsigned short *ucsbuf, int ucslen);
void  pdfapp_onresize(  pdfapp *app, int w, int h);
void  pdfapp_invert(    pdfapp *app, fz_bbox rect);
void  pdfapp_inverthit( pdfapp *app);
