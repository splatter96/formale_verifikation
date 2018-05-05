//Aufgabenblatt 3 Aufgabe 6

//0 linkes ufer, 1 rechtes ufer
bool ferryman;
bool goat;
bool cabbage;
bool wolf;

//negation because we want to see the path that leads to our goal
ltl { !(((goat==cabbage || goat==wolf) -> goat==ferryman) U (ferryman && goat && cabbage && wolf)) }

active proctype P(){
	bool next_ferryman

	do 
	:: true ->
		//Nondeterministic choice of the ferryman to cross or not to cross
		if
			:: true -> next_ferryman = 0
			:: true -> next_ferryman = 1
		fi

		//Nondeterministic choice which element to carry to the other side, or none
		if
			:: goat == ferryman -> 
						atomic{
							ferryman = next_ferryman
							goat = next_ferryman
						}
			:: cabbage == ferryman ->
						atomic{
							ferryman = next_ferryman	
							cabbage = next_ferryman							
						}
			:: wolf == ferryman -> 
						atomic{
							ferryman = next_ferryman
							wolf = next_ferryman
						}
			:: true -> ferryman = next_ferryman //nothing carried
		fi

	od

}