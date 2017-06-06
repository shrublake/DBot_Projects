
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

include 'shared.lua'

net.Receive 'DTF2.SendWeaponAnim', ->
    act = net.ReadUInt(16)
    wep = LocalPlayer()\GetActiveWeapon()
    return if not IsValid(wep)
    wep\SendWeaponAnim2(act)

net.Receive 'DTF2.SendWeaponSequence', ->
    act = net.ReadUInt(16)
    wep = LocalPlayer()\GetActiveWeapon()
    return if not IsValid(wep)
    wep\SendWeaponSequence(act)

SWEP.SendWeaponSequence = (seq = 0) =>
    hands = @GetOwner()\GetViewModel()
    return if not IsValid(hands)
    seq = hands\LookupSequence(seq) if type(seq) ~= 'number'
    hands\SendViewModelMatchingSequence(seq)

SWEP.SendWeaponAnim2 = (act = ACT_INVALID) =>
    hands = LocalPlayer()\GetHands()
    return if not IsValid(hands)
    seqId = hands\SelectWeightedSequence(act)
    hands\ResetSequence(seqId) if seqId

SWEP.PostDrawViewModel = (viewmodel = NULL, weapon = NULL, ply = NULL) =>
    return if not IsValid(@GetTF2WeaponModel())
    @GetTF2WeaponModel()\DrawModel()

return nil
