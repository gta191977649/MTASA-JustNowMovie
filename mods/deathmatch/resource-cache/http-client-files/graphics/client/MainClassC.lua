--[[
	Name: WetRoadsReloaded
	Filename: MainClassC.lua
	Authors: Sam@ke
--]]

local Instance = nil

MainClassC = {}

function MainClassC:constructor()
	mainOutput("MainClassC was loaded.")
	
	self.hour = 0
	self.minute = 0
	
	self.m_Update = bind(self.update, self)
	addEventHandler("onClientHUDRender", root, self.m_Update)
	
	self:init()
end


function MainClassC:init()
	if (not self.roadShineConfigs) then
		self.roadShineConfigs = new(RoadShineConfigsC, self)
	end
	
	if (not self.wetShaders) then
		self.wetShaders = new(WetShadersC, self)
	end
	
	if (not self.wetParticles) then
		self.wetParticles = new(WetParticlesC, self)
	end
end


function MainClassC:update()
	--setPlayerHudComponentVisible("all", false)
	
	self.hour, self.minute = getTime()
		
	if (self.roadShineConfigs) then
		self.roadShineConfigs:update()
	end
	
	if (self.wetShaders) then
		self.wetShaders:update()
	end
	
	if (self.wetParticles) then
		self.wetParticles:update()
	end
end


function MainClassC:getDayTime()
	if (self.hour >= 22) and (self.hour <= 23) then
		return "Night"
	elseif (self.hour >= 0) and (self.hour <= 4) then
		return "Night"
	elseif (self.hour >= 5) and (self.hour <= 11) then
		return "Morning"
	elseif (self.hour >= 12) and (self.hour <= 17) then
		return "Day"
	elseif (self.hour >= 18) and (self.hour <= 21) then
		return "Evening"
	else
		return "Day"
	end
end


function MainClassC:clear()
	if (self.roadShineConfigs) then
		delete(self.roadShineConfigs)
		self.roadShineConfigs = nil
	end
	
	if (self.wetShaders) then
		delete(self.wetShaders)
		self.wetShaders = nil
	end
	
	if (self.wetParticles) then
		delete(self.wetParticles)
		self.wetParticles = nil
	end
end


function MainClassC:destructor()
	removeEventHandler("onClientHUDRender", root, self.m_Update)
	
	self:clear()
	
	--setPlayerHudComponentVisible("all", true)
	
	mainOutput("MainClassC was deleted.")
end


addEventHandler("onClientResourceStart", resourceRoot,
function()
	Instance = new(MainClassC)
end)


addEventHandler("onClientResourceStop", resourceRoot,
function()
	if (Instance) then
		delete(Instance)
		Instance = nil
	end
end)