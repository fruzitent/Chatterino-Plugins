local JSON = require "JSON"

local crash_and_burn = function(result)
  local testJSON = result:data()
  local json = JSON:decode(testJSON)

  print("I'm 'boutta craaaaash")

  c2.later(function()
    Request_Beer()
  end, 100)
end

Request_Beer = function()
  local request = c2.HTTPRequest.create(c2.HTTPMethod.Get, "https://api.sampleapis.com/beers/ale")
  request:on_success(function(result) crash_and_burn(result) end)
  request:on_error(print)
  request:execute()
end

local cmd_crash = function()
  Request_Beer()
end

c2.register_command("/crash", cmd_crash)
