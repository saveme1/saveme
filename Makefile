ADOCS:=$(shell find html -name '*.adoc')
SRC= *.pas *.lpi *.lps *.lfm html.zip saveme.tag
BLDOPTS= -B
CROSSFPC="/usr/local/lib/fpc/2.6.4/ppcross386"
#BLDOPTS=

.PHONY: clean rel all gittag

saveme: $(SRC)
	lazbuild $(BLDOPTS) --bm=Release saveme.lpi
	cp saveme saveme.linux64

saveme.exe: $(SRC)
	wine "$$WINEAPPS/lazarus/lazbuild.exe" $(BLDOPTS) --bm=Release saveme.lpi

saveme.ver: saveme
	@if [ -z "$$DISPLAY" ]; then \
		echo "*** ERROR: DISPLAY needs to be set for saveme -v"; \
		echo ; \
	else \
	   ./saveme -v 2>/dev/null | tr -d \\n | cat > $@; \
	fi

gittag:
	echo \'`git describe --tags`\' > saveme.tag

all: saveme saveme.exe saveme.ver

html.zip: $(ADOCS)
	cd html && make

#folowing  target not working yet
saveme.linux32: $(SRC)
	lazbuild $(BLDOPTS) --compiler="$(CROSSFPC)" --cpu=i386 --os=linux --bm=Release saveme.lpi
	mv saveme saveme.linux32

clean:
	cd html && make clean
	rm saveme saveme.exe saveme.ver

rel: gittag rel/saveme rel/saveme.exe rel/saveme.ver
	if gcc -dumpmachine | grep '64.*linux' > /dev/null; then \
		mv rel/saveme rel/saveme.linux64; \
	elif gcc -dumpmachine | grep '386.*linux' > /dev/null; then \
		mv rel/saveme rel/saveme.linux32; \
	fi

rel/%: %
	cp -a "$<" "$@"

