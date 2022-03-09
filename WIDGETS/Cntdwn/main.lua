-- File main.lua
-- Script "Countdown Timer"
--
-- Nome: "Cntdwn"
-- Da collocare in "/WIDGETS/Cntdwn/"

local options = {
        { "Color", COLOR, BLUE },
        { "Timer", VALUE, 1, 1, 3 },
        { "Start", VALUE, 180, 30, 600 }
}

local Total             
local NextSecond = 11   
local Played            
local Elapsed           

local function create (zone, options)
        local widget = { zone=zone, options=options }
        Total = widget.options.Start
        Played = false
        Elapsed = false
        return widget
end

local function update(widget, options)
        if (widget ~= nil) then
                widget.options = options
        end
        Total = widget.options.Start
        Played = false
        Elapsed = false
end

local function drawByWidgetSize(widget, countdown)
        lcd.setColor(CUSTOM_COLOR, widget.options.Color)

        -- Widget a schermo intero
        if widget.zone.w > 380 and widget.zone.h > 165 then
                lcd.drawText(widget.zone.x, widget.zone.y, "Countdown", DBLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 140, widget.zone.y + 40, countdown, XXLSIZE + CUSTOM_COLOR)

        -- Widget Grande
        elseif widget.zone.w > 180 and widget.zone.h > 145 then
                lcd.drawText(widget.zone.x, widget.zone.y, "Countdown", MIDSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 13, widget.zone.y + 25, countdown, XXLSIZE + CUSTOM_COLOR)

        -- Widget Medio
        elseif widget.zone.w > 170 and widget.zone.h > 65 then
                lcd.drawText(widget.zone.x, widget.zone.y, "Countdown", SMLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 3, widget.zone.y + 5, countdown, XXLSIZE + CUSTOM_COLOR)

        -- Widget Piccolo
        elseif  widget.zone.w > 150 and widget.zone.h > 28 then
                lcd.drawText(widget.zone.x, widget.zone.y + 7, "Countdown", SMLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 90, widget.zone.y + 1, countdown, MIDSIZE + CUSTOM_COLOR)

        -- Widget della barra superiore
        elseif widget.zone.w > 65 and widget.zone.h > 35 then
                lcd.drawText(widget.zone.x, widget.zone.y, "Countdown", SMLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x, widget.zone.y + 10, countdown, MIDSIZE + CUSTOM_COLOR)
        else
                lcd.drawText(widget.zone.x, widget.zone.y, "Insufficient space", SMLSIZE + CUSTOM_COLOR)
        end
end

local function resetPlayedFlag(countdown, NextSecond)
        if countdown % 60 == 59 then
                Played = false
        elseif countdown == 29 or countdown == 14 then
                Played = false
        elseif countdown <= 10 and Elapsed ~= true and countdown ~= NextSecond then
                Played = false
        end
end

local function playTime(countdown)
        local seconds = countdown % 60 
        local minutes = (countdown - seconds) / 60

        if Played == true then
                resetPlayedFlag(countdown, NextSecond)
        end

        if Played == false then
                if countdown > 30 then
                        -- viene riprodotto ogni minuto
                        if countdown % 60 == 0 and countdown ~= Total then
                                if minutes ~= 0 and seconds == 0 then
                                        playNumber(minutes, 36)
                                else
                                        playNumber(minutes, 36)
                                        playNumber(seconds, 37)
                                end
                                Played = true
                        end
                -- riproduce gli ultimi 30 secondi
                elseif countdown == 30 then
                        playNumber(countdown, 37)
                        Played = true
                elseif countdown == 15 then
                        playNumber(countdown, 37)
                        Played = true
                -- riproduce gli ultimi 10 secondi
                elseif countdown <= 10 and countdown > 0 then
                        playNumber(countdown, UNIT_RAW)
                        Played = true
                        NextSecond = countdown
                -- il conto alla rovescia è terminato
                elseif countdown == 0 then
                        playFile("/WIDGETS/Cntdwn/timelpsd.wav")
                        Played = true
                        Elapsed = true
                end
        end
end


local function refresh(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        local countdown

        if Total - timer.value > 0 then
                countdown = Total - timer.value
        else
                countdown = 0
        end

        drawByWidgetSize(widget, countdown)

        if Elapsed == false then
                playTime(countdown)
        end
end


local function background(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        local countdown

        if Total - timer.value > 0 then
                countdown = Total - timer.value
        else
                countdown = 0
        end

        if Elapsed == false then
                playTime(countdown)
        end
end


return { name="Cntdwn", options=options, create=create, update=update, background=background, refresh=refresh }
