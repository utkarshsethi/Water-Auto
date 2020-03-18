local mytimer = tmr.create()

if not mytimer:alarm(5000, tmr.ALARM_SINGLE, function()
  print("hey there")
end)
then
  print("whoopsie")
end



initTimer = tmr.create()
initTimer:alarm(1000, tmr.ALARM_SINGLE,
    function()
        local fi=node.flashindex; return pcall(fi and fi'_init')
    end
    )



local initTimer = tmr.create()
initTimer:register(1000, tmr.ALARM_SINGLE,
    function()
        local fi=node.flashindex; return pcall(fi and fi'_init')
    end
    )
initTimer:start()


if not tmr.create():alarm(5000, tmr.ALARM_SINGLE, function()
  print("hey there")
end)
then
  print("whoopsie")
end


mytimer = tmr.create()
mytimer:alarm(30, tmr.ALARM_AUTO, function() print("hey test") end)
--mytimer:interval(3000) -- actually, 3 seconds is better!
--mytimer:start()
mytimer:stop()