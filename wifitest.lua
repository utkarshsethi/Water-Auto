

--print stored access point info
do
  for k,v in pairs(wifi.sta.getapinfo()) do
    if (type(v)=="table") then
      print(" "..k.." : "..type(v))
      for k,v in pairs(v) do
        print("\t\t"..k.." : "..v)
      end
    else
      print(" "..k.." : "..v)
    end
  end
end

--Get default Station configuration (NEW FORMAT)
do
local def_sta_config=wifi.sta.getdefaultconfig(true)
print(string.format("\tDefault station config\n\tssid:\"%s\"\tpassword:\"%s\"\n\tbssid:\"%s\"\tbssid_set:%s", def_sta_config.ssid, def_sta_config.pwd, def_sta_config.bssid, (def_sta_config.bssid_set and "true" or "false")))
end



--Get RSSI(Received Signal Strength Indicator) of the Access Point which ESP8266 station connected to.
print("RSSI is", wifi.sta.getrssi())

--wifi details
print(wifi.getmode())
print(wifi.getphymode())
print(wifi.getchannel())
print(wifi.sta.getmac())
print(wifi.sta.status())
print(wifi.sta.getip())
print(wifi.sta.gethostname())

-------------------------------------------------------------
        SET UP
-------------------------------------------------------------

--Hostname
if (wifi.sta.sethostname("WaterNode1") == true) then
    print("hostname was successfully changed")
else
    print("hostname was not changed")
end

--Set the current country info.
do
  country_info={}
  country_info.country="IN"
  country_info.start_ch=1
  country_info.end_ch=13
  country_info.policy=wifi.COUNTRY_AUTO;
  wifi.setcountry(country_info)
end

--Station mode
wifi.setmode(wifi.STATION, true)

--wifi set
station_cfg={}
station_cfg.ssid="SSID"
station_cfg.pwd="password"
wifi.sta.config(station_cfg)

-------------------------------------------------------------


