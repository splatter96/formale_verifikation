//Aufgabenblatt 4 Aufgabe 7

ltl noerrors {[]<>received && []<>sent}
//ltl noerros {[]<>received && false}

chan messchan = [0] of {bit, byte}
chan ackchan = [0] of {bit}

bit received;
bit sent;

proctype sender(){
	bit control;
	byte message = 0;

	bit ack;

	do
	:: true ->
			sent = 0;

			messchan ! control, message;
			ackchan ? ack;

			//Nondeterministc choice to corrupt packet
			if
			:: true -> ack = ack
			:: true -> ack = !ack
			fi

			do
			:: ack == control -> break;
			:: else ->
						messchan ! control, message;
						ackchan ? ack;

						//Nondeterministc choice to corrupt packet
						if
						:: true -> ack = ack
						:: true -> ack = !ack
						fi

			od
			control = !control;
			sent = 1;		
			message = message + 1;	
	od

}

proctype receiver(){
	bit control;
	byte message;

	bit expcontrol

	do
	:: true ->
			received = 0;
			messchan ? control, message;

			//Nondeterministc choice to corrupt packet
			if
			:: true -> control = control
			:: true -> control = !control
			fi
			
			do
			:: control == expcontrol -> break;
			:: else -> 
							ackchan ! expcontrol
							messchan ? control, message
							//Nondeterministc choice to corrupt packet
							if
								:: true -> control = control
								:: true -> control = !control
							fi
			od

			received = 1;

			ackchan ! control;
			expcontrol = !expcontrol;
	od
}

init{
	atomic{
		run sender();
		run receiver();
	}
}