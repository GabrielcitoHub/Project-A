local character = {}
character.charactersPath = ""
character.charactersImagePath = ""

function character:setCharactersImagePath(path)
    character.charactersImagePath = path
end

function character:setCharactersPath(path)
    character.charactersPath = path
end

function character:loadCharacter(chr)
    local char = require(character.charactersPath .. "/" .. chr)
    char.id = chr
    char.fixedParts = self:loadCharacterParts(char)

    return char
end

function character:loadCharacterFromPath(path)
    return require(path)
end

-- read {x,y} whether it’s a raw array or an indexed-list of items
local function readOffset(off)
    if type(off) ~= "table" then return 0, 0 end
    -- case A: raw array {7,-13}
    if type(off[1]) ~= "table" then
        return tonumber(off[1]) or 0, tonumber(off[2]) or 0
    end
    -- case B: accidentally converted to indexed items { {key=1,value=7}, {key=2,value=-13} }
    local x = off[1] and off[1].value
    local y = off[2] and off[2].value
    return tonumber(x) or 0, tonumber(y) or 0
end

function character:loadParts(char, partList)
    local id = char.id
    local partsfound = {}

    for _, partv in ipairs(partList) do
        local partid = partv.key or "notfound"
        local offx, offy = 0, 0
        local origx, origy = 0, 0

        -- partv.value is the list of children/fields for this part
        if type(partv.value) == "table" then
            local offsetfnd, origfnd
            -- 1) find offset entry (don’t assume order)
            for _, sub in ipairs(partv.value) do
                if sub.key == "offset" and not offsetfnd then
                    offx, offy = readOffset(sub.value)
                    offsetfnd = true
                end
                if sub.key == "origin" and not origfnd then
                    origx, origy = readOffset(sub.value)
                    origfnd = true
                end
                if offsetfnd and origfnd then
                    break
                end
            end

            -- 2) recurse into children first (depth-first)
            for _, sub in ipairs(partv.value) do
                if sub.key ~= "offset" and sub.key ~= "origin" then
                    local nested = character:loadParts(char, { sub })
                    for _, np in ipairs(nested) do
                        partsfound[#partsfound+1] = np
                    end
                end
            end
        end

        -- 3) add the current part after its children
        partsfound[#partsfound+1] = {
            id = partid,
            offset = { x = offx, y = offy },
            origin = { x = origx, y = origy},
            rotation = 0,
            image = love.graphics.newImage(character.charactersImagePath .. "/" .. char.id .. "/" .. partid .. ".png"),
        }
    end

    return partsfound
end

local function tableToText(tbl, indent)
    indent = indent or 0
    local pad = string.rep("    ", indent)
    local lines = {"{"}

    -- collect keys first so order is stable
    local keys = {}
    for k in next, tbl do
        table.insert(keys, k)
    end
    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local key
        if type(k) == "string" and k:match("^%a[%w_]*$") then
            key = k .. " = "
        else
            key = "[" .. tostring(k) .. "] = "
        end

        if type(v) == "table" then
            table.insert(lines, pad .. "    " .. key .. tableToText(v, indent + 1) .. ",")
        elseif type(v) == "string" then
            table.insert(lines, pad .. "    " .. key .. string.format("%q", v) .. ",")
        else
            table.insert(lines, pad .. "    " .. key .. tostring(v) .. ",")
        end
    end

    table.insert(lines, pad .. "}")
    return table.concat(lines, "\n")
end

-- pure-array detection (contiguous 1..n)
local function is_array(tbl)
    if type(tbl) ~= "table" then return false end
    local n = 0
    for k in next, tbl do
        if type(k) ~= "number" or k % 1 ~= 0 or k < 1 then return false end
        n = n + 1
    end
    return n == #tbl
end

-- convert maps deterministically, but keep arrays
local function dictToIndexed(tbl)
    if type(tbl) ~= "table" then return tbl end

    if is_array(tbl) then
        -- keep array shape; but still recursively convert elements
        local arr = {}
        for i = 1, #tbl do
            local v = tbl[i]
            arr[i] = (type(v) == "table") and dictToIndexed(v) or v
        end
        return arr
    end

    -- map/dict → collect keys in deterministic order
    local keys = {}
    for k in next, tbl do keys[#keys+1] = k end
    table.sort(keys, function(a,b) return tostring(a) < tostring(b) end)

    local out = {}
    for _, k in ipairs(keys) do
        local v = tbl[k]
        out[#out+1] = {
            key   = k,
            value = (type(v) == "table") and dictToIndexed(v) or v
        }
    end
    return out
end

function character:loadCharacterParts(char)
    local parts = character:loadParts(char, dictToIndexed(char.parts))

    if character.partsLoaded then
        character:partsLoaded(char, parts)
    end
    
    return parts
end

return character