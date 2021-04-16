-- VCI GakkiMetry MIT License by aisot
-- Version 2021.04.2
local GakkiMetry = {}

local eBassNote2Gen = {
    4, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
}
function GetDrumKitNoteMap()
    local drumMap = {}
    local n = 0
    for i = 1, 128 do drumMap[i] = "drumkit_pad" .. (i % 6) + 1 end
    for i, v in ipairs({33, 35, 36}) do drumMap[v] = "drumkit_kick" end
    for i, v in ipairs({27, 29, 31, 34, 38, 40}) do
        drumMap[v] = "drumkit_snare"
    end
    for i, v in ipairs({52, 53, 54, 55, 57, 59}) do
        drumMap[v] = "drumkit_cymbal1"
    end
    drumMap[41] = "drumkit_tom3"
    drumMap[43] = "drumkit_tom2"
    drumMap[45] = "drumkit_tom1"
    drumMap[47] = "drumkit_tom3"
    drumMap[48] = "drumkit_tom2"
    drumMap[50] = "drumkit_tom1"

    drumMap[42] = "drumkit_hihat_close"
    drumMap[46] = "drumkit_hihat_open"
    drumMap[44] = "drumkit_hihat_close"
    drumMap[51] = "drumkit_cymbal2"
    drumMap[49] = "drumkit_cymbal2"
    return drumMap
end

local DrumKitMaterials = {
    "drumkit_kick", "drumkit_snare", "drumkit_tom1", "drumkit_tom2",
    "drumkit_tom3", "drumkit_hihat_open", "drumkit_hihat_close",
    "drumkit_cymbal1", "drumkit_cymbal2", "drumkit_pad1", "drumkit_pad2",
    "drumkit_pad3", "drumkit_pad4", "drumkit_pad5", "drumkit_pad6"
}

