(*let addtwo i j =
	Printf.printf "%8d%8d\n" i j;;*)

(*returns true if the list b contains element i*)
let rec contains b i = match b with
	| [] -> false
	| x :: r -> (if x = i then true else contains r i);;


(*Write a function subset a b that returns true iff a is a subset of b*)
let rec subset a b = match a with
	| [] -> true
	| x :: r -> if not (contains b x) then false else subset r b;; 


