mzscheme := mzscheme
planet   := planet

plt-file := offby1.plt
owner := offby1
version := 2 0

$(plt-file): $(wildcard *.ss *.scm) doc.txt
	$(planet) create . 

clean:
	-rm $(plt-file)

install: 
	$(planet) link $(owner) $(plt-file) $(version) $$(pwd)

uninstall:
	$(planet) --erase $(owner) $(plt-file) $(version)

.PHONY: clean install uninstall
