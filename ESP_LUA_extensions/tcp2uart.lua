print(uart.getconfig(0))
uart.setup(0,15200,8,0,1,1)
sv=net.createServer(net.TCP, 60)
global_c = nil
sv:listen(9999, function(c)
	if global_c~=nil then
		global_c:close()
	end
	global_c=c
	c:on("receive",function(sck,pl)	uart.write(0,pl) end)
end)

uart.on("data",4, function(data)
	if global_c~=nil then
        global_c:send(data)
        print(data)
	end
end, 0)