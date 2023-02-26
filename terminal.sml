(* Terminal handling *)
(* Author: Dan Cross <cross@fat-dragon.org> *)

structure Terminal = struct
    val ESC = chr 0x1b
    val CSI = (str ESC) ^ "["
    val HomeSeq = CSI ^ "H"
    fun GotoXYSeq x y = CSI ^ Int.toString(x) ^ ";" ^ Int.toString(y) ^ "H"
    fun GotoRowSeq n = CSI ^ Int.toString(n) ^ ";H"
    fun GotoColumnSeq m = CSI ^ Int.toString(m) ^ "G"
    val EraseToEOLSeq = CSI ^ "K"
    val EraseToBOLSeq = CSI ^ "1K"
    val EraseLineSeq = CSI ^ "2K"
    val InsertLineSeq = CSI ^ "L"
    fun InsertLinesSeq n = CSI ^ Int.toString(n) ^ "L"
    val DeleteLineSeq = CSI ^ "M"
    fun DeleteLinesSeq n = CSI ^ Int.toString(n) ^ "M"
    val DeleteCharSeq = CSI ^ "P"
    fun DeleteCharsSeq n = CSI ^ Int.toString(n) ^ "P"
    val EraseToBottomSeq = CSI ^ "J"
    val EraseToTopSeq = CSI ^ "1J"
    val EraseCharSeq = CSI ^ "X"
    fun EraseCharsSeq n = CSI ^ Int.toString(n) ^ "X"
    val ClearSeq = CSI ^ "2J"
    val ResetSeq = CSI ^ "0m"
    fun InsertChar c = CSI ^ "@" ^ str(c)
    fun InsertStr s = CSI ^ Int.toString(size s) ^ "@" ^ s
    val SetInsertModeSeq = CSI ^ "4h"
    val SetOverwriteModeSeq = CSI ^ "4l"

    datatype Colors =
        Black | Red | Green | Yellow | Blue | Magenta | Cyan | White
      | BrightBlack | BrightRed | BrightGreen | BrightYellow
      | BrightBlue | BrightMagenta | BrightCyan | BrightWhite
      | ExtendedColor of int

    fun colorsCode Black = 30
      | colorsCode Red = 31
      | colorsCode Green = 32
      | colorsCode Yellow = 33
      | colorsCode Blue = 34
      | colorsCode Magenta = 35
      | colorsCode Cyan = 36
      | colorsCode White = 37
      | colorsCode BrightBlack = 90
      | colorsCode BrightRed = 91
      | colorsCode BrightGreen = 92
      | colorsCode BrightYellow = 93
      | colorsCode BrightBlue = 94
      | colorsCode BrightMagenta = 95
      | colorsCode BrightCyan = 96
      | colorsCode BrightWhite = 97
      | colorsCode (ExtendedColor cc) = cc

    fun fgSeq BrightBlack = "1;30"
      | fgSeq BrightRed = "1;31"
      | fgSeq BrightGreen = "1;32"
      | fgSeq BrightYellow = "1;33"
      | fgSeq BrightBlue = "1;34"
      | fgSeq BrightMagenta = "1;35"
      | fgSeq BrightCyan = "1;36"
      | fgSeq BrightWhite = "1;37"
      | fgSeq c = Int.toString (colorsCode c)

    fun bgSeq BrightBlack = "1;40"
      | bgSeq BrightRed = "1;41"
      | bgSeq BrightGreen = "1;42"
      | bgSeq BrightYellow = "1;43"
      | bgSeq BrightBlue = "1;44"
      | bgSeq BrightMagenta = "1;45"
      | bgSeq BrightCyan = "1;46"
      | bgSeq BrightWhite = "1;47"
      | bgSeq (c as ExtendedColor _) = Int.toString (colorsCode c)
      | bgSeq c = Int.toString (colorsCode c + 10)

    val AIXTERM = true

    fun foregroundColorStr (ExtendedColor f) = "38;5;" ^ Int.toString(f)
      | foregroundColorStr f =
            if AIXTERM then Int.toString (colorsCode f)
            else fgSeq f

    fun backgroundColorStr (ExtendedColor b) = "48;5;" ^ Int.toString(b)
      | backgroundColorStr b =
            if AIXTERM then Int.toString (colorsCode b + 10)
            else bgSeq b

    fun colorStr f b = (foregroundColorStr f) ^ ";" ^ (backgroundColorStr b)

    fun ForegroundColorSeq c = CSI ^ foregroundColorStr c ^ "m"
    fun BackgroundColorSeq c = CSI ^ backgroundColorStr c ^ "m"
    fun ColorSeq f b = CSI ^ colorStr f b ^ "m"

    (*
     * Put the terminal into "BBS" mode: this is a modified raw
     * mode that leaves some minor processing enabled (e.g.,
     * converting \r\n sequences to newlines on input, and otherwise
     * ignoring carriage returns; enabling character-at-a-time
     * input, etc.
     *)
    fun setTermMode fd =
        let open Posix.TTY

            (* Retrieve existing terminal attributes *)
            val attr = TC.getattr fd

            (* Functionally create terminal attributes for raw mode *)
            val attrIFlag = Posix.TTY.getiflag attr
            val rawIFlagC =
                I.flags
                    [ (*I.maxbel,*) I.ignbrk, I.brkint, I.parmrk,
                      I.istrip, I.inlcr, I.igncr, I.icrnl, I.ixon ]
            val iflag = I.clear (rawIFlagC, attrIFlag)
            val iflag = I.flags [ iflag, I.icrnl ]

            val attrOFlag = getoflag attr
            val rawOFlagC = O.flags [ (* O.opost *) ]
            val oflag = O.clear (rawOFlagC, attrOFlag)

            val attrCFlag = getcflag attr
            val rawCFlagC = C.flags [ C.csize, C.parenb ]
            val cflag = C.clear (rawCFlagC, attrCFlag)
            val cflag = C.flags [ cflag, C.cs8 ]

            val attrLFlag = getlflag attr
            val rawLFlagC = L.flags [ L.echo, L.echonl, L.icanon, L.isig, L.iexten ]
            val lflag = L.clear (rawLFlagC, attrLFlag)

            val attrCC = getcc attr
            val rawCC = [(V.min, chr(1)), (V.time, chr(0))]
            val cc = V.update (attrCC, rawCC)

            val rawModeAttr =
                termios {
                    iflag = iflag,
                    oflag = oflag,
                    cflag = cflag,
                    lflag = lflag,
                    cc = cc,
                    ispeed = CF.getispeed attr,
                    ospeed = CF.getospeed attr
                }
        in  TC.setattr (fd, TC.sanow, rawModeAttr);
            attr
        end

    (* Resets terminal attributes to specified values. *)
    fun resetTerm fd attrs =
        Posix.TTY.TC.setattr (fd, Posix.TTY.TC.sanow, attrs)
end
