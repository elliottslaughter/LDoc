LUA= $(shell echo `which terra`)
LUA_BINDIR= $(shell echo `dirname $(LUA)`)
TERRA_RELEASE = $(CURDIR)/../terra/release

ifneq ($(wildcard ../terra/build/luajit/share/luajit-2.0.5/.*),)
	PREFIX=$(CURDIR)/../terra/build/luajit
else
	PREFIX=$(CURDIR)/../terra/build/
endif

LUA_SHAREDIR=$(PREFIX)/share/luajit-2.0.5

ifeq ($(shell uname -s),Darwin)
	LIB_OPTION= -bundle -undefined dynamic_loopkup
else
	LIB_OPTION= -shared
endif

ldoc: penlight

fs: luafilesystem
	make -C luafilesystem LUA_INC=-I${TERRA_RELEASE}/include/terra LIB_OPTION=$(LIB_OPTION)
	make -C luafilesystem PREFIX=$(PREFIX) install

penlight: Penlight fs
	ln -sfn $(CURDIR)/Penlight/lua/pl $(PREFIX)/share/luajit-2.0.5/

install: install_parts
	echo "terra $(CURDIR)/ldoc.lua \$$*" > $(TERRA_RELEASE)/bin/ldoc
	chmod +x $(TERRA_RELEASE)/bin/ldoc

install_parts:
	mkdir -p $(DESTDIR)$(LUA_SHAREDIR)
	cp ldoc.lua $(DESTDIR)$(LUA_SHAREDIR)
	cp -r ldoc $(DESTDIR)$(LUA_SHAREDIR)

uninstall:
	-rm $(DESTDIR)$(LUA_SHAREDIR)/ldoc.lua
	-rm -r $(DESTDIR)$(LUA_SHAREDIR)/ldoc
	-rm $(DESTDIR)$(LUA_BINDIR)/ldoc

test: test-basic test-example test-md test-tables

RUN=&&  ldoc . && diff -r docs cdocs && echo ok

test-basic:
	cd tests $(RUN)

test-example:
	cd tests && cd example $(RUN)

test-md:
	cd tests && cd md-test $(RUN)

test-tables:
	cd tests && cd simple $(RUN)

test-clean: clean-basic clean-example clean-md clean-tables

CLEAN=&& ldoc . && rd /S /Q cdocs && cp -rf docs cdocs

clean-basic:
	cd tests $(CLEAN)

clean-example:
	cd tests && cd example $(CLEAN)

clean-md:
	cd tests && cd md-test $(CLEAN)

clean-tables:
	cd tests && cd simple $(CLEAN)
