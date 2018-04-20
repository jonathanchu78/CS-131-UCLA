type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*1: convert_grammar*)
let rec unwrapped_convert gram1 gram2 x = match gram1 with
	| [] -> gram2
	| g1item :: g1rest -> match g1item with
		| (nt, ts) -> if nt =  x 
					  then unwrapped_convert g1rest (gram2@[ts]) x
					  else unwrapped_convert g1rest gram2 x

let convert_grammar gram1 = match gram1 with
	| (ss, rules) -> (ss, unwrapped_convert rules [])


(*2: parse_prefix*)
let parse ss prod  = 
	(*write functions within parse_prefix, better encapsulation*)
	(*recurse through rules for nonterminal*)
	(*EQUIVALENT: let rec expand_nt prod nt rules = match rules with*)
	let rec expand_nt prod nt = function
		(*no more rules; haven't found a match. Return None*)
		| [] -> (fun accept d frag -> None)
		| ruleitem :: rulesrest -> (fun accept d frag ->
			(*local variable function calls, more readable*)
			let checkitem = match_item prod ruleitem

			in match checkitem accept (d @ [(nt, ruleitem)]) frag (*reverse order append?*) with
				(*return whatever acceptor returns*)
				| None -> expand_nt prod nt rulesrest accept d frag
				(*continue*)
				| _ -> checkitem accept (d @ [(nt, ruleitem)]) frag
		)

	(*check what the next item is and handle*)
	and match_item prod = function
		(*no more rules; return what acceptor returned*)
		| [] -> (fun accept d frag -> accept d frag)
		(*item was a terminal symbol ==> check for match*)
		| (T tm) :: rulesrest -> (fun accept d -> function
			| [] -> None
			| fragitem :: fragrest ->
				let matcher = match_item prod rulesrest in 
				if fragitem = tm then 
					(*Found a match! Now the tricky part*)
					matcher accept d fragrest
				else None (*terminal didn't match fragitem*)
		)
		(*item was a nonterminal ==> feed it back into expand_nt*)
		| (N nt) :: rulesrest -> (fun accept d frag ->
			let checkrest = expand_nt prod nt (prod nt)
			and new_acceptor = match_item prod rulesrest accept
			in checkrest new_acceptor d frag
		)
	in
	(*start by expanding the start symbol, program will recursively expand the rest*)
	(* (prod ss) evaluates to the rules corresponding to start symbol*)
	fun accept frag -> expand_nt prod ss (prod ss) accept [] frag

let parse_prefix gram = parse (fst gram) (snd gram)
