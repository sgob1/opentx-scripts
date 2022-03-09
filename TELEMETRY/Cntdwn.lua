-- File Cntdwn.lua
--
-- Script "Countdown Timer"
--
-- Da collocare in "/SCRIPTS/TELEMETRY/"
--
-- variabili modificabili
local TimerNumber = 1
local CountdownTotalSeconds = 180
local InversColor = false
--
-- variabili di script
local Timer
local TimerInfo
local Countdown         
local NextSecond        
local Played            
local Elapsed           
-- funzioni di script
local function resetPlayedFlag()
        if Countdown % 60 == 59 then
                Played = false
        elseif Countdown == 29 or Countdown == 14 then
                Played = false
        elseif Countdown <= 10 and Countdown >= 0 and Countdown ~= NextSecond then
                Played = false
        end
end

local function playTime()

        local Seconds = Countdown % 60 
        local Minutes = (Countdown - Seconds) / 60

        if Played == true then
                resetPlayedFlag(Countdown, NextSecond)
        end

        if Played == false then
                if Countdown > 30 then
                        if Countdown % 60 == 0 and Countdown ~= CountdownTotalSeconds then
                                if Minutes ~= 0 and Seconds == 0 then
                                        playNumber(Minutes, 36)
                                elseif Minutes == 0 and Seconds ~= 0 then
                                        playNumber(Seconds, 37)
                                else
                                        playNumber(Minutes, 36)
                                        playNumber(Seconds, 37)
                                end
                                Played = true
                        end
                elseif Countdown == 30 then
                        playNumber(Countdown, 37)
                        Played = true
                elseif Countdown == 15 then
                        playNumber(Countdown, 37)
                        Played = true
                elseif Countdown <= 10 and Countdown > 0 then
                        playNumber(Countdown, 0)
                        Played = true
                        NextSecond = Countdown
                elseif Countdown == 0 then
                        playFile("/SCRIPTS/TELEMETRY/timelpsd.wav")
                        Played = true
                        Elapsed = true
                end
        end
end

local function drawTelemetry()
        lcd.clear() 
        lcd.drawScreenTitle("Countdown Timer", 0, 0)
        if InversColor == true then
                lcd.drawFilledRectangle(0, 0, 128, 64)
                lcd.drawText(0, 9, TimerInfo, INVERS)
                lcd.drawNumber(3, 18, Countdown, XXLSIZE + INVERS)
        else
                lcd.drawText(0, 9, TimerInfo, BIGSIZE)
                lcd.drawNumber(3, 18, Countdown, XXLSIZE)
        end
end


-- funzioni principali
local function init()
        Timer = model.getTimer(TimerNumber - 1)
        TimerInfo = string.format("T%s:", TimerNumber)
        Countdown = CountdownTotalSeconds
        NextSecond = 11
        Played = false
        Elapsed = false
end

local function refresh()
        drawTelemetry()
end

local function background()
        Timer = model.getTimer(TimerNumber - 1)
        Countdown = CountdownTotalSeconds - Timer.value
        if Countdown < 0 then
                Countdown = 0
        end

        if Elapsed == false then
                playTime()
        end
end

-- istruzione di return
return { run=refresh, background=background, init=init }
