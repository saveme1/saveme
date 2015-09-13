ADOCS:=$(shell find html -name '*.adoc')
SRC= *.pas *.lpi *.lps *.lfm html.zip
BLDOPTS= -B
#BLDOPTS=

.PHONY: clean rel all

saveme: $(SRC)
	lazbuild $(BLDOPTS) --bm=Release saveme.lpi
	#strip saveme saveme.exe

saveme.exe: $(SRC)
	wine "$$WINEAPPS/lazarus/lazbuild.exe" $(BLDOPTS) --bm=Release saveme.lpi

saveme.ver: saveme
	./saveme -v 2>/dev/null | tr -d \\n | cat > $@

all: saveme saveme.exe saveme.ver

html.zip: $(ADOCS)
	cd html && make

#folowing  target not working yet
saveme.linux32: $(SRC)
	cd html && make
	lazbuild $(BLDOPTS) --cpu=i386 --bm=Release saveme.lpi

clean:
	cd html && make clean
	rm saveme saveme.exe saveme.ver

rel: rel/saveme rel/saveme.exe rel/saveme.ver
	if gcc -dumpmachine | grep '64.*linux' > /dev/null; then \
		mv rel/saveme rel/saveme.linux64; \
	elif gcc -dumpmachine | grep '386.*linux' > /dev/null; then \
		mv rel/saveme rel/saveme.linux32; \
	fi

rel/%: %
	cp -a "$<" "$@"

