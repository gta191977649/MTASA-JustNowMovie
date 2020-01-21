--[[
	Name: WetRoadsReloaded
	Filename: WetShadersC.lua
	Authors: Sam@ke
--]]

WetShadersC = {}

function WetShadersC:constructor(parent)
	mainOutput("WetShadersC was loaded.")
	
	self.mainClass = parent
	self.drawDistance = 200
	
	self.settings = {}

	self.settings["Night"] = {}
	self.settings["Night"].bloomFactor = 1.6				-- 1.5
	self.settings["Night"].zoomXValue = 1.0 				-- 1.00
	self.settings["Night"].zoomYValue = 0.8					-- 0.8
	self.settings["Night"].bumpFactor = 0.55				-- 0.55
	self.settings["Night"].shiftXValue = 0.00				-- 0.00
	self.settings["Night"].shiftYValue = -0.03				-- -0.03
	self.settings["Night"].reflectionStrength = 0.85		-- 0.85
	self.settings["Night"].diffuseFactor = 1.7				-- 1.7
	self.settings["Night"].sunColor = {0.3, 0.3, 0.4, 1.0}	-- {0.3, 0.3, 0.4, 1.0}
	
	self.settings["Morning"] = {}
	self.settings["Morning"].bloomFactor = 1.5 				-- 1.5
	self.settings["Morning"].zoomXValue = 1.0 				-- 1.00
	self.settings["Morning"].zoomYValue = 0.8				-- 0.8
	self.settings["Morning"].bumpFactor = 0.5				-- 0.4
	self.settings["Morning"].shiftXValue = 0.00				-- 0.00
	self.settings["Morning"].shiftYValue = -0.03			-- -0.03
	self.settings["Morning"].reflectionStrength = 0.75		-- 0.75
	self.settings["Morning"].diffuseFactor = 1.5 			-- 1.5
	self.settings["Morning"].sunColor = {0.8, 0.78, 0.7, 1.0}	-- {0.8, 0.78, 0.7, 1.0}
	
	self.settings["Day"] = {}
	self.settings["Day"].bloomFactor = 1.4 					-- 1.4
	self.settings["Day"].zoomXValue = 1.0 					-- 1.00
	self.settings["Day"].zoomYValue = 0.8					-- 0.8
	self.settings["Day"].bumpFactor = 0.45					-- 0.4
	self.settings["Day"].shiftXValue = 0.00					-- 0.00
	self.settings["Day"].shiftYValue = -0.03				-- -0.03
	self.settings["Day"].reflectionStrength = 0.7			-- 0.5
	self.settings["Day"].diffuseFactor = 1.4 				-- 1.4
	self.settings["Day"].sunColor = {0.95, 0.91, 0.88, 1.0}		-- {0.95, 0.91, 0.88, 1.0}
	
	self.settings["Evening"] = {}
	self.settings["Evening"].bloomFactor = 1.5 				-- 1.5
	self.settings["Evening"].zoomXValue = 1.0 				-- 1.00
	self.settings["Evening"].zoomYValue = 0.8				-- 0.8
	self.settings["Evening"].bumpFactor = 0.5				-- 0.5
	self.settings["Evening"].shiftXValue = 0.00				-- 0.00
	self.settings["Evening"].shiftYValue = -0.03			-- -0.03
	self.settings["Evening"].reflectionStrength = 0.75		-- 0.6
	self.settings["Evening"].diffuseFactor = 1.5 			-- 1.5
	self.settings["Evening"].sunColor = {0.85, 0.82, 0.74, 1.0}	-- {0.85, 0.82, 0.74, 1.0}
	
	self.sunTR = 255
	self.sunTG = 255
	self.sunTB = 255
	self.sunBR = 255
	self.sunBG = 255
	self.sunBB = 255
	
	self.isWetStarted = "false"
	self.isDryingRoadsStarted = "false"
	
	self.wetStage = 0 -- 0 dry roads, 1 dry to wet, 2 wet to wet with puddles, 3 wet with puddles to dry with wet places, 4 dry with wet places to dry
	self.fadeValue = 0
	self.getWetAmount = 0.0015
	self.getDryAmount = 0.0005
	
	self.wetLevel = 0
	self.minWetLevel = 0
	self.maxWetLevel = 1
	self.rollBack = "false"
	
	self.wetRoadPuddlesTextures = {	"*freew*",
									"*road*",
									"tar_*",
									"hiwaym*",
									"hiwayi*",
									"hiwayo*",
									"hiwaye*",
									"snpedtest*",
									"*junction*",
									"cos_hiwaymid_256",
									"cos_hiwayout_256",
									"gm_lacarpark1",
									"des_1line256",
									"des_1linetar",
									"ws_carpark*",
									"*crossing_law*",
									"*tarmac*",
									"ws_whitestripe",
									"ws_airpt_concrete",
									"ws_yellowline"}
						
	self.wetRoadTextures = {		"crazy paving",
									"grasstype*",
									"rocktq128_grass4blend",
									"concretenewb256",
									"des_dirtgrassmix_grass*",
									"grass4dirty",
									"desgreengrass",
									"vegaspavement*",
									"pierplanks02_128",
									"des_dirt*",
									"ws_floortiles4",
									"greyground*",
									"grassdry_128hv",
									"brickred",
									"bow_church_grass_gen",
									"fancy_slab128",
									"hiwaygravel1_256",
									"hiway2sand*",
									"ws_traingravel",
									"des_scrub1_dirt1b",
									"con2sand1*",
									"des_scrub*",
									"vgs_rockmid*",
									"vgs_rockbot*",
									"desgrassbrn",
									"des_grass2scrub",
									"concretedust2*",
									"conchev_64hv",
									"concrete_64hv",
									"*pave*", -- sidewalks
									"grass_128hv",
									"sandnew_law",
									"beachwalk_law"}
									-- bremsspuren "particleskid"
									
	self.vehicleTextures = {	"vehiclegrunge256", "?emap*", "predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
								"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128", 
								"rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
								"coach92interior128","combinetexpage128","hotdog92body256",
								"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
								"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" , 
								"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256", 
								"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256"}
					
	self.renderTargetPool = {}
	self.renderTargetPool.list = {}
	
	self:init()
