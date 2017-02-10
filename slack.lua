slack = {}

function slack.send(id, msg)
 local slack_url = 'https://hooks.slack.com/services/'..id
  local post_headers= 'Content-Type: application/x-www-form-urlencoded\r\ncache-control: no-cache\r\n'
  local post_body = 'payload={"username":"bruce-nodeMcu","icon_emoji":":man_with_turban::skin-tone-4:","text":"*ip is* `'..wifi.sta.getip()..'` \\n*SSID is * `'..wifi.sta.getdefaultconfig()..'`"}'

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

return slack
