-- Timer Counter Widget
-- Nome: TmrCnt
--
-- File: "main.lua"
-- Da collocare in "/WIDGETS/TmrCnt/"



local played = false

local options = {
        { "Color", COLOR, BLUE }, 
        { "Timer", VALUE, 1, 1, 3 }, -- Timer 1, 2 o 3
        { "Alert", VALUE, 30, 15, 180 } -- Numero di secondi fra ciascun annuncio
}

local function create (zone, options)
        local widget = { zone=zone, options=options }
        return widget
end

local function update(widget, options)
        if (widget ~= nil) then
                widget.options = options
        end
end


local function drawByWidgetSize(widget, timer)
        local timerInfo = string.format("T%s:", widget.options.Timer)
        lcd.setColor(CUSTOM_COLOR, widget.options.Color)

        -- Widget a schermo intero
        if widget.zone.w > 380 and widget.zone.h > 165 then
                lcd.drawText(widget.zone.x, widget.zone.y, timerInfo, DBLSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x + 100, widget.zone.y + 40, timer.value, XXLSIZE + CUSTOM_COLOR)

        -- Widget Grande
        elseif widget.zone.w > 180 and widget.zone.h > 145 then
                lcd.drawText(widget.zone.x, widget.zone.y, timerInfo, MIDSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x + 13, widget.zone.y + 25, timer.value, XXLSIZE + CUSTOM_COLOR)

        -- Widget Medio
        elseif widget.zone.w > 170 and widget.zone.h > 65 then
                lcd.drawText(widget.zone.x, widget.zone.y, timerInfo, SMLSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x + 3, widget.zone.y + 5, timer.value, XXLSIZE + CUSTOM_COLOR)

        --Widget Piccolo
        elseif  widget.zone.w > 150 and widget.zone.h > 28 then
                lcd.drawText(widget.zone.x, widget.zone.y + 7, timerInfo, SMLSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x + 70, widget.zone.y + 1, timer.value, MIDSIZE + CUSTOM_COLOR)

        -- Widget nella barra superiore
        elseif widget.zone.w > 65 and widget.zone.h > 35 then
                lcd.drawText(widget.zone.x, widget.zone.y, timerInfo, SMLSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x, widget.zone.y + 10, timer.value, MIDSIZE + CUSTOM_COLOR)
        else
                lcd.drawText(widget.zone.x, widget.zone.y, "Insufficient space", SMLSIZE + CUSTOM_COLOR)
        end
end
        

local function playTimer(timer, alert)
        if timer.value % alert == 1 then
                played = false
        end

        if  timer.value % alert == 0 and timer.value ~= 0 then
                if played == false then
                        playDuration(timer.value, 0)
                        played = true
                end
        end
end 


local function refresh(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        drawByWidgetSize(widget, timer)
        playTimer(timer, widget.options.Alert)
end


local function background(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        playTimer(timer, widget.options.Alert)
end


return { name="TmrCnt", options=options, create=create, update=update, background=background, refresh=refresh }
