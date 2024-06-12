-- Iface widget

local wibox = require("wibox")
local watch = require("awful.widget.watch")
local spawn = require("awful.spawn")
local gears = require("gears")
local naughty = require("naughty")

local widget = {}
local function worker(args)
    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/status/"
    local timeout = args.timeout or 10
    local margin = args.margin or 3

    local get_iface_cmd = args.get_iface_cmd or [[bash -c "ip r get 1 ; echo -n 'pubip:' ; pubip -last ; echo -n 'netspeed:' ; netspeed -short ; grep '^nameserver' /etc/resolv.conf"]]

    widget = wibox.widget {
        {
            {
                id = "icon",
                image = path_to_icons.."network-offline-symbolic.svg",
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
    -- pubip update
    gears.timer {
        timeout   = 300,
        call_now  = true,
        autostart = true,
        callback  = function()
            spawn.easy_async("pubip -update", function(_, _, _, _) end)
        end
    }
    local signal = ""
    local function signal_update()
        -- awful.spawn.easy_async("awk 'NR==3 {printf \"%3.0f\" ,($3/70)*100}' /proc/net/wireless", function(stdout, stderr, reason, exit_code)
            spawn.easy_async([[bash -c "awk 'NR==3 {printf \"%3.0f\" ,(\$3/70)*100}' /proc/net/wireless"]],
            function(stdout, stderr, reason, exitcode)
            signal = (tonumber(stdout) or 0).."%"
        end)
    end
    local iface, addr, gateway, pubip, rxspeed, txspeed, dns
    local update_widget = function(widget, stdout, _, _, _)
        iface = string.match(stdout, "dev%s+(%w+)") or 0
        addr = string.match(stdout, "src%s+(%d+%.%d+%.%d+%.%d+)") or 0
        gateway = string.match(stdout, "via%s+(%d+%.%d+%.%d+%.%d+)") or 0
        pubip = string.match(stdout, "pubip:(%d+%.%d+%.%d+%.%d+)") or 0
        rxspeed, txspeed = string.match(stdout, "netspeed:(%S*)%s+(%S*)")
        dns = string.match(stdout, "nameserver (%d+%.%d+%.%d+%.%d+)") or 0

        if string.match(iface, '^en.*$') then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."network-wired-symbolic.svg"
            signal = ""
        elseif string.match(iface, '^wl.*$') then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."network-wireless-connected-symbolic.svg"
            signal_update()
        elseif string.match(iface, '^ww.*$') then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."network-cellular-connected-symbolic.svg"
            signal = ""
        elseif string.match(iface, '^tun.*$') then
            widget:get_children_by_id('icon')[1].image = path_to_icons.."network-vpn-symbolic.svg"
            signal = ""
        else
            widget:get_children_by_id('icon')[1].image = path_to_icons.."network-offline-symbolic.svg"
            signal = ""
        end
        -- widget:get_children_by_id('text')[1].markup = signal.." (↓"..rxspeed.." ↑"..txspeed..")"
        widget:get_children_by_id('text')[1].markup = signal
    end

    local notification
    local show_status = function()
        naughty.destroy(notification)
        notification = naughty.notify {
            title = "Network:\t"..iface.." ("..signal.."%)",
            text = "Local:\t\t"..addr.."\nGW:\t\t"..gateway.."\nPublic:\t\t"..pubip.."\nDNS:\t\t"..dns.."\n\nDown:\t\t"..rxspeed.."\nUp:\t\t"..txspeed,
            icon = path_to_icons.."network-transmit-receive-symbolic.svg",
            timeout = 5,
            screen = mouse.screen
        }
    end

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then show_status() end
    end)

    watch(get_iface_cmd, timeout, update_widget, widget)
    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
