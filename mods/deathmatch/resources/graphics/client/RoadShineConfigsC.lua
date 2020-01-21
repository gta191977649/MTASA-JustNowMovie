--[[
	Name: WetRoadsReloaded
	Filename: RoadShineConfigsC.lua
	Authors: Ren712, Sam@ke
--]]

RoadShineConfigsC = {}

function RoadShineConfigsC:constructor(parent)
	mainOutput("RoadShineConfigsC was loaded.")
	
	self.mainClass = parent
	
	self.shineDirectionList = {
			-- H   M    Direction x, y, z,                  sharpness,	brightness,	nightness
			{  0,  0,	-0.019183,	0.994869,	-0.099336,	4,			0.0,		1 },			-- Moon fade in start
			{  0, 30,	-0.019183,	0.994869,	-0.099336,	4,			0.25,		1 },			-- Moon fade in end
			{  3, 00,	-0.019183,	0.994869,	-0.099336,	4,			0.5,		1 },			-- Moon bright
			{  6, 30,	-0.019183,	0.994869,	-0.099336,	4,			0.5,		1 },			-- Moon fade out start
			{  6, 39,	-0.019183,	0.994869,	-0.099336,	4,			0.0,		0 },			-- Moon fade out end

			{  6, 40,	-0.914400,	0.377530,	-0.146093,	16,			0.0,		0 },			-- Sun fade in start
			{  6, 50,	-0.914400,	0.377530,	-0.146093,	16,			1.0,		0 },			-- Sun fade in end
			{  7,  0,	-0.891344,	0.377265,	-0.251386,	16,			1.0,		0 },			-- Sun
			{ 10,  0,	-0.678627,	0.405156,	-0.612628,	16,			0.5,		0 },			-- Sun
			{ 13,  0,	-0.303948,	0.490790,	-0.816542,	16,			0.5,		0 },			-- Sun
			{ 16,  0,	 0.169642,	0.707262,	-0.686296,	16,			0.5,		0 },			-- Sun
			{ 18,  0,	 0.380167,	0.893543,	-0.238859,	16,			0.5,		0 },			-- Sun
			{ 18, 30,	 0.398043,	0.911378,	-0.238859,	4,			1.0,		0 },			-- Sun
			{ 18, 53,	 0.360288,	0.932817,	-0.238859,	1,			1.5,		0 },			-- Sun fade out start
			{ 19, 00,	 0.360288,	0.932817,	-0.238859,	1,			0.0,		0 },			-- Sun fade out end

			{ 19, 01,	 0.360288,	0.932817,	-0.612628,	4,			0.0,		0 },			-- General fade in start
			{ 19, 30,	 0.360288,	0.932817,	-0.612628,	4,			0.5,		0 },			-- General fade in end
			{ 21, 00,	 0.360288,	0.932817,	-0.612628,	4,			0.5,		0 },			-- General fade out start
			{ 22, 09,	 0.360288,	0.932817,	-0.612628,	4,			0.0,		0 },			-- General fade out end

			{ 22, 10,	-0.744331,	0.663288,	-0.077591,	32,			0.0,		1 },			-- Star fade in start
			{ 22, 30,	-0.744331,	0.663288,	-0.077591,	32,			0.5,		1 },			-- Star fade in end
			{ 23, 50,	-0.744331,	0.663288,	-0.077591,	32,			0.5,		1 },			-- Star fade out start
			{ 23, 59,	-0.744331,	0.663288,	-0.077591,	32,			0.0,		1 },			-- Star fade out end
			}
	
	self.weatherInfluenceList = {
			-- id   sun:size   :translucency  :bright      night:bright 
			{  0,       1,			0,			1,			1 },		-- Hot, Sunny, Clear
			{  1,       0.8,		0,			1,			1 },		-- Sunny, Low Clouds
			{  2,       0.8,		0,			1,			1 },		-- Sunny, Clear
			{  3,       0.8,		0,			0.8,		1 },		-- Sunny, Cloudy
			{  4,       1,			0,			0.2,		0 },		-- Dark Clouds
			{  5,       3,			0,			0.5,		1 },		-- Sunny, More Low Clouds
			{  6,       3,			1,			0.5,		1 },		-- Sunny, Even More Low Clouds
			{  7,       1,			0,			0.01,		0 },		-- Cloudy Skies
			{  8,       1,			0,			0,			0 },		-- Thunderstorm
			{  9,       1,			0,			0,			0 },		-- Foggy
			{  10,      1,			0,			1,			1 },		-- Sunny, Cloudy (2)
			{  11,      3,			0,			1,			1 },		-- Hot, Sunny, Clear (2)
			{  12,      3,			1,			0.5,		0 },		-- White, Cloudy
			{  13,      1,			0,			0.8,		1 },		-- Sunny, Clear (2)
			{  14,      1,			0,			0.7,		1 },		-- Sunny, Low Clouds (2)
			{  15,      1,			0,			0.1,		0 },		-- Dark Clouds (2)
			{  16,      1,			0,			0,			0 },		-- Thunderstorm (2)
			{  17,      3,			1,			0.8,		1 }, 		-- Hot, Cloudy
			{  18,      3,			1,			0.8,		1 },		-- Hot, Cloudy (2)
			{  19,      1,			0,			0,			0 },		-- Sandstorm
		}
		
	self.lightDirection = {0, 0, 1}
	self.sharpness = 0
	self.brightness = 0
	self.timeHMS = {0, 0, 0}

