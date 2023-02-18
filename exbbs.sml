(* ExBBS - an Experimental BBS program *)
(* Author: Dan Cross <cross@fat-dragon.org> *)
(* SML version *)

datatype Menus = Main | Messages | Mail;

fun menu(Main) = print "Main menu\n"
  | menu(Messages) = print "Messages menu\n"
  | menu(Mail) = print "Mail menu\n"

fun main() =
    let
        val config = Config.read("config.json5")
        val savedTermMode = Terminal.setTermMode Posix.FileSys.stdin
        val vec = Posix.IO.readVec(Posix.FileSys.stdin, 16)
    in
        print (Terminal.ClearSeq ^ Terminal.HomeSeq);
        print (Terminal.ColorSeq Terminal.BrightBlue (Terminal.ExtendedColor 232));
        print "This is a lame BBS\n";
        menu(Main);
        menu(Messages);
        menu(Mail);
        print ("name:  " ^ (#name config) ^ "\n");
        print ("admin: " ^ (#admin config) ^ "\n");
        print ("host:  " ^ (#host config) ^ "\n");
        print ("port:  " ^ Int.toString (#port config) ^ "\n");
        print (Terminal.GotoXYSeq 1 10);
        print (Terminal.DeleteCharsSeq 5);
        print (Terminal.ColorSeq Terminal.BrightGreen (Terminal.ExtendedColor 232));
        (*print (Terminal.ColorSeq Terminal.BrightGreen Terminal.Blue);*)
        print (Terminal.InsertStr " really really cool");
        print (Terminal.ColorSeq Terminal.BrightBlue (Terminal.ExtendedColor 232));
        print (Terminal.GotoXYSeq 9 1);
        print (Terminal.ResetSeq);
        print ("Read earlier: |" ^ (Byte.bytesToString vec) ^"|\n");
        Terminal.resetTerm Posix.FileSys.stdin savedTermMode
    end

val _ = main()
