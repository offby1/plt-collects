planet   := raco planet

plt-file := offby1.plt
owner := offby1
version := 2 2

$(plt-file): $(wildcard *.ss *.scm *.rkt)
	$(planet) create . && mv -v "$$(basename $$(pwd)).plt" "$@"

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