end


function RoadShineConfigsC:update()
	self:calculateTime()
	self:updateShineDirection()
end


function RoadShineConfigsC:calculateTime()
	self.hour, self.minute = getTime()
	self.second = 0
	
	if (self.minute ~= self.timeHMS[2]) then
		self.minuteStartTickCount = getTickCount()
		local gameSpeed = math.clamp(0.01, getGameSpeed(), 10)
		self.minuteEndTickCount = self.minuteStartTickCount + 1000 / gameSpeed
	end
	
	if (self.minuteStartTickCount) then
		local minFraction = math.unlerpclamped(self.minuteStartTickCount, getTickCount(), self.minuteEndTickCount )
		self.second = math.min(59, math.floor(minFraction * 60))
	end
	
	self.timeHMS = {self.hour, self.minute, self.second}
end


function RoadShineConfigsC:updateShineDirection()

	local h, m, s = getTimeHMS(self.timeHMS)
	local fhoursNow = h + m / 60 + s / 3600

	for idx, v in ipairs(self.shineDirectionList) do
		local fhoursTo = v[1] + v[2] / 60
		
		if (fhoursNow <= fhoursTo) then
			local vFrom = self.shineDirectionList[math.max( idx-1, 1 )]
			local fhoursFrom = vFrom[1] + vFrom[2] / 60
		
			local f = math.unlerp(fhoursFrom, fhoursNow, fhoursTo)
			local x = math.lerp(vFrom[3], f, v[3])
			local y = math.lerp(vFrom[4], f, v[4])
			local z = math.lerp(vFrom[5], f, v[5])
			local sharpness  = math.lerp(vFrom[6], f, v[6])
			local brightness = math.lerp(vFrom[7], f, v[7])
			local nightness = math.lerp(vFrom[8], f, v[8])

			self.sharpness, self.brightness = self:applyWeatherInfluence(sharpness, brightness, nightness)

			local threshold = -0.128859
			if (z < threshold) then
				z = (z - threshold) / 2 + threshold
			end

			self.lightDirection = {x, y, z}
			
			break
		end
	end
end


function RoadShineConfigsC:applyWeatherInfluence(sharpness, brightness, nightness)

	local id = getWeather()
	id = math.min(id, #self.weatherInfluenceList - 1)
	local item = self.weatherInfluenceList[id + 1]
	
	if (item) then
		local sunSize = item[2]
		local sunTranslucency = item[3]
		local sunBright = item[4]
		local nightBright = item[5]

		local useSize  = math.lerp(sunSize, nightness, 1)
		local useTranslucency = math.lerp(sunTranslucency, nightness, 0)
		local useBright = math.lerp(sunBright, nightness, nightBright)

		brightness = brightness * useBright
		sharpness = sharpness / useSize
	end
	
	return sharpness, brightness
end


function RoadShineConfigsC:getResourceTime()
	return self.timeHMS
end


function RoadShineConfigsC:getLightDirection()
	return self.lightDirection
end


function RoadShineConfigsC:getSharpness()
	return self.sharpness
end


function RoadShineConfigsC:getBrightness()
	return self.brightness
end


function RoadShineConfigsC:destructor()

	
	mainOutput("RoadShineConfigsC was deleted.")
end