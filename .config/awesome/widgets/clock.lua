-- Clock and calendar widget

local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local widget = {}

local function worker(args)

    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/apps/"
    local margin = args.margin or 3

    local styles = {}
    styles.month = {
        padding = 5,
        bg_color = beautiful.bg_normal,
        border_width = 2,
        shape = gears.shape.rounded_rect
    }
    styles.normal = {
        shape = gears.shape.rounded_rect
    }

    styles.focus = {
        fg_color = beautiful.fg_focus,
        bg_color = beautiful.bg_focus,
        markup = function(t) return '<b>'..t..'</b>' end,
        shape =gears.shape.rounded_rect
    }
    styles.header = {
        fg_color = beautiful.fg_normal,
        bg_color = beautiful.bg_normal,
        markup = function(t) return '<b>'..t..'</b>' end,
        shape =gears.shape.rounded_rect
    }
    styles.weekday = {
        fg_color = beautiful.fg_urgent,
        bg_color = beautiful.bg_normal,
        markup = function(t) return '<b>'..t..'</b>' end,
        shape =gears.shape.rounded_rect
    }
    styles.weeknumber = {
        fg_color = beautiful.fg_urgent,
        bg_color = beautiful.bg_normal,
        shape = gears.shape.rounded_rect
    }
    local function decorate_cell(widget, flag, date)
        if flag=='monthheader' and not styles.monthheader then
            flag = 'header'
        end
        local props = styles[flag] or {}
        if props.markup and widget.get_text and widget.set_markup then
            widget:set_markup(props.markup(widget:get_text()))
        end
        -- Change bg color for weekends
        local d = {year=date.year, month=(date.month or 1), day=(date.day or 1)}
        local weekday = tonumber(os.date('%w', os.time(d)))
        local default_bg = (weekday==0 or weekday==6) and beautiful.bg_minimize or beautiful.bg_normal
        local ret = wibox.widget {
            {
                widget,
                margins = (props.padding or 2) + (props.border_width or 0),
                widget = wibox.container.margin
            },
            shape = props.shape,
            shape_border_color = props.border_color or beautiful.border_normal,
            shape_border_width = props.border_width or 0,
            fg = props.fg_color or beautiful.fg_normal,
            bg = props.bg_color or default_bg,
            widget = wibox.container.background
        }
        return ret
    end

    widget = wibox.widget {
        {
            {
                id = "icon",
                image = path_to_icons.."clock-applet-symbolic.svg",
                resize = true,
                widget = wibox.widget.imagebox,
            },
            top = margin,
            bottom = margin,
            right = margin,
            widget = wibox.container.margin
        },
        {
            id = "clock",
            format = "%a %d %b, %H:%M",
            widget = wibox.widget.textclock,
        },
        layout = wibox.layout.fixed.horizontal,
    }

    local month = wibox.widget {
        date = os.date('*t'),
        long_weekdays = true,
        week_numbers = true,
        start_sunday = false,
        fn_embed = decorate_cell,
        widget = wibox.widget.calendar.month
    }
    local year = wibox.widget {
        date = os.date('*t'),
        long_weekdays = true,
        week_numbers = true,
        start_sunday = false,
        fn_embed = decorate_cell,
        widget = wibox.widget.calendar.year
    }
    local popup_month = awful.popup {
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_color = beautiful.border_focus,
        offset = { y = 5 },
        border_width = 1,
        widget = month,
        type = "dock"
    }
    local popup_year = awful.popup {
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_color = beautiful.border_focus,
        offset = { y = 5 },
        border_width = 1,
        widget = year,
        type = "dock"
    }

    local toggle = function(huge)
        if popup_month.visible or popup_year.visible then
            popup_month.visible = false
            popup_year.visible = false
        else
            if huge then
                year:set_date(nil)
                year:set_date(os.date('*t'))
                popup_year:set_widget(nil)
                popup_year:set_widget(year)
                awful.placement.top_right(popup_year, { margins = { top = 30, right = 10}, parent = awful.screen.focused() })
                popup_year.visible = true
            else
                month:set_date(nil)
                month:set_date(os.date('*t'))
                popup_month:set_widget(nil)
                popup_month:set_widget(month)
                awful.placement.top_right(popup_month, { margins = { top = 30, right = 10}, parent = awful.screen.focused() })
                popup_month.visible = true
            end

        end
    end

    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then toggle(false)
        elseif button == 3 then toggle(true)
        end
    end)

    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
