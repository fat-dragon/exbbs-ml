// Provides "FFI"-able symbols for importing into SML.
// Functions are mapped as functions, constants will be
// mapped to SML variables.

#include <assert.h>
#include <curses.h>
#include <locale.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "ffi.h"

// Because of the way the ncurses library implements many of
// these constants, we cannot simply assign them to global
// variables that we then import as symbols and extract the
// value of in SML; they are not valid compile-time constants.
// So instead we wrap them in small functions that we import
// and call.

// Colors
int MFFI_COLOR_BLACK(void) { return COLOR_BLACK; }
int MFFI_COLOR_RED(void) { return COLOR_RED; }
int MFFI_COLOR_GREEN(void) { return COLOR_GREEN; }
int MFFI_COLOR_YELLOW(void) { return COLOR_YELLOW; }
int MFFI_COLOR_BLUE(void) { return COLOR_BLUE; }
int MFFI_COLOR_MAGENTA(void) { return COLOR_MAGENTA; }
int MFFI_COLOR_CYAN(void) { return COLOR_CYAN; }
int MFFI_COLOR_WHITE(void) { return COLOR_WHITE; }

// Display attributes
int MFFI_A_ATTRIBUTES(void) { return A_ATTRIBUTES; }
int MFFI_A_NORMAL(void) { return A_NORMAL; }
int MFFI_A_STANDOUT(void) { return A_STANDOUT; }
int MFFI_A_UNDERLINE(void) { return A_UNDERLINE; }
int MFFI_A_REVERSE(void) { return A_REVERSE; }
int MFFI_A_BLINK(void) { return A_BLINK; }
int MFFI_A_DIM(void) { return A_DIM; }
int MFFI_A_BOLD(void) { return A_BOLD; }
int MFFI_A_ALTCHARSET(void) { return A_ALTCHARSET; }
int MFFI_A_INVIS(void) { return A_INVIS; }
int MFFI_A_PROTECT(void) { return A_PROTECT; }
int MFFI_A_HORIZONTAL(void) { return A_HORIZONTAL; }
int MFFI_A_LEFT(void) { return A_LEFT; }
int MFFI_A_LOW(void) { return A_LOW; }
int MFFI_A_RIGHT(void) { return A_RIGHT; }
int MFFI_A_TOP(void) { return A_TOP; }
int MFFI_A_VERTICAL(void) { return A_VERTICAL; }

// Character set attributes (for pseudo-graphics)
int MFFI_ACS_ULCORNER(void) { return ACS_ULCORNER; }
int MFFI_ACS_URCORNER(void) { return ACS_URCORNER; }
int MFFI_ACS_LLCORNER(void) { return ACS_LLCORNER; }
int MFFI_ACS_LRCORNER(void) { return ACS_LRCORNER; }
int MFFI_ACS_LTEE(void) { return ACS_LTEE; }
int MFFI_ACS_RTEE(void) { return ACS_RTEE; }
int MFFI_ACS_BTEE(void) { return ACS_BTEE; }
int MFFI_ACS_TTEE(void) { return ACS_TTEE; }
int MFFI_ACS_HLINE(void) { return ACS_HLINE; }
int MFFI_ACS_VLINE(void) { return ACS_VLINE; }
int MFFI_ACS_PLUS(void) { return ACS_PLUS; }
int MFFI_ACS_S1(void) { return ACS_S1; }
int MFFI_ACS_S9(void) { return ACS_S9; }
int MFFI_ACS_DIAMOND(void) { return ACS_DIAMOND; }
int MFFI_ACS_CKBOARD(void) { return ACS_CKBOARD; }
int MFFI_ACS_DEGREE(void) { return ACS_DEGREE; }
int MFFI_ACS_PLMINUS(void) { return ACS_PLMINUS; }
int MFFI_ACS_BULLET(void) { return ACS_BULLET; }

// Supposedly teletype 5410v1 symbols
int MFFI_ACS_LARROW(void) { return ACS_LARROW; }
int MFFI_ACS_RARROW(void) { return ACS_RARROW; }
int MFFI_ACS_DARROW(void) { return ACS_DARROW; }
int MFFI_ACS_UARROW(void) { return ACS_UARROW; }
int MFFI_ACS_BOARD(void) { return ACS_BOARD; }
int MFFI_ACS_LANTERN(void) { return ACS_LANTERN; }
int MFFI_ACS_BLOCK(void) { return ACS_BLOCK; }

