idIndex = 0

-- Tables --
global = {}
idused = {}

-- Functions --
function readFile()
	local File =  fileOpen('Shared/IDs.ID')   
	local Data =  fileRead(File, fileGetSize(File))
	 fileClose ( File)
	return split(Data,10)
end

function index(table,name)
	local placeholder = {}
	for i,v in pairs(table) do
		local split = split(v,",")
		placeholder[tonumber(split[1])] = split[2]
		placeholder[split[2]] = split[1]
	end
	global[name] = placeholder
end

function indexUsables(table,name)
	local placeholder = {}
	count = 0
	for i,v in pairs(table) do
		local split = split(v,",")
		if split[3] then
			if allowinteriors then 
				if tonumber(split[3]) == 1 then
					count = count + 1
					placeholder[count] = {tonumber(split[1]),split[2]}
				end
			else
				count = count + 1
				placeholder[count] = {tonumber(split[1]),split[2]}
			end
		end
	end
	global[name] = placeholder
end

index(readFile(),'EveryID') 
indexUsables(readFile(),'Useable')

function getModelFromID(id)
	return global['EveryID'][id]
end

function getFreeID(name,looped)
	if data.id[name] then
		return data.id[name] -- If id is already assigned then just send back that ID
	else
		idIndex = idIndex + 1
		if not global['Useable'][idIndex] then
			if (idIndex == #global['Useable']) and looped then
				print('JStreamer:','Out of IDs')
				return
			else
				idIndex = 0
				return getFreeID(name,true)
			end
		end
			
		if not idused[global['Useable'][idIndex][1]] then
			return global['Useable'][idIndex][1]
		else
			return getFreeID(name,looped)
		end
	end
end
