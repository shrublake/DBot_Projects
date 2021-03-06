

--
-- Copyright (C) 2017-2018 DBot
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

-- Was auto generated by allclass_melee.py

AddCSLuaFile()

SWEP.Base = 'dbot_tf_melee'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2 Heavy'
SWEP.PrintName = 'Memory Maker (Heavy)'
SWEP.ViewModel = 'models/weapons/c_models/c_heavy_arms.mdl'
SWEP.WorldModel = 'models/weapons/c_models/c_8mm_camera/c_8mm_camera.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.BulletDamage = 65
SWEP.BulletForce = 20
SWEP.PreFire = 0.24
SWEP.CooldownTime = 0.8

SWEP.MissSoundsScript = 'Weapon_Fist.Miss'
SWEP.MissCritSoundsScript = 'Weapon_Fist.MissCrit'
SWEP.HitSoundsScript = 'Weapon_Fist.HitWorld'
SWEP.HitSoundsFleshScript = 'Weapon_Fist.HitFlesh'

SWEP.DrawAnimation = 'melee_allclass_draw'
SWEP.IdleAnimation = 'melee_allclass_idle'

SWEP.AttackAnimation = 'melee_allclass_swing'
SWEP.AttackAnimationTable = {'melee_allclass_swing'}
SWEP.AttackAnimationCrit = 'melee_allclass_swing'

