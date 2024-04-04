(* ncurses interface from SML *)
(* Uses MLton FFI *)
(* Author: Dan Cross <cross@fat-dragon.org> *)

structure NCurses = struct
    structure FFI = struct
        type Win = MLton.Pointer.t;
        val setlocale = _import "mffi_setlocale": unit -> unit;
        val initscr = _import "mffi_initscr": unit -> Win;
        val cbreak = _import "mffi_cbreak": unit -> unit;
        val noecho = _import "mffi_noecho": unit -> unit;
        val echo = _import "mffi_echo": unit -> unit;
        val wclear = _import "mffi_wclear": Win -> unit;
        val idlok = _import "mffi_idlok": Win -> unit;
        val scrollok = _import "mffi_scrollok": Win -> unit;
        val endwin = _import "mffi_endwin": unit -> unit;
        val wrefresh = _import "mffi_wrefresh": Win -> unit;
        val wnoutrefresh = _import "mffi_wnoutrefresh": Win -> unit;
        val doupdate = _import "mffi_doupdate": unit -> unit;
        val resizeterm = _import "mffi_resizeterm": (int * int) -> unit;

        val newwin = _import "mffi_newwin": (int * int * int * int) -> Win;
        val derwin = _import "mffi_derwin": (Win * int * int * int * int) -> Win;
        val delwin = _import "mffi_delwin": Win -> unit;
        val box = _import "mffi_box": (Win * int * int) -> unit;
        val wborder = _import "mffi_wborder":
                (Win * int * int * int * int * int * int * int * int ) -> unit;
        val wmove = _import "mffi_wmove": Win * int * int -> unit;
        val touchwin = _import "mffi_touchwin": Win -> unit;

        val wgetch = _import "mffi_wgetch": Win -> char;
        val wgetnstr = _import "mffi_wgetnstr": Win * C_UChar.t array * int -> unit;
        val waddnstr = _import "mffi_waddnstr": Win * string * int -> unit;
        val has_colors = _import "mffi_has_colors": unit -> int;
        val start_color = _import "mffi_start_color": unit -> unit;

        (* Colors *)
        val COLOR_BLACK = _import "MFFI_COLOR_BLACK": unit -> int;
        val COLOR_RED = _import "MFFI_COLOR_RED": unit -> int;
        val COLOR_GREEN = _import "MFFI_COLOR_GREEN": unit -> int;
        val COLOR_YELLOW = _import "MFFI_COLOR_YELLOW": unit -> int;
        val COLOR_BLUE = _import "MFFI_COLOR_BLUE": unit -> int;
        val COLOR_MAGENTA = _import "MFFI_COLOR_MAGENTA": unit -> int;
        val COLOR_CYAN = _import "MFFI_COLOR_CYAN": unit -> int;
        val COLOR_WHITE = _import "MFFI_COLOR_WHITE": unit -> int;

        (* ACS *)
        val ACS_ULCORNER = _import "MFFI_ACS_ULCORNER": unit -> int;
        val ACS_URCORNER = _import "MFFI_ACS_URCORNER": unit -> int;
        val ACS_LLCORNER = _import "MFFI_ACS_LLCORNER": unit -> int;
        val ACS_LRCORNER = _import "MFFI_ACS_LRCORNER": unit -> int;
        val ACS_LTEE = _import "MFFI_ACS_LTEE": unit -> int;
        val ACS_RTEE = _import "MFFI_ACS_RTEE": unit -> int;
        val ACS_BTEE = _import "MFFI_ACS_BTEE": unit -> int;
        val ACS_TTEE = _import "MFFI_ACS_TTEE": unit -> int;
        val ACS_HLINE = _import "MFFI_ACS_HLINE": unit -> int;
        val ACS_VLINE = _import "MFFI_ACS_VLINE": unit -> int;
        val ACS_PLUS = _import "MFFI_ACS_PLUS": unit -> int;
        val ACS_S1 = _import "MFFI_ACS_S1": unit -> int;
        val ACS_S9 = _import "MFFI_ACS_S9": unit -> int;
        val ACS_DIAMOND = _import "MFFI_ACS_DIAMOND": unit -> int;
        val ACS_CKBOARD = _import "MFFI_ACS_CKBOARD": unit -> int;
        val ACS_DEGREE = _import "MFFI_ACS_DEGREE": unit -> int;
        val ACS_PLMINUS = _import "MFFI_ACS_PLMINUS": unit -> int;
        val ACS_BULLET = _import "MFFI_ACS_BULLET": unit -> int;
        val ACS_LARROW = _import "MFFI_ACS_LARROW": unit -> int;
        val ACS_RARROW = _import "MFFI_ACS_RARROW": unit -> int;
        val ACS_DARROW = _import "MFFI_ACS_DARROW": unit -> int;
        val ACS_UARROW = _import "MFFI_ACS_UARROW": unit -> int;
        val ACS_BOARD = _import "MFFI_ACS_BOARD": unit -> int;
        val ACS_LANTERN = _import "MFFI_ACS_LANTERN": unit -> int;
        val ACS_BLOCK = _import "MFFI_ACS_BLOCK": unit -> int;
        val ACS_S3 = _import "MFFI_ACS_S3": unit -> int;
        val ACS_S7 = _import "MFFI_ACS_S7": unit -> int;
        val ACS_LEQUAL = _import "MFFI_ACS_LEQUAL": unit -> int;
        val ACS_GEQUAL = _import "MFFI_ACS_GEQUAL": unit -> int;
        val ACS_PI = _import "MFFI_ACS_PI": unit -> int;
        val ACS_NEQUAL = _import "MFFI_ACS_NEQUAL": unit -> int;
        val ACS_STERLING = _import "MFFI_ACS_STERLING": unit -> int;
        val ACS_BSSB = _import "MFFI_ACS_BSSB": unit -> int;
        val ACS_SSBB = _import "MFFI_ACS_SSBB": unit -> int;
        val ACS_BBSS = _import "MFFI_ACS_BBSS": unit -> int;
        val ACS_SBBS = _import "MFFI_ACS_SBBS": unit -> int;
        val ACS_SBSS = _import "MFFI_ACS_SBSS": unit -> int;
        val ACS_SSSB = _import "MFFI_ACS_SSSB": unit -> int;
        val ACS_SSBS = _import "MFFI_ACS_SSBS": unit -> int;
        val ACS_BSSS = _import "MFFI_ACS_BSSS": unit -> int;
        val ACS_BSBS = _import "MFFI_ACS_BSBS": unit -> int;
        val ACS_SBSB = _import "MFFI_ACS_SBSB": unit -> int;
        val ACS_SSSS = _import "MFFI_ACS_SSSS": unit -> int;

        (* Tracking window size *)
        val LINES = _import "MFFI_LINES": unit -> int;
        val COLS = _import "MFFI_COLS": unit -> int;

	val KEY_RESIZE = _import "MFFI_KEY_RESIZE": unit -> int;

        val NUL = C_UChar.fromInt 0x0
        val EOF = 0x4
        val NL = 0xA
        val CR = 0xD
        val SP = 0x20
    end

    structure FFIUtils = struct
        fun cstrlen cstr =
            case Array.findi (fn (_, c) => c = FFI.NUL) cstr of
                SOME((k, _)) => k
              | NONE => Array.length cstr

        fun cstrToString cstr =
            let val ba = ArraySlice.slice (cstr, 0, SOME(cstrlen cstr));
                val cs = ArraySlice.foldr (fn (b, l) => (Byte.byteToChar b)::l) [] ba;
            in  String.implode cs
            end

        fun intToBool b = b <> 0
    end

    structure Acs = struct
        val ULCORNER = FFI.ACS_ULCORNER;
        val URCORNER = FFI.ACS_URCORNER;
        val LLCORNER = FFI.ACS_LLCORNER;
        val LRCORNER = FFI.ACS_LRCORNER;
        val LTEE = FFI.ACS_LTEE;
        val RTEE = FFI.ACS_RTEE;
        val BTEE = FFI.ACS_BTEE;
        val TTEE = FFI.ACS_TTEE;
        val HLINE = FFI.ACS_HLINE;
        val VLINE = FFI.ACS_VLINE;
        val PLUS = FFI.ACS_PLUS;
        val S1 = FFI.ACS_S1;
        val S9 = FFI.ACS_S9;
        val DIAMOND = FFI.ACS_DIAMOND;
        val CKBOARD = FFI.ACS_CKBOARD;
        val DEGREE = FFI.ACS_DEGREE;
        val PLMINUS = FFI.ACS_PLMINUS;
        val BULLET = FFI.ACS_BULLET;
        val LARROW = FFI.ACS_LARROW;
        val RARROW = FFI.ACS_RARROW;
        val DARROW = FFI.ACS_DARROW;
        val UARROW = FFI.ACS_UARROW;
        val BOARD = FFI.ACS_BOARD;
        val LANTERN = FFI.ACS_LANTERN;
        val BLOCK = FFI.ACS_BLOCK;
        val S3 = FFI.ACS_S3;
        val S7 = FFI.ACS_S7;
        val LEQUAL = FFI.ACS_LEQUAL;
        val GEQUAL = FFI.ACS_GEQUAL;
        val PI = FFI.ACS_PI;
        val NEQUAL = FFI.ACS_NEQUAL;
        val STERLING = FFI.ACS_STERLING;
        val BSSB = FFI.ACS_BSSB;
        val SSBB = FFI.ACS_SSBB;
        val BBSS = FFI.ACS_BBSS;
        val SBBS = FFI.ACS_SBBS;
        val SBSS = FFI.ACS_SBSS;
        val SSSB = FFI.ACS_SSSB;
        val SSBS = FFI.ACS_SSBS;
        val BSSS = FFI.ACS_BSSS;
        val BSBS = FFI.ACS_BSBS;
        val SBSB = FFI.ACS_SBSB;
        val SSSS = FFI.ACS_SSSS;

        fun Space () = FFI.SP
    end

    fun dim () = (FFI.LINES (), FFI.COLS ())

    type Win = FFI.Win

    datatype height = Ht of int
    datatype width = Wd of int
    datatype pos = Pos of int * int

    val NUL = #"\000"
    val EOF = #"\004"
    val BS = #"\b"
    val DEL = #"\b"
    val NL = #"\n"
    val CR = #"\r"
    val SP = #" "

    fun init () =
        let val win = FFI.initscr ()
            val has_colors = FFIUtils.intToBool o FFI.has_colors
        in  FFI.cbreak ();
            FFI.noecho ();
            FFI.wclear win;
            if has_colors () then FFI.start_color () else ();
            win
        end


    fun newwin (Pos (y, x)) (Ht h) (Wd w) = FFI.newwin (h, w, y, x)
    fun subwin win (Pos (y, x)) (Ht h) (Wd w) = FFI.derwin (win, h, w, y, x)
    fun box win = FFI.box (win, 0, 0)
    fun aborder win l r t b ul ur ll lr =
        FFI.wborder (win, l (), r (), t (), (b ()), (ul ()), (ur ()), (ll ()), (lr ()))
    fun border win l r t b ul ur ll lr =
        let val ord = Char.ord
        in  FFI.wborder (win,
                (ord l), (ord r), (ord t), (ord b),
                (ord ul), (ord ur), (ord ll), (ord lr))
        end
    val clear = FFI.wclear
    val delwin = FFI.delwin

    val refresh = FFI.wrefresh

    val shutdown = FFI.endwin
    val getch = FFI.wgetch
    fun getche win = (
        FFI.echo ();
        FFI.wgetch win before FFI.noecho ()
    )
    fun putstr win s = FFI.waddnstr (win, s, size s)
    fun wreadln win buf = (
        FFI.echo ();
        FFI.wgetnstr (win, buf, Array.length buf);
        FFI.noecho ();
        buf
    )
    fun getstr win maxLen =
        let val buf = Array.array (maxLen, FFI.NUL)
        in  FFIUtils.cstrToString (wreadln win buf)
        end
    fun readline win =
        let fun next () = getche win
            fun loop #"\004" cs = cs
              | loop #"\n" cs = cs
              | loop #"\r" cs = cs
              | loop #"\b" [] = loop (next ()) []
              | loop #"\b" (c::cs) = loop (next ()) cs
              | loop c cs = loop (next ()) (c::cs)
            val line = loop (next ()) []
        in  String.implode (List.rev line)
        end
    fun move win (Pos (y, x)) = FFI.wmove (win, y, x)
    val touch = FFI.touchwin
    val update = FFI.wnoutrefresh
    val flush = FFI.doupdate

    fun scrolling w = (FFI.idlok w; FFI.scrollok w)
