local item = {}

item.name = "ItemE"
item.desc = "Default item"
item.durability = 1

function item:used(usesleft, limb)
end

function item:equipped(limb)
end

function item:unequipped(limb)
end

function item:trown(force)
end

function item:landed()
end

function item:discharged(discharge, battery)
end

function item:toolUsed(tool, limb)
end

return item