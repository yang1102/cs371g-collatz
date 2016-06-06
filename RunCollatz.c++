// -------------------------------
// projects/collatz/RunCollatz.c++
// Copyright (C) 2016
// Glenn P. Downing
// -------------------------------

// --------
// includes
// --------

#include <iostream> // cin, cout

#include "Collatz.h"

// ----
// main
// ----

int main () {
    using namespace std;
    collatz_solve(cin, cout);
    return 0;}

/*
% g++-4.8 -pedantic -std=c++11 -Wall -fprofile-arcs -ftest-coverage Collatz.c++ RunCollatz.c++ -o RunCollatz
% ./RunCollatz < RunCollatz.in > RunCollatz.tmp
% diff RunCollatz.tmp RunCollatz.out
*/
