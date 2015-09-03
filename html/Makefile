DIRS=en
AOPTS=-a 'iconsdir=html/images' -a 'imagesdir=html/images'
ADOCS:=$(shell find . -name '*.adoc')

HTMLVERSION: ../html.zip
	../saveme_md5 ../html.zip ../HTMLVERSION

../html.zip: $(ADOCS:.adoc=.html) images/*.png
	cd .. && zip html.zip $(addprefix html/,$^)

%.html: %.adoc
	asciidoc $(AOPTS) $<
	sed -i -e '/Last updated/ d' $@

html:
	echo $(HTMLS)
	echo $(ADOCS)
	for i in $(DIRS); do \
		cd $$i; \
		for f in *.adoc; do \
		   asciidoc $(AOPTS) $$f; \
		done; \
		sed -i -e '/Last updated/ d' *.html; \
	done
