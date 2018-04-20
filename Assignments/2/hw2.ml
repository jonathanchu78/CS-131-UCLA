type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*1*)
let rec unwrapped_convert gram1 gram2 x = match gram1 with
	| [] -> gram2
	| g1item :: g1rest -> match g1item with
		| (nt, ts) -> if nt =  x 
					  then unwrapped_convert g1rest (gram2@[ts]) x
					  else unwrapped_convert g1rest gram2 x

let convert_grammar gram1 = match gram1 with
	| (ss, rules) -> (ss, unwrapped_convert rules [])
