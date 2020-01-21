pVehStatus = {
    flycar = false,
    hovercar = false
}

pvehicle = {}

function flycar()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then 
        outputChatBox("[错误]: 你不在车里",255,100,100)
    end
    pVehStatus.flycar = not pVehStatus.flycar
    setWorldSpecialPropertyEnabled( "aircars",pVehStatus.flycar )
end
addCommandHandler('flycar',flycar,false,false)

function hovercar()
    local veh = getPedOccupiedVehicle(localPlayer)
    if not veh then 
        outputChatBox("[错误]: 你不在车里",255,100,100)
    end
    pVehStatus.hovercar = not pVehStatus.hovercar
    setWorldSpecialPropertyEnabled( "hovercars", pVehStatus.hovercar )
end
addCommandHandler('hovercar',hovercar,false,false)