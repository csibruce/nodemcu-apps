dofile("credentials.lua")
dofile("slack.lua")
bluePin = 1
redPin = 2
serverCount = 0
gpio.mode(bluePin,gpio.OUTPUT)
gpio.mode(redPin,gpio.OUTPUT)
 
i2c.setup(0, 3, 4, i2c.SLOW)
lcd = dofile("lcd1602.lua")()

lcd:put(lcd:locate(0, 0), "SSID:"); lcd:put(lcd:locate(0, 6), "none")
lcd:put(lcd:locate(1, 0), "IP:");   lcd:put(lcd:locate(1, 4), "none")
 
function printServerState(count)
  lcd:put(lcd:locate(3, 0), "server on("..count..")")
end

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
    lcd:put(lcd:locate(3, 0), "server on")
    file.close("init.lua")
    blinkRed()
    blinkBlue()   
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

second = 0
tmr.alarm(1, 1000, 1, function()
  if wifi.sta.getip()== nil then
    print("IP unavaiable, Waiting...")
    lcd:put(lcd:locate(2, 0), "IP unavaiable("..second..")")
    second=second+1
    print(SLACK_ID)
    blinkRed()
  else
    tmr.stop(1)
    print("Config done, IP is "..wifi.sta.getip())
    print("You have 5 seconds to abort Startup")
    print("Waiting...")
    slack.send(SLACK_ID)
    lcd:put(lcd:locate(0, 5), " "..wifi.sta.getdefaultconfig())
    lcd:put(lcd:locate(1, 3), " "..wifi.sta.getip())
    lcd:put(lcd:locate(2, 0), "---Wifi Connected---")
    tmr.alarm(0,5000,0,startup)
  end
 end)
