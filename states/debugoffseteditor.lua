local state = {}

function state:init()
    self.zoom = 1
    self.mode = "offset"
    self.timerx = 0
    self.timery = 0
    self.timerx2 = 0
    self.timery2 = 0
    self.charLoader = require("lib.character")
    self.charLoader:setCharactersPath("assets/data/characters")
    self.charLoader:setCharactersImagePath("assets/images/characters")
    self.center = {
        x = 100,
        y = 100
    }
    self.characters = love.filesystem.getDirectoryItems("assets/data/characters")
    self.selectedCharacter = {}
    self.selected = 1
    self.selectedCharacter = self.charLoader:loadCharacter(self.characters[1]:sub(1, -5))
    self.selectedPart = self.selectedCharacter.fixedParts[#self.selectedCharacter.fixedParts]
end

function state:enter()
    self.characters = love.filesystem.getDirectoryItems("assets/data/characters")
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

function state:update(dt)
    if not self.selectedPart then return end
    -- center Movement
    local movespeed = 5
    if love.keyboard.isDown("lshift") then
        movespeed = movespeed - 2
    end
    if love.keyboard.isDown("lctrl") then
        movespeed = movespeed - 2
    end
    movespeed = (movespeed * 30) * dt
    movespeed = math.floor(movespeed)
    local speedx, speedy = 0, 0

    if self.timerx == 0 or self.timerx >= 1 then
        if love.keyboard.isDown("w") then
            speedy = speedy - movespeed
        elseif love.keyboard.isDown("s") then
            speedy = speedy + movespeed
        end
    end

    if self.timery == 0 or self.timery >= 1 then
        if love.keyboard.isDown("a") then
            speedx = speedx - movespeed
        elseif love.keyboard.isDown("d") then
            speedx = speedx + movespeed
        end
    end

    if not love.keyboard.isDown("w") and not love.keyboard.isDown("s") then
        self.timerx = 0
    else
        self.timerx = self.timerx + (1 * dt)
    end

    if not love.keyboard.isDown("a") and not love.keyboard.isDown("d") then
        self.timery = 0
    else
        self.timery = self.timery + (1 * dt)
    end

    self.center["x"] = self.center["x"] + speedx
    self.center["y"] = self.center["y"] + speedy

    -- Offset movement
    local speedx, speedy = 0, 0

    if self.timerx2 == 0 or self.timerx2 >= 1 then
        if love.keyboard.isDown("up") then
            speedy = speedy - movespeed
        elseif love.keyboard.isDown("down") then
            speedy = speedy + movespeed
        end
    end

    if self.timery2 == 0 or self.timery2 >= 1 then
        if love.keyboard.isDown("left") then
            speedx = speedx - movespeed
        elseif love.keyboard.isDown("right") then
            speedx = speedx + movespeed
        end
    end
    if not love.keyboard.isDown("up") and not love.keyboard.isDown("down") then
        self.timerx2 = 0
    else
        self.timerx2 = self.timerx2 + (1 * dt)
    end

    if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        self.timery2 = 0
    else
        self.timery2 = self.timery2 + (1 * dt)
    end

    if self.selectedPart then
        if self.mode == "offset" then
            self.selectedPart.offset["x"] = self.selectedPart.offset["x"] + speedx
            self.selectedPart.offset["y"] = self.selectedPart.offset["y"] + speedy
        elseif self.mode == "origin" then
            self.selectedPart.origin["x"] = self.selectedPart.origin["x"] + speedx
            self.selectedPart.origin["y"] = self.selectedPart.origin["y"] + speedy
        end
    end

    if love.keyboard.isDown("z") then
        self.zoom = self.zoom + (1 * dt)
    elseif love.keyboard.isDown("x") then
        self.zoom = self.zoom - (1 * dt)
    end
end

local function dumpParts(parts, indent)
    indent = indent or 1
    local lines = {}
    local pad = string.rep("    ", indent)

    for _, part in ipairs(parts) do
        table.insert(lines, pad .. part.id .. " = {")
        table.insert(lines, pad .. "    offset = { " .. part.offset.x .. ", " .. part.offset.y .. " },")
        if part.parts and #part.parts > 0 then
            local childLines = dumpParts(part.parts, indent + 1)
            for _, line in ipairs(childLines) do
                table.insert(lines, line)
            end
        end
        table.insert(lines, pad .. "},")
    end

    return lines
end

function state:copyOffsetsToClipboard()
    local char = self.selectedCharacter
    local out = {}

    table.insert(out, "char.parts = {")
    local partLines = dumpParts(char.parts, 1)
    for _, line in ipairs(partLines) do
        table.insert(out, line)
    end
    table.insert(out, "}")

    local result = table.concat(out, "\n")

    love.system.setClipboardText(result)

    print("✅ Offsets copied to clipboard for " .. char.id)
end

function state:keypressed(key)
    if not self.selectedCharacter then return end
    if key == "o" then
        if self.mode == "offset" then
            self.mode = "origin"
        elseif self.mode == "origin" then
            self.mode = "offset"
        end
    end
    if key == "g" then
        self:copyOffsetsToClipboard()
    end
    if key == "-" then
        local fpart
        local found = false
        for i,part in ipairs(self.selectedCharacter.fixedParts) do
            if found then
                fpart = part
                break
            end
            if part == self.selectedPart then
                found = true
            end
        end
        if fpart then
            self.selectedPart = fpart
        end
    elseif key == "+" then
        local fpart
        for i,part in ipairs(self.selectedCharacter.fixedParts) do
            if part == self.selectedPart then
                break
            end
            fpart = part
        end
        if fpart then
            self.selectedPart = fpart
        end
    end
end

local function reverseTable(t)
    local reversed = {}
    for i = #t, 1, -1 do
        reversed[#reversed + 1] = t[i]
    end
    return reversed
end


function state:draw()
    if not self.selectedPart then return end
    love.graphics.print((self.selectedCharacter.id or "Plr not found") .. " Selected part: " .. self.selectedPart.id)
    love.graphics.print("OffsetX: " .. self.selectedPart.offset.x .. " OffsetY: " .. self.selectedPart.offset.y, 0, 20)
    love.graphics.print("OriginX: " .. self.selectedPart.origin.x .. " OriginY: " .. self.selectedPart.origin.y, 0, 40)

    for _,part in ipairs(reverseTable(self.selectedCharacter.fixedParts)) do
        love.graphics.draw(
            part.image,
            self.center.x + part.offset.x * self.zoom,
            self.center.y + part.offset.y * self.zoom,
            part.rotation,
            self.zoom,
            self.zoom,
            (part.image:getWidth() / 2) + part.origin.x,
            (part.image:getHeight() / 2) + part.origin.y
        )
    end

    local part = self.selectedPart

    local ox = self.center.x + (part.offset.x + part.origin.x) * self.zoom
    local oy = self.center.y + (part.offset.y + part.origin.y) * self.zoom

    -- small red square
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", ox - 2, oy - 2, 4, 4)

    -- reset color so next draw isn’t tinted
    love.graphics.setColor(1, 1, 1, 1)
end

return state