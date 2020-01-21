engineSetAsynchronousLoading ( false,true ) 

local startTickCount = getTickCount ()
-- Tables --
cache = {}
data = {usingTXD = {},list = {},info = {},defintions = {},lods = {}}
Loaded = {}
Objects = {}

-- Functions --
function getID (element)
	return getElementID(element) or getElementData(element,'ID')
end

for i,v in pairs(getElementsByType('object',resourceRoot)) do
	local id = getID(v)
	data.list[id] = data.list[id] or {}
	data.list[id][v] = true
	data.info[id] = data.info[id] or {}
	data.info[id]['ID'] = getElementModel(v)
end

function JCreateObjectDefinition(name,dffLocation,txdLocation,collLocation,streamingDistance,alphaFlag,cullFlag,lodFlag,turnOn,turnOff)
	if name then
		data.defintions[name] = {drawdistance = streamingDistance,col = collLocation,txd = txdLocation,dff = dffLocation,alpha = alphaFlag,cull = cullFlag,lod = lodFlag,on = tonumber(turnOn),off = tonumber(turnOff)}
		requestCollision(collLocation)
		requestTextureArchive(txdLocation,name)
		requestModel(dffLocation)
		
	
		for element,index in pairs(data.list[name] or {}) do
			changeObject(element,name)
			--if isElementStreamedIn(element) then // Disabling due to MTAs poor performance when replace DFFs, TXDs and COLs
				local model = getElementModel(element)
				if not Loaded[name] then
					loadModel(name,model,true)
				end
			--end
		end
	end
end

--[[
function loadDefinition ( )
	if (getElementType( source ) == "object") then
		local id = getID(source)
		local model = getElementModel(source)
		if not Loaded[id] then
			loadModel(id,model,true)
		end
	end
end
addEventHandler( "onClientElementStreamIn", getRootElement( ),loadDefinition)
]]--

function loadModel(name,model,partial)
	
	data.info[name] = data.info[name] or {}
	if data.defintions[name] then
		Loaded[name] = true
		if not (data.info[name]['ID'] == model) or (not data.info[name]['Replaced']) then
			if (tonumber(data.info[name]['ID']) and (data.info[name]['Replaced']))  then
				engineRestoreCOL (data.info[name]['ID'])
				engineRestoreModel (data.info[name]['ID'])
			end
			data.info[name]['Replaced'] = true
			data.info[name]['ID'] = model
			local definitionTable = data.defintions[name]
		
			if definitionTable.lod then 
				engineSetModelLODDistance (model,math.max(tonumber(definitionTable.drawdistance),170))
			else
				engineSetModelLODDistance (model,definitionTable.drawdistance)
			end
			
			engineReplaceCOL (requestCollision(definitionTable.col),model)
			engineImportTXD (requestTextureArchive(definitionTable.txd,name),model)
			engineReplaceModel (requestModel(definitionTable.dff),model,definitionTable.alpha)
		end
	end
end
addEvent( "sendID", true )
addEventHandler( "sendID", root, loadModel )

function getFileData(path)
    local file = fileOpen(path)
    local count = fileGetSize(file) 
    local data = fileRead(file, count)
    fileClose(file)
    return data
end

function requestCollision(path)
	if path then
		cache[path] = cache[path] or engineLoadCOL(path)
		if not cache[path] then
			triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
		end
		signalLoaded()
		return cache[path]
	end
end
	
function requestTextureArchive(path,name)
	if path then
		cache[path] = cache[path] or engineLoadTXD(path)
		data.usingTXD[path] = data.usingTXD[path] or {}
		if name then
			data.usingTXD[path][name] = true
		end
		if not cache[path] then
			triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
		end
		signalLoaded()
		return cache[path]
	end
end

function requestModel(path)
	if path then
		cache[path] = cache[path] or engineLoadDFF(path)
		if not cache[path] then
			triggerServerEvent ( "FailedInLoading", resourceRoot, path ) -- IF FAILED SEND TO SERVER
		end
		signalLoaded()
		return cache[path]
	end
end

-- 
function signalLoaded()
	if isTimer(loadedTimer) then
		killTimer(loadedTimer)
	end
	loadedTimer = setTimer ( loadedFunction, 1500, 1)
end

function loadedFunction ( )
	if not InitalPrep then
		local endTickCount = getTickCount ()-startTickCount
		triggerServerEvent ( "onPlayerLoad", resourceRoot, tostring(endTickCount) )
		InitalPrep = true
	end
end

function reloadStuff()
	timer = nil
	nightElementReload()
	vegitationElementReload()
end

