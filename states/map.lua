local state = {}
state.curx, state.cury = 0, 0

local function generateNoiseGrid()
	-- Fill each tile in our grid with noise.
	local baseX = 10000 * love.math.random()
	local baseY = 10000 * love.math.random()
    state.blockx = math.random(1,4)
    state.blocky = math.random(1,4)
    state.blockquad = love.graphics.newQuad((8*state.blockx)-8, (8*state.blocky)-8, 8, 8,state.blocks)
    state.rotations = {0}
	for y = 1, 260 do
		state.grid[y] = {}
		for x = 1, 380 do
            state.grid[y][x] = {}
			state.grid[y][x]["noise"] = love.math.noise(baseX+.1*x, baseY+.2*y)
            state.grid[y][x]["rot"] = state.rotations[math.random(1,4)]
		end
	end
end

function state:init()
    state.blocks = love.graphics.newImage("assets/images/blocks-tilemap.png")
end

function state:enter()
    state.grid = {}
    generateNoiseGrid()
end

function state:update(dt)
    state.movespeed = (5 * 60) * dt
    if love.keyboard.isDown("w") then
        self.cury = self.cury +  self.movespeed
    elseif love.keyboard.isDown("s") then
        self.cury = self.cury -  self.movespeed
    end

    if love.keyboard.isDown("a") then
        self.curx = self.curx +  self.movespeed
    elseif love.keyboard.isDown("d") then
        self.curx = self.curx -  self.movespeed
    end
end

function state:draw()
    local tileSize = 2
    local blocksize = 8
	for y = 1, #state.grid do
		for x = 1, #state.grid[y] do
			-- love.graphics.setColor(1, 1, 1, state.grid[y][x])
            if state.grid[y][x]["noise"] >= 0.7 then
                love.graphics.draw(state.blocks, state.blockquad, ((x*tileSize) * blocksize)+state.curx, ((y*tileSize) * blocksize)+state.cury, state.grid[y][x]["rot"], tileSize, tileSize, tileSize / 2, tileSize / 2)
                -- love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize-1, tileSize-1)
            end
		end
	end
end

return state