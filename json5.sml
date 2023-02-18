(* JSON5 parser *)
(* Author: Dan Cross <cross@fat-dragon.org> *)

structure JSON5Types = struct
    type Identifier = string

    datatype Key = KeyIdentifier of Identifier | KeyString of string
    and Value =
        Null
      | Boolean of bool
      | String of string
      | Int of int
      | Real of real
      | Object of (Key * Value) list
      | Array of Value list

    exception Exception of string
end

signature JSON5 = sig
    type Identifier = JSON5Types.Identifier

    datatype Key = datatype JSON5Types.Key
    datatype Value = datatype JSON5Types.Value

    exception Exception of string

    val parse : string -> Value
    val idToString : string -> Value -> string
    val idToInt : string -> Value -> int
    val unwrapObject : Value -> (Key * Value) list
end

structure JSON5 :> JSON5 = struct
    open JSON5Types

    datatype Token =
        TokLBrace
      | TokRBrace
      | TokLBracket
      | TokRBracket
      | TokColon
      | TokComma
      | TokNull
      | TokBool of bool
      | TokStr of string
      | TokId of string
      | TokInt of int
      | TokReal of real

    val skipWS = Substring.dropl Char.isSpace
    val next = Substring.getc
    val peek = Substring.first
    val rest = Substring.triml 1
    val toString = String.implode o List.rev
    fun startNum c = c = #"+" orelse c = #"-" orelse c = #"." orelse Char.isDigit c
    fun startWord c = c = #"$" orelse c = #"_" orelse Char.isAlpha c
    fun scan cs =
        let val cs = skipWS cs
        in  case peek cs of
                NONE => NONE
              | SOME(#"{")  => SOME(TokLBrace, rest cs)
              | SOME(#"}")  => SOME(TokRBrace, rest cs)
              | SOME(#"[")  => SOME(TokLBracket, rest cs)
              | SOME(#"]")  => SOME(TokRBracket, rest cs)
              | SOME(#",")  => SOME(TokComma, rest cs)
              | SOME(#":")  => SOME(TokColon, rest cs)
              | SOME(#"\"") => SOME(scanString (rest cs) #"\"")
              | SOME(#"'")  => SOME(scanString (rest cs) #"'")
              | SOME(#"/")  => scanComment cs
              | SOME(c) =>
                    if startNum c then SOME(scanNumber c cs)
                    else if startWord c then SOME(scanWord cs)
                    else raise Exception("Lexical error; bad token")
        end
    and scanString cs q =
        let fun isLineEnd c = c = #"\n" orelse c = #"\r"
            fun loop NONE _ = raise Exception("Unterminated string (end)")
              | loop (SOME(#"\n", _)) _ = raise Exception("Unterminated string (nl)")
              | loop (SOME(#"\\", cs)) tcs =
                    (case next cs of
                        NONE => raise Exception("Unterminated string (escape)")
                      | SOME(#"0", cs) => loop (next cs) (#"\000"::tcs)
                      | SOME(#"b", cs) => loop (next cs) (#"\b"::tcs)
                      | SOME(#"f", cs) => loop (next cs) (#"\f"::tcs)
                      | SOME(#"n", cs) => loop (next cs) (#"\n"::tcs)
                      | SOME(#"r", cs) => loop (next cs) (#"\r"::tcs)
                      | SOME(#"t", cs) => loop (next cs) (#"\t"::tcs)
                      | SOME(#"v", cs) => loop (next cs) (#"\v"::tcs)
                      | SOME(c, cs) =>  (* handle possibly continued line *)
                            loop (next cs) (if isLineEnd c then tcs else c::tcs))
              | loop (SOME(c, cs)) tcs =
                    if c = q then (toString tcs, cs) else loop (next cs) (c::tcs)
            val (token, cs') = loop (next cs) []
        in
            (TokStr token, skipWS cs')
        end
    and scanNumber c cs =
        let fun isNumChar c =
                Char.isDigit c orelse Char.isAlpha c orelse
                    c = #"." orelse c = #"+" orelse c = #"-"
            fun scanReal word =
                case Real.scan next word of
                    NONE => NONE
                  | SOME(value, after) =>
                        if Substring.isEmpty after then SOME(value) else NONE
            fun scanInt word radix =
                case Int.scan radix next word of
                    NONE => NONE
                  | SOME(value, after) =>
                        if Substring.isEmpty after then SOME(value) else NONE
            val (word, cs') = Substring.splitl isNumChar cs
            val wordStr = Substring.string word
        in
            if wordStr = "+Infinity" then (TokReal Real.posInf, cs')
            else if wordStr = "-Infinity" then (TokReal Real.negInf, cs')
            else if (Substring.isPrefix "0x" word) orelse (Substring.isPrefix "0X" word) then
                case scanInt word StringCvt.HEX of
                    NONE => raise Exception("Bad hex string")
                  | SOME(value) => (TokInt value, cs')
            else
                case scanInt word StringCvt.DEC of
                    SOME(value) => (TokInt value, cs')
                  | NONE =>
                        case scanReal word of
                            NONE => raise Exception("bad number")
                          | SOME(value) => (TokReal value, cs')
        end
    and scanComment cs =
        let val terminator =
                if Substring.isPrefix "//" cs then "\n"
                else if Substring.isPrefix "/*" cs then "*/"
                else raise Exception("Bad comment")
            val (_, cs) = Substring.position terminator cs
        in
            if terminator = "*/" andalso not (Substring.isPrefix terminator cs)
            then raise Exception "unterminated comment"
            else scan (Substring.triml (String.size terminator) cs)
        end
    and scanWord cs =
        let
            fun isWord c = Char.isAlpha c orelse Char.isDigit c orelse
                    c = #"_" orelse c = #"$"
            val (tcs, cs') = Substring.splitl isWord cs
            val token = Substring.string tcs
        in
            case token of
                "null" => (TokNull, cs')
              | "true" => (TokBool true, cs')
              | "false" => (TokBool false, cs')
              | "NaN" => (TokReal (0.0 * Real.posInf), cs')
              | "Infinity" => (TokReal Real.posInf, cs')
              | _ => (TokId token, cs')
        end

    fun tokenize s =
        let
            fun scanLoop cs ts =
                case scan cs of
                    NONE => List.rev ts
                  | SOME(token, cs') => scanLoop cs' (token::ts)
        in
            scanLoop (Substring.full s) []
        end

    fun findValue matcher os =
        case List.find matcher os of
            SOME(_, value) => value
          | NONE => raise Exception "Key not found"

    fun extractValueById s os =
            findValue (fn (KeyIdentifier id, _) => s = id | _ => false) os

    fun extractValueByStr s os =
            findValue (fn (KeyString id, _) => s = id | _ => false) os

    fun unwrapNull Null = ()
      | unwrapNull _ = raise Exception "Value is not a Null"
    fun unwrapBool (Boolean b) = b
      | unwrapBool _ = raise Exception "Value is not a Bool"
    fun unwrapString (String s) = s
      | unwrapString _ = raise Exception "Value is not a String"
    fun unwrapInt (Int i) = i
      | unwrapInt _ = raise Exception "Value is not an Int"
    fun unwrapReal (Real r) = r
      | unwrapReal _ = raise Exception "Value is not a Real"
    fun unwrapObject (Object obj) = obj
      | unwrapObject _ = raise Exception "Value is not an Object"
    fun unwrapArray (Array arr) = arr
      | unwrapArray _ = raise Exception "Value is not an Array"

    fun idToString key obj =
            unwrapString (extractValueById key (unwrapObject obj))
    fun idToInt key obj =
            unwrapInt (extractValueById key (unwrapObject obj))

    fun parse s =
        let
            fun matchColon (TokColon::ts) = ts
              | matchColon _ = raise Exception "match failed"

            fun parse [] = (Null, [])
              | parse (TokLBrace::ts) = parseObj ts []
              | parse (TokLBracket::ts) = parseArray ts []
              | parse (TokNull::ts) = (Null, ts)
              | parse (TokBool b::ts) = (Boolean b, ts)
              | parse (TokInt i::ts)  = (Int i, ts)
              | parse (TokReal r::ts) = (Real r, ts)
              | parse (TokStr s::ts) = (String s, ts)
              | parse (_::ts) = raise Exception("Unexpected token in parse")
            and parseObj (TokRBrace::ts) kvs = (Object (List.rev kvs), ts)
              | parseObj ts kvs =
                let
                    val (key, ts) = parseKey ts
                    val ts = matchColon(ts)
                    val (value, ts) = parse(ts)
                    val kv = (key, value)
                in
                    parseObjTail ts (kv::kvs)
                end
            and parseKey (TokStr s::ts) = (KeyString s, ts)
              | parseKey (TokId id::ts) = (KeyIdentifier id, ts)
              | parseKey _ = raise Exception("Bad key")
            and parseObjTail (ts as TokRBrace::tailTs) kvs = parseObj ts kvs
              | parseObjTail (TokComma::ts) kvs = parseObj ts kvs
              | parseObjTail _ _ = raise Exception("Object parse failed")
            and parseArray (TokRBracket::ts) vs = (Array (List.rev vs), ts)
              | parseArray ts vs =
                    let val (obj, ts) = parse ts in parseArrayTail ts (obj::vs) end
            and parseArrayTail (ts as TokRBracket::tailTs) vs = parseArray ts vs
              | parseArrayTail (TokComma::ts) vs = parseArray ts vs
              | parseArrayTail _ _ = raise Exception("Array parse failed")

            fun parseSingleObj ts =
                case parse ts of
                    (object, []) => object
                  | (object, _) => raise Exception("malformed object")
        in
            parseSingleObj (tokenize s)
        end
end
