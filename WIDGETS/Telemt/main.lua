-- Telemetry and Battery Widget
-- Nome: Telemt
--
-- File: "main.lua"
-- Da collocare in "/WIDGETS/Telemt/"

local TxBatterySensor = "tx-voltage"
local RxBatterySensor
local TxVolts
local RxVoltsRxBt
local RxVoltsVFAS
local Voltage

local Samples = {0.0, 0.0, 0.0, 0.0, 0.0} -- vettore di campioni
local SamplesIndex = 1

local zeroPlayed = false
local lowTxBattery = false
local lowTxBatteryPlayed = false
local lowRxBattery = false
local lowRxBatteryPlayed = false

local time = 0
local lastSecondSampled = 0

local options = {
        { "Timer", VALUE, 1, 1, 3 }, 
        { "Alert", VALUE, 30, 15, 180 }, 
        { "TxmV", VALUE, 7000, 6000, 10000 },
        { "RxmV", VALUE, 3200, 3000, 5000 },
        { "MdCels", VALUE, 4, 1, 10 }
}

local function create (zone, options)
        local widget = { zone=zone, options=options }
        return widget
end

local function update(widget, options)
        if (widget ~= nil) then
                widget.options = options
        end
        lowTxBattery = false
        lowTxBatteryPlayed = false
        lowRxBattery = false
        lowRxBatteryPlayed = false
end

-- questa funzione fa la somma della tensione
-- di tutte le celle
local function getCellVoltage(sensor)
        sensorValue = getValue(sensor)
        sum = 0
        if (type(SensorValue) == "table") then
                for i, volts in ipairs(sensorValue) do
                        sum = sum + volts
                end
        else -- cella singola
                sum = sensorValue 
        end

        return sum
end

local function getSample(sensor)
        Samples[SamplesIndex] = getCellVoltage(sensor) * 10

        if SamplesIndex == 5 then
                SamplesIndex = 1
        else
                SamplesIndex = SamplesIndex + 1
        end
end



local function calcAverageRxVoltage()
        local Sum = 0.0
        local Average = 0.0
        local i = 1
        while i <= 5 do
                Sum = Sum + Samples[i]
                Average = Sum / 5.0
                i = i + 1
        end
        return Average
end




local flag = false
local function playAnnouncement(timer, alert)
        if timer.value % alert == 1 then
                flag = false
        end

        if  timer.value % alert == 0 and timer.value ~= 0 then
                if flag == false then
                        playDuration(timer.value, 0)
                        playNumber(Voltage, UNIT_VOLTS, PREC1)
                        flag = true
                end
        end
end 


local function drawByWidgetSize(widget, timer)
        local timerInfo = string.format("T%s:", widget.options.Timer)

        if lowTxBattery == true or lowRxBattery == true then
                lcd.setColor(CUSTOM_COLOR, RED)
        else
                lcd.setColor(CUSTOM_COLOR, WHITE)
        end

        -- XXL Widget
        if widget.zone.w > 380 and widget.zone.h > 165 then
                lcd.drawText(widget.zone.x, widget.zone.y, timerInfo, DBLSIZE + CUSTOM_COLOR)
                lcd.drawTimer(widget.zone.x + 50, widget.zone.y + 20, timer.value, XXLSIZE + CUSTOM_COLOR)
                lcd.drawText(widget.zone.x, widget.zone.y + 120, "RxV", DBLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 72, widget.zone.y + 120, RxVolts, DBLSIZE + CUSTOM_COLOR + PREC1)
                lcd.drawText(widget.zone.x + 145, widget.zone.y + 120, "V", DBLSIZE + CUSTOM_COLOR)
                lcd.drawText(widget.zone.x + 195, widget.zone.y + 120, "Avg", DBLSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 260, widget.zone.y + 120, calcAverageRxVoltage(), DBLSIZE + CUSTOM_COLOR + PREC1)
                lcd.drawText(widget.zone.x + 330, widget.zone.y + 120, "V", DBLSIZE + CUSTOM_COLOR)
                lcd.drawText(widget.zone.x + 245, widget.zone.y + 30, "RSSI", MIDSIZE + CUSTOM_COLOR)
                lcd.drawText(widget.zone.x + 245, widget.zone.y + 50, getRSSI(), MIDSIZE + CUSTOM_COLOR)
                lcd.drawText(widget.zone.x + 305, widget.zone.y + 30, "TxV", MIDSIZE + CUSTOM_COLOR)
                lcd.drawNumber(widget.zone.x + 305, widget.zone.y + 50, TxVolts, MIDSIZE + CUSTOM_COLOR + PREC2)
                lcd.drawText(widget.zone.x + 355, widget.zone.y + 50, "V", MIDSIZE + CUSTOM_COLOR)
        else
                lcd.drawText(widget.zone.x, widget.zone.y, "Not Enough space", SMLSIZE + CUSTOM_COLOR)
        end
