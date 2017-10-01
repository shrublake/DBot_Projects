
-- Copyright (C) 2017 DBot

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
local weaponMeta = FindMetaTable('Weapon')
local entMeta = FindMetaTable('Entity')
local IN_CALL = false
local ENABLE_PHYSICAL_BULLETS = CreateConVar('sv_physbullets', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Enable physical bullets')
local PHYSICAL_SPREAD = CreateConVar('sv_physbullets_spread', '1', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Physical bullets spread multiplier')
local DISABLE_TRACERS

if CLIENT then
	DISABLE_TRACERS = CreateConVar('sv_physbullets_tracers', '0', {FCVAR_ARCHIVE}, 'Enable default tracers for bullets')
end

weaponrystats.SKIP_NEXT = false

local HL2WEP_MAPPING = DLib.hl2wdata

local function EntityFireBullets(self, bulletData)
	if IN_CALL then return end

	if weaponrystats.SKIP_NEXT then
		weaponrystats.SKIP_NEXT = false
		return
	end

	if self.IS_BULLET then return end

	if type(self) ~= 'Weapon' and type(bulletData.Attacker) == 'Player' then return end

	local findWeapon, findOwner

	if type(self) == 'Player' then
		findOwner = self
		findWeapon = self:GetActiveWeapon()
	elseif type(self) == 'Weapon' then
		findWeapon = self
		findOwner = self:GetOwner()
	end

	if not IsValid(findWeapon) or not IsValid(findOwner) then return end
	local modif, wtype = findWeapon:GetWeaponModification(), findWeapon:GetWeaponType()
	if not modif and not wtype then return end
	findWeapon.weaponrystats_bullets = CurTime()

	local hl2 = HL2WEP_MAPPING[findWeapon:GetClass()]
	if hl2 then
		bulletData.Damage = hl2.damage
		bulletData.PhysDamageType = hl2.dtype
	end

	if wtype then
		local oldCallback = bulletData.Callback

		bulletData.Spread = ((bulletData.Spread or Vector(0, 0, 0)) + wtype.scatterAdd) * wtype.scatter
		bulletData.Distance = math.ceil((bulletData.Distance or 56756) * wtype.dist)
		bulletData.Num = math.max(math.floor(((bulletData.Num or 1) + wtype.numAdd) * wtype.num), 1)

		if wtype.isAdditional then
			function bulletData.Callback(attacker, tr, dmginfo, ...)
				if IsValid(tr.Entity) and SERVER then
					local newDMG = dmginfo:Copy()
					newDMG:SetDamage(dmginfo:GetDamage() * (wtype.damage or 1))
					newDMG:SetMaxDamage(dmginfo:GetMaxDamage() * (wtype.damage or 1))
					newDMG:SetDamageType(wtype.dmgtype)
					tr.Entity:TakeDamageInfo(newDMG)
				end

				if oldCallback then oldCallback(attacker, tr, dmginfo, ...) end
			end
		else
			bulletData.Damage = (bulletData.Damage or 1) * (wtype.damage or 1)
			bulletData.Force = (bulletData.Force or 1) * (wtype.force or 1)

			function bulletData.Callback(attacker, tr, dmginfo, ...)
				dmginfo:SetDamageType(bit.bor(dmginfo:GetDamageType(), wtype.dmgtype))
				if oldCallback then oldCallback(attacker, tr, dmginfo, ...) end
			end
		end
	end

	if modif then
		bulletData.Damage = (bulletData.Damage or 1) * (modif.damage or 1)
		bulletData.Force = (bulletData.Force or 1) * (modif.force or 1)
	end

	bulletData.Distance = bulletData.Distance or 56756

	if CLIENT or not ENABLE_PHYSICAL_BULLETS:GetBool() or bulletData.Distance < 1024 then
		if CLIENT and not DISABLE_TRACERS:GetBool() and bulletData.Distance > 1024 then return false end
		return true
	else
		bulletData.Num = bulletData.Num or 1
		bulletData.Spread = bulletData.Spread or Vector(0, 0, 0)

		for i = 1, bulletData.Num do
			local spreadPos = DLib.util.randomVector(bulletData.Spread.x, bulletData.Spread.x, bulletData.Spread.y) * PHYSICAL_SPREAD:GetInt() * 0.65
			
			local trData = {
				start = bulletData.Src,
				endpos = bulletData.Src + bulletData.Dir * bulletData.Distance,
				filter = self
			}

			local tr = util.TraceLine(trData)

			local bulletType = wtype.bullet or 'dbot_physbullet'
			local ent = ents.Create(bulletType)
			ent:SetBulletCallback(bulletData.Callback)
			local copied = table.Copy(bulletData)
			copied.Num = 1
			ent:SetBulletData(copied)
			ent:SetInitialTrace(tr)
			ent:SetPos(bulletData.Src)
			ent:SetAngles(bulletData.Dir:Angle())
			ent:SetDirection(bulletData.Dir + spreadPos)
			ent:SetDistance(bulletData.Distance)
			ent:SetForce(bulletData.Force or 1)
			ent:SetAttacker(bulletData.Attacker or self)
			ent:SetInflictor(self)
			ent:SetInitialEntity(self)
			ent:SetDamage(copied.Damage)
			ent:SetMaxDamage(copied.Damage)
			ent:SetReportedPosition(bulletData.Src)
			ent:SetDamagePosition(nil)
			ent:SetDamageType(DMG_BULLET)
			ent:SetOwner(self)
			ent:Spawn()
			ent:Activate()
			ent:SetOwner(self)
			ent:Think()
		end

		return false
	end
end

entMeta.weaponrystats_FireBullets = entMeta.weaponrystats_FireBullets or entMeta.FireBullets

function entMeta:FireBullets(bulletData, ...)
	-- IN_CALL = true
	-- kill stupid gmod behaviour
	-- local status = hook.Run('EntityFireBullets', self, bulletData)
	-- IN_CALL = false
	-- if status == false then return end
	if EntityFireBullets(self, bulletData) == false then return end
	weaponrystats.SKIP_NEXT = true
	return entMeta.weaponrystats_FireBullets(self, bulletData, ...)
end

weaponrystats.EntityFireBullets = EntityFireBullets
weaponMeta.weaponrystats_SetNextPrimaryFire = weaponMeta.weaponrystats_SetNextPrimaryFire or weaponMeta.SetNextPrimaryFire
weaponMeta.weaponrystats_SetNextSecondaryFire = weaponMeta.weaponrystats_SetNextSecondaryFire or weaponMeta.SetNextSecondaryFire

function weaponMeta:SetNextPrimaryFire(time)
	local delta = time - CurTime()

	if delta > 0 then
		local modif, wtype = self:GetWeaponModification(), self:GetWeaponType()

		if modif and modif.speed then
			delta = delta / modif.speed
		end

		if wtype and wtype.speed then
			delta = delta / wtype.speed
		end

		time = CurTime() + delta
	end

	return weaponMeta.weaponrystats_SetNextPrimaryFire(self, time)
end

function weaponMeta:SetNextSecondaryFire(time)
	local delta = time - CurTime()

	if delta > 0 then
		local modif, wtype = self:GetWeaponModification(), self:GetWeaponType()

		if modif and modif.speed then
			delta = delta / modif.speed
		end

		if wtype and wtype.speed then
			delta = delta / wtype.speed
		end

		time = CurTime() + delta
	end

	return weaponMeta.weaponrystats_SetNextSecondaryFire(self, time)
end

hook.Add('EntityFireBullets', 'WeaponryStats.EntityFireBullets', EntityFireBullets)
