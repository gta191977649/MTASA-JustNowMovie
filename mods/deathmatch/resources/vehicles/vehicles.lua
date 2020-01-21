p_vehicles = {}
MAX_VEH_LIMIT = 5

function vid(player,cmd,model) 

    if not isVehicleMax(player) then
        --local x,y,z = getElementPosition(player)
        local x,y,z = getPositionInfrontOfElement(player,5)
        createPlayerVehicle(player,model,x,y,z)
    else
        local len = table.size(p_vehicles[player])
        outputChatBox(string.format("车数上限: %d",len),player,255,255,255)
        return
    end
end
addCommandHandler('vid',vid,false,false)


function createPlayerVehicle(player,model,x,y,z) 
    if not p_vehicles[player] then 
        p_vehicles[player] = {}
    end

    local veh = createVehicle(model,x,y + 5,z)

    table.insert(p_vehicles[player],veh)
    local len = table.size(p_vehicles[player])

    outputChatBox(string.format("Size : %d",len),player,255,255,255)
end

function deleteAllPlayerVehicle(player) 
    
    if p_vehicles[player] then 
        table.foreach(p_vehicles[player],function(k,v) 
            --print(k)
            local veh = p_vehicles[player][k]
            destroyElement(veh)
            --table.remove(p_vehicles[player],k)
        end)
        p_vehicles[player] = {}
        outputChatBox("全部载具删除",player,255,255,255)
    end

end
addCommandHandler('dc',deleteAllPlayerVehicle,false,false)
function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end


-- Plate
function vplate(thePlayer,commandName,text)
	local Vehicle = getPedOccupiedVehicle(thePlayer)
	if Vehicle then
		if text then
			setVehiclePlateText( Vehicle, text )
		else
			outputChatBox("错误的格式.",thePlayer)
		end
	else
		outputChatBox("你需要在载具里.",thePlayer)
	end
end
addCommandHandler("vplate",vplate)


function massChange ( me, command, mass )
    local mass = tonumber ( mass ) -- Convert mass to a number
    local veh = getPedOccupiedVehicle ( me ) -- Get the player's vehicle
    
    if mass and veh then  -- If valid mass and in a vehicle
        local success = setVehicleHandling ( veh, "mass", mass) -- Set the vehicle's mass, and check if successful
        
        if success then -- If successful
            outputChatBox ( "[载具]: 修改载具重量-> "..mass.." kg", me, 0, 255, 0 ) -- Notify the player of success
        else -- Too bad failure is still an option
            outputChatBox ( "[错误]: 修改失败,数值错误", me, 255, 0, 0 ) -- Notify the player of failure, and give a possible reason
        end
    elseif not veh then -- If not in a vehicle
        outputChatBox ( "[错误]: 你不在载具里", me, 255, 0, 0 ) -- Tell the player; He / she obviously doesn't know
    elseif not mass then -- If not a valid mass
        outputChatBox ( "[用法]: /vmass [重量(kg)]", me, 255, 0, 0 ) -- Tell the player the proper syntax
    end
end
addCommandHandler ( "vmass", massChange )

function isVehicleMax(player) 
    if p_vehicles[player] then 
        local len = table.size(p_vehicles[player])
        if len < MAX_VEH_LIMIT then
            return false
        end
        return true
    end
    return false
end

function getPositionInfrontOfElement(element, meters)
    if (not element or not isElement(element)) then return false end
    local meters = (type(meters) == "number" and meters) or 3
    local posX, posY, posZ = getElementPosition(element)
    local _, _, rotation = getElementRotation(element)
    posX = posX - math.sin(math.rad(rotation)) * meters
    posY = posY + math.cos(math.rad(rotation)) * meters
    rot = rotation + math.cos(math.rad(rotation))
    return posX, posY, posZ , rot
end