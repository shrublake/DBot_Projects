
-- Copyright (C) 2017-2018 DBot

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at

--     http://www.apache.org/licenses/LICENSE-2.0

-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local weaponrystats = weaponrystats

local ALLOW_BLINK = CreateConVar('cl_weaponrystats_blinking', '1', {FCVAR_ARCHIVE}, 'Labels of current weapon are blinking')

local GET_POSITION = DLib.HUDCommons.DefinePosition('weaponrystats', 0.7, 15)

surface.CreateFont('WPS.DisplayName', {
	font = 'Roboto',
	size = 18,
	weight = 400
})

surface.CreateFont('WPS.DisplayStats', {
	font = 'Roboto',
	size = 14,
	weight = 400
})

local qualityColors = {
	Color(141, 141, 141),
	Color(255, 255, 255),
	Color(41, 78, 200),
	Color(35, 162, 68),
	Color(254, 199, 134),
	Color(239, 122, 122),
	Color(246, 156, 241),
	Color(173, 82, 231),
	Color(0, 255, 60),
	Color(255, 241, 15),
	Color(0, 255, 246),
	Color(255, 0, 0),
	Color(108, 0, 255),
}

local function doDrawText(text, x, y, color)
	surface.SetTextColor(0, 0, 0)
	surface.SetTextPos(x + 1, y + 1)
	surface.DrawText(text)

	surface.SetTextColor(color)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

local function HUDPaint()
	if not weaponrystats.ENABLED:GetBool() then return end
	local weapon = LocalPlayer():GetActiveWeapon()
	if not IsValid(weapon) then return end
	local modif, wtype = weapon:GetWeaponModification(), weapon:GetWeaponType()
	if not modif and not wtype then return end
	local name = weapon:GetPrintName()
	local x, y = GET_POSITION()
	local currentQuality = 0

	local sin = 0
	local STATS_COLOR = Color(255, 255, 255)

	if ALLOW_BLINK:GetBool() then
		sin = math.sin(RealTime() * 10) * 20
		STATS_COLOR = Color(230 + sin, 230 + sin, 230 + sin)
	end

	local speed = 1
	local force = 1
	local damage = 1
	local clip = 1
	local scatter = 1
	local scatterAdd = Vector(0, 0, 0)
	local num = 1
	local numAdd = 0
	local dist = 1
	local randomMin = 1
	local randomMax = 1
	local bulletSpeed = 1
	local bulletRicochet = 1
	local bulletPenetration = 1
	local additional = false
	local add = 0
	local dps = weapon:DLibVar('wps_dps')

	if string.sub(name, 1, 1) == '#' then
		name = language.GetPhrase(string.sub(name, 2))
	end

	if modif then
		name = modif.name .. ' ' .. name
		currentQuality = currentQuality + (modif.quality or 0)
		speed = speed * modif.speed
		force = force * modif.force
		damage = damage * modif.damage
		clip = clip * modif.clip
		scatter = scatter * modif.scatter
		num = num * modif.num
		dist = dist * modif.dist
		bulletSpeed = bulletSpeed * modif.bulletSpeed
		bulletRicochet = bulletRicochet * modif.bulletRicochet
		bulletPenetration = bulletPenetration * modif.bulletPenetration
		randomMin = randomMin * modif.randomMin
		randomMax = randomMax * modif.randomMax
		scatterAdd = scatterAdd + modif.scatterAdd
		numAdd = numAdd + modif.numAdd
	end

	if wtype then
		name = name .. ' of ' .. wtype.name
		currentQuality = currentQuality + (wtype.quality or 0)
		speed = speed * wtype.speed
		force = damage * wtype.force
		clip = clip * wtype.clip
		scatter = scatter * wtype.scatter
		num = num * wtype.num
		dist = dist * wtype.dist
		randomMin = randomMin * wtype.randomMin
		randomMax = randomMax * wtype.randomMax
		bulletSpeed = bulletSpeed * wtype.bulletSpeed
		bulletRicochet = bulletRicochet * wtype.bulletRicochet
		bulletPenetration = bulletPenetration * wtype.bulletPenetration
		scatterAdd = scatterAdd + wtype.scatterAdd
		numAdd = numAdd + wtype.numAdd

		if wtype.isAdditional then
			add = wtype.damage
			additional = true
		else
			damage = damage * wtype.damage
		end
	end

	local currentQualityColor = math.Clamp(currentQuality + 2, 1, #qualityColors)
	surface.SetFont('WPS.DisplayName')

	local r, g, b = qualityColors[currentQualityColor].r, qualityColors[currentQualityColor].g, qualityColors[currentQualityColor].b
	local colorQuality = Color(math.Clamp(r + sin, 0, 255), math.Clamp(g + sin, 0, 255), math.Clamp(b + sin, 0, 255))
	doDrawText(name, x, y, colorQuality)

	y = y + 17

	surface.SetFont('WPS.DisplayStats')

	doDrawText(string.format('Level %i weapon', currentQuality), x, y, colorQuality)
	y = y + 16

	doDrawText(string.format('%i damage per second', dps), x, y, STATS_COLOR)
	y = y + 19

	if additional then
		doDrawText(string.format('%+i%% damage (+%i%% additional damage)', damage * 100 - 100, add * 100), x, y, STATS_COLOR)
		y = y + 15
	else
		if damage ~= 1 then
			doDrawText(string.format('%+i%% damage', damage * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	end

	if speed ~= 1 then
		doDrawText(string.format('%+i%% attack speed', speed * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if force ~= 1 then
		doDrawText(string.format('%+i%% knockback', force * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if clip ~= 1 then
		doDrawText(string.format('%+i%% clip size', clip * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if scatterAdd:Length() == 0 then
		if scatter ~= 1 then
			doDrawText(string.format('%+i%% bullet scatter', scatter * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	else
		doDrawText(string.format('%+i%% bullet scatter (+%i extra)', scatter * 100 - 100, scatterAdd:Length() * 1000), x, y, STATS_COLOR)
		y = y + 15
	end

	if numAdd == 0 then
		if num ~= 1 then
			doDrawText(string.format('%+i%% bullets amount', num * 100 - 100), x, y, STATS_COLOR)
			y = y + 15
		end
	else
		doDrawText(string.format('%+i%% bullets amount (+%i extra bullets)', num * 100 - 100, numAdd), x, y, STATS_COLOR)
		y = y + 15
	end

	if dist ~= 1 then
		doDrawText(string.format('%+i%% bullet travel distance', dist * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletSpeed ~= 1 then
		doDrawText(string.format('%+i%% bullet travel speed', bulletSpeed * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletRicochet ~= 1 then
		doDrawText(string.format('%+i%% bullet ricochet force', bulletRicochet * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end

	if bulletPenetration ~= 1 then
		doDrawText(string.format('%+i%% bullet penetration force', bulletPenetration * 100 - 100), x, y, STATS_COLOR)
		y = y + 15
	end
end

weaponrystats.HUDPaint = HUDPaint

hook.Add('HUDPaint', 'WeaponryStats.HUD', HUDPaint)
