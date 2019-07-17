-- Executes a lua file if it exists
function doFileSafe(path)
    if file.exists(path) then
        dofile(path)
    end
end

local initTimer = tmr.create()
initTimer:alarm(3000, tmr.ALARM_SINGLE, function(t)
    doFileSafe("wifi.lua")
    doFileSafe("start.lua")
    doFileSafe("utils.lua")
end)