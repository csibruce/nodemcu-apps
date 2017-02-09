dofile("credentials.lua")
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
    slack_send()
    dofile("webserver.lua")
  end
end

function slack_send(msg)
  local slack_url = 'https://hooks.slack.com/services/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'
  local post_headers= 'Content-Type: application/x-www-form-urlencoded\r\ncache-control: no-cache\r\n'
  local post_body = 'payload={"username":"bruce-nodeMcu","icon_emoji":":man_with_turban::skin-tone-4:","text":"*ip is* `'..wifi.sta.getip()..'`"}'

  print(post_headers)
  print(post_body)
  http.post(slack_url, post_headers, post_body,
    function(code, data)
      if (code < 0) then
        print("HTTP request failed: code "..code)
      else
        print("Slack response: ", code, data)
      end
    end
  )
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
    blinkRed()
  else
    tmr.stop(1)
    print("Config done, IP is "..wifi.sta.getip())
    print("You have 5 seconds to abort Startup")
    print("Waiting...")
    tmr.alarm(0,5000,0,startup)
  end
 end)
