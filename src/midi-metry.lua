 -- VCI MidiMetry MIT License by aisot
-- Version 2021.03.28
local Performance = {}
function Performance:new(PrefData)
    local Class = {
        data = PrefData['data'],
        duration = PrefData['duration'],
        length = #PrefData['data'] / 5,
        IsPlay = false,
        startTime = 0,
        chGakkiTbl = {},
        Get = function(self, n)
            local b = {}
            local s = (n - 1) * 5 + 1
            for i, v in pairs({string.unicode(self.data, s, s + 5)}) do
                b[i] = v - 248
            end
            local time = bit32.bor(b[1], bit32.lshift(b[2], 8),
                                   bit32.lshift(b[3], 16))
            local tbl = {time = time, event = b[4], note = b[5]}
            if tbl.event >= 0x80 and tbl.event <= 0x8F then
                tbl["ch"] = tbl.event - 0x80 + 1
                tbl["IsNoteOn"] = false
            elseif tbl.event >= 0x90 and tbl.event <= 0x9F then
                tbl["ch"] = tbl.event - 0x90 + 1
                tbl["IsNoteOn"] = true
            end
            return tbl
        end,
        clock = function() return os.time() * 1000 end,
        Play = function(self, callback)
            for ch, Gakki in pairs(self.chGakkiTbl) do
                callback()
                Gakki:Reset()
            end
            self.startTime = self:clock()
            self.IsPlay = true
            for count = 1, self.length do
                local event = self:Get(count)
                while (event.time > self:clock() - self.startTime) do
                    if type(callback) == 'function' then
                        callback()
                    end
                    if self.IsPlay == false then
                        goto play_stop
                    end
                end
                self:onEvent(event)
            end
            while (self.duration > self:clock() - self.startTime and self.IsPlay) do
                callback()
            end
            self.IsPlay = false
            ::play_stop::
            if type(self.onPlayEnd) == 'function' then
                self:onPlayEnd()
            end
        end,
        Stop = function(self) self.IsPlay = false end,
        SetChGakki = function(self, tbl) self.chGakkiTbl = tbl end,
        onEvent = function(self, event)
            if self.chGakkiTbl["ch" .. event.ch] ~= nil then
                local Gakki = self.chGakkiTbl["ch" .. event.ch]
                Gakki:onNoteEventExecute(event, self)
            end
        end,
        GetElapsedTime = function(self)
            return self:clock() - self.startTime
        end,
        -- データが多い場合、callbackにcoroutine.yieldを入れて非同期で使わないとエラーになります
        IsProcessing = false,
        GetAll = function(self, callback)
            local perf_data = {}
            local len = #self.data / 5
            self.IsProcessing = true
            for i = 1, len do
                if type(callback) == 'function' then callback(i) end
                local tbl = self:Get(i)
                table.insert(perf_data, tbl)
            end
            self.IsProcessing = false
            return perf_data
        end
    }
    return Class
end
return {Performance = Performance}
