
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

BACKGROUND_COLOR =          DLib.HUDCommons.CreateColor('tf_background', 'TF HUD Background', 0, 0, 0, 150)
FONT_COLOR =                DLib.HUDCommons.CreateColor('tf_font', 'TF Font', 255, 255, 255)
FONT_COLOR_GREEN =          DLib.HUDCommons.CreateColor('tf_font_positive', 'TF HUD positive text', 88, 183, 56)
FONT_COLOR_RED =            DLib.HUDCommons.CreateColor('tf_font_negative', 'TF HUD negative text', 217, 101, 83)
COLOR_HP_BAR_BACKGROUND =   DLib.HUDCommons.CreateColor('tf_hpbar_background', 'TF HUD HP Bar Background', 176, 176, 176)
COLOR_HP_BAR =              DLib.HUDCommons.CreateColor('tf_hpbar', 'TF HUD HP Bar', 167, 197, 92)
HUD_BAR_BACKGROUND =        DLib.HUDCommons.CreateColor('tf_bar_bg', 'TF HUD generic bar background', 168, 168, 168)
HUD_BAR_COLOR =             DLib.HUDCommons.CreateColor('tf_bar', 'TF HUD generic bar', 235, 235, 235)

DTF2.BACKGROUND_COLOR = BACKGROUND_COLOR

FONT = 'DTF2.HUDFont'

surface.CreateFont(FONT, {
	'font': 'Roboto'
	'size': 18
	'weight': 400
})

METAL_HISTORY = {}
UPDATE_HISTORY = false

hook.Add 'Think', 'DTF2.UpdateMetalHistory', ->
	rTime = RealTime()

	if UPDATE_HISTORY
		METAL_HISTORY = [data for data in *METAL_HISTORY when data.endtime > rTime]
		UPDATE_HISTORY = false

	for data in *METAL_HISTORY
		if data.endtime < rTime
			UPDATE_HISTORY = true
		data.fade = (data.endtime - rTime) / 5
		data.a = data.fade * 255
		data.slide += FrameTime() * 25

hook.Add 'DTF2.MetalEffect', 'DTF2.MetalHistory', (event = true, amount = 0) ->
	return if amount == 0

	data = {
		start: RealTime()
		endtime: RealTime() + 5
		slide: 0
		fade: 1
		text: event and "+#{amount}" or "-#{amount}"
		color: event and FONT_COLOR_GREEN() or FONT_COLOR_RED()
	}

	table.insert(METAL_HISTORY, data)
	{:r, :g, :b} = data.color
	data.r = r
	data.g = g
	data.b = b
	data.a = 255

METAL_COUNTER_POS = DLib.HUDCommons.DefinePosition('tf_metal_counter', .8, .95)

DTF2.DrawMetalCounter = ->
	x, y = METAL_COUNTER_POS()
	DLib.HUDCommons.WordBox("Avaliable Metal: #{LocalPlayer()\GetTF2Metal()}", FONT, x, y, FONT_COLOR(), BACKGROUND_COLOR())
	
	x += 110
	for data in *METAL_HISTORY
		DLib.HUDCommons.WordBox(data.text, nil, x, y - data.slide, Color(data.r, data.g, data.b, data.a), Color(0, 0, 0, 150 * data.fade))

CENTERED_BUILDABLES_POS = DLib.HUDCommons.DefinePosition('tf_centered_buildables', .5, .6)
CENTERED_BAR_POS = DLib.HUDCommons.DefinePosition('tf_centered', .5, .65)
CENTERED_BAR_SMALLER_POS = DLib.HUDCommons.DefinePosition('tf_smallcentered', .5, .73)

DTF2.DrawCenteredBar = (mult = 0.5, text) ->
	x, y = CENTERED_BAR_POS()

	surface.SetTextColor(FONT_COLOR())
	surface.SetFont(FONT)
	DLib.HUDCommons.SoftBarWithText(x - 150, y, 300, 25, mult, BACKGROUND_COLOR(), HUD_BAR_BACKGROUND(), HUD_BAR_COLOR(), text, 'tf_centered')

DTF2.DrawSmallCenteredBar = (mult = 0.5, text) ->
	x, y = CENTERED_BAR_SMALLER_POS()
	surface.SetTextColor(FONT_COLOR())
	surface.SetFont(FONT)
	DLib.HUDCommons.SoftBarWithText(x - 100, y, 200, 18, mult, BACKGROUND_COLOR(), HUD_BAR_BACKGROUND(), HUD_BAR_COLOR(), text, 'tf_smallcentered')

DTF2.DrawBuildingInfo = =>
	x, y = CENTERED_BUILDABLES_POS()
	text = @GetDrawText and @GetDrawText() or @PrintName
	if IsValid(@GetTFPlayer()) and @GetTFPlayer()\IsPlayer()
		text ..= " built by #{@GetTFPlayer()\Nick()}"
	hp, mhp = @Health(), @GetMaxHealth()
	text ..= "\nHealth: #{hp}/#{mhp}"
	text ..= "\nUpgrade level: #{@GetUpgradeAmount()}/#{DTF2.GrabInt(@MAX_UPGRADE)}" if @GetLevel() < 3
	text ..= '\n'
	text ..= @GetHUDText()

	W, H = DLib.HUDCommons.AdvancedWordBox(text, FONT, x, y, FONT_COLOR(), BACKGROUND_COLOR(), true)

	surface.SetDrawColor(COLOR_HP_BAR_BACKGROUND())
	surface.DrawRect(x - W / 2, y + H - 12, W, 12)
	surface.SetDrawColor(COLOR_HP_BAR())
	surface.DrawRect(x - W / 2, y + H - 12, W * math.Clamp(hp / mhp, 0, 1), 12)

hook.Add 'HUDPaint', 'DTF2.BuildablesHUD', ->
	self = LocalPlayer()\GetEyeTrace().Entity
	return if not IsValid(@)
	return if not @IsTF2Building
	@DrawHUD()
