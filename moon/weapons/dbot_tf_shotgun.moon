
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

BaseClass = baseclass.Get('dbot_tf_ranged')

SWEP.Base = 'dbot_tf_ranged'
SWEP.Author = 'DBot'
SWEP.Category = 'TF2'
SWEP.PrintName = 'Shotgun'
SWEP.ViewModel = 'models/weapons/v_models/v_shotgun_engineer.mdl'
SWEP.WorldModel = 'models/weapons/w_models/w_shotgun.mdl'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.AdminOnly = false
SWEP.UseHands = false

SWEP.MuzzleAttachment = 'muzzle'
SWEP.MuzzleEffect = 'muzzle_shotgun'

SWEP.BulletDamage = 14
SWEP.BulletsAmount = 6
SWEP.ReloadBullets = 1
SWEP.DefaultSpread = Vector(1, 1, 0) * 0.05

SWEP.FireSounds = {'weapons/shotgun_shoot.wav'}

SWEP.Primary = {
    'Ammo': 'Buckshot'
    'ClipSize': 6
    'DefaultClip': 6
    'Automatic': true
}
