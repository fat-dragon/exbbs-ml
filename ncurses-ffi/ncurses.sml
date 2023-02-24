(* ncurses interface from SML *)
(* Uses MLton FFI *)
(* Author: Dan Cross <cross@fat-dragon.org> *)

structure NCurses = struct
    structure FFI = struct
        type Win = MLton.Pointer.t;
        val initscr = _import "mffi_initscr": unit -> Win;
        val cbreak = _import "mffi_cbreak": unit -> unit;
        val noecho = _import "mffi_noecho": unit -> unit;
        val wclear = _import "mffi_wclear": Win -> unit;
        val endwin = _import "mffi_endwin": unit -> unit;
        val wrefresh = _import "mffi_wrefresh": Win -> unit;

        val subwin = _import "mffi_subwin": (Win * int * int * int * int) -> Win;
        val delwin = _import "mffi_delin": Win -> unit;
        val box = _import "mffi_box": (Win * int * int) -> unit;

        val wgetch = _import "mffi_wgetch": Win -> char;
        val has_colors = _import "mffi_has_colors": unit -> int;
        val start_color = _import "mffi_start_color": unit -> unit;
        val printcolors = _import "mffi_printcolors": unit -> unit;

        val COLOR_BLACK = _import "MFFI_COLOR_BLACK": unit -> int;
        val COLOR_RED = _import "MFFI_COLOR_RED": unit -> int;
        val COLOR_GREEN = _import "MFFI_COLOR_GREEN": unit -> int;
        val COLOR_YELLOW = _import "MFFI_COLOR_YELLOW": unit -> int;
        val COLOR_BLUE = _import "MFFI_COLOR_BLUE": unit -> int;
        val COLOR_MAGENTA = _import "MFFI_COLOR_MAGENTA": unit -> int;
        val COLOR_CYAN = _import "MFFI_COLOR_CYAN": unit -> int;
        val COLOR_WHITE = _import "MFFI_COLOR_WHITE": unit -> int;
    end

    type Win = FFI.Win

    datatype height = Height of int
    datatype width = Width of int
    datatype pos = Pos of int * int

    fun init () = let
            val win = FFI.initscr ();
            val () = FFI.cbreak ();
            val () = FFI.noecho ();
            val () = FFI.wclear win;
            val () = if (FFI.has_colors () = 1) then FFI.start_color () else ();
        in
            win
        end

    fun subwin win (Pos (x, y)) (Height h) (Width w) = FFI.subwin (win, h, w, y, x)
    fun box win = FFI.box (win, 0, 0)

    val refresh = FFI.wrefresh

    val delwin = FFI.delwin

    val shutdown = FFI.endwin
    val getch = FFI.wgetch
end

structure NC = NCurses

val win = NC.init ()
val sw = NC.subwin win (NC.Pos (10, 10)) (NC.Height 10) (NC.Width 30)
val _ = NC.box sw
val _ = NC.refresh win
val c = NC.getch win
val _ = NC.shutdown ()
