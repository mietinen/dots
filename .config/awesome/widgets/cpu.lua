-- CPU widget

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")
local gears = require("gears")
local naughty = require("naughty")

local widget = {}
local function worker(args)

    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/devices/"
    local timeout = args.timeout or 2
    local timeout_temp = args.timeout_temp or 10
    local margin = args.margin or 3

    local get_temp_cmd = args.get_temp_cmd or [[cat /sys/class/thermal/thermal_zone0/temp]]
    local get_ps_cmd = args.get_ps_cmd or [[bash -c "ps axc -eo pid,cmd:20,%cpu,%mem --sort=-%cpu | head -n 11"]]

    widget = wibox.widget {
        {
            {
                id = "icon",
                image = path_to_icons.."cpu-symbolic.svg",
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
        {
            id = "text_temp",
            widget = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
    }
    local usage = {}
    local update_usage = function()
        local f = assert(io.open("/proc/stat", "r"))
        local proc = f:read("*all")
        f:close()
        for name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice in
            string.gmatch(proc, '(cpu%d*)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)') do
            local total = user + nice + system + idle + iowait + irq + softirq + steal
            if usage[name] == nil then usage[name] = {} end
            local diff_idle = idle - tonumber(usage[name].idle_prev == nil and 0 or usage[name].idle_prev)
            local diff_total = total - tonumber(usage[name].total_prev == nil and 0 or usage[name].total_prev)
            usage[name].usage = math.floor((100 * (diff_total - diff_idle) / diff_total) + 0.5)
            usage[name].total_prev = total
            usage[name].idle_prev = idle
            if name == "cpu" then
                widget:get_children_by_id('text')[1].markup = usage[name].usage.."%"
            end
        end
    end
    timer = gears.timer {
        timeout = timeout,
        call_now  = true,
        autostart = true,
        callback  = function() update_usage() end
    }

    local update_temp = function(widget, stdout, _, _, _)
        local temp = string.match(stdout, "(%d+)")
        if temp == nil then return end
        widget:get_children_by_id('text_temp')[1].markup = " ("..(temp / 1000).."°)"
    end
    watch(get_temp_cmd, timeout_temp, update_temp, widget)

    local notification
    local show_status = function()
        spawn.easy_async(get_ps_cmd,
        function(stdout, stderr, exitreason, exitcode)
            local tkeys = {}
            for k in pairs(usage) do table.insert(tkeys, k) end
            table.sort(tkeys)
            local usage_string = "\n\tCORE\t\tUSAGE\n"
            for _, k in ipairs(tkeys) do
                usage_string = usage_string.."\t"..k.."\t\t "..usage[k].usage.."%\n"
            end
            naughty.destroy(notification)
            notification = naughty.notify {
                title = "CPU hogs",
                text = stdout..usage_string,
                icon = path_to_icons.."cpu-symbolic.svg",
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
