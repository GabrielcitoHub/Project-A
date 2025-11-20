local state = {}
state.curx, state.cury = 0, 0
state.player = require("lib.player")

-- settings
local TILE_SIZE = 2
local BLOCK_SIZE = 8
local CHUNK_SIZE = 32 -- tiles per chunk (both width & height)
state.TILE_SIZE = TILE_SIZE
state.CHUNK_SIZE = CHUNK_SIZE

-- generate a single chunk
-- Define biome palettes (each biome has its own tile options)
local biomePalettes = {
    forest = {
        {x=1, y=1}, {x=2, y=1}, {x=3, y=1}, {x=4, y=1} -- grass-like blocks
    },
    desert = {
        {x=1, y=2}, {x=2, y=2}, {x=3, y=2}, {x=4, y=2} -- sand-like blocks
    },
    snow = {
        {x=1, y=3}, {x=2, y=3}, {x=3, y=3}, {x=4, y=3} -- snow-like blocks
    }
}

-- Decide biome for chunk
local function getBiomeForChunk(cx, cy)
    local n = love.math.noise(cx * 0.1, cy * 0.1)
    if n < 0.33 then
        return "forest"
    elseif n < 0.66 then
        return "desert"
    else
        return "snow"
    end
end

-- Generate chunk
local function generateChunk(cx, cy)
    local biome = getBiomeForChunk(cx, cy)
    local palette = biomePalettes[biome]

    local chunk = {}
    local baseX = 10000 * love.math.random()
    local baseY = 10000 * love.math.random()
    local rotations = {0, math.pi/2, math.pi, 3*math.pi/2}
    local rotations = {0,0,0,0}

    for y = 1, CHUNK_SIZE do
        chunk[y] = {}
        for x = 1, CHUNK_SIZE do
            local gx = (cx * CHUNK_SIZE) + x
            local gy = (cy * CHUNK_SIZE) + y

            -- Smooth tile selection using noise instead of pure random
            local n = love.math.noise((gx + baseX) * 0.1, (gy + baseY) * 0.1)

            -- Pick palette index based on noise value (clusters form naturally)
            local idx = math.floor(n * #palette) + 1
            if idx > #palette then idx = #palette end
            local tile = palette[idx]

            local noise = love.math.noise(baseX + 0.1 * gx, baseY + 0.2 * gy)
            local rot = rotations[math.random(1, #rotations)]
            local quadX = (8 * tile.x) - 8
            local quadY = (8 * tile.y) - 8
            local blockquad = nil

            if quadX < state.blocks:getWidth() and quadY < state.blocks:getHeight() then
                blockquad = love.graphics.newQuad(
                    quadX,
                    quadY,
                    8, 8,
                    state.blocks
                )
            end

            chunk[y][x] = {
                noise = noise,
                rot = rot,
                quad = blockquad,
                biome = biome
            }
        end
    end
    return chunk
end

function state:init()
    state.blocks = love.graphics.newImage("assets/images/blocks-tilemap.png")
    state.player:init(380*8, 260*8, state)
    state.chunks = {}
end

function state:enter()
    state.chunks = {}
end

-- lazy chunk getter
function state:getChunk(cx, cy)
    if not self.chunks[cy] then self.chunks[cy] = {} end
    if not self.chunks[cy][cx] then
        self.chunks[cy][cx] = generateChunk(cx, cy)
    end
    return self.chunks[cy][cx]
end

function state:update(dt)
    state.player:update(dt)

    -- Camera follows player
    self.curx = -state.player.x + love.graphics.getWidth()/2
    self.cury = -state.player.y + love.graphics.getHeight()/2

    -- state.movespeed = 5
    -- if love.keyboard.isDown("lshift") then
    --     state.movespeed = state.movespeed + 15
    -- end
    -- if love.keyboard.isDown("rshift") then
    --     state.movespeed = state.movespeed + 35
    -- end
    -- if love.keyboard.isDown("lctrl") then
    --     state.movespeed = state.movespeed + 15
    -- end
    -- if love.keyboard.isDown("rctrl") then
    --     state.movespeed = state.movespeed + 35
    -- end
    -- if love.keyboard.isDown("2") then
    --     state.movespeed = state.movespeed * 2
    -- end
    -- if love.keyboard.isDown("3") then
    --     state.movespeed = state.movespeed * 3
    -- end
    -- if love.keyboard.isDown("4") then
    --     state.movespeed = state.movespeed * 4
    -- end
    -- if love.keyboard.isDown("5") then
    --     state.movespeed = state.movespeed * 5
    -- end
    -- if love.keyboard.isDown("0") then
    --     state.movespeed = state.movespeed * 999999
    -- end
    -- state.movespeed = (state.movespeed * 60) * dt
    -- if love.keyboard.isDown("w") then
    --     self.cury = self.cury + self.movespeed
    -- elseif love.keyboard.isDown("s") then
    --     self.cury = self.cury - self.movespeed
    -- end

    -- if love.keyboard.isDown("a") then
    --     self.curx = self.curx + self.movespeed
    -- elseif love.keyboard.isDown("d") then
    --     self.curx = self.curx - self.movespeed
    -- end
end

function state:draw()
    local screenW, screenH = love.graphics.getDimensions()
    local tilesOnScreenX = math.ceil(screenW / (TILE_SIZE * BLOCK_SIZE)) + 2
    local tilesOnScreenY = math.ceil(screenH / (TILE_SIZE * BLOCK_SIZE)) + 2

    -- figure out which chunks are visible
    local startTileX = math.floor(-self.curx / (TILE_SIZE * BLOCK_SIZE))
    local startTileY = math.floor(-self.cury / (TILE_SIZE * BLOCK_SIZE))

    local startChunkX = math.floor(startTileX / CHUNK_SIZE)
    local startChunkY = math.floor(startTileY / CHUNK_SIZE)

    local endChunkX = math.floor((startTileX + tilesOnScreenX) / CHUNK_SIZE)
    local endChunkY = math.floor((startTileY + tilesOnScreenY) / CHUNK_SIZE)

    for cy = startChunkY, endChunkY do
        for cx = startChunkX, endChunkX do
            local chunk = self:getChunk(cx, cy)
            for y = 1, CHUNK_SIZE do
                for x = 1, CHUNK_SIZE do
                    local cell = chunk[y][x]
                    if cell and cell.noise >= 0.7 then
                        local gx = (cx * CHUNK_SIZE + x)
                        local gy = (cy * CHUNK_SIZE + y)
                        love.graphics.draw(
                            self.blocks,
                            cell.quad,
                            (gx * TILE_SIZE * BLOCK_SIZE) + self.curx,
                            (gy * TILE_SIZE * BLOCK_SIZE) + self.cury,
                            cell.rot,
                            TILE_SIZE, TILE_SIZE,
                            TILE_SIZE / 2, TILE_SIZE / 2
                        )
                    end
                end
            end
        end
    end
    state.player:draw(self.curx, self.cury)
end

function state:mousepressed(x, y, button)
    local worldX = x - self.curx
    local worldY = y - self.cury

    if button == 1 then
        self.player:digTile(worldX, worldY)
    elseif button == 2 then
        self.player:placeTile(worldX, worldY)
    end
end

return state