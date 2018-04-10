let my_subset_test0 = subset [] []
let my_subset_test1 = subset [] [1]
let my_subset_test2 = subset [1] [1;4;5;6]
let my_subset_test3 = subset [3;4;5;6] [3;4;5;6]
let my_subset_test4 = not (subset [1;2] [])

let my_equal_sets_test0 = equal_sets [] [] 
let my_equal_sets_test1 = equal_sets [1;2;3] [1;2;3]
let my_equal_sets_test2 = not (equal_sets [] [1])
let my_equal_sets_test3 = not (equal_sets [1;2;3;4;5] [1;2;3;4;5;6])

let my_set_union_test0 = equal_sets (set_union [] []) []
let my_set_union_test1 = equal_sets (set_union [1] [1;2;3]) [1;2;3]
let my_set_union_test2 = equal_sets (set_union [1;3;5;7] [2;4;6;8]) [1;2;3;4;5;6;7;8]

let my_set_intersection_test0 = equal_sets (set_intersection [1] []) []
let my_set_intersection_test1 = equal_sets (set_intersection [1;2;3;4] [2;3]) [2;3]
let my_set_intersection_test2 = equal_sets (set_intersection [2;3;4] [4;5;6]) [4]

let my_set_diff_test0 = equal_sets (set_diff [1;2] []) [1;2]
let my_set_diff_test1 = equal_sets (set_diff [1;2;3;4;5] [1;2;3;4;5]) []

let my_computed_fixed_point_test0 =
	computed_fixed_point (=) (fun x -> 9*x/10) 1000000000 = 0

let my_computed_periodic_point_test0 =
	computed_periodic_point (=) (fun x -> x * -1) 2 1 = 1

let my_while_away_test0 =
	equal_sets (while_away (fun x -> x + 1) (fun x -> x < 6) 1) [1; 2; 3; 4; 5]

let my_rle_decode_test0 = 
	equal_sets (rle_decode [3,4;1,5;2,7])  [4;4;4;5;7;7]

type my_nonterminals =
	| Noun | Verb | Adjective

let my_rules = [
	Noun, [T "dog"];
	Noun, [T "grass"];
	Verb, [T "eats"];
	Verb, [T "cuts"];
	Adjective, [N Adjective]]

let my_grammar = S, my_rules

let my_filter_blind_alleys_test0 = filter_blind_alleys my_grammar = (S, [
	Noun, [T "dog"];
        Noun, [T "grass"];
        Verb, [T "eats"];
        Verb, [T "cuts"]])
