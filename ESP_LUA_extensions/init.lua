-- function used for logging
-- can be overwritten
-- will be overwritten in the log module
log = function(data) 
    print(data)
end

-- Checks that a list of files exist and can be compiled
-- load compiled files on success
function load_files(files)
    for _,fileName in pairs(files) do
        -- check that the files exist
        current = fileName ..".lua"
        if not file.exists(current) then
            log("Error expected file " .. current)
            return false
        end
        -- create error handler
        function compile_handler( err )
            log( "ERROR: " .. err )
        end
        -- compile and use error handler on failiure
        if not xpcall(function() node.compile(current) end, compile_handler) then
            return false
        end
    end
    -- load files after successful compilation 
    for _,fileName in pairs(files) do
        current = fileName .. ".lc"
        log("loading: " .. current)
        dofile(current)
    end
    return true
end

local initTimer = tmr.create()
initTimer:alarm(3000, tmr.ALARM_SINGLE, function(t)
    load_files({"log","wifi", "mqtt", "tcp2uart"})
end)