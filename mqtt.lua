
-----------------------------

print("MQTT File Open")

-----------------------------
    --CallBacks
-----------------------------

NodeName = config.ID[node.chipid()]
-- init mqtt client without logins, keepalive timer 120s
--m = mqtt.Client("clientid", 120)
-- init mqtt client with logins, keepalive timer 120sec
--m = mqtt.Client("clientid", 120, "user", "password")
m = mqtt.Client(NodeName, 120, config.USER, config.PASS)

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("auto/water/status", NodeName .. " Disconnected - LW", 2, 0)

m:on("offline", function(client)
    print (NodeName .. " offline")
    --                  min /* sec /* millisec
    tmr.create():alarm(1 * 10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
    end)

-----------------------------
    --APPLICATION--
-----------------------------


-----------------------------
    --App Fnc's
-----------------------------


function Relay_on()
    print(config.ENDPOINT .. "/status" .. " > " .. NodeName .. " > Relay On")
    gpio.write(2, gpio.HIGH)
    m:publish(config.ENDPOINT .. "/status", NodeName .. " Relay On", 2, 0)
    tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, Relay_Off)
end

function Relay_Off()
    print(config.ENDPOINT .. "/status" .. " > " .. NodeName .. " > Relay Off")
    m:publish(config.ENDPOINT .. "/status", NodeName .. " Relay Off", 2, 0)
    gpio.write(2, gpio.LOW)
end


-- register message callback beforehand
-- on publish message receive event

      m:on("message", function(client, topic, data)
      gpio.serout(4,gpio.HIGH,{99500,99500},3)
      if data ~= nil then
        print("MQTT < " .. topic .. " < " .. data)   
        if string.match(data, "on") then
            Relay_on()
        elseif string.match(data, "off") then
            Relay_Off()
        else
            print(">> " .. data .. " --Not a Command--")
        end
      end
    end)


-----------------------------
    --Connecction
-----------------------------

-- on publish overflow receive event
--m:on("overflow", function(client, topic, data)
--  print(topic .. " partial overflowed message: " .. data )
--end)

function connect()
        print("MQTT connected")

        gpio.write(4, gpio.HIGH)     
        
        m:subscribe(config.ENDPOINT, 2, function(conn)
            print(NodeName .. " > " .. config.ENDPOINT .. " > subscribed")
        end)
        
        m:publish(config.ENDPOINT .. "/status", NodeName .." connected", 2, 0)
        print(config.ENDPOINT .. "/status" .. " > " .. NodeName .." connected")
end


function handle_mqtt_error(client, reason)
    print("Handling Error...Redirecting do_mqtt_connect")
    tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function do_mqtt_connect()
    --Handle Panic error
    m:close()
    --Connect to MQTT
    gpio.serout(4,gpio.HIGH,{99500,9950},10)
    print("Attempting to Re - Connect MQTT....")
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    --m:connect(config.HOST, config.PORT, true, function(client)
    -- Unsecure
    --m:connect("192.168.11.118", 1883, 0, function(client)
    m:connect(config.HOST, config.PORT, false, function(client)
    
    
      --print("connected To MQTT Host")
      print("connecting " .. NodeName .. " to MQTT Host > " .. config.HOST .. " : " .. config.PORT)
      -- Calling subscribe/publish only makes sense once the connection
      -- was successfully established. You can do that either here in the
      -- 'connect' callback or you need to otherwise make sure the
      -- connection was established (e.g. tracking connection status or in
      -- m:on("connect", function)).
      gpio.serout(4,gpio.HIGH,{99500,99500},10)
      print("Calling connect()")
      tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, connect)
    end,
    --Error Handling
    function(client, reason)
      print("MQTT failed reason: " .. reason)
      handle_mqtt_error()
    end)
end

-----------------------------

gpio.serout(4,gpio.HIGH,{99500,9950},10, function() print("Start Mqtt") end)
do_mqtt_connect()

-----------------------------
