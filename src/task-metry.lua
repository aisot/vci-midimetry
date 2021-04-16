-- VCI TaskMetory MIT License by aisot
-- Version 2021.03.30
local Task = {}
local _id = 0
function clock() return os.clock() * 1000 end
function newid()
    _id = _id + 1;
    return _id
end

function Task:new(keyNum)
    local Class = {
        queue = {},
        timer_tbl = {},
        Set = function(self, func) table.insert(self.queue, func) end,
        QueueExecute = function(self)
            if #self.queue > 0 then table.remove(self.queue)() end
        end,
        TimerExecute = function(self)
            if (self.timer_tbl[1] and (self.timer_tbl[1][2] <= clock())) then
                local func, t, argv, id =
                    table.unpack(table.remove(self.timer_tbl, 1))
                func(argv)
            end
        end,
        insert = function(self, func, t, argv, Id)
            table.insert(self.timer_tbl, {func, clock() + t, argv, Id})
            table.sort(self.timer_tbl, function(a, b)
                return a[2] < b[2]
            end)
            return Id
        end,
        clearInterval = function(self, clearId)
            for i, v in ipairs(self.timer_tbl) do
                if (v[4] == clearId) then
                    return table.remove(self.timer_tbl, i)
                end
            end
        end,
        timerCancel = function(self, ...) return self:clearInterval(...) end,
        timerAllClear = function(self) self.timer_tbl = {} end,
        setTimeout = function(self, func, t, argv)
            return self:insert(func, t, argv, newid())
        end,
        setInterval = function(self, func, t, argv, Id)
            Id = Id or newid()
            return self:insert(function()
                func(table.unpack(argv or {}))
                self:setInterval(func, t, argv, Id)
            end, t, argv or {}, Id)
        end,
        Execute = function(self)
            self:QueueExecute()
            self:TimerExecute()
        end
    }
    return Class
end

return Task
