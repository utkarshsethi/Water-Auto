--DELAY--
print(">>>> 3 sec to stop <<<<")
tmr.create():alarm(3000, tmr.ALARM_SINGLE,function() print(">>>><<<<") end)

-- load credentials, 'SSID' and 'PASSWORD' declared and initialize in there
dofile("config.lua")
dofile("gpio.lua")

-----------------------------

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Running Startup")
        --file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("mqtt.lua")
    end
end

-----------------------------
    --WIFI RESET--
-----------------------------
wifi_reset = function()
    gpio.serout(4,gpio.LOW,{39950,99500},1, function() print(" Reset WIFI ") end)    
    wifi.sta.disconnect()
    wifi.setmode(wifi.NULLMODE)
    wifi.sta.clearconfig()
end

-----------------------------

-----------------------------

-- Define WiFi station event callbacks
wifi_connect_event = function(T)
  print("Connection to AP("..T.SSID..") established!")
  print("Waiting for IP address...")
  if disconnect_ct ~= nil then disconnect_ct = nil end
end

wifi_got_ip_event = function(T)
  -- Note: Having an IP address does not mean there is internet access!
  -- Internet connectivity can be determined with net.dns.resolve().
  print("Wifi connection is ready! IP address is: "..T.IP)
  tmr.create():alarm(3000, tmr.ALARM_SINGLE, startup)
  gpio.write(4, gpio.LOW)
end

wifi_disconnect_event = function(T)
  gpio.write(4, gpio.HIGH)
  if T.reason == wifi.eventmon.reason.ASSOC_LEAVE then
    --the station has disassociated from a previously connected AP
    return
  end
  
  
  -- total_tries: how many times the station will attempt to connect to the AP. Should consider AP reboot duration.
  local total_tries = 30
  local reset_wait = (20*60*1000)
  
  print("\nWiFi connection to AP("..T.SSID..") has failed!")

  --There are many possible disconnect reasons, the following iterates through
  --the list and returns the string corresponding to the disconnect reason.
  for key,val in pairs(wifi.eventmon.reason) do
    if val == T.reason then
      print("WIFI Disconnect reason: "..val.."("..key..")")
      break
    end
  end

  if disconnect_ct == nil then
    disconnect_ct = 1
  else
    disconnect_ct = disconnect_ct + 1
  end
  if disconnect_ct < total_tries then
--    print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")")
    gpio.serout(4,gpio.LOW,{39950,99500},1, function() print("Retrying connection...(attempt "..(disconnect_ct+1).." of "..total_tries..")") end)
  else
    wifi_reset()
    print("Aborting connection to AP!")
    disconnect_ct = nil

--    print("...waiting before re-attempting...")
--    tmr.create():alarm(2*10*1000, tmr.ALARM_SINGLE, function()
--        print("trying to reconnect")
--        disconnect_ct = 1
--    end)

    print("...waiting " .. reset_wait/1000/60 .. " min to restart....")
    file.close("init.lua")
    file.close("gpio.lua")
    file.close("mqtt.lua")
    file.close("config.lua")

    tmr.create():alarm(reset_wait, tmr.ALARM_SINGLE, function()
        print("..Restarting......")
        node.restart()
    end)
    
  end
end


-----------------------------

-- Register WiFi Station event callbacks
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect_event)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip_event)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect_event)

print("Connecting to WiFi access point...")

--wifi.setphymode(wifi.PHYMODE_N)
--wifi.setphymode(wifi.PHYMODE_G)
wifi.setphymode(wifi.PHYMODE_B)

wifi.setmode(wifi.STATION)
wifi.sta.sethostname(config.ID[node.chipid()],true)
wifi.sta.config({ssid=SSID, pwd=PASSWORD},true)
-- wifi.sta.connect() not necessary because config() uses auto-connect=true by default
