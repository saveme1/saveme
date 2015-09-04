DIRS=en
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
#current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
current_dir := $(shell pwd)
AOPTS=-b html5 -a 'iconsdir=html/images' -a 'imagesdir=html/images' -a 'stylesdir=$(current_dir)/'
#AOPTS=-b html5 -a 'iconsdir=html/images' -a 'imagesdir=html/images'
ADOCS:=$(shell find . -name '*.adoc')

HTMLVERSION: ../html.zip
	../saveme_md5 ../html.zip ../HTMLVERSION

../html.zip: $(ADOCS:.adoc=.html) images/*.png
	cd .. && zip html.zip $(addprefix html/,$^)

%.html: %.adoc
	asciidoc $(AOPTS) $<
	sed -i -e '/Last updated/ d' $@

clean:
	rm $(ADOCS:.adoc=.html)
