
function w2(player,cmd,weapon_id) 
    giveWeapon ( player, weapon_id, 99999999 )
end
addCommandHandler('w2',w2,false,false)