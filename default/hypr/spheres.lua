-- Spherie: every sphere window gets its sphere's border color and tag.
--
-- The host's waypipe client for each sphere prepends "[<sphere>] " to every
-- window title (see default/systemd/user/spherie-gui@.service), and the
-- vsock router only connects a sphere to its own client. A sphere can't
-- choose that prefix, so these rules can't be spoofed by a sphere's apps.

local conf_dir = "/etc/spherie/spheres"

local function read_sphere(path)
  local values = {}
  local file = io.open(path, "r")
  if not file then
    return nil
  end
  for line in file:lines() do
    local key, value = line:match("^([A-Z_]+)=(.*)$")
    if key then
      values[key] = value:gsub("^[\"']", ""):gsub("[\"']$", "")
    end
  end
  file:close()
  return values
end

local listing = io.popen("ls " .. conf_dir .. "/*.conf 2>/dev/null")
if listing then
  for path in listing:lines() do
    local sphere = read_sphere(path)
    if sphere and sphere.NAME and sphere.HIDDEN ~= "1" and sphere.NAME:match("^[a-z0-9-]+$") then
      local color = (sphere.COLOR or "888888"):match("^%x%x%x%x%x%x$") or "888888"
      o.window({ title = "^\\[" .. sphere.NAME .. "\\] " }, {
        border_color = "rgb(" .. color .. ")",
        tag = "+sphere-" .. sphere.NAME,
      })
    end
  end
  listing:close()
end

if _G.omarchy_default_bindings ~= false then
  o.bind("SUPER + D", "Sphere apps", "omarchy-sphere-menu")
  -- Variants of universal copy/paste that cross spheres, once (see omarchy-sphere-clip).
  o.bind("SUPER + ALT + C", "Copy to another sphere", "omarchy-sphere-clip copy")
  o.bind("SUPER + ALT + V", "Paste from another sphere", "omarchy-sphere-clip paste")
end
