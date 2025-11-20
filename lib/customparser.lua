local parser = {}
local self = parser
function self:parseToTable(text)
    local result = {}
    local lines = {}

    -- split text into lines
    for line in text:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local stack = { result }
    local lastKey = nil
    local buffer = nil  -- collect multiline text

    local function flushBuffer()
        if buffer and lastKey then
            local tbl = stack[#stack]
            tbl[lastKey] = buffer
            buffer = nil
            table.remove(stack) -- pop back up
            lastKey = nil
        end
    end

    for _, line in ipairs(lines) do
        line = line:match("^%s*(.-)%s*$") -- trim spaces

        if line:sub(1, 2) == "--" then
            flushBuffer()
            local key = line:sub(4)
            result[key] = {}
            stack = { result[key] }
            lastKey = nil

        elseif line:sub(1, 1) == "-" then
            flushBuffer()
            local key = line:sub(3)
            local tbl = stack[#stack]
            tbl[key] = {}
            table.insert(stack, tbl[key])
            lastKey = key

        elseif line:sub(1, 1) == '"' and line:sub(-1) == '"' then
            flushBuffer()
            local key = line:sub(2, -2)
            local tbl = stack[#stack]
            tbl[key] = {}
            table.insert(stack, tbl[key])
            lastKey = key

        else
            -- value line (may be multiline)
            if buffer then
                buffer = buffer .. "\n" .. line
            else
                buffer = line
            end
        end
    end

    flushBuffer()
    return result
end
return self