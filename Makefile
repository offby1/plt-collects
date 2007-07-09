# at Amazon, you'd invoke this makefile like this:

# make mzscheme="/apollo/bin/env /apollo/env/hanchrow-PLT/bin/mzscheme" planet="/apollo/bin/env /apollo/env/hanchrow-PLT/bin/planet"

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

# TODO -- find a way of examining the installed thingy, and seeing if
# it's actually older than the current plt-file.
install: $(plt-file)
	-$(MAKE) uninstall
	$(planet) --file $^ $(owner) $(version)

uninstall:
	$(planet)  --erase $(owner) $(plt-file) $(version)

.PHONY: clean install uninstall
