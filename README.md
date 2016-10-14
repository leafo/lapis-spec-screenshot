
# lapis-spec-screenshot

`lapis-spec-screenshot` provides a busted output handler that, in addition to
rendering the normal output, listens for special Lapis request events. Upon
being notified, it will use the tool `wkhtmltoimage` to screenshot the running
attached spec server at the specified URL.

This tool can be used to help discover visual regressions on your webpage by
giving you screenshots for each test request to view. (Further automation can
be done as you see fit)

> [wkhtmltoimage](http://wkhtmltopdf.org/) must be installed on your system for
> this library to work. Consult your package manager.

## Install

```bash
luarocks install 
```

## Usage

When running `busted`, pass the module name for the screenshot output handler:

```bash
busted -o "lapis.spec.screenshot"
```

The tests will now listen to `screenshot` and `html` events.

* `screenshot` - takes a URL to request. Saves a snapshot to the screenshot directory (default `spec/screenshots`)
* `html` - takes HTML to render

The name of the image written is calculated by the full name of the test
(including any wrapping describes)

You can then provide an alternate implementation of `request`

```lua
-- spec/helpers.lua
local server = require "lapis.spec.server"

local function request(url, opts)
  local out = { server.request url, opts, ... }
  local opts = opts or {}

  local busted = require "busted"

  if out[1] == 200 and not opts.post and out[3].content_type == "text/html" then
    busted.publish({"lapis", "screenshot"}, url, opts, ...)
  end

  return unpack(out)
end

return { request = request }
```

Use this in place of the regular request method to automatically take a
screenshot on every 200 request that returns HTML.
