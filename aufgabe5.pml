//Aufgabenblatt 3 Aufgabe 5
#include "for.h"

#define check1 (reg[4] == 1)
#define check2 (reg[4] == 0)
#define initNot0 (reg[0] != 0 || reg[1] != 0 || reg[2] != 0 || reg[3] != 0 || reg[4] != 0)

//ltl {<>(initNot0) -> !([]check2||[]check1)}
ltl {<>(initNot0) -> ([]<>check2 && []<>check1)}

byte n = 5; //Number of elements in register
bit reg[n];

active proctype P(){
	//Nondeterministic initialization
	for(i, 0, n-1)
		if
		:: true -> reg[i] = 0
		:: true -> reg[i] = 1
		fi
	rof(i)

	do
	:: true ->
		bit tmp = reg[1] ^ reg[4]; //xor

		for(j, 1, n-1)
		 	reg[n-j] = reg[n-j-1];
		rof(j)

		reg[0] = tmp
	od
}