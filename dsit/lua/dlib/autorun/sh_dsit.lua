
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

_G.DSitConVars = DLib.Convars('dsit')
_G.DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES or table()
local DSitConVars = _G.DSitConVars
local DSIT_TRACKED_VEHICLES = _G.DSIT_TRACKED_VEHICLES

DSitConVars:create('enable', '1', {FCVAR_NOTIFY}, 'Enable')
DSitConVars:create('speed_val', '350', {FCVAR_NOTIFY}, 'Speed check value. Set to 0 or less to disable')
DSitConVars:create('allow_weapons', '1', {FCVAR_NOTIFY}, 'Allow weapons in seat')
DSitConVars:create('distance', '128', {FCVAR_NOTIFY}, 'Max distance (in Hammer Units)')
DSitConVars:create('anyangle', '0', {FCVAR_NOTIFY}, 'Letting players have fun')

DSitConVars:create('allow_ceiling', '1', {FCVAR_NOTIFY}, 'Allow players to sit on ceiling')

DSitConVars:create('entities', '1', {FCVAR_NOTIFY}, 'Allow to sit on entities')
DSitConVars:create('entities_owner', '0', {FCVAR_NOTIFY}, 'Allow to sit on entities owned only by that player')
DSitConVars:create('entities_world', '0', {FCVAR_NOTIFY}, 'Allow to sit on non-owned entities only')

DSitConVars:create('players', '1', {FCVAR_NOTIFY}, 'Allow to sit on players (heads)')
DSitConVars:create('players_legs', '1', {FCVAR_NOTIFY}, 'Allow to sit on players (legs/sit on sitting players)')

DLib.nw.pool('dsit_flag', net.WriteBool, net.ReadBool, false)
DLib.nw.pool('dsit_entity', net.WriteEntity, net.ReadEntity, NULL)
DLib.nw.pool('dsit_target', net.WritePlayer, net.ReadPlayer, NULL)

local function PhysgunPickup(ply, ent)
	if IsValid(ply:DLibVar('dsit_entity')) then
		return false
	end

	ply.dsit_pickup = true
end

local function PhysgunDrop(ply, ent)
	ply.dsit_pickup = nil
end

DLib.friends.Register('dsit', 'DSit Friend', true)

local function Think()
	local lply, lang

	if CLIENT then
		lply = LocalPlayer()
		lang = Angle(0, 0, 0)

		if lply:InVehicle() then
			lang = lply:GetVehicle():GetAngles()
		end
	end

	for i, vehicle in DSIT_TRACKED_VEHICLES:ipairs() do
		if not IsValid(vehicle) then
			DSIT_TRACKED_VEHICLES:remove(i)
			return
		end

		local ent = vehicle:DLibVar('dsit_target')

		if not IsValid(ent) or not ent:Alive() then
			if SERVER then
				vehicle:Remove()
				DSIT_TRACKED_VEHICLES:remove(i)
			end

			goto CONTINUE
		end

		local ang = ent:EyeAngles()

		if ent == lply then
			ang = ang + lang
		end

		local pos = ent:EyePos()

		ang.p = 0
		ang.r = 0
		ang.y = math.floor(ang.y - 90)
		pos.z = pos.z + 10
		ang:Normalize()

		if vehicle:GetPos() ~= pos then vehicle:SetPos(pos) end
		if vehicle:GetAngles() ~= ang then vehicle:SetAngles(ang) end

		if CLIENT then
			vehicle:SetRenderOrigin(pos)
			vehicle:SetRenderAngles(ang)
		end

		::CONTINUE::
	end
end

-- hook.Add('PhysgunPickup', 'DSit', PhysgunPickup)
-- hook.Add('PhysgunDrop', 'DSit', PhysgunDrop)
hook.Add('GravGunPickupAllowed', 'DSit', PhysgunPickup)
hook.Add('GravGunPunt', 'DSit', PhysgunPickup)
hook.Add('Think', 'DSit', Think)
