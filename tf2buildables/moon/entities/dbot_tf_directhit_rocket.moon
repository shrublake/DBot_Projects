
--
-- Copyright (C) 2017 DBot
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

AddCSLuaFile()

ENT.PrintName = 'Direct Hit Rocket Projectile'
ENT.Author = 'DBot'
ENT.Category = 'TF2'
ENT.Base = 'dbot_tf_rocket_projectile'
ENT.Type = 'anim'
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.BlowRadius = 170
ENT.ProjectileDamage = 110
ENT.ProjectileSpeed = 1500 * 1.8
ENT.BlowSound = 'DTF2_Weapon_RPG_DirectHit.Explode'
ENT.DegradationDivider = 2048

return if CLIENT
ENT.OnHit = (ent) =>
	return if not IsValid(ent)
	if ent.OnGround and not ent\OnGround()
		@SetIsMiniCritical(true)
