local customParser = require "lib.customparser"
-- using LÖVE’s file system (recommended)
local function readFile(filename)
    if love.filesystem.getInfo(filename) then
        return love.filesystem.read(filename)
    else
        error("File not found: " .. filename)
    end
end

local lore = readFile("lore.txt")
local parsed = customParser:parseToTable(lore)

local function dump(tbl, indent)
    indent = indent or 0
    for k,v in pairs(tbl) do
        if type(v) == "table" then
            print(string.rep(" ", indent) .. k .. " = {")
            dump(v, indent + 2)
            print(string.rep(" ", indent) .. "}")
        else
            print(string.rep(" ", indent) .. k .. " = " .. v)
        end
    end
end

dump(parsed)

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Gamestate = require "lib.hump.gamestate"
    Gamestate.registerEvents()

    loadStates()

    Gamestate.switch(menu)
    _G.sprite = require "lib.Love2D-Systems.sprite"
end

local function reloadModule(name)
    package.loaded[name] = nil
    print("Hotswapped " .. name)
    return require(name)
end

function _G.loadStates()
    _G.menu = reloadModule("states.menu")
    _G.debugoffsetseditor = reloadModule("states.debugoffseteditor")
    _G.map = reloadModule("states.map")
end

function love.update(dt)
end

function love.draw()
    sprite:draw()
    local stats = love.graphics.getStats()

    local str = string.format("Estimated amount of texture memory used: %.2f MB", stats.texturememory / 1024 / 1024)
    love.graphics.print(str, 10, 10)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f1" then
        Gamestate.switch(menu)
    elseif key == "f2" then
        Gamestate.switch(debugoffsetseditor)
    elseif key == "f3" then
        Gamestate.switch(map)
    end
    if key == "r" then
        loadStates()
    end
end
