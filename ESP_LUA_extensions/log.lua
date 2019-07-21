-- keeps track of the last MAX_ENTRIES log messages

-- log messages which are greater than MAX_LOG_FILE_SIZE will be printed in
-- a separate file
MAX_LOG_FILE_SIZE = 800 -- byte
MAX_LOG_FILE_COUNT = 10 -- 1 <= count <= 99
LOG_META_NAME = "LOGMETA"
current_log_file_index = 0

function init()
    -- try to read the last log file
    if file.open(LOG_META_NAME, "r+") then
        last_file = file.read()
        if tonumber(last_file) then
            current_log_file_index = tonumber(last_file)
        else
            current_log_file_index = 0
        end
    else
        current_log_file_index = 0
        file.open(LOG_META_NAME, "w")
        file.write(current_log_file_index)
    end
    file.close()
    -- make shure log file exists
    if not file.exists("log" .. current_log_file_index) then
        file.open("log" .. current_log_file_index, "w")
        file.close()
    end
end

-- circle the indices
function next_log_file()
    current_log_file_index = current_log_file_index +1
    if current_log_file_index == MAX_LOG_FILE_COUNT then
        current_log_file_index = 0
    end
    -- remember the last written file
    file.open(LOG_META_NAME, "w")
    file.write(current_log_file_index)
    file.close()
end

-- returns an interator over all log entries
-- begins at the oldest entry
-- the last element is the most recent log message
function log_entries()
    file.list() -- somehow prevents watchdog reset ¯\_(ツ)_/¯
    local current_file = current_log_file_index
    local current_position = 0
    local start_file = current_log_file_index
    -- helper for itereating file index
    function next()
        current_file = current_file +1
        if current_file == MAX_LOG_FILE_COUNT then
            current_file = 0
        end
    end
    next() -- start file is the oldest file (not the current writing file)
    
    -- iterator function
    return function()
        -- at the end - stay at the end
        if current_position == nil then
            return nil
        end
        -- circle file indices as long as we don't find existing files
        while file.open("log" .. current_file, "r+") == nil do
            next()
            if current_file == start_file then
                file.open("log" .. current_file, "r+")
                break
            end
        end
        file.seek("set", current_position) -- reset reading position
        entry = file.readline()
        current_position = file.seek() -- remember reading position
        -- circle files if we are not back at the start file
        if current_file ~= start_file then
            while entry == nil do -- nil entry on incomplete lines
                file.close()
                next()
                while file.open("log" .. current_file, "r+") == nil do
                    next()
                end
                entry = file.readline()
                current_position = file.seek()
                -- break if we found the start file again
                if current_file == start_file then
                    break
                end
            end
        else -- at the start file, ensure finish
            -- ensure future nil's
            if entry == nil then
                current_position = nil
            else
                current_position = file.seek()
            end
        end
        file.close()
        return entry
    end
end

init()

-- overwrites the logfunction from the init.lua 
log = function (data)
    -- get the file size
    filesize = 0
    file_name = "log" .. current_log_file_index
    if file.exists(file_name) then
        filesize = file.stat(file_name).size
    end
    -- open next file if the current is too big
    -- +1 for newline
    -- delete the next file to use append mode
    if (string.len(data) + filesize + 1) > MAX_LOG_FILE_SIZE then
        next_log_file()
        file_name = "log" .. current_log_file_index
        if file.exists(file_name) then
            file.remove(file_name)
        end
    end
    -- write the entry
    file.open(file_name, "a+")
    file.writeline(data)
    file.close()
end
