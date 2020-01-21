
function ghostmode_on()
	local playerVehicle = getPedOccupiedVehicle(localPlayer) -- Get the players vehicle
	if(playerVehicle) then -- Check the return value.
		for i,v in pairs(getElementsByType("vehicle")) do --LOOP through all vehicles
			setElementCollidableWith(v, playerVehicle, false) -- Set the collison off with the other vehicles.
		end
		outputChatBox("[状态]: 被动模式开启")
	end
end
addCommandHandler("ghost", ghostmode_on) -- Add the /ghostmode Command.