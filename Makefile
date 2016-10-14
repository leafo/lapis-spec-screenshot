.PHONY: local lint build

local: build
	luarocks make --local lapis-spec-screenshot-dev-1.rockspec

build: 
	moonc lapis
 
lint:
	moonc -l lapis