end


function WetShadersC:init()
	if (self:checkVersion()) then
		self.screenWidth, self.screenHeigth = guiGetScreenSize()
		
		-- Create things
		self.screenSource = dxCreateScreenSource(self.screenWidth / 2, self.screenHeigth / 2)
        self.blurHShader = dxCreateShader("res/shaders/blurH.fx")
        self.blurVShader = dxCreateShader("res/shaders/blurV.fx")
		self.wetRoadsShader = dxCreateShader("res/shaders/wetRoads.fx", 0, self.drawDistance, false, "world,object")
		self.wetRoadsWithPuddlesShader = dxCreateShader("res/shaders/wetRoadsWithPuddles.fx", 0, self.drawDistance, false, "world,object")
		self.puddleMask = dxCreateTexture("res/textures/puddleMask.png")
		self.waterNormal = dxCreateTexture("res/textures/waterNormal.png")
		self.waterDropsNormal = dxCreateTexture("res/textures/waterDrops.png")
		
		self.allLoaded = self.screenSource and self.blurHShader and self.blurVShader and self.wetRoadsShader and self.wetRoadsWithPuddlesShader and self.puddleMask and self.waterNormal and self.waterDropsNormal
		
		if (self.allLoaded) then
			for index, texture in ipairs(self.wetRoadPuddlesTextures) do
				self.wetRoadsWithPuddlesShader:applyToWorldTexture(texture)
			end

			for index, texture in ipairs(self.wetRoadTextures) do
				self.wetRoadsWithPuddlesShader:removeFromWorldTexture(texture)
			end
			
			for index, texture in ipairs(self.wetRoadTextures) do
				self.wetRoadsShader:applyToWorldTexture(texture)
			end

			for index, texture in ipairs(self.wetRoadPuddlesTextures) do
				self.wetRoadsShader:removeFromWorldTexture(texture)
			end
		else
			mainOutput("FAIL // WetRoadsReloaded could´nt be started. Check ´/debugscript 3´ for details!")
		end
	end
end


function WetShadersC:startWetEffect()
	self.rainStartTime = getTickCount()
	self.isWetStarted = "true"
	self.isDryingRoadsStarted = "false"
	
	if (self.wetStage == 0) or (self.wetStage == 1) then
		self.wetStage = 1
		self.rollBack = "false"
	elseif (self.wetStage == 2) then
		self.wetStage = 2
		self.rollBack = "false"
	elseif (self.wetStage == 3) then
		self.wetStage = 3
		self.rollBack = "true"
	elseif (self.wetStage == 4) then
		self.wetStage = 4
		self.rollBack = "true"
	end
end


function WetShadersC:stopWetEffect()
	self.rainStopTime = getTickCount()
	self.isDryingRoadsStarted = "true"
	self.isWetStarted = "false"
end


