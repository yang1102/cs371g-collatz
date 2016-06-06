# http://stackoverflow.com/questions/31176997/what-does-clang-check-do-without-analyze-option

FILES :=                              \
    Collatz.c++                       \
    Collatz.h                         \
    Collatz.log                       \
    html                              \
    RunCollatz.c++                    \
    RunCollatz.in                     \
    RunCollatz.out                    \
    TestCollatz.c++                   \
    TestCollatz.out

# uncomment these:
#    collatz-tests/EID-RunCollatz.in   \
#    collatz-tests/EID-RunCollatz.out  \
#    collatz-tests/EID-TestCollatz.c++ \
#    collatz-tests/EID-TestCollatz.out \

CLANG-FORMAT := clang-format
CXXFLAGS     := -pedantic -std=c++11 -Wall
LDFLAGS      := -lgtest -lgtest_main -pthread
VALGRIND     := valgrind

ifeq ($(CC), clang)
    CLANG-CHECK := clang-check
    CXX         := clang++
else
    CXX         := g++-4.8
    GCOV        := gcov-4.8
    GCOVFLAGS   := -fprofile-arcs -ftest-coverage
    GPROF       := gprof
    GPROFFLAGS  := -pg
endif

collatz-tests:
	git clone https://github.com/cs371g-summer-2016/collatz-tests.git

html: Doxyfile Collatz.h Collatz.c++ RunCollatz.c++ TestCollatz.c++
	doxygen Doxyfile

Collatz.log:
	git log > Collatz.log

Doxyfile:
	doxygen -g

RunCollatz: Collatz.h Collatz.c++ RunCollatz.c++
ifeq ($(CC), clang)
	$(CXX) $(CXXFLAGS) Collatz.c++ RunCollatz.c++ -o RunCollatz
	-$(CLANG-CHECK) -extra-arg=-std=c++11          Collatz.c++     --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze Collatz.c++     --
	-$(CLANG-CHECK) -extra-arg=-std=c++11          RunCollatz.c++  --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze RunCollatz.c++  --
else
	$(CXX) $(CXXFLAGS) $(GPROFFLAGS) Collatz.c++ RunCollatz.c++ -o RunCollatz
endif

RunCollatz.tmp: RunCollatz
	./RunCollatz < RunCollatz.in > RunCollatz.tmp
	diff RunCollatz.tmp RunCollatz.out
ifeq ($(CC), gcc)
	$(GPROF) ./RunCollatz < RunCollatz.in > RunCollatz.tmp
endif
	cat RunCollatz.tmp

TestCollatz: Collatz.h Collatz.c++ TestCollatz.c++
ifeq ($(CC), clang)
	$(CXX) $(CXXFLAGS) Collatz.c++ TestCollatz.c++ -o TestCollatz $(LDFLAGS)
	-$(CLANG-CHECK) -extra-arg=-std=c++11          TestCollatz.c++ --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze TestCollatz.c++ --
else
	$(CXX) $(CXXFLAGS) $(GCOVFLAGS) Collatz.c++ TestCollatz.c++ -o TestCollatz $(LDFLAGS)
endif

TestCollatz.tmp: TestCollatz
	$(VALGRIND) ./TestCollatz                                       >  TestCollatz.tmp 2>&1
ifeq ($(CC), gcc)
	$(GCOV) -b Collatz.c++     | grep -A 5 "File 'Collatz.c++'"     >> TestCollatz.tmp
	$(GCOV) -b TestCollatz.c++ | grep -A 5 "File 'TestCollatz.c++'" >> TestCollatz.tmp
endif
	cat TestCollatz.tmp

check:
	@not_found=0;                                 \
    for i in $(FILES);                            \
    do                                            \
        if [ -e $$i ];                            \
        then                                      \
            echo "$$i found";                     \
        else                                      \
            echo "$$i NOT FOUND";                 \
            not_found=`expr "$$not_found" + "1"`; \
        fi                                        \
    done;                                         \
    if [ $$not_found -ne 0 ];                     \
    then                                          \
        echo "$$not_found failures";              \
        exit 1;                                   \
    fi;                                           \
    echo "success";

clean:
	rm -f *.gcda
	rm -f *.gcno
	rm -f *.gcov
	rm -f RunCollatz
	rm -f RunCollatz.tmp
	rm -f TestCollatz
	rm -f TestCollatz.tmp

config:
	git config -l

format:
	clang-format -i Collatz.c++
	clang-format -i Collatz.h
	clang-format -i RunCollatz.c++
	clang-format -i TestCollatz.c++

scrub:
	make clean
	rm -f  Collatz.log
	rm -rf html
	rm -rf latex

status:
	make clean
	@echo
	git branch
	git remote -v
	git status

test: html Collatz.log RunCollatz.tmp TestCollatz.tmp collatz-tests check
