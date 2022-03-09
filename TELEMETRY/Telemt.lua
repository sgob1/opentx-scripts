-- Script "Telemetry"
--
-- File: "Telemt.lua"
-- Da collocare in "/SCRIPTS/TELEMETRY/"
--
-- Variabili di configurazione
local TimerNumber = 1
local Alert = 30
local InversColor = false
--
-- 
-- Variabili di script
-- Non modificare la parte sottostante

local Timer
local TxBatterySensor = "tx-voltage"
local RxBatterySensor = "RxBt"
local RxVolts
local Txvolts

local Samples = {0.0, 0.0, 0.0, 0.0, 0.0} -- vettore di campioni
local SamplesIndex = 1

local zeroPlayed = false

local time = 0
local lastSecondSampled = 0


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

local function playRxVoltage()
        local Voltage = calcAverageRxVoltage()
        playNumber(Voltage, UNIT_VOLTS, PREC1)
end


local flag = false
local function playAnnouncement(Timer, alert)
        if Timer.value % alert == 1 then
                flag = false
        end

        if  Timer.value % alert == 0 and Timer.value ~= 0 then
                if flag == false then
                        playDuration(Timer.value, 0)
                        playRxVoltage()
                        flag = true
                end
        end
end 

local function drawTelemetry()
        lcd.clear()
        lcd.drawScreenTitle("Telemetry", 0, 0)
        if InversColor == true then
                lcd.drawFilledRectangle(0, 0, 128, 64)
                lcd.drawText(0, 9, timerInfo, INVERS)
                lcd.drawTimer(17, 9, Timer.value, DBLSIZE + INVERS)
                lcd.drawText(5, 32, "RxV", SMLSIZE + INVERS)
                lcd.drawNumber(5, 41, RxVolts, DBLSIZE + INVERS + PREC1)
                lcd.drawText(35, 41, "V", DBLSIZE + INVERS)
                lcd.drawText(65, 32, "Avg", SMLSIZE + INVERS)
                lcd.drawNumber(65, 41, calcAverageRxVoltage(), DBLSIZE + INVERS + PREC1)
                lcd.drawText(95, 41, "V", DBLSIZE + INVERS)
                lcd.drawText(65, 9, "RSSI", SMLSIZE + INVERS)
                lcd.drawNumber(65, 17, getRSSI(), SMLSIZE + INVERS)
                lcd.drawText(95, 9, "TxV", SMLSIZE + INVERS)
                lcd.drawNumber(95, 17, TxVolts, SMLSIZE + INVERS + PREC2)
        else 
                lcd.drawText(0, 9, timerInfo)
                lcd.drawTimer(17, 9, Timer.value, DBLSIZE)
                lcd.drawText(5, 32, "RxV", SMLSIZE)
                lcd.drawNumber(5, 41, RxVolts, DBLSIZE + PREC1)
                lcd.drawText(35, 41, "V", DBLSIZE)
                lcd.drawText(65, 32, "Avg", SMLSIZE)
                lcd.drawNumber(65, 41, calcAverageRxVoltage(), DBLSIZE + PREC1)
                lcd.drawText(95, 41, "V", DBLSIZE)
                lcd.drawText(65, 9, "RSSI", SMLSIZE)
                lcd.drawNumber(65, 17, getRSSI(), SMLSIZE)
                lcd.drawText(95, 9, "TxV", SMLSIZE)
                lcd.drawNumber(95, 17, TxVolts, SMLSIZE + PREC2)

        end

end


-- funzioni principali --------------------------------------------------------
-- init
local function init()
        Timer = model.getTimer(TimerNumber - 1)
        timerInfo = string.format("T%s:", TimerNumber)
end


--local currentVolts = getCellVoltage(RxBatterySensor) * 0.98 -- * (1000/1024)
--local maxVolts = getCellVoltage(RxBatterySensor.."+") * 0.98
local function refresh()
        drawTelemetry()
end


local function background()
        Timer = model.getTimer(TimerNumber - 1)
        local currentVolts = getCellVoltage(RxBatterySensor) 

        TxVolts = getValue(TxBatterySensor) * 100
        RxVolts = currentVolts * 10

        time = Timer.value
        if time ~= lastSecondSampled then
                if getRSSI() > 0 then
                        getSample(RxBatterySensor)
                        lastSecondSampled = time
                end
        end

        playAnnouncement(Timer, Alert)
end


return { run=refresh, background=background, init=init }
