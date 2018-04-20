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
(* Array appendation. This is faster than @ op since it does not copy every element *)
let rec append_array rhs = function
	| [] -> rhs
	| h::t -> h::(append_array rhs t)
in

let rec expand_nt prod nt = function
	| [] -> (fun accept d frag -> None)
	| rulesitem :: rulesrest -> (fun accept d frag -> 
		let item_match = match_tm prod rulesrest rulesitem (*added rulesrest parameter*)
		and rest_match = expand_nt prod nt rulesrest in

		let matcher = item_match accept (append_array [(nt, rules_head)] derivation) frag in
		match matcher with
			| None -> rest_match accept d frag
			| _ -> matcher
	)

let rec match_tm prod rules = function
	| [] -> (fun accept d frag -> accept d frag)
	| (T t) :: rules ->
		(fun accept derivation -> function
			| [] -> None
			| fragitem :: fragrest -> 
				let matcher = match_tm prod rules
			in if fragitem = t then matcher accept d fragrest
			   else None
		)
	| (N nt) :: rules_tail ->
		(fun accept d frag ->
			let tail_matcher = expand_nt prod nt (prod_func nt)
			and new_acceptor = match_tm prod rules accept
			in tail_matcher new_acceptor d frag)
		)

let parse_prefix gram = 
	let ss = fst gram
	and prod = snd gram in
	fun accept frag -> expand_nt prod ss (prod ss) accept [] frag

