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

(*Helper -  *)
(*7.Write a function computed_periodic_point eq f p x that returns the computed periodic point for f with period p and with respect to x*)
let computed_periodic_point eq f p x =



