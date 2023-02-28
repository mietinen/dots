-- Battery widget

local wibox = require("wibox")
local gears = require("gears")
local gfs = require("gears.filesystem")

local widget = {}
local function worker(args)
    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/status/"
    local timeout = args.timeout or 10
    local margin = args.margin or 3
    local bat = args.bat or 'BAT0'
    local path = "/sys/class/power_supply/"..bat

    if not gfs.dir_readable(path) then
        return wibox.widget {
            {
                {
                    id = "icon",
                    image = path_to_icons.."battery-missing-symbolic.svg",
                    resize = true,
                    widget = wibox.widget.imagebox,
                },
                top = margin,
                bottom = margin,
                widget = wibox.container.margin
            },
            layout = wibox.layout.fixed.horizontal,
        }
    end

    widget = wibox.widget {
        {
            {
                id = "icon",
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
        local f = assert(io.open(path.."/status", "r"))
        local status = f:read()
        f:close()
        local f = assert(io.open(path.."/capacity", "r"))
        local capacity = tonumber(f:read())
        f:close()

        if (capacity >= 0 and capacity < 15) then bat_icon = "battery-empty%s-symbolic.svg"
        elseif (capacity >= 15 and capacity < 40) then bat_icon = "battery-caution%s-symbolic.svg"
        elseif (capacity >= 40 and capacity < 60) then bat_icon = "battery-low%s-symbolic.svg"
        elseif (capacity >= 60 and capacity < 80) then bat_icon = "battery-good%s-symbolic.svg"
        elseif (capacity >= 80 and capacity <= 100) then bat_icon = "battery-full%s-symbolic.svg"
        end
        if status == 'Charging' then bat_icon = string.format(bat_icon, '-charging')
        else bat_icon = string.format(bat_icon, '')
        end

        widget:get_children_by_id('icon')[1].image = path_to_icons..bat_icon
        widget:get_children_by_id('text')[1].markup = capacity.."%"
    end
    timer = gears.timer {
        timeout = timeout,
        call_now  = true,
        autostart = true,
        callback  = function() update_widget() end
    }
    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
