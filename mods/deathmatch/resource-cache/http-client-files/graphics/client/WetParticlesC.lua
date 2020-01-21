--[[
	Name: WetRoadsReloaded
	Filename: WetParticlesC.lua
	Authors: Sam@ke
--]]

WetParticlesC = {}

function WetParticlesC:constructor(parent)
	mainOutput("WetParticlesC was loaded.")
	
	self.mainClass = parent
	self.showPlayerParticles = "true"
	self.showOtherParticle = "true"
	
	self.player = getLocalPlayer()
	self.vehicle = nil
	self.vehicleSpeed = 0

	self.rainLevel = 0.5
	
	self.playerParticlePositions = {}
end


function WetParticlesC:update()
	if (self.mainClass) then
		if (self.mainClass.wetShaders:getWetLevel()) then
			if (self.mainClass.wetShaders:getWetLevel() >= 0.2) then
				self.vehicle = self.player:getOccupiedVehicle()
				
				self.playerParticlePositions = {}
				
				if (self.vehicle) and (self.player:isInVehicle()) then
					if (self.vehicle:isOnGround()) then
						local vehicleSpeed = self.vehicle:getVelocity()
						
						if (vehicleSpeed) then
							self.vehicleSpeed = (vehicleSpeed.x^2 + vehicleSpeed.y^2 + vehicleSpeed.z^2)^(0.5)
						end

						
						local xwlf, ywlf, zwlf = getVehicleComponentPosition(self.vehicle, "wheel_lf_dummy" , "world")
						
						if (xwlf) and (ywlf) and (zwlf) then
							if (not self.playerParticlePositions["wheel_lf_dummy"]) then
								self.playerParticlePositions["wheel_lf_dummy"] = {x = xwlf, y = ywlf, z = zwlf - 0.9}
							else
								self.playerParticlePositions["wheel_lf_dummy"].x = xwlf
								self.playerParticlePositions["wheel_lf_dummy"].y = ywlf
								self.playerParticlePositions["wheel_lf_dummy"].z = zwlf
							end
						end
						
						local xwrf, ywrf, zwrf = getVehicleComponentPosition(self.vehicle, "wheel_rf_dummy" , "world")
						
						if (xwrf) and (ywrf) and (zwrf) then
							if (not self.playerParticlePositions["wheel_rf_dummy"]) then
								self.playerParticlePositions["wheel_rf_dummy"] = {x = xwrf, y = ywrf, z = zwrf - 0.9}
							else
								self.playerParticlePositions["wheel_rf_dummy"].x = xwrf
								self.playerParticlePositions["wheel_rf_dummy"].y = ywrf
								self.playerParticlePositions["wheel_rf_dummy"].z = zwrf
							end
						end
						
						local xwlb, ywlb, zwlb = getVehicleComponentPosition(self.vehicle, "wheel_lb_dummy" , "world")
						
						if (xwlb) and (ywlb) and (zwlb) then
							if (not self.playerParticlePositions["wheel_lb_dummy"]) then
								self.playerParticlePositions["wheel_lb_dummy"] = {x = xwlb, y = ywlb, z = zwlb - 0.9}
							else
								self.playerParticlePositions["wheel_lb_dummy"].x = xwlb
								self.playerParticlePositions["wheel_lb_dummy"].y = ywlb
								self.playerParticlePositions["wheel_lb_dummy"].z = zwlb
							end
						end
						
						local xwrb, ywrb, zwrb = getVehicleComponentPosition(self.vehicle, "wheel_rb_dummy" , "world")
						
						if (xwrb) and (ywrb) and (zwrb) then
							if (not self.playerParticlePositions["wheel_rb_dummy"]) then
								self.playerParticlePositions["wheel_rb_dummy"] = {x = xwrb, y = ywrb, z = zwrb - 0.9}
							else
								self.playerParticlePositions["wheel_rb_dummy"].x = xwrb
								self.playerParticlePositions["wheel_rb_dummy"].y = ywrb
								self.playerParticlePositions["wheel_rb_dummy"].z = zwrb
							end
						end
						
						if (self.showPlayerParticles == "true") then
							if (self.vehicleSpeed > 0.05) then
								self:drawPlayerParticles()
							end
						end
						
						if (self.showOtherParticle == "true") then
							--self:drawOtherParticles()
						end
					end
				end
			end
		end
	end
end


function WetParticlesC:drawPlayerParticles()
	for index, posContainer in pairs(self.playerParticlePositions) do
		if (posContainer) then
			if (posContainer.x) and (posContainer.y) and (posContainer.z) then
				self:addParticle(posContainer.x, posContainer.y, posContainer.z)
			end
		end
	end
end


function WetParticlesC:drawOtherParticles()
	
end


function WetParticlesC:addParticle(x, y, z)
	if (x) and (y) and (z) then
		fxAddBulletSplash(x, y, z)
		--fxAddTyreBurst(x, y, z + 0.6, 0, 0, 0.2)
	end
end


function WetParticlesC:clear()
	
	self.playerParticlePositions = nil
end


function WetParticlesC:destructor()
	self:clear()
	
	mainOutput("WetParticlesC was deleted.")
end