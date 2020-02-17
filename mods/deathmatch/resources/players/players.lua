

-- player join  
function system_spawnPlayer()
    -- spawn player
    spawnPlayer(source,1722.1062,1508.2020,10.8128)
    -- camera 
    fadeCamera(source,true)
    setCameraTarget(source ,source )
end
function kill(source)
    setElementHealth(source,0)
    outputChatBox("[系统]: 你自杀了",source)
end
addCommandHandler("kill",kill)
function sound(source,cmd,val)
    playSoundFrontEnd ( source, val )
end
addCommandHandler("sound",sound)

addEventHandler('onPlayerJoin',root,system_spawnPlayer)
addEventHandler("onPlayerWasted",root, system_spawnPlayer) 
