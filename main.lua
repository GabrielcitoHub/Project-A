function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    Gamestate = require "lib.hump.gamestate"
    Gamestate.registerEvents()

    loadStates()

    Gamestate.switch(menu)
    _G.sprite = require "lib.Love2D-Systems.sprite"
end

function loadStates()
    menu = require "states.menu"
    debugoffsetseditor = require "states.debugoffseteditor"
    map = require "states.map"
end

function love.update(dt)
end

function love.draw()
    sprite:draw()
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
