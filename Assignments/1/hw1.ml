(*let addtwo i j =
	Printf.printf "%8d%8d\n" i j;;*)

(*Helper - returns true if the list b contains element i*)
let rec contains b i = match b with
	| [] -> false
	| x :: r -> (if x = i then true else contains r i);;


(*1.Write a function subset a b that returns true iff a is a subset of b*)
let rec subset a b = match a with
	| [] -> true
	| x :: r -> if not (contains b x) then false else subset r b;; 

(*2.Write a function equal_sets a b that returns true iff the sets are equal.*)
let equal_sets a b =
	subset a b && subset b a;;

(*3.Write a function set_union a b that returns a list a∪b*)
let rec set_union a b = match a with
	| [] -> b
	| x :: r -> set_union r (x :: b);;

(*4.Write a function set_intersection a b that returns a list a∩b.*)
let rec set_intersection a b =
	if subset a b then a 
	else (match a with 
	| [] -> [] (*this case never happens; i just want to avoid a warning*)
	| x :: r -> if contains b x then set_intersection (r@[x]) b 
		    else set_intersection r b);;

(*5.Write a function set_diff a b that returns a list representing a−b, that is, the set of all members of a that are not also members of b.*)
let rec set_diff a b = 
	if set_intersection a b = [] then a
	else match a with
	| [] -> [] (*this case never happens; i just want to avoid a warning*)
	| x :: r -> if contains b x then set_diff r b 
		    else set_diff (r@[x]) b;;

(*6.Write a function computed_fixed_point eq f x that returns the computed fixed point for f with respect to x*)
let rec computed_fixed_point eq f x = 
	if  (eq x (f x)) then x
	else computed_fixed_point eq f (f x);;

(*Helper - apply function f n times on input x *)
let rec fn f n x = match n with
	| 0 -> x
	| _ -> fn f (n-1) (f x);;

(*7.Write a function computed_periodic_point eq f p x that returns the computed periodic point for f with period p and with respect to x*)
let rec computed_periodic_point eq f p x =
	if (eq (fn f p x) x) then x
	else computed_periodic_point eq f p (f x);;

(*8.Write a function while_away s p x that returns the longest list [x; s x; s (s x); ...] such that p e is true for every element e in the list*)
let rec while_away s p x =
	if p x = false then []
	else x::(while_away s p (s x));;

(*9.Write a function rle_decode lp that decodes a list of pairs lp in run-length encoding form.*)
let rec decode lp lst = match lp with
	| [] -> lst
	| x :: r -> if fst x = 0 then decode r lst
		    else if fst x = 1 then decode r ((snd x) :: lst)
		    else decode (((fst x) - 1, snd x) :: r) ((snd x) :: lst);;

(*Helper - reverse a list*)
let rec reverse lst rev_lst = match lst with
	| [] -> rev_lst
	| x :: r -> reverse r rev_lst@[x];;

(* this implementation is terribly inefficient, oh well*)
let rle_decode lp = 
	reverse (decode lp []) [];;


(*10.Write a function filter_blind_alleys g that returns a copy of the grammar g with all blind-alley rules removed.*)
type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

(*check if written as terminal OR if written as non-terminal but determined to be terminal*)
let is_terminal smb terminals =
	match smb with
	| T _ -> true
	| N s -> contains terminals s;;

(*check if all rules are terminal*)
let rec check_rules rules terminals =
	match rules with
	| [] -> true
	| s :: t -> if (is_terminal s terminals) then (check_rules t terminals)
		    else false;;

(*create list of terminals*)
let rec construct grammar terminals =
	match grammar with
	| [] -> terminals
	| (e, r) :: t -> if (check_rules r terminals) && not (contains terminals e) 
			    then (construct t (e :: terminals))
			    else (construct t terminals);;

(*wrapper to return object in correct format*)
let construct_wrapper (orig_lst, terminals) =
	orig_lst, (construct orig_lst terminals);;

(*check if second element (a list) in each tuple is equal*)
let snd_equal_set (i1, j1) (i2, j2) = equal_sets j1 j2;;

(*discard rules that aren't terminal*)
let rec filter_rules rules terminals new_rules =
	match rules with
	| [] -> new_rules
	| (e, r) :: t -> if (check_rules r terminals) 
			then (filter_rules t terminals (new_rules@[(e,r)]))
		        else (filter_rules t terminals new_rules);;

let filter_blind_alleys g =
	(fst g), 
	(filter_rules (snd g) (snd (computed_fixed_point snd_equal_set construct_wrapper ((snd g), []))) []);;