function changeObject(object,name)
	if not data.defintions[name] then
		data.list[name] = data.list[name] or {}
		data.list[name][object] = true
		return
	end
	
	if isElement(object) and data.defintions[name] then	
		data.list[name] = data.list[name] or {}
		data.list[name][object] = true
		local definitionTable = data.defintions[name] 
		setElementDoubleSided(object,definitionTable.cull)
		if getLowLODElement(object) then
			destroyElement(getLowLODElement(object)) -- Remove any previous lod elements
		end
		setElementData(object,'ID',name)
		setElementID(object,name)				
		if definitionTable.lod then 							
			local lod = createObject(getElementModel(object),0,0,0,0,0,0,true)
			data.lods[name] = data.lods[name] or {}
			setElementID(lod,name)
			setElementData(lod,'ID',name)
			setLowLODElement(object,lod)
			setElementDoubleSided(lod,definitionTable.cull)
			setElementDimension(lod,getElementDimension(object))
			setElementCollisionsEnabled(lod,false)
			local x,y,z = getElementPosition(object)
			local xr,yr,zr = getElementRotation(object)
			setElementPosition(lod,x,y,z)
			setElementRotation(lod,xr,yr,zr)
		end			
		reloadStuff()
		return true
	end
end
addEvent( "LoadObject", true )
addEventHandler( "LoadObject", root, changeObject )

function JcreateObject(name,x,y,z,xr,yr,zr)
	if tonumber(name) or getModelFromID(name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(name) or getModelFromID(name))
		return createObject(tonumber(name) or getModelFromID(name),x,y,z,xr,yr,zr) 
	end
	
	if not data.info[name] then
		triggerServerEvent ( "PrepID", resourceRoot,name) -- Attempt to load ID
	end
		
	if data.info[name] then 
		local object = createObject(1899,x,y,z,xr,yr,zr)
		setElementModel(object,data.info[name]['ID'])	
		Objects[sourceResource] = Objects[sourceResource] or {} 
		Objects[sourceResource][object] = true
		isNightElement(object)
		isVegElement(object)
		return object
	end
end

function JsetElementModel(element,name) --- SET model

	local id = getID(element)
		
	if data.list[id] then
		data.list[id][element] = nil
	end
		
	if tonumber(name) or getModelFromID(name) then
		triggerServerEvent ( "prepOriginals", resourceRoot,tonumber(name) or getModelFromID(name) )
		return setElementModel(element,tonumber(name) or getModelFromID(name))
	end
		
		
	if not data.info[name] then
		triggerServerEvent ( "PrepID", resourceRoot,name) -- Attempt to load ID
	end
		
	if data.info[name] then
		if data.info[name]['ID'] then
			setElementModel(element,data.info[name]['ID'])
			changeObject(element,name)
		end
	end
	isNightElement(element)
	isVegElement(element)
end

function checkTXD(txd)
	if data.usingTXD[txd] then
		for i,v in pairs(data.usingTXD[txd]) do
			if i then 
				return false
			end
		end
		destroyElement(cache[txd])
	cache[txd] = nil
	end
end

function fetchDefintions()
	return data.defintions
end

function unloadModel(name)
	if data.defintions[name] then
		if data.info[name] then
			if data.defintions[name].col then
				if cache[data.defintions[name].col] and cache[data.defintions[name].dff] then
					destroyElement(cache[data.defintions[name].col])
					cache[data.defintions[name].col] = nil
					destroyElement(cache[data.defintions[name].dff])
					cache[data.defintions[name].dff] = nil
					data.usingTXD[data.defintions[name].txd][name] = nil
					checkTXD(data.defintions[name].txd)
				end
			end
			for i,v in pairs(data.lods[name] or {}) do
				if isElement(i) then
					destroyElement(i)
				end
			end
			if data.info[name]['ID'] then
				engineRestoreCOL (data.info[name]['ID'])
				engineRestoreModel (data.info[name]['ID'])
			end
			data.lods[name] = nil
			data.info[name] = nil
			data.defintions[name] = nil
		end
	end
end
addEvent( "unLoadObject", true )
addEventHandler( "unLoadObject", root, unloadModel )

	
addEventHandler("onClientObjectBreak", resourceRoot,
    function()
		triggerServerEvent ( "onElementBreak", resourceRoot,source)
    end
)

addEventHandler("onClientElementDestroy", resourceRoot, function ()
	if getElementType(source) == "object" then
		if getLowLODElement(source) then
			destroyElement(getLowLODElement(source))
		end
	end
end)

addEventHandler ( "onClientResourceStop", root, 
    function ( resource )
		if Objects[resource] then
			for i,v in pairs(Objects[resource]) do
				if isElement(i) then
					destroyElement(i)
				end
			end
			Objects[resource] = nil
		end
   end 
)