end



local function refresh(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        local currentVolts

        if getValue("VFAS") == 0 then
                RxBatterySensor = "RxBt"
        elseif getValue("RxBt") == 0 then
                RxBatterySensor = "VFAS"
        else
                RxBatterySensor = "RxBt"
        end

        currentVolts = getCellVoltage(RxBatterySensor) 
        RxVolts = currentVolts * 10
        TxVolts = getValue(TxBatterySensor) * 100


        time = timer.value
        if time ~= lastSecondSampled then
                if getRSSI() > 0 then
                        getSample(RxBatterySensor)
                        lastSecondSampled = time

                        local cells = widget.options.MdCels
                        local MinCellVoltage = widget.options.RxmV / 100.0
                        Voltage = calcAverageRxVoltage()
                        local CellVoltage = Voltage / cells

                        if CellVoltage <= MinCellVoltage and lastSecondSampled > 5 then
                                lowRxBattery = true
                        end
                        

                        if lowRxBattery == true and lowRxBatteryPlayed == false then
                                playFile("/WIDGETS/Telemt/modelbat.wav")
                                lowRxBatteryPlayed = true
                        end
                end

                if TxVolts <= widget.options.TxmV / 10.0 and lastSecondSampled > 5 then
                        lowTxBattery = true
                end

                if lowTxBattery == true and lowTxBatteryPlayed == false then
                        playFile("/SOUNDS/en/SYSTEM/lowbatt.wav")
                        lowTxBatteryPlayed = true
                end
        end

        drawByWidgetSize(widget, timer)
        playAnnouncement(timer, widget.options.Alert)
end


local function background(widget)
        local timer = model.getTimer(widget.options.Timer - 1)
        local currentVolts

        if getValue("VFAS") == 0 then
                RxBatterySensor = "RxBt"
        elseif getValue("RxBt") == 0 then
                RxBatterySensor = "VFAS"
        else
                RxBatterySensor = "RxBt"
        end

        currentVolts = getCellVoltage(RxBatterySensor) 
        RxVolts = currentVolts * 10
        TxVolts = getValue(TxBatterySensor) * 100


        time = timer.value
        if time ~= lastSecondSampled then
                if getRSSI() > 0 then
                        getSample(RxBatterySensor)
                        lastSecondSampled = time

                        local cells = widget.options.MdCels
                        local MinCellVoltage = widget.options.RxmV / 100.0
                        Voltage = calcAverageRxVoltage()
                        local CellVoltage = Voltage / cells

                        if CellVoltage <= MinCellVoltage and lastSecondSampled > 5 then
                                lowRxBattery = true
                        end

                        if lowRxBattery == true and lowRxBatteryPlayed == false then
                                playFile("/WIDGETS/Telemt/modelbat.wav")
                                lowRxBatteryPlayed = true
                        end

                end

                if TxVolts <= widget.options.TxmV / 10.0 and lastSecondSampled > 5 then
                        lowTxBattery = true
                end

                if lowTxBattery == true and lowTxBatteryPlayed == false then
                        playFile("/SOUNDS/en/SYSTEM/lowbatt.wav")
                        lowTxBatteryPlayed = true
                end
        end

        playAnnouncement(timer, widget.options.Alert) 
end


return { name="Telemt", options=options, create=create, update=update, background=background, refresh=refresh }
