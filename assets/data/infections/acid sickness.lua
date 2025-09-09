local infection = {}
infection.name = "Acid Sickness"
infection.desc = "Acid sickness gained from eating something acid like (like batteries)"

function infection:progressed(limb, progress)
    limb:hurt()
    if progress >= 0.9 then
        limb:hurt(2)
    elseif progress == 1 then
        limb:hurt(3)
        limb:spread(infection)
    end
end

return infection