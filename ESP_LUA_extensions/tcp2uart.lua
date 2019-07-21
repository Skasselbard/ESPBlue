server=net.createServer()
client = nil
relay = true -- switch for interpreting and forwarding mode

-- create a server
server:listen(9999, function(c)
    if client~=nil then
        client:close()
    end
    client=c
    c:on("receive",function(socket,data)	
        handle_input(data)
    end)
    c:on("connection", function(socket, c)
        log("New Connection from: " .. socket:getpeer())
        socket:send("Connected to " .. wifi.sta.gethostname() .."\n")
    end)
end)

-- send data to tcp connection if a connection exists
function send_to_remote(data)
    if client~=nil then
        -- for line in string.gmatch(data, "([^\n]+)") do
            --client:send(line .. "\n")
        -- end
        client:send(data)
    end
end

-- forward uart data to tcp connection
uart.on("data",4, function(data)
    send_to_remote(data)
end, 1)

-- redirect interpreter output to tcp connection
node.output(send_to_remote, 0)

-- decide whatr to do witch received data
-- switch between modes if "stm" or "esp" was send
-- in forward (stm) mode: send all data to the serial port
-- in interpreter (esp) mode: interpret data as lua code and send the output back to the client
function handle_input(data)
    -- check for mode switches
    if data == "esp" then
        relay = false
        log("switched to lua interpete mode")
        client:send("switched to lua interpreter mode\n")
        return
    end
    if data == "stm" then
        relay = true
        log("switched to forwarding mode")
        client:send("switched to forwarding mode\n")
        return
    end
    -- handle input depending on internal state
    if relay then
        uart.write(0, data)
    else
        node.input(data)
    end
end