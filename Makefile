ADOCS:=$(shell find html -name '*.adoc')
SRC= *.pas saveme.ver $(ADOC)

.PHONY: clean rel

saveme: $(SRC)
	cd html && make
	lazbuild -B --bm=Release saveme.lpi
	#strip saveme saveme.exe

saveme.ver: main.pas
	grep VERSION\ = main.pas | tr -cd \[0-9.\] | cat > $@

#folowing 2 targets not working yet
saveme.linux32: $(SRC)
	cd html && make
	lazbuild -B --cpu=i386 --bm=Release saveme.lpi

saveme.exe: $(SRC)
	cd html && make
	lazbuild -B --cpu=i386 --os=win32 --ws=win32 --bm=Release saveme.lpi

clean:
	cd html && make clean
	rm saveme saveme.exe

rel: saveme saveme.exe
	cp -a saveme saveme.exe rel
