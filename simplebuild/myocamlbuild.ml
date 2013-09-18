open Ocamlbuild_plugin

let toolchain = A"android"

(* ocamlfind command *)
let ocamlfind x = if toolchain = A"" then S[A"ocamlfind"; x]
	else S[A"ocamlfind"; A"-toolchain"; toolchain; x]

let _ = dispatch begin function
   | Before_options ->
       (* by using Before_options one let command line options have an higher priority *)
       (* on the contrary using After_options will guarantee to have the higher priority *)

       (* override default commands by ocamlfind ones *)
       Options.ocamlc     := ocamlfind & A"ocamlc";
       Options.ocamlopt   := ocamlfind & A"ocamlopt";
       Options.ocamldep   := ocamlfind & A"ocamldep";
       Options.ocamldoc   := ocamlfind & A"ocamldoc";
       Options.ocamlmktop := ocamlfind & A"ocamlmktop";
       Options.ocamlmklib := ocamlfind & A"ocamlmklib"

   | _ -> ()
end