end

structure NC = NCurses;

let val w = NC.init ();
    val prompt = "CHOICE ===> "
    val (lines, columns) = NC.dim ()
    val statusPos = NC.Pos (lines - 7, 1)
    val promptPos = NC.Pos (lines - 2, 1)
    val systemPos = NC.Pos (lines - 1, columns - 14)
    val menuHt = lines - 7 + 1
    val menuWd = columns - 2
    val mw = NC.newwin (NC.Pos (0, 1)) (NC.Ht menuHt) (NC.Wd menuWd)
    val menu = NC.subwin mw (NC.Pos (1, 2)) (NC.Ht (menuHt - 2)) (NC.Wd (menuWd - 4))
    val tw = NC.newwin statusPos (NC.Ht 5) (NC.Wd menuWd)
    val pw = NC.newwin promptPos (NC.Ht 1) (NC.Wd menuWd)
    val iw = NC.subwin pw (NC.Pos (0, size prompt)) (NC.Ht 1) (NC.Wd (menuWd - 14))
    val sw = NC.newwin systemPos (NC.Ht 1) (NC.Wd 20)
    fun loop w i =
        let val s = NC.getstr i 256 before NC.clear i
        in  if s <> "" then
                (NC.putstr w (s ^ "\n");
                NC.update w;
                NC.flush ();
                loop w i)
            else ()
        end
in  NC.box mw;
    NC.move mw (NC.Pos (0, 2));
    NC.putstr mw "///+. M A I N  M E N U .+\\\\\\";
    NC.scrolling menu;
    NC.putstr menu "This is a menu.\n";
    NC.putstr menu "This is a menu line.\n";
    NC.aborder tw NC.Acs.VLINE NC.Acs.VLINE NC.Acs.HLINE NC.Acs.HLINE NC.Acs.LTEE NC.Acs.RTEE NC.Acs.LLCORNER NC.Acs.LRCORNER;
    NC.move tw (NC.Pos (0, 2));
    NC.putstr tw "\\\\\\+. S Y S T E M  S T A T U S .+///";
    NC.putstr sw "ExBBS RUNNING";
    NC.putstr pw prompt;
    NC.update mw;
    NC.update tw;
    NC.update sw;
    NC.update pw;
    NC.update menu;
    NC.flush ();
    loop menu iw;
    NC.putstr iw (NC.readline pw);
    NC.getche iw;
    NC.delwin iw;
    NC.delwin pw;
    NC.delwin menu;
    NC.delwin mw;
    NC.delwin sw;
    NC.shutdown ()
end
