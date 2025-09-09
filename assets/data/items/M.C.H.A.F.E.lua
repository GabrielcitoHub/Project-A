local item = {}

item.name = "M.C.H.A.F.E"
item.desc = "M.C.H.A.F.E or Mind Control Helper At Finding Experiments\nThis peculiar item connects the individual to a higher force usually does nothing on its own\nit has an a way to deactivate but it should be the last thing you want to do as this will mostly result on inmediate disease on it's individual due to it's lack of brain stimuli"
item.durability = -1
item.equippable = true

function item:used(usesleft, limb)
end

function item:equipped(limb)
    if limb ~= "head" then return false end
end

function item:unequipped(limb)
    local player = limb.player
    local character = player.character
    character:disconnect()
    if not math.random(1, 100) then
        player:mindWipe()
        character:hurt(999)
    else
        character:giveTrait("Relief", "You feel lucky")
    end
end

return item