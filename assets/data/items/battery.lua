local item = {}

item.name = "Battery"
item.desc = "Just a normal sized battery.\nmight be usefull for some items"
item.durability = 1
item.canUse = true
item.charge = 1

function item:used(usesleft, limb)
    limb:hurt(0.1)
    if math.random(1, 10) then
        item:explode()
    else
        limb:infect("acid sickness", 0.2)
    end
end

function item:collide(force)
    if force >= 5 then
        item:explode()
    end
end

function item:discharged(item, discharge)
    if not item then return end
    item.charge = item.charge - discharge
end

function item:toolUsed(tool, limb)
    tool.battery = item
end

return item