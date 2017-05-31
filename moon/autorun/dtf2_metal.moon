
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

export DTF2
DTF2 = DTF2 or {}

plyMeta = FindMetaTable('Player')

export DTF2_MAX_METAL
DTF2_MAX_METAL = CreateConVar('dtf2_max_metal', '200', {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}, 'Max metal per player')

PlayerClass =
    GetMaxTF2Metal: => @GetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL\GetInt())
    MaxTF2Metal: => @GetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL\GetInt())
    SetMaxTF2Metal: (amount = DTF2_MAX_METAL\GetInt()) => @SetNWInt('DTF2.MaxMetal', amount)
    ResetMaxTF2Metal: => @SetNWInt('DTF2.MaxMetal', DTF2_MAX_METAL\GetInt())
    ResetTF2Metal: => @SetNWInt('DTF2.Metal', DTF2_MAX_METAL\GetInt())
    GetTF2Metal: => @GetNWInt('DTF2.Metal')
    SetTF2Metal: (amount = @GetTF2Metal()) => @SetNWInt('DTF2.Metal', amount)
    AddTF2Metal: (amount = 0) => @SetNWInt('DTF2.Metal', @GetTF2Metal() + amount)
    ReduceTF2Metal: (amount = 0) => @SetNWInt('DTF2.Metal', @GetTF2Metal() - amount)
    RemoveTF2Metal: => @SetNWInt('DTF2.Metal', 0)
    HasTF2Metal: (amount = 0) => @GetTF2Metal() >= amount
    SimulateTF2MetalRemove: (amount = 0, apply = true) =>
        return 0 if @GetTF2Metal() <= 0
        oldMetal = @GetTF2Metal()
        newMetal = math.Clamp(oldMetal - amount, 0, @GetMaxTF2Metal())
        @SetTF2Metal(newMetal) if apply
        return oldMetal - newMetal
    SimulateTF2MetalAdd: (amount = 0, apply = true, playSound = apply) =>
        return 0 if @GetTF2Metal() >= @GetMaxTF2Metal()
        oldMetal = @GetTF2Metal()
        newMetal = math.Clamp(oldMetal + amount, 0, @GetMaxTF2Metal())
        @SetTF2Metal(newMetal) if apply
        @EmitSound('items/ammo_pickup.wav', 50, 100, 0.7) if playSound
        return newMetal - oldMetal

plyMeta[k] = v for k, v in pairs PlayerClass

if SERVER
    hook.Add 'PlayerSpawn', 'DTF2.Metal', => @ResetTF2Metal()
