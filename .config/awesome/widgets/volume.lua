-- Volume widget

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")

local widget = {}
local function worker(args)
    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/status/"
    local timeout = args.timeout or 5
    local margin = args.margin or 3

    local get_volume_cmd = args.get_volume_cmd or "volumectl get"
    local inc_volume_cmd = args.inc_volume_cmd or "volumectl up"
    local dec_volume_cmd = args.dec_volume_cmd or "volumectl down"
    local tog_volume_cmd = args.tog_volume_cmd or "volumectl toggle"
    local mix_volume_cmd = args.mix_volume_cmd or "volumectl control"

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

    local update_widget = function(widget, stdout, _, _, _)
        local volume = math.floor((tonumber(string.match(stdout, "(%d*%.?%d+)")) or 0) * 100)
        local muted = string.match(stdout, "%[MUTED%]")
        if (muted ~= nil) then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."audio-volume-muted-symbolic.svg"
        elseif (tonumber(volume) > 100) then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."audio-volume-overamplified-symbolic.svg"
        elseif (tonumber(volume) > 70) then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."audio-volume-high-symbolic.svg"
        elseif (tonumber(volume) < 30) then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."audio-volume-low-symbolic.svg"
        else
            widget:get_children_by_id('icon')[1].image = path_to_icons.."audio-volume-medium-symbolic.svg"
        end
        widget:get_children_by_id('text')[1].markup = volume.."%"
    end
    local watch, watch_timer = watch(get_volume_cmd, timeout, update_widget, widget)

    widget:connect_signal("button::press", function(_, _, _, button)
        if (button == 1) then
            spawn(tog_volume_cmd, false)
        elseif (button == 3) then
            spawn(mix_volume_cmd, false)
        elseif (button == 4) then
            spawn(inc_volume_cmd, false)
        elseif (button == 5) then
            spawn(dec_volume_cmd, false)
        end

        watch_timer:emit_signal("timeout")
    end)

    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
