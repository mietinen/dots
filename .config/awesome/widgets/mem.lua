-- Memory widget

local wibox = require("wibox")
local spawn = require("awful.spawn")
local gears = require("gears")
local naughty = require("naughty")

local widget = {}
local function worker(args)

    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/devices/"
    local timeout = args.timeout or 5
    local margin = args.margin or 3

    widget = wibox.widget {
        {
            {
                id = "icon",
                image = path_to_icons.."ram-symbolic.svg",
                resize = true,
                widget = wibox.widget.imagebox,
            },
            top = margin,
            bottom = margin,
            right = margin,
            widget = wibox.container.margin
        },
        {
            id = "text",
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
    }

    local update_widget = function()
        local f = assert(io.open("/proc/meminfo", "r"))
        local proc = f:read("*all")
        f:close()
        local memtotal = tonumber(string.match(proc, "MemTotal:%s+(%d+)"))
        local shmem = tonumber(string.match(proc, "Shmem:%s+(%d+)"))
        local memfree = tonumber(string.match(proc, "MemFree:%s+(%d+)"))
        local buffers = tonumber(string.match(proc, "Buffers:%s+(%d+)"))
        local cached = tonumber(string.match(proc, "Cached:%s+(%d+)"))
        local sreclaimable = tonumber(string.match(proc, "SReclaimable:%s+(%d+)"))

        local mem_used = memtotal + shmem - memfree - buffers - cached - sreclaimable
        local mem_percent = math.floor((100 * mem_used / memtotal) + 0.5)
        local mem_text = string.format("%.1fG/%.1fG", mem_used / 1048576, memtotal / 1048576)

        widget:get_children_by_id('text')[1].markup = mem_percent.."% ("..mem_text..")"
    end
    timer = gears.timer {
        timeout = timeout,
        call_now  = true,
        autostart = true,
        callback  = function() update_widget() end
    }

    local notification
    local show_status = function()
        spawn.easy_async([[bash -c "ps axc -eo pid,cmd:20,%cpu,%mem --sort=-%mem | head -n 11"]],
        function(stdout, stderr, exitreason, exitcode)
            naughty.destroy(notification)
            notification = naughty.notify {
                title = "Memory hogs",
                text =  stdout,
                icon = path_to_icons.."ram-symbolic.svg",
                timeout = 5,
                screen = mouse.screen
            }
        end)
    end

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then show_status() end
    end)

    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
