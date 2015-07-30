all: htkio.cpp
	g++ -std=c++11 -Wall -shared -fPIC -o htkwrite.so -I/usr/include/lua5.1 -llua5.1  htkio.cpp
test.o: htkio.cpp
	g++ -g -std=c++11 -c htkio.cpp -o htkio.o

test: test.o
	g++ htkio.o -std=c++11 -Wall -o testhtkwrite -lm -llua5.1 -ldl
	rm htkio.o

