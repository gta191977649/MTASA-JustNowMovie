function broadcast(text, type, byResource)
	
	if isPlayerMuted(source) then
	
		outputChat("#ff0000You are Muted!", source, getPlayerName(source), type, byResource)
		return
		
	end
	
	if type == "Global" then
	
		outputChat(text, root, getPlayerName(source), type, byResource)
		
	elseif type == "Team" then
	
		local team = getPlayerTeam(source)
		
		if not team then return end
		
		for i, p in pairs(getPlayersInTeam(team)) do 
		
			outputChat(text, p, getPlayerName(source), type, byResource)
			
		end
		
	elseif type == "Group" then
	
		if not getElementData(source, "chatgroup") then return end
	
		for i, p in pairs(getElementsByType("player")) do 
		
			if getElementData(p, "chatgroup") == getElementData(source, "chatgroup") then
			
				outputChat(text, p, getPlayerName(source), type, byResource)
				
			end
			
		end
		
	else
	
		outputChat(text, getElementParent(source), getPlayerName(source), type, byResource)
		
	end
	
end
addEvent("sendText", true)
addEventHandler("sendText", root, broadcast)


--Commands
function executeCommand(command, args)

	if not hasObjectPermissionTo(source, "command."..command[1], true) then return end
		
	executeCommandHandler(command[1], source, args)

end
addEvent("executeCommand", true)
addEventHandler("executeCommand", root, executeCommand)


--Output
function outputChat(msg, toElement, playerName, type, byResource, onlyTab)

	triggerLatentClientEvent(toElement, "receiveChat", root, playerName, msg, type, byResource, onlyTab)

end
addEvent("outputChat")
addEventHandler("outputChat", root, outputChat)


--Create Group
function createGroup(p, c)

	if getElementData(p, "chatgroup") then
		outputChat("#ff0000Error: You already have a group!", p, "", "Group", true, false)
		return
	end

	setElementData(p, "chatgroup", getPlayerSerial(p))
	outputChat("#00ff00Info: You created a group!", p, "", "Local", true, false)

end
addCommandHandler("create", createGroup)


--Invite a Player
function invitePlayer(p, c, name)

	if not getElementData(p, "chatgroup") then
		outputChat("#ff0000Error: You don't have a group!", p, "", "Local", true, false)
		return
	end
	
	if not name then
		outputChat("#ff0000Error: You have to provide a player!", p, "", "Group", true, false)
		return
	end

	local player = findPlayer(name)
	
	if not player then 
		outputChat("#ff0000Error: Player not found!", p, "", "Group", true, false)
		return
	end
	
	if getElementData(player, "chatgroup") then
		outputChat("#ff0000Error: Player already has a group!", p, "", "Group", true, false)
		return
	end
	
	
	setElementData(player, "chatgroup", getElementData(p, "chatgroup"))
	triggerEvent("sendText", player, "#00ff00Info: "..clean(getPlayerName(player)).." joined the group!", "Group", true)


end
addCommandHandler("invite", invitePlayer)


--Leave Group
function leaveGroup(p, c, t)

	if not getElementData(p, "chatgroup") then		
		outputChat("#ff0000Error: You don't have a group!", p, "", "Local", true, false)
		return
	end

	triggerEvent("sendText", p, "#00ff00INFO: "..clean(getPlayerName(p)).." left the group!", "Group", true)
	setElementData(p, "chatgroup", nil)
	outputChat("#00ff00Info: You left the group!", p, "", "Local", true, false)

end
addCommandHandler("leave", leaveGroup)


--Remove a Player
function removePlayer(p, c, name)

	if not getElementData(p, "chatgroup") then		
		outputChat("#ff0000Error: You don't have a group!", p, "", "Local", true, false)
		return
	end

	if getElementData(p, "chatgroup") ~= getPlayerSerial(p) then
		outputChat("#ff0000Error: You are not the group owner!", p, "", "Group", true, false)
		return
	end
	
	if not name then
		outputChat("#ff0000Error: You have to provide a player!", p, "", "Group", true, false)
		return
	end
	
	local player = findPlayer(name)
	
	if not player then 
		outputChat("#ff0000Error: Player not found!", p, "", "Group", true, false)
		return
	end
	
	if not getElementData(player, "chatgroup") then
		outputChat("#ff0000Error: Player doesn't have a group!", p, "", "Group", true, false)
		return
	end
	
	if getElementData(player, "chatgroup") ~= getElementData(p, "chatgroup") then
		outputChat("#ff0000Error: Player isn't in your group!", p, "", "Group", true, false)
		return
	end
	
	triggerEvent("sendText", p, "#00ff00Info: "..clean(getPlayerName(player)).." left the group!", "Group", true)
	outputChat("#00ff00Info:  You have been removed from the Group!", player, "", "Local", true, false)
	
	setElementData(player, "chatgroup", nil)

end
addCommandHandler("remove", removePlayer)


--Private Message
function private(p, c, t, ...)

	if t == nil then return end
	
	player = findPlayer(t)
	
	if not player then 
	
		outputChat("#ff0000Error: Player not found!", p, "", "PM", true, false)
		return 
	
	end
	
	local message = #{...}>0 and table.concat({...},' ') or nil
	
	if not message then return end
	
	outputChat(getPlayerName(player).."#ffffff: "..message, p, "", "PM", true, false)
	
	outputChat(getPlayerName(player).."#ffffff: "..message, player, "", "PM", true, false)

end
addCommandHandler("pm", private)


--Find a Player
function findPlayer(name)

    local name = name:lower()
	
    for i, p in ipairs(getElementsByType("player")) do
        local fullname = string.gsub(getPlayerName(p), '#%x%x%x%x%x%x', ''):lower()
        if string.find(fullname, name, 1, true) then
            return p
        end
    end
    return false
	
end


--Clean text
function clean(text)

	cleanText = string.gsub(text, '#%x%x%x%x%x%x', '')
	return cleanText

end