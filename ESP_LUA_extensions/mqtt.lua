
function start_mqtt(mqttName)
    mqttName = "{name}" -- will be rplaced by the deploy script
    mqttClient = mqtt.Client(mqttName, 120)
    mqttClient:lwt("status/ip/"..mqttName, "offline")
    mqttTimer = tmr.create()
    mqttTimer:alarm(5000,tmr.ALARM_AUTO, function(t) 
        log("Attempting to connect to mqtt")
        mqttClient:connect(getSetting("mqtt_server"), 1883)
    end)
    register_callbacks()
end

-- here you can add global variables, run one time initializations,
-- and configure custom events

-- also you can define your mqtt logic here
-- add your subscription to the others in the "connect" event and
-- add your logic to the message event

function register_callbacks()
    client = nil

    mqttClient:on("connect", function(c) 
        mqttTimer:stop()
        log("mqtt connected as: "..mqttName)
        client = c
        client:publish("status/ip/"..mqttName, wifi.sta.getip(),0,0)
        -- add your subscription here
        client:subscribe({
        ["control/"..mqttName] = 0,
        ["control/all"] = 0,
        ["#"] = 0
        })
    end)

    mqttClient:on("offline", function(c)
        log("mqtt disconnected")
        client = nil
    end)

    mqttClient:on("message", function(client, topic, message)
        if topic == "control/"..mqttName or topic == "control/all" then
            node.input(message)
        else
        log(topic .. ":" ) 
        if message ~= nil then
            log(message)
        end
        end
    end)
end