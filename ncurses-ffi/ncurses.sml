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

        val newwin = _import "mffi_newwin": (int * int * int * int) -> Win;
        val derwin = _import "mffi_derwin": (Win * int * int * int * int) -> Win;
        val delwin = _import "mffi_delwin": Win -> unit;
        val box = _import "mffi_box": (Win * int * int) -> unit;
        val wborder = _import "mffi_wborder":
                (Win * int * int * int * int * int * int * int * int ) -> unit;
        val wmove = _import "mffi_wmove": Win * int * int -> unit;
        val touchwin = _import "mffi_touchwin": Win -> unit;

        val wgetch = _import "mffi_wgetch": Win -> char;
        val waddnstr = _import "mffi_waddnstr": Win * string * int -> unit;
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

    fun init () =
        let val win = FFI.initscr ()
        in  FFI.cbreak ();
            FFI.noecho ();
            FFI.wclear win;
            if (FFI.has_colors () = 1) then FFI.start_color () else ();
            win
        end

    fun newwin (Pos (y, x)) (Height h) (Width w) = FFI.newwin (h, w, y, x)
    fun subwin win (Pos (y, x)) (Height h) (Width w) = FFI.derwin (win, h, w, y, x)
    fun box win = FFI.box (win, 0, 0)

    val refresh = FFI.wrefresh

    fun delwin win =
        let val SP = Char.ord #" "
        in  (*FFI.wborder (win, SP, SP, SP, SP, SP, SP, SP, SP);
            FFI.wrefresh win;*)
            FFI.delwin win
        end

    val shutdown = FFI.endwin
    val getch = FFI.wgetch
    fun putstr win s = FFI.waddnstr (win, s, size s)
    fun move win (Pos (y, x)) = FFI.wmove (win, y, x)
    val touch = FFI.touchwin
end

structure NC = NCurses;

let val win = NC.init ();
    val sw = NC.newwin (NC.Pos (10, 10)) (NC.Height 10) (NC.Width 30);
in  NC.box sw;
    NC.move sw (NC.Pos (1, 1));
    NC.putstr sw "This is a test";
    NC.refresh sw;
    NC.getch sw;
    NC.delwin sw;
    NC.refresh win;
    NC.getch win;
    NC.shutdown ()
end
