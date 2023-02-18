(* ExBBS - an Experimental BBS program *)
(* Author: Dan Cross <cross@fat-dragon.org> *)
(* SML version *)

structure Config = struct
    type Config =
        { name: string,
          admin: string,
          host: string,
          port: int }

    fun parse(text: string): Config =
        let
            val json5Config = JSON5.parse text
        in
            { name = (JSON5.idToString "name" json5Config),
              admin = (JSON5.idToString "admin" json5Config),
              host = (JSON5.idToString "host" json5Config),
              port = (JSON5.idToInt "port" json5Config) }
        end

    fun read(file: string): Config =
        let
            val confFile = TextIO.openIn file
            val text = TextIO.inputAll confFile
            val _ = TextIO.closeIn confFile
            val config = parse text
                handle JSON5.Exception e => (print (e ^ "\n"); raise JSON5.Exception e)
        in
            config
        end
end
