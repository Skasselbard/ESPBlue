
function start_mqtt(mqttName)
    mqttName = "{name}" -- will be rplaced by the deploy script
    mqttClient = mqtt.Client(mqttName, 120)
    mqttClient:lwt("status/ip/"..mqttName, "offline")
    mqttTimer = tmr.create()
    mqttTimer:alarm(5000,tmr.ALARM_AUTO, function(t) 
        print("Attempting to connect to mqtt")
        mqttClient:connect(getSetting("mqtt_server"), 1883)
    end)
    doFileSafe("events.lua")
end
