local slugify
slugify = require("lapis.util").slugify
local get_file_name
get_file_name = function(context)
  local busted = require("busted")
  local names = {
    context.name or context.descriptor
  }
  while true do
    context = busted.parent(context)
    if not (context) then
      break
    end
    local name = context.name or context.descriptor
    if context.descriptor == "file" then
      break
    end
    table.insert(names, 1, name)
  end
  do
    local _accum_0 = { }
    local _len_0 = 1
    for _index_0 = 1, #names do
      local name = names[_index_0]
      _accum_0[_len_0] = slugify(assert(name:gsub("#%w*", ""):match("^%s*(.-)%s*$"), "no spec name"))
      _len_0 = _len_0 + 1
    end
    names = _accum_0
  end
  return table.concat(names, ".")
end
local screenshot_path
do
  local counts = { }
  screenshot_path = function(spec_name)
    local full_name
    if counts[spec_name] then
      counts[spec_name] = counts[spec_name] + 1
      full_name = tostring(spec_name) .. "." .. tostring(counts[spec_name])
    else
      counts[spec_name] = 1
      full_name = spec_name
    end
    local config = require("lapis.config").get()
    local dir = config.spec_screenshots_dir or "spec/screenshots"
    return tostring(dir) .. "/" .. tostring(full_name) .. ".png"
  end
end
local parse_query_string, encode_query_string
do
  local _obj_0 = require("lapis.util")
  parse_query_string, encode_query_string = _obj_0.parse_query_string, _obj_0.encode_query_string
end
return function(options)
  local busted = require("busted")
  local handler = require("busted.outputHandlers.utfTerminal")(options)
  local spec_name
  busted.subscribe({
    "test",
    "start"
  }, function(context)
    spec_name = get_file_name(context)
  end)
  busted.subscribe({
    "test",
    "end"
  }, function()
    spec_name = nil
  end)
  busted.subscribe({
    "lapis",
    "html"
  }, function(html, opts)
    local fname = screenshot_path(spec_name)
    local f = io.popen("wkhtmltoimage -q - '" .. tostring(fname) .. "'", "w")
    f:write(html)
    return f:close()
  end)
  busted.subscribe({
    "lapis",
    "screenshot"
  }, function(url, opts)
    assert(spec_name, "no spec name set")
    local get_current_server
    get_current_server = require("lapis.spec.server").get_current_server
    local server = get_current_server()
    if opts.get then
      local _, url_query = url:match("^(.-)%?(.*)$")
      local get_params = url_query and parse_query_string(url_query) or { }
      for k, v in pairs(opts.get) do
        get_params[k] = v
      end
      url = url:gsub("(%?.*)$", "") .. "?" .. encode_query_string(get_params)
    end
    local host, path = url:match("^https?://([^/]*)(.*)$")
    local headers
    do
      local _accum_0 = { }
      local _len_0 = 1
      for k, v in pairs(opts.headers or { }) do
        _accum_0[_len_0] = "--custom-header '" .. tostring(k) .. "' '" .. tostring(v) .. "'"
        _len_0 = _len_0 + 1
      end
      headers = _accum_0
    end
    if host then
      table.insert(headers, "--custom-header 'Host' '" .. tostring(host) .. ":" .. tostring(server.app_port) .. "'")
    else
      path = url
    end
    local full_url = "http://127.0.0.1:" .. tostring(server.app_port) .. tostring(path)
    headers = table.concat(headers, " ")
    local cmd = "wkhtmltoimage -q " .. tostring(headers) .. " '" .. tostring(full_url) .. "' '" .. tostring(screenshot_path(spec_name)) .. "'"
    return assert(os.execute(cmd))
  end)
  return handler
end
