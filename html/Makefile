DIRS=en
AOPTS=-a 'iconsdir=html/images' -a 'imagesdir=html/images'

html:
	for i in $(DIRS); do \
		cd $$i; \
		asciidoc $(AOPTS) *.adoc; \
		sed -i -e '/Last updated/ d' *.html; \
	done
