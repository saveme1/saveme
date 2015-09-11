ADOCS:=$(shell find html -name '*.adoc')
SRC= *.pas *.lpi $(ADOCS)

.PHONY: clean rel all

saveme: $(SRC)
	cd html && make
	lazbuild -B --bm=Release saveme.lpi
	#strip saveme saveme.exe

saveme.exe: $(SRC)
	cd html && make
	wine "$$WINEAPPS/lazarus/lazbuild.exe" -B --bm=Release saveme.lpi

saveme.ver: saveme
	./saveme -v 2>/dev/null | tr -d \\n | cat > $@

all: saveme saveme.exe saveme.ver


#folowing  target not working yet
saveme.linux32: $(SRC)
	cd html && make
	lazbuild -B --cpu=i386 --bm=Release saveme.lpi

clean:
	cd html && make clean
	rm saveme saveme.exe saveme.ver

rel: saveme saveme.exe saveme.ver
	cp -a saveme saveme.exe saveme.ver rel
