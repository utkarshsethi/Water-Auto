-----------------------------

gpio.serout(4,gpio.LOW,{39950,99500},4, function() print("Configuring GPIOs ...") end)

-----------------------------

--Configure GPIO from TABLE
for k,v in pairs(config.GPIO) do
    nr = tonumber(k)
    if (v == "INPUT") then
        gpio.mode(nr, gpio.INT, gpio.PULLUP)
        print(v, " on Port", nr)
    elseif (v == "OUTPUT") then
        gpio.mode(nr, gpio.OUTPUT)
        gpio.write(nr, gpio.LOW)
        print(v, " on Port", nr)
    end    
end

-----------------------------
