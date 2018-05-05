//Aufabenblatt 4 Aufgabe 8
#include "for.h"

//'Aufzug nie ausserhalb Etage 0-3'
//ltl {[](floor==0 || floor==1 || floor==2 || floor==3)}

//'Up Befehl nur wenn Etage = 0-2'
//ltl {[](motorcom==up -> (lastfloor==0 || lastfloor==1 || lastfloor==2))}
//'Down Befehl nur wenn Etage = 1-3
//ltl {[](motorcom==down -> (lastfloor==1 || lastfloor==2 || lastfloor==3))}

//Close und Open siehe doorproc

//'Aufzug faehrt nie mit offener Tuer' siehe motorproc

//'Wenn Knopf gedrueckt, dann haelt aufzug dort mit offener tuer'
//ltl {[](buttons[0]==1 -> <>(floor==0 && door==0))}
//ltl {[](buttons[1]==1 -> <>(floor==1 && door==0))}
//ltl {[](buttons[2]==1 -> <>(floor==2 && door==0))}
ltl {[](buttons[3]==1 -> <>(floor==3 && door==0))}

byte floor; //floor the elevator is on
bit door; //0 open, 1 closed
bit buttons[4]; //one button per floor

mtype = {off, up, down, open, close} //Commands for elevator motor and door motor

//ghost variables
mtype motorcom;
byte lastfloor;

//channels
chan doorchan = [0] of {mtype}
chan motorchan = [0] of {mtype}

chan doorack = [0] of {bool}
chan motorack = [0] of {bool}


proctype controlproc(){
	do
	:: true ->
			for(i, 0, 3)
				if
				:: buttons[i] == 1 ->
						if
						:: door == 0 ->
													doorchan ! close;
													doorack ? _;
						:: else -> skip;
						fi
						do
						:: i > floor -> 
													motorchan ! up;
													motorack ? _
						:: i < floor ->
													motorchan ! down;
													motorack ? _
						:: else -> break;
						od
						if //open door if not already open
						:: door == 1 ->	
													doorchan ! open;
													doorack ? _;
						:: else -> skip;
						fi
						buttons[i] = 0;						
				:: else -> skip;
				fi			
			rof(i)
	od
}

proctype buttonsproc(){
	do
	:: true ->
			//nondeterministically press buttons
			for(j, 0, 3)
				if
				:: buttons[j] == 0 -> buttons[j] = 1;
				:: true -> buttons[j] = buttons[j]
				fi
			rof(j)
	od
}

proctype motorproc(){
	do
	:: true ->
		motorchan ? motorcom;
		assert(door==1) //'Aufzug faehrt nie mit offenen Tueren'
		if
		:: motorcom == up -> 
				lastfloor = floor;
				floor = floor + 1;
		:: motorcom == down -> 
				lastfloor = floor;
				floor = floor - 1;
		:: motorcom == off -> skip; //floor unchanged
		:: else -> skip //ignore other commands
		fi

		motorack ! true;
	od
}

proctype doorproc(){
	mtype move;
	do
	:: true ->
		doorchan ? move;
		if
		:: move == open -> 
					assert(door == 1) //'Open Befehl nur erteilt, wenn Tuer geschlossen'
					door = 0
		:: move == close ->
					assert(door == 0) //'Close Befehl nur erteilt, wenn Tuer offen'
					door = 1
		:: move == off -> skip; //door unchanged
		:: else -> skip //ignore other commands
		fi

		doorack ! true
	od
}

init{
	atomic{
		run controlproc();
		run buttonsproc();
		run motorproc();
		run doorproc();
	}
}