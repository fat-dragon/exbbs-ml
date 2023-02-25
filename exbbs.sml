(* ExBBS - an Experimental BBS program *)
(* Author: Dan Cross <cross@fat-dragon.org> *)
(* SML version *)

datatype Menus = Main | Messages | Mail;

fun menu(Main) = print "Main menu\n"
  | menu(Messages) = print "Messages menu\n"
  | menu(Mail) = print "Mail menu\n"

fun main() =
    let val config = Config.read "config.json5"
        val savedTermMode = Terminal.setTermMode Posix.FileSys.stdin
    in  print (Terminal.ClearSeq ^ Terminal.HomeSeq);
        print (Terminal.ColorSeq Terminal.BrightBlue (Terminal.ExtendedColor 232));
        print ("Welcome to " ^ (#name config) ^ "\n");
        print ("Your host: " ^ (#admin config) ^ "\n");
        print ("Online at " ^ (#proto config) ^ "://" ^ (#host config) ^ ":" ^ Int.toString (#port config) ^ "\n");
        Terminal.resetTerm Posix.FileSys.stdin savedTermMode
    end

val _ = main()