// System V extensions
int MFFI_ACS_S3(void) { return ACS_S3; }
int MFFI_ACS_S7(void) { return ACS_S7; }
int MFFI_ACS_LEQUAL(void) { return ACS_LEQUAL; }
int MFFI_ACS_GEQUAL(void) { return ACS_GEQUAL; }
int MFFI_ACS_PI(void) { return ACS_PI; }
int MFFI_ACS_NEQUAL(void) { return ACS_NEQUAL; }
int MFFI_ACS_STERLING(void) { return ACS_STERLING; }

// For line-drawing?
int MFFI_ACS_BSSB(void) { return ACS_BSSB; }
int MFFI_ACS_SSBB(void) { return ACS_SSBB; }
int MFFI_ACS_BBSS(void) { return ACS_BBSS; }
int MFFI_ACS_SBBS(void) { return ACS_SBBS; }
int MFFI_ACS_SBSS(void) { return ACS_SBSS; }
int MFFI_ACS_SSSB(void) { return ACS_SSSB; }
int MFFI_ACS_SSBS(void) { return ACS_SSBS; }
int MFFI_ACS_BSSS(void) { return ACS_BSSS; }
int MFFI_ACS_BSBS(void) { return ACS_BSBS; }
int MFFI_ACS_SBSB(void) { return ACS_SBSB; }
int MFFI_ACS_SSSS(void) { return ACS_SSSS; }

static int
try(int status, const char *fmt, ...)
{
	va_list ap;

	if (status != ERR)
		return status;

	if (endwin() != OK)
		fprintf(stderr, "endwin failed\n");

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	exit(EXIT_FAILURE);
}

static void *
tryp(void *p, const char *fmt, ...)
{
	va_list ap;

	if (p != NULL)
		return p;

	if (endwin() != OK)
		fprintf(stderr, "endwin failed\n");

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	exit(EXIT_FAILURE);
}

void mffi_setlocale() { setlocale(LC_ALL, ""); }

void *mffi_initscr(void) { return initscr(); }
void mffi_noecho(void) { try(noecho(), "noecho failed\n"); }
void mffi_echo(void) { try(echo(), "echo failed\n"); }
void mffi_cbreak(void) { try(cbreak(), "cbreak failed\n"); }
void mffi_wclear(void *win) { try(wclear(win), "clear failed\n"); }
void mffi_delwin(void *win) { try(delwin(win), "delwin failed\n"); }
void mffi_endwin(void) { try(endwin(), "endwin failed\n"); }
void mffi_wmove(void *win, int y, int x) { try(wmove(win, y, x), "wmove failed\n"); }

int mffi_wgetch(void *win) { return try(wgetch(win), "fetch failed\n"); }
void
mffi_wgetnstr(void *win, void *p, int n)
{
	try(wgetnstr(win, p, n), "wgetnstr failed");
}

void
mffi_waddnstr(void *win, const char *s, int n)
{
	try(waddnstr(win, s, n), "waddnstr failed");
}

void *
mffi_newwin(int h, int w, int y, int x)
{
	return tryp(newwin(h, w, y, x),
	    "subwin(%d, %d, %d, %d) failed", h, w, y, x);
}
void *
mffi_derwin(void *win, int h, int w, int y, int x)
{
	return tryp(derwin(win, h, w, y, x),
	    "subwin(%p, %d, %d, %d, %d) failed",
	    win, h, w, y, x);
}
void mffi_box(void *win, int vch, int hch) { try(box(win, vch, hch), "box failed\n"); }
void
mffi_wborder(void *win, int l, int r, int u, int b, int ul, int ur, int bl, int br)
{
	try(wborder(win, l, r, u, b, ul, ur, bl, br), "wborder failed\n");
}
void mffi_wrefresh(void *win) { try(wrefresh(win), "wrefresh failed\n"); }
void mffi_wnoutrefresh(void *win) { try(wnoutrefresh(win), "wnoutrefresh failed\n"); }
void mffi_doupdate(void) { try(doupdate(), "doupdate failed\n"); }
void mffi_touchwin(void *win) { WINDOW *w = win; try(touchwin(w), "touchwin failed\n"); }

int mffi_has_colors(void) { return has_colors() == TRUE; }
void mffi_start_color(void) { try(start_color(), "start_color failed\n"); }
