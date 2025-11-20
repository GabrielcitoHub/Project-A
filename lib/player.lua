local player = {}

function player:init(x, y, state)
    self.x = x or 0
    self.y = y or 0
    self.w = 12   -- collision box width
    self.h = 16   -- collision box height
    self.speed = 100
    self.jumpForce = -250
    self.gravity = 600
    self.vx = 0
    self.vy = 0
    self.onGround = false

    self.sprite = love.graphics.newImage("assets/images/player.png")
    self.state = state
end

--------------------------------------------------------
-- World → chunk/tile conversion helper
--------------------------------------------------------
local function worldToChunkTile(px, py, tileSize, chunkSize)
    local tx = math.floor(px / tileSize)
    local ty = math.floor(py / tileSize)

    local chunkX = math.floor(tx / chunkSize)
    local chunkY = math.floor(ty / chunkSize)

    local localX = (tx % chunkSize) + 1
    local localY = (ty % chunkSize) + 1

    return chunkX, chunkY, localX, localY
end

--------------------------------------------------------
-- Get tile reference (for reading + editing)
--------------------------------------------------------
function player:getCell(px, py)
    local tileSize = self.state.TILE_SIZE * 8
    local chunkSize = self.state.CHUNK_SIZE

    local cx, cy, lx, ly = worldToChunkTile(px, py, tileSize, chunkSize)
    local chunk = self.state:getChunk(cx, cy)
    if not chunk then return nil, nil, nil, nil end

    return chunk, lx, ly, chunk[ly][lx]
end

--------------------------------------------------------
-- Tile interactions
--------------------------------------------------------
function player:digTile(px, py)
    local chunk, lx, ly, cell = self:getCell(px, py)
    if chunk and cell then
        chunk[ly][lx] = nil
    end
end

function player:placeTile(px, py)
    local chunk, lx, ly, cell = self:getCell(px, py)
    local cellFound = false
    
    if cell and cell.quad then
        print(cell.quad)
        cellFound = true
    end
    if not chunk then
        player:digTile(px, py)
        chunk, lx, ly, cell = self:getCell(px, py)
    end
    if cellFound == false then
        local blockquad = love.graphics.newQuad(
            0,
            0,
            8, 8,
            self.state.blocks
        )
        chunk[ly][lx] = {
            noise = 1,
            rot = 0,
            quad = blockquad,
            biome = chunk.biome
        } -- solid block
    end
end

--------------------------------------------------------
-- Collision: check if point hits solid
--------------------------------------------------------
function player:isSolidAt(px, py)
    local _, _, _, cell = self:getCell(px, py)
    return cell and cell.noise >= 0.7
end

--------------------------------------------------------
-- Sign helper
--------------------------------------------------------
function math.sign(x)
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

--------------------------------------------------------
-- Movement & physics
--------------------------------------------------------
function player:move(dx, dy)
    local function isColliding(x, y)
        return self:isSolidAt(x - self.w/2, y - self.h/2)
            or self:isSolidAt(x + self.w/2, y - self.h/2)
            or self:isSolidAt(x - self.w/2, y + self.h/2)
            or self:isSolidAt(x + self.w/2, y + self.h/2)
    end

    -- Horizontal movement
    if dx ~= 0 then
        local newX = self.x + dx
        if not isColliding(newX, self.y) then
            self.x = newX
        else
            while not isColliding(self.x + math.sign(dx), self.y) do
                self.x = self.x + math.sign(dx)
            end
        end
    end

    -- Vertical movement
    if dy ~= 0 then
        local newY = self.y + dy
        if not isColliding(self.x, newY) then
            self.y = newY
            self.onGround = false
        else
            if dy > 0 then self.onGround = true end
            self.vy = 0
            while not isColliding(self.x, self.y + math.sign(dy)) do
                self.y = self.y + math.sign(dy)
            end
        end
    end
end

--------------------------------------------------------
-- Update physics & input
--------------------------------------------------------
function player:update(dt)
    self.vx = 0
    if love.keyboard.isDown("a") then self.vx = -self.speed end
    if love.keyboard.isDown("d") then self.vx = self.speed end
    if love.keyboard.isDown("w") and self.onGround then
        self.vy = self.jumpForce
        self.onGround = false
    end

    self.vy = self.vy + self.gravity * dt
    self:move(self.vx * dt, self.vy * dt)
end

--------------------------------------------------------
-- Draw
--------------------------------------------------------
function player:draw(camx, camy)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(
        self.sprite,
        self.x + camx, self.y + camy,
        0,
        self.w / self.sprite:getWidth(),
        self.h / self.sprite:getHeight(),
        self.sprite:getWidth()/2,
        self.sprite:getHeight()/2
    )
end

return player