function WetShadersC:calculateWetEffects()
		
	self.currentTime = getTickCount()
	
	if (getRainLevel() > 0.05) then
		if (self.isWetStarted == "false") then
			self:startWetEffect()
		end
	else
		if (self.isDryingRoadsStarted == "false") then
			self:stopWetEffect()
		end
	end
	
	if (self.wetStage > 0) then
		if (self.isWetStarted == "true") then
			if ((self.currentTime - self.rainStartTime) > 10000) then
				if (self.rollBack == "false") then
					self.fadeValue = self.fadeValue + self.getWetAmount
					
					if (self.fadeValue > 1) then
						if (self.wetStage < 2) then
							self.fadeValue = 0
							self.wetStage = self.wetStage + 1
						else
							self.fadeValue = 1
						end
					end
				elseif (self.rollBack == "true") then
					self.fadeValue = self.fadeValue - self.getWetAmount
				
					if (self.fadeValue < 0) then
						self.fadeValue = 0
					end
				end
			end
	
			self.wetLevel = self.wetLevel + self.getWetAmount / 2
			
			if (self.wetLevel >= self.maxWetLevel) then
				self.wetLevel = self.maxWetLevel
			end
		end
		
		if (self.isDryingRoadsStarted == "true") then
			if ((self.currentTime - self.rainStopTime) > 10000) then
				self.fadeValue = self.fadeValue + self.getDryAmount
				
				if (self.fadeValue > 1) then
					if (self.wetStage < 4) then
						self.fadeValue = 0
						self.wetStage = self.wetStage + 1
					else
						self.wetStage = 0
						self.fadeValue = 0
					end
				end
			end
	
			self.wetLevel = self.wetLevel - self.getDryAmount / 2
			
			if (self.wetLevel <= self.minWetLevel) then
				self.wetLevel = self.minWetLevel
			end
		end
	end
end

function WetShadersC:getWetLevel()
	return self.wetLevel
end

		
function WetShadersC:update()
	if (self.allLoaded) and (self.mainClass) then
		
		local currentSettungs = self.settings[self.mainClass:getDayTime()]

		self:calculateWetEffects()
		
		if (currentSettungs) then
			
			self.wetRoadsWithPuddlesShader:setValue("sunColor", currentSettungs.sunColor)
			self.wetRoadsWithPuddlesShader:setValue("wetStage", self.wetStage)
			self.wetRoadsWithPuddlesShader:setValue("fadeValue", self.fadeValue)
			self.wetRoadsWithPuddlesShader:setValue("puddleMask", self.puddleMask)
			self.wetRoadsWithPuddlesShader:setValue("waterNormal", self.waterNormal)
			self.wetRoadsWithPuddlesShader:setValue("zoomXValue", currentSettungs.zoomXValue)
			self.wetRoadsWithPuddlesShader:setValue("zoomYValue", currentSettungs.zoomYValue)
			self.wetRoadsWithPuddlesShader:setValue("bumpFactor", currentSettungs.bumpFactor)	
			self.wetRoadsWithPuddlesShader:setValue("shiftXValue", currentSettungs.shiftXValue)
			self.wetRoadsWithPuddlesShader:setValue("shiftYValue", currentSettungs.shiftYValue)	
			self.wetRoadsWithPuddlesShader:setValue("diffuseFactor", currentSettungs.diffuseFactor)	
			self.wetRoadsWithPuddlesShader:setValue("reflectionStrength", currentSettungs.reflectionStrength)
			self.wetRoadsWithPuddlesShader:setValue("fadeStart", self.drawDistance / 10)
			self.wetRoadsWithPuddlesShader:setValue("fadeEnd", self.drawDistance)
			
			self.wetRoadsShader:setValue("sunColor", currentSettungs.sunColor)
			self.wetRoadsShader:setValue("wetStage", self.wetStage)
			self.wetRoadsShader:setValue("fadeValue", self.fadeValue)
			self.wetRoadsShader:setValue("puddleMask", self.puddleMask)
			self.wetRoadsShader:setValue("waterNormal", self.waterNormal)
			self.wetRoadsShader:setValue("zoomXValue", currentSettungs.zoomXValue)
			self.wetRoadsShader:setValue("zoomYValue", currentSettungs.zoomYValue)
			self.wetRoadsShader:setValue("bumpFactor", currentSettungs.bumpFactor)	
			self.wetRoadsShader:setValue("shiftXValue", currentSettungs.shiftXValue)
			self.wetRoadsShader:setValue("shiftYValue", currentSettungs.shiftYValue)	
			self.wetRoadsShader:setValue("diffuseFactor", currentSettungs.diffuseFactor)	
			self.wetRoadsShader:setValue("reflectionStrength", currentSettungs.reflectionStrength)
			self.wetRoadsShader:setValue("fadeStart", self.drawDistance / 10)
			self.wetRoadsShader:setValue("fadeEnd", self.drawDistance)
			self.wetRoadsShader:setValue("wetLevel", self.wetLevel)
			
			if (self.mainClass.roadShineConfigs) then
				self.wetRoadsWithPuddlesShader:setValue("lightDirection", self.mainClass.roadShineConfigs:getLightDirection())
				self.wetRoadsWithPuddlesShader:setValue("specularBrightness", self.mainClass.roadShineConfigs:getBrightness())
				self.wetRoadsWithPuddlesShader:setValue("specularStrength", self.mainClass.roadShineConfigs:getSharpness())
				
				self.wetRoadsShader:setValue("lightDirection", self.mainClass.roadShineConfigs:getLightDirection())
				self.wetRoadsShader:setValue("specularBrightness", self.mainClass.roadShineConfigs:getBrightness())
				self.wetRoadsShader:setValue("specularStrength", self.mainClass.roadShineConfigs:getSharpness())
			end
			
			self:startFrame()
			self.screenSource:update()
			
			self.current = self.screenSource
			
			self.current = self:applyGBlurH(self.current, currentSettungs.bloomFactor)
			self.current = self:applyGBlurV(self.current, currentSettungs.bloomFactor)
			
			dxSetRenderTarget()
			
			self.wetRoadsShader:setValue("screenSource", self.current)
			self.wetRoadsWithPuddlesShader:setValue("screenSource", self.current)
		end
	end
end


function WetShadersC:startFrame()
	for renderTarget, info in pairs(self.renderTargetPool.list) do
		if (info) then
			info.isInUse = false
		end
	end
end


function WetShadersC:applyGBlurH(source, bloom)
	if (source) then
		local mw, mh = dxGetMaterialSize(source)
		
		local newRenderTarget = self:getUnusedRenderTarget(mw, mh)
		
		if (newRenderTarget) then
			dxSetRenderTarget(newRenderTarget, true) 
			
			self.blurHShader:setValue("TEX0", source)
			self.blurHShader:setValue("TEX0SIZE", {mw, mh})
			self.blurHShader:setValue("BLOOM", bloom )
			
			dxDrawImage( 0, 0, mw / 2, mh / 2, self.blurHShader)
			
			return newRenderTarget
		end
	end
end


function WetShadersC:applyGBlurV(source, bloom)
	if (source) then
		local mw, mh = dxGetMaterialSize(source)
		
		local newRenderTarget = self:getUnusedRenderTarget(mw, mh)
		
		if (newRenderTarget) then
			dxSetRenderTarget(newRenderTarget, true) 
			self.blurVShader:setValue("TEX0", source)
			self.blurVShader:setValue("TEX0SIZE", mw, mh)
			self.blurVShader:setValue("BLOOM", bloom )
			
			dxDrawImage( 0, 0, mw / 2, mh / 2, self.blurVShader)
			
			return newRenderTarget
		end
	end
end


function WetShadersC:getUnusedRenderTarget(w, h)
	for renderTarget, info in pairs(self.renderTargetPool.list) do
		if (not info.isInUse and info.w == w and info.h == h) then
			info.isInUse = true
			return renderTarget
		end
	end

	local newRenderTarget = dxCreateRenderTarget(w / 2, h / 2)
	
	if (newRenderTarget) then
		self.renderTargetPool.list[newRenderTarget] = {isInUse = true, w = w, h = h}
	end
	
	return newRenderTarget
end


function WetShadersC:checkVersion()
	if (getVersion().sortable < "1.5") then
		mainOutput("FAIL // Resource is not compatible with this client. Please update to MTA 1.5!")
		return nil
	end
	
	return true
end


function WetShadersC:clear()
	if (self.screenSource) then
		self.screenSource:destroy()
		self.screenSource = nil
	end
	
	if (self.blurHShader) then
		self.blurHShader:destroy()
		self.blurHShader = nil
	end
	
	if (self.blurVShader) then
		self.blurVShader:destroy()
		self.blurVShader = nil
	end

	if (self.wetRoadsShader) then
		self.wetRoadsShader:destroy()
		self.wetRoadsShader = nil
	end
	
	if (self.wetRoadsWithPuddlesShader) then
		self.wetRoadsWithPuddlesShader:destroy()
		self.wetRoadsWithPuddlesShader = nil
	end
	
	if (self.puddleMask) then
		self.puddleMask:destroy()
		self.puddleMask = nil
	end
	
	if (self.waterNormal) then
		self.waterNormal:destroy()
		self.waterNormal = nil
	end
	
	if (self.waterDropsNormal) then
		self.waterDropsNormal:destroy()
		self.waterDropsNormal = nil
	end
	
	for renderTarget, info in pairs(self.renderTargetPool.list) do
		if (renderTarget) then
			renderTarget:destroy()
			renderTarget = nil
		end
	end
	
	self.renderTargetPool = nil
end


function WetShadersC:destructor()
	self:clear()
	
	mainOutput("WetShadersC was deleted.")
end