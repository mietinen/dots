-- yr.no widget

-- Some awesome libraries
local awful = require("awful")
local wibox = require("wibox")
local spawn = require("awful.spawn")
local gears = require("gears")
local beautiful = require("beautiful")
local gfs = require("gears.filesystem")

-- JSON library
-- ~/.config/awesome/lib/json.lua
local json = require("lib.json")

local widget = {}
local popup = {}
local function worker(args)

    local args = args or {}
    local path_to_icons = args.path_to_icons or "/usr/share/icons/Papirus-Dark"
    path_to_icons = path_to_icons.."/symbolic/status/"
    local timeout = args.timeout or 300
    local margin = args.margin or 3
    local location = args.location or os.getenv("LOCATION") or "Oslo"

    local yrdata = {}
    local jsonfile = gfs.get_cache_dir().."/yr.json"

    -- Match symbol_code to icon file
    local icon_match = function(s)
        if s:find('clearsky') then return 'weather-clear-symbolic.svg'
        elseif s:find('fair') or s:find('partlycloudy') then return 'weather-few-clouds-symbolic.svg'
        elseif s:find('cloudy') then return 'weather-overcast-symbolic.svg'
        elseif s == 'fog' then return 'weather-fog-symbolic.svg'
        elseif s:find('snow') then return 'weather-snow-symbolic.svg'
        elseif s:find('heavy') then return 'weather-showers-symbolic.svg'
        elseif s:find('rain') or s:find('sleet') then return 'weather-showers-scattered-symbolic.svg'
        else return 'weather-tornado-symbolic.svg' -- :D
        end
    end

    -- Widget
    widget = wibox.widget {
        {
            {
                id = "icon",
                image = path_to_icons..icon_match('cloudy'),
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

    -- Pupup box
    popup = awful.popup {
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_width = 1,
        margins = 10,
        border_color = beautiful.bg_focus,
        maximum_width = 400,
        type = "dock",
        widget = {}
    }

    -- Update JSON cache file
    --  curl geocode.xyz to get lon/lat
    --  curl api.met.no for weather data
    local update_jsonfile = function()
        spawn.easy_async("curl -s 'https://geocode.xyz/"..location.."?geoit=json'",
        function(stdout, _, _, exitcode)
            local ok, json_table = pcall(json.decode, stdout)
            if exitcode ~= 0 or not ok then return end

            local lat, lon = json_table.latt, json_table.longt
            if lat == nil or lon == nil then return end
            local url = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat="..lat.."&lon="..lon
            spawn.easy_async("curl -s '"..url.."'",
            function(stdout, _, _, exitcode)
                if exitcode ~= 0 then return end
                local f = assert(io.open(jsonfile, "w"))
                f:write(stdout)
                f:close()

            end)
        end)
    end

    -- Update widget and popup box
    local update_widget = function()
        if not gfs.file_readable(jsonfile) then
            widget:get_children_by_id('text')[1].markup = " no data"
            update_jsonfile()
            return
        end

        -- error handling
        local E = {}

        local f = assert(io.open(jsonfile, "r"))
        local data = f:read("*all")
        f:close()
        local ok, json_table = pcall(json.decode, data)

        if not ok or ((json_table.properties or E).meta or E).updated_at == nil then
            widget:get_children_by_id('text')[1].markup = " data error"
            update_jsonfile()
            return
        end

        local rows = {
            { widget = wibox.widget.textbox },
            layout = wibox.layout.fixed.vertical,
        }

        updated_at = json_table.properties.meta.updated_at
        local u_y, u_m, u_d, u_h, u_mi, u_s = string.match(updated_at, "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)")
        local updated_at_unix = os.time{year = u_y, month = u_m, day = u_d, hour = u_h, min = u_mi, sec = u_s}
        local timediff = os.time(os.date("!*t")) - updated_at_unix

        local i = 1
        for _, value in ipairs(json_table.properties.timeseries) do
            local time = value.time
            local year, month, day, hour, min, sec = string.match(time, "(%d+)%-(%d+)%-(%d+)%a(%d+)%:(%d+)%:([%d%.]+)")
            local ostime = os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}

            -- 
            -- Get data for every 6 hours
            if (value.data or E).next_6_hours ~= nil and (tonumber(hour) % 6 == 0 or i == 1) then
                if yrdata[i] == nil then yrdata[i] = {} end
                local symbol_code   = (value.data.next_6_hours.summary or E).symbol_code
                local precipitation = (value.data.next_6_hours.details or E).precipitation_amount
                local winddirection = ((value.data.instant or E).details or E).wind_from_direction
                local windspeed     = ((value.data.instant or E).details or E).wind_speed
                local temperature   = ((value.data.instant or E).details or E).air_temperature
                local pressure      = ((value.data.instant or E).details or E).air_pressure_at_sea_level
                if time == nil or symbol_code == nil or precipitation == nil or winddirection == nil
                    or windspeed == nil or temperature == nil or pressure == nil then
                    widget:get_children_by_id('text')[1].markup = " data error"
                    update_jsonfile()
                    break
                end

                -- Winddirection arrow, and precipitation text
                local windarrow, precipitationtext
                if tonumber(winddirection) <= 22 then windarrow = "↓"
                elseif tonumber(winddirection) <= 67 then windarrow = "↙"
                elseif tonumber(winddirection) <= 112 then windarrow = "←"
                elseif tonumber(winddirection) <= 157 then windarrow = "↖"
                elseif tonumber(winddirection) <= 202 then windarrow = "↑"
                elseif tonumber(winddirection) <= 247 then windarrow = "↗"
                elseif tonumber(winddirection) <= 292 then windarrow = "→"
                elseif tonumber(winddirection) <= 337 then windarrow = "↘"
                else windarrow = "↓" end
                if tonumber(precipitation) > 0 then precipitationtext = ", ("..precipitation.."mm)"
                else precipitationtext = "" end

                -- Icon and text
                yrdata[i].time = os.date("%a, %H:%M", ostime)
                yrdata[i].image = path_to_icons..icon_match(symbol_code)
                yrdata[i].markup = temperature.."°C"..precipitationtext..", "..windarrow..windspeed.."m/s"

                -- First data point goes into widget
                if i == 1 then
                    widget:get_children_by_id('icon')[1].image = yrdata[i].image
                    widget:get_children_by_id('text')[1].markup = yrdata[i].markup
                end
                -- All data points goes into popup box
                local row = wibox.widget {
                    {
                        {
                            markup = yrdata[i].time,
                            widget = wibox.widget.textbox,
                        },
                        left = 15,
                        right = 10,
                        widget = wibox.container.margin
                    },
                    {
                        {
                            image = yrdata[i].image,
                            resize = true,
                            -- forced_height = 15,
                            widget = wibox.widget.imagebox,
                        },
                        margins = margin,
                        widget = wibox.container.margin
                    },
                    {
                        {
                            markup = yrdata[i].markup,
                            widget = wibox.widget.textbox,
                        },
                        right = 15,
                        widget = wibox.container.margin
                    },
                    forced_height = 20,
                    layout = wibox.layout.fixed.horizontal,
                }
                table.insert(rows, row)

                i = i + 1
            end
        end

        -- Update json cache file if over an hour old
        -- give it 5 extra minutes to be sure new data is available
        if timediff > 3900 then update_jsonfile() end
        popup:setup(rows)
    end

    -- Update timer
    timer = gears.timer {
        timeout = timeout,
        call_now  = true,
        autostart = true,
        callback  = function() update_widget() end
    }

    -- Open popup on mouse press
    widget:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            if popup.visible then
                popup.visible = not popup.visible
            else
                popup:move_next_to(mouse.current_widget_geometry)
            end
        end
    end)

    return widget
end

return setmetatable(widget, { __call = function(_, ...) return worker(...) end })
