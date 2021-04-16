-- VCI MidiMetry Sample1 CC0 License by aisot
-- Version 2021.04.16
--　これはsample1用のスクリプトです

local TaskMetry = require 'task-metry'
local MidiMetry = require 'midi-metry'
local GakkiMetry = require 'gakki-metry'
local PrefData = require 'perf_data_offset248'

local Task = TaskMetry:new()
updateAll = function() Task:Execute() end

local Kenban = GakkiMetry.Gakki:new("kenban", 88, 21)
Kenban:SetOnNoteRotation(2.5, Vector3.left)

local VKey = GakkiMetry.Gakki:new("vkey", 37, 36)
VKey:SetTranspose(-12)
VKey:SetOnNoteRotation(2.5, Vector3.left)

local eBass = GakkiMetry.Gakki:new("ebass", 36, 39, {type = "bass"})

local Drums = GakkiMetry.Gakki:new("drumkit", 14, 36, {type = "drum",})

local Pref = MidiMetry.Performance:new(PrefData)
Pref:SetChGakki({
    ch1 = Kenban,
    ch2 = VKey,
    ch3 = eBass,
    ch10 = Drums
})

function PlayStart()
    local _play = function(item)
        local item = vci.assets.GetTransform(item)
        local audioSources = item.GetAudioSources()
        audioSources[1].Play(0.5, false)
    end
    _play("ch1")
    _play("ch2")
    _play("ch3")
    _play("ch10")
    Pref:Play(coroutine.yield)
end

onUse = function(item)
    if Pref.IsProcessing == false and Pref.IsPlay == false then
        vci.StartCoroutine(coroutine.create(PlayStart))
    else
        print("再生中の為、実行できません")
    end
end
