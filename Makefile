mzscheme := mzscheme
planet   := planet

plt-file := offby1.plt
owner := offby1
version := 2 0

$(plt-file): $(wildcard *.ss *.scm) doc.txt
	$(planet) create . 

.PHONY: doc
doc:
	setup-plt -P $(owner) $(plt-file) $(version)

clean:
	rm -rf $(plt-file) compiled

install: 
	$(planet) link $(owner) $(plt-file) $(version) $$(pwd)

uninstall:
	$(planet) --erase $(owner) $(plt-file) $(version)

.PHONY: clean install uninstall