local Gakki = {}
function Gakki:new(name, max, start_key, ...)
    local option, params = ...
    local Class = {
        event = nil,
        DrumKitMaterials = option and option['drumkit_materials'] or
            DrumKitMaterials,
        drumkit_note_map = option and option['drumkit_note_map'] or
            GetDrumKitNoteMap(),
        type = option and option['type'] or 'piano',
        not_active = option and option['not_active'] or false,
        on_note_color = option and option['on_note_color'] or
            Color.__new(1.5, 0.01, 0.01),
        on_position_color = option and option['on_position_color'] or
            Color.__new(1.5, 1.5, 1.5),
        on_gen_color = option and option['gen_color'] or
            Color.__new(1.5, 0.01, 0.01),
        key_material_name = option and option['material_name_format'] or name ..
            "_%d",
        key_transform_name = option and option['transform_name_format'] or name ..
            "_%d",
        gen_material_name = option and option['material_name_format'] or name ..
            "_gen_%d",
        KeyItems = {},
        KeyItemsRot = {},
        transpose = 0,
        onNoteEventTaskTbl = {},
        SetOnNoteEventTask = function(self, func)
            table.insert(self.onNoteEventTaskTbl, func)
        end,
        GetKeyMaterialName = function(self, askey)
            return string.format(self.key_material_name, askey)
        end,
        GetGenMaterialName = function(self, askey)
            return string.format(self.gen_material_name, askey)
        end,
        GetKeyTransformName = function(self, askey)
            return string.format(self.key_transform_name, askey)
        end,
        assign_key_number = function(self, event)
            local askey = event.note + self.transpose - start_key
            return askey >= max and max or askey <= 0 and 1 or askey
        end,
        SetTranspose = function(self, trans) self.transpose = trans end,
        onNoteEventExecute = function(self, event, midi_metry)
            self.event = event
            local askey = self:assign_key_number(event)
            local item = self.KeyItems[askey]
            local itemRot = self.KeyItemsRot[askey]
            if type(self.onNoteTransform) == 'function' then
                self:onNoteTransform(item, itemRot, event)
            end
            if type(self.onNote) == 'function' then
                self:onNote(event)
            end
            for i, func in ipairs(self.onNoteEventTaskTbl) do
                func(self, event, item, itemRot, event)
            end
            if type(self.onNoteColorChange) == 'function' then
                self:onNoteColorChange(event)
            end
        end,
        SetOnNoteRotation = function(self, on_note_angle, on_note_rot_vecter)
            self['on_note_angle'] = on_note_angle
            self['on_note_rot_vecter'] = on_note_rot_vecter
            self:SetOnNoteEventTask(function(self, event, item, item_rot)
                local rot_val = self.on_note_angle
                local rot_vecter = self.on_note_rot_vecter
                if event.IsNoteOn then
                    local rot = Quaternion.AngleAxis(rot_val, Vector3.left);
                    item.SetLocalRotation(item_rot * rot)
                else
                    item.SetLocalRotation(item_rot)
                end
            end)
        end,
        SetOnNoteActive = function(self, active)
            self['on_note_active'] = active
            self['off_note_active'] = not active
            self:SetOnNoteEventTask(function(self, event, item, item_rot)
                item.SetActive(event.IsNoteOn and self.on_note_active or
                                   self.off_note_active)
            end)
        end,
        Init = function(self)
            local onNoteColorChange = function(self, event)
                local askey = self:assign_key_number(event)
                local mat_name = self:GetKeyMaterialName(askey)
                if event.IsNoteOn then
                    local color = self.on_note_color
                    vci.assets.material.SetColor(mat_name, color)
                else
                    vci.assets.material.Reset(mat_name)
                end
            end
            if self.type == 'bass' then
                self.not_active = true
                self:SetOnNoteActive(true)
                self.on_note_color = self.on_position_color

                self:SetOnNoteEventTask(function(self, event, item, item_rot)
                    local askey = self:assign_key_number(event)
                    local mat_name = self:GetGenMaterialName(
                                         eBassNote2Gen[askey])
                    if event.IsNoteOn then
                        vci.assets.material
                            .SetColor(mat_name, self.on_gen_color)
                    else
                        vci.assets.material.Reset(mat_name)
                    end
                end)
            end
            if self.type == "piano" or self.type == "bass" then
                for i = 1, max do
                    local item_name = self:GetKeyTransformName(i)
                    local item = vci.assets.GetTransform(item_name)
                    if item == nil then
                        error("GetTransformに失敗しました=" .. item_name)
                    end
                    self.KeyItems[i] = item
                    self.KeyItemsRot[i] = item.GetLocalRotation()
                    if self.not_active then
                        item.SetActive(false)
                    end
                end
                self.onNoteColorChange = onNoteColorChange
            end
            if self.type == "drum" then
                self.onNoteColorChange =
                    function(self, event)
                        local mat_name = self.drumkit_note_map[event.note]
                        if event.IsNoteOn then
                            vci.assets.material.SetColor(mat_name,
                                                         self.on_note_color)
                        else
                            vci.assets.material.Reset(mat_name)
                        end
                    end
            end
        end,
        Reset = function(self)

            if self.type == "piano" or self.type == "bass" then
                for i = 1, max do
                    local item = self.KeyItems[i]
                    item.SetLocalRotation(self.KeyItemsRot[i])
                    if self.not_active then
                        item.SetActive(false)
                    end
                    local mat_name = self:GetKeyMaterialName(i)
                    vci.assets.material.Reset(mat_name)
                end
                if self.type == "bass" then
                    for i = 1, 4 do
                        local mat_name = self:GetGenMaterialName(i)
                        vci.assets.material.Reset(mat_name)
                    end
                end
            elseif self.type == "drums" then
                for i, mat_name in ipairs(self.DrumKitMaterials) do
                    vci.assets.material.Reset(mat_name)
                end
            end
        end
    }
    Class:Init()
    Class:Reset()
    return Class
end
return {Gakki = Gakki}
