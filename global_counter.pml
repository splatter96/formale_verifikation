
byte n = 0;

proctype P() {
    byte temp;
    temp = n + 1;
    n = temp;
}

init{
	run P();
	run P();
	
	_nr_pr == 2 ->
		assert(n == 2);
}