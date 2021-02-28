.PHONY: local lint build

local: build
	luarocks --lua-version=5.1 make --local lapis-spec-screenshot-dev-1.rockspec

build: 
	moonc lapis
 
lint:
	moonc -l lapis

