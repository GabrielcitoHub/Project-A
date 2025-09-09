local trait = {}

trait.name = "Non-Obedient"
trait.desc = "The subject is non-obedient, control reduced significantly"

function trait:update(dt, char)
    if char.stats["control"] >= 5 then
        char.stats["control"] = char.stats["control"] - math.random(0.1, 0.5)
    end
end

return trait