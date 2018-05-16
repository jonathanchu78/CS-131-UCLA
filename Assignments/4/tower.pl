%for debugging, from http://www.swi-prolog.org/pldoc/man?predicate=print/1
print(Term) :-
    current_prolog_flag(print_write_options, Options), !,
    write_term(Term, Options).
print(Term) :-
    write_term(Term, [ portray(true),
                       numbervars(true),
                       quoted(true)
                     ]).

/*helper - return true if for X | R list of lists all lists are length N*/
len([], _).
len([X | R], N) :- 
	length(X, N),
	len(R, N).

/*transpose of matrix from: https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog*/
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).

lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).

/*helper - return true if all elements before are less*/
all_less([], _).
all_less([H | Rest], X) :-
	%print(H), nl, print(X), nl,
	H #< X,
	all_less(Rest, X).

verify_one([], _, X) :- X = 0.
verify_one([X | R], Before, Count) :-
	%print(Count), nl,
	%print(Before), print(X), nl, nl,
	append(Before, [X], NewBefore),
	verify_one(R, NewBefore, Count1),
	(all_less(Before, X) -> Count is Count1 + 1; Count1 = Count).

/*helper - take one list of vals to check, check it works assuming it's the
  left side of the board T*/
verify_rc([], []).
verify_rc([X | TRest], [Num | ValsRest]) :-
	verify_one(X, [], Cnt), Cnt = Num,
	verify_rc(TRest, ValsRest).

/*helper - reverse all lists within this list of lists*/
reverse_all([], []).
reverse_all([X | L], [XRev | LRev]) :-
	reverse(X, XRev),
	reverse_all(L, LRev).

/*check the visible building counts matches on every edge*/
verify(T, A, Top, Bottom, Left, Right) :-
	verify_rc(T, Left),
	reverse_all(T, TR), verify_rc(TR, Right),
	verify_rc(A, Top),
	reverse_all(A, AR), verify_rc(AR, Bottom).

dom(N, X) :-
	fd_domain(X, 1, N).


tower(N, T, C) :-
	C = counts(Top, Bottom, Left, Right),
	length(T, N),
	len(T, N),
	%found out about maplist at TA Yoo's OH
	maplist(dom(N), T),
	maplist(fd_all_different, T),
	transpose(T, A),
	maplist(dom(N), A),
	maplist(fd_all_different, A),
	maplist(fd_labeling, T),
	length(Top, N), length(Bottom, N), length(Left, N), length(Right, N),
	verify(T, A, Top, Bottom, Left, Right).

%---------------------------------------
%plain_tower:

my_domain([], _, _).
my_domain([X | R], Lower, Upper) :-
	X #> Lower - 1, X #< Upper + 1,
	my_domain(R, Lower, Upper).

my_dom(N, X) :-
	my_domain(X, 1, N).

elem_diff(_, []).
elem_diff(X, [F | R]) :-
	X #\= F,
	elem_diff(X, R).

my_all_unwrap(_, []).
my_all_unwrap(Before, [X | R]) :-
	elem_diff(X, R),
	append(Before, [X], NewBefore),
	my_all_unwrap(NewBefore, R).

my_all_different(L) :-
	my_all_unwrap([], L). 

my_labeling(N, L) :-
	findall(Num, between(1, N, Num), X), 
	permutation(X, L).

plain_tower(N, T, C) :-
	C = counts(Top, Bottom, Left, Right),
        length(T, N),
        len(T, N),
	maplist(my_dom(N), T),
        maplist(my_all_different, T),
        transpose(T, A),
        maplist(my_dom(N), A),
        maplist(my_all_different, A),
        maplist(my_labeling(N), T),
	length(Top, N), length(Bottom, N), length(Left, N), length(Right, N),
        verify(T, A, Top, Bottom, Left, Right).


%----------------------------------
%statistics:

time(Y) :-
statistics(runtime,[Start|_]),
tower(4, T, counts([2, 1, 3, 2], [2, 2, 1, 3], [2, 4, 1, 3], [2, 1, 2, 2])),
statistics(runtime,[Stop|_]),
Y is Stop - Start.

ptime(Z) :-
statistics(runtime,[Start2|_]),
plain_tower(4, T, counts([2, 1, 3, 2], [2, 2, 1, 3], [2, 4, 1, 3], [2, 1, 2, 2])),
statistics(runtime,[Stop2|_]),
Z is Stop2 - Start2.

speedup(Ratio) :- 
	time(Y), ptime(Z), 
	Ratio is Z/Y.


%----------------------------------------------
%ambiguity:

ambiguous(N, C, T1, T2) :-
	C = counts(Top, Bottom, Left, Right),
	tower(N, T1, C),
	tower(N, T2, C),
	T1 \= T2.

