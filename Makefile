ADOCS:=$(shell find html -name '*.adoc')

.PHONY: clean rel

saveme: *.pas $(ADOCS)
	cd html && make
	lazbuild -B --bm=Release saveme.lpi
	#strip saveme saveme.exe

clean:
	cd html && make clean
	rm saveme saveme.exe

rel: saveme saveme.exe
	cp -a saveme saveme.exe rel
