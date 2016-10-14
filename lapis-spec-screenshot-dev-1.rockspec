package = "lapis-spec-screenshot"
version = "dev-1"

source = {
  url = "git://github.com/leafo/lapis-spec-screenshot.git",
}

description = {
  summary = "Use wkhtmltoimage to automatically screenshot pages when running tests",
  homepage = "https://github.com/leafo/lapis-spec-screenshot",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
  "lapis",
}

build = {
  type = "builtin",
  modules = {
		["lapis.spec.screenshot"] = "lapis/spec/screenshot.lua",
  }
}

