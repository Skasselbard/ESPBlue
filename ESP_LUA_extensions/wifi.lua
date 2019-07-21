-- Attempts to connect to the wifi
function connectWifi()
    local ssid = "{ssid}" -- will be rplaced by the deploy script
    local pwd = "{pwd}" -- will be rplaced by the deploy script
    local hostname = "{name}" -- will be replaced by the deploy script
    if (ssid == nil) or (pwd == nil) or (ssid:len() < 1) or (pwd:len() < 1) then
        log("Error while loading wifi settings")
    else
        wifi.setmode(wifi.STATION)
        wifi.sta.autoconnect(1)
        local cfg = {}
        cfg.ssid = ssid
        cfg.pwd = pwd

        cfg.got_ip_cb = function(t)
            log("Connected to network, received ip: " .. t.IP)
            wifiTimer:stop()
            if mqttClient ~= nil then
                mqttClient:connect(getSetting("mqtt_server"), 1883)
            end
        end
        wifi.sta.config(cfg)
        wifi.sta.sethostname(hostname)
        wifi.sta.connect(function(x) log("Connected to wifi, waiting for ip...") end)
    end
end

-- Attempt to connect to wifi every 10s. connectWifi() automatically stops the timer if successful.
wifiTimer = tmr.create()
wifiTimer:register(10000,tmr.ALARM_AUTO,connectWifi)

if wifi.sta.getip() == nil then
    connectWifi()
    wifiTimer:start()
end