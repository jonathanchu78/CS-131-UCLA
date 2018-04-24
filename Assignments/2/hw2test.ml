type ('a, 'b) symbol = N of 'a | T of 'b

let accept_all derivation string = Some (derivation, string)

type my_nonterminals =
        | Noun | Verb | Adjective

let my_rules = [
        Noun, [T "dog"];
        Noun, [T "grass"];
	Noun, [N Adjective; N Noun];
	Noun, [N Verb];
        Verb, [T "eats"];
        Verb, [T "cuts"];
        Adjective, [T "big"];
	Adjective, [T "green"]]

let my_grammar = Noun, my_rules

let test_grammar = convert_grammar my_grammar

(*hardcoded grammar:
(Noun,
	function
	| Noun ->
		[[T "dog"];
		[T "grass"];
		[N Adjective; N Noun];
		[N Verb]]
	| Verb ->
		[[T "eats"];
		[T "cuts"]]
	| Adjective ->
		[[T "big"];
		[T "green"]])*)

let test = parse_prefix test_grammar accept_all

let test_1 = 
	(test ["dog"; "eats"; "grass"] =
	Some ([(Noun, [T "dog"])], ["eats"; "grass"]))

let test_2 = 
	(test ["big"; "dog"; "cuts"; "green"; "grass"; "i"; "hate"; "cats"] =
	Some
	([(Noun, [N Adjective; N Noun]); (Adjective, [T "big"]); (Noun, [T "dog"])],
	["cuts"; "green"; "grass"; "i"; "hate"; "cats"]))
