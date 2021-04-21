
-----------------------------

print("MQTT File Open")

NodeName = config.ID[node.chipid()]

--Client Setup

-- init mqtt client with logins, keepalive timer 120sec
--m = mqtt.Client("clientid", 120, "user", "password", cleansession)
m = mqtt.Client(NodeName, 120, config.USER, config.PASS, 0)


-----------------------------
    --CallBacks
-----------------------------


-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline"
-- to topic "/lwt" if client don't send keepalive packet
m:lwt( config.ENDPOINT .. NodeName .. "/LW", NodeName .. " Disconnected", 2, 0)

m:on("offline", function(client)
    print (NodeName .. " Broker offline")
    --                  min /* sec /* millisec
    tmr.create():alarm(1*60*1000, tmr.ALARM_SINGLE, do_mqtt_connect) --if broker offline, retry after 1 min
    end)

-----------------------------
    --APPLICATION--
-----------------------------


function Relay_on()

--    print(config.ENDPOINT .. "/" .. NodeName .. "/status" .. " >> " .. NodeName .. " > Relay On")
    print(" >> " .. NodeName .. " > Relay On for " .. config.watertime)
    m:publish(config.ENDPOINT .. "/" .. NodeName .. "/status", NodeName .. " Relay On for " .. config.watertime, 2, 0)
    gpio.write(2, gpio.HIGH)
    tmr.create():alarm(config.watertime, tmr.ALARM_SINGLE, Relay_Off) --pick time to water from config.watertime

end

function Relay_Off()
    
    gpio.write(2, gpio.LOW)
--    print(config.ENDPOINT .. "/" .. NodeName .. "/status" .. " >> " .. NodeName .. " > Relay Off")
    print(" >> " .. NodeName .. " > Relay Off")
    m:publish(config.ENDPOINT .. "/" .. NodeName .. "/status", NodeName .. " Relay Off", 2, 0)

end


-- register message callback beforehand
-- on publish message receive event

m:on("message", function(client, topic, data)

    gpio.serout(4,gpio.HIGH,{99500,99500},3)

    tmr.create():alarm( 1 * 1000, tmr.ALARM_SINGLE, function()

        if data ~= nil then
            print("MQTT << " .. topic .. " << " .. data)   

            if string.match(data, "on") then  --todo add node specific commands
                Relay_on()
            elseif string.match(data, "off") then  --todo add node specific commands
                Relay_Off()
            else
                m:publish(topic .. "/status", data .. "????   --Not a Command--   >" .. NodeName, 2, 0)
                print(">> " .. data .. " --Not a Command--")
            end
        end

    gpio.write(4, gpio.HIGH)

    end)

end)


-----------------------------
    --Connecction
-----------------------------

--on publish overflow receive event
m:on("overflow", function(client, topic, data)

    print(topic .. " partial overflowed message: " .. data )

end)


-----------------------------
    --Connect & Sub
-----------------------------

function connect()

        print("MQTT connected")
        gpio.write(4, gpio.HIGH)
        print("Reset fail_time = nil")
        fail_time = nil
        

--        m:subscribe( { [config.ENDPOINT]=2, [config.ENDPOINT .. "/" .. NodeName]=2 }, function()
--        
--            print(NodeName .. " >>> " .. config.ENDPOINT .. " >>> subscribed")
--            print(NodeName .. " >>> " .. config.ENDPOINT .. "/" .. NodeName .. " >>> subscribed")
--            
--            m:publish(config.ENDPOINT .. "/status", NodeName .." connected", 2, 0)
--            print(config.ENDPOINT .. "/status" .. " >> " .. NodeName .." connected")
--        
--        end)
        
end


function handle_mqtt_error(client, reason)

    --wait incremental times before reattempting MQTT connect
    if fail_time == nil then
        fail_time = 1
    else
        fail_time = fail_time + 1
    end

    if fail_time > 120 then
        node.restart()
    end


    gpio.serout(4,gpio.LOW,{39950,99500},1, function() print("Handling Error...Redirecting do_mqtt_connect in " .. fail_time*10 .. " sec") end)
    tmr.create():alarm( fail_time * 10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end


function do_mqtt_connect()
    --Handle Panic error
    m:close()
    --Connect to MQTT
    gpio.serout(4,gpio.HIGH,{99500,9950},2)
    print("Attempting to Re - Connect MQTT....")
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    -- for TLS: m:connect("192.168.11.118", secure-port, 1)
    --m:connect(config.HOST, config.PORT, true, function(client)
    -- Unsecure
    --m:connect("192.168.11.118", 1883, 0, function(client)
    m:connect(config.HOST, config.PORT, false, function(client)
    
        print("connecting " .. NodeName .. " to MQTT Host > " .. config.HOST .. " : " .. config.PORT)
        -- Calling subscribe/publish only makes sense once the connection
         -- was successfully established. You can do that either here in the
         -- 'connect' callback or you need to otherwise make sure the
         -- connection was established (e.g. tracking connection status or in
         -- m:on("connect", function)).
          
--        tmr.create():alarm( 3 * 1000, tmr.ALARM_SINGLE, function()
--            print("Calling connect()")
--            connect()
--        end)

          connect()
        end,
        --Error Handling
        function(client, reason)
            print("MQTT failed reason: " .. reason)
            handle_mqtt_error()
    end)
end

-----------------------------

gpio.serout(4,gpio.HIGH,{99500,9950},5, function() print("Start Mqtt") end)
do_mqtt_connect()

-----------------------------
