// ----------------------------
// projects/collatz/Collatz.c++
// Copyright (C) 2016
// Glenn P. Downing
// ----------------------------

// --------
// includes
// --------

#include <cassert>  // assert
#include <iostream> // endl, istream, ostream
#include <map>

using namespace std;

#define OPTMIZE true

#ifdef OPTMIZE
map<int, int> CACHE;
#endif

// ------------
// collatz_read
// ------------
// -------------------------------
// projects/collatz/RunCollatz.c++
// Copyright (C) 2016
// Glenn P. Downing
// -------------------------------

// --------
// includes
// --------

#include <iostream> // cin, cout

bool collatz_read(istream &r, int &i, int &j) {
  if (!(r >> i))
    return false;
  r >> j;
  return true;
}

// ------------
// cycle_length
// ------------

int cycle_length(int num) {
  assert(num > 0);
  if (num == 1) {
    return 1;
  } else {

#ifdef OPTMIZE
    if (CACHE.count(num) == 0) {
      if (num % 2 == 0)
        CACHE[num] = 1 + cycle_length(num / 2);
      else
        CACHE[num] = 2 + cycle_length(num + (num >> 1) + 1);
    }
    return CACHE[num];
#endif

    int result;
    if (num % 2 == 0)
      result = 1 + cycle_length(num / 2);
    else
      result = 2 + cycle_length(num + (num >> 1) + 1);
    return result;
  }
}

// ------------
// collatz_eval
// ------------

int collatz_eval(int i, int j) {
  // <your code>
  assert(i > 0);
  assert(j > 0);

  // check range
  if (i > j) {
    int temp = j;
    j = i;
    i = temp;
  }

#ifdef OPTMIZE
  // range optimization
  if (i < (j / 2 + 1)) {
    i = j / 2 + 1;
  }
#endif

  int max_result = 0;
  int result = 0;
  while (i <= j) {
    // lazy cache optimization
    if (CACHE.count(i) != 0)
      result = CACHE[i];
    else
      result = cycle_length(i);
    if (result > max_result) {
      max_result = result;
    }
    ++i;
  }
  return max_result;
}

// -------------
// collatz_print
// -------------

void collatz_print(ostream &w, int i, int j, int v) {
  w << i << " " << j << " " << v << endl;
}

// -------------
// collatz_solve
// -------------

void collatz_solve(istream &r, ostream &w) {
  int i;
  int j;
  while (collatz_read(r, i, j)) {
    const int v = collatz_eval(i, j);
    collatz_print(w, i, j, v);
  }
}

int main() {
  using namespace std;
  collatz_solve(cin, cout);
  return 0;
}
