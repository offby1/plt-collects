mzscheme := mzscheme
planet   := planet

plt-file := offby1.plt
owner := offby1
version := 1 2

$(plt-file): $(wildcard *.ss *.scm) doc.txt
	$(planet) --create-archive . 

clean:
	-rm $(plt-file)

# planet --file gacks if it's already installed, so we uninstall first.

install: 
	$(planet) --associate $(owner) $(plt-file) $(version) $$(pwd)

uninstall:
	$(planet) --erase $(owner) $(plt-file) $(version)

.PHONY: clean install uninstall
