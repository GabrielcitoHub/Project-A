local state = {}

function state:enter()
    loadStates()
end

function state:draw()
    love.graphics.print("I got lazy, have a text for menu instead!!!")
end

return state