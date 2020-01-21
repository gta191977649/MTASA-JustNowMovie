-- player join  
function system_spawnPlayer()
    -- spawn player
    spawnPlayer(source,1722.1062,1508.2020,10.8128)
    -- camera 
    fadeCamera(source,true)
    setCameraTarget(source ,source )
end

addEventHandler('onPlayerJoin',root,system_spawnPlayer)
addEventHandler("onPlayerWasted",root, system_spawnPlayer) 
