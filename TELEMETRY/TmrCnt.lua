-- File TmrCnt.lua
--
-- Script "Timer Counter"
--
-- Da collocare in "/SCRIPTS/TELEMETRY/"
--
-- impostazioni e variabili modificabili 
local TimerNumber = 1
local Alert = 30                
local InversColor = false

-- variabili di script 
-- Non modificare al di sotto di questa riga
local Timer
local TimerInfo
local Played 


-- funzioni dello script 
local function playTimer()
        if Timer.value % Alert == 1 then
                Played = false
        end

        if  Timer.value % Alert == 0 and Timer.value ~= 0 then
                if Played == false then
                        playDuration(Timer.value, 0)
                        Played = true
                end
        end
end 

local function drawTelemetry()
        lcd.clear() 
        lcd.drawScreenTitle("Timer Counter", 0, 0)
        if InversColor == true then
                lcd.drawFilledRectangle(0, 0, 128, 64)
                lcd.drawText(0, 9, TimerInfo, INVERS)
                lcd.drawTimer(13, 18, Timer.value, XXLSIZE + INVERS)
        else
                lcd.drawText(0, 9, TimerInfo, BIGSIZE)
                lcd.drawTimer(13, 18, Timer.value, XXLSIZE)
        end
end

-- funzioni principali 
local function init()
        Timer = model.getTimer(TimerNumber - 1)
        TimerInfo = string.format("T%s:", TimerNumber)
        Played = false
end

local function refresh()
        drawTelemetry()
end

local function background()
        Timer = model.getTimer(TimerNumber - 1)
        playTimer()
end

-- istruzione di return 
return { run=refresh, background=background, init=init }
