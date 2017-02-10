dofile("credentials.lua")
dofile("slack.lua")
bluePin = 1
redPin = 2
gpio.mode(bluePin,gpio.OUTPUT)
gpio.mode(redPin,gpio.OUTPUT)


function blinkRed()
  gpio.write(redPin,1)
  tmr.delay(100000)
  gpio.write(redPin,0)
end

function blinkBlue()
  gpio.write(bluePin,1)
  tmr.delay(100000)
  gpio.write(bluePin,0)
end

function startup()
  if file.open("init.lua") == nil then
    print("init.lua deleted")
  else
    print("Running")
    file.close("init.lua")
    blinkRed()
    blinkBlue()
    slack.send(SLACK_ID)
    dofile("webserver.lua")
  end
end

--init.lua
wifi.sta.disconnect()
-- vdd = adc.readvdd33()
-- print("Vdd = "..vdd.." mV")
print("set up wifi mode")
wifi.setmode(wifi.STATION)
wifi.sta.config(SSID,PASSWORD,0)
wifi.sta.connect()
tmr.alarm(1, 1000, 1, function()
  if wifi.sta.getip()== nil then
    print("IP unavaiable, Waiting...")
    print(SLACK_ID)
    blinkRed()
  else
    tmr.stop(1)
    print("Config done, IP is "..wifi.sta.getip())
    print("You have 5 seconds to abort Startup")
    print("Waiting...")
    tmr.alarm(0,5000,0,startup)
  end
 end)
