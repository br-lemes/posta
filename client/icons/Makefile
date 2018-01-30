
PNG=$(wildcard *.png)
LUA=$(patsubst %.png,%.lua,$(PNG))

all: ../icons.lua

../icons.lua: $(LUA)
	lua convert.lua $^

%.lua: %.png
	iupview -t LUA -o $@ $<

clean:
	rm -f $(LUA)

.PHONY: all clean
