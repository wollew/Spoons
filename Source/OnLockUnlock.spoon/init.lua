local obj={}
obj.__index = obj

-- Metadata
obj.name = "OnLockUnlock"
obj.version = "0.1"
obj.author = "WMR"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"

obj.log = hs.logger.new('OnLockUnlock', 3)

obj.OnLockAppleScript  = ""
obj.OnUnlockAppleScript = ""

local function ok2str(ok)
    if ok then return "ok" else return "fail" end
end

function obj:init()
end

function obj:start()
    obj.pow:start()
    obj.log.i("started")
end

function obj:stop()
    obj.pow:stop()
    obj.log.i("stopped")
end

local function on_pow(event)
    local name = "?"
    for key,val in pairs(hs.caffeinate.watcher) do
        if event == val then name = key end
    end
    obj.log.f("caffeinate event %d => %s", event, name)
    -- if event == hs.caffeinate.watcher.screensDidWake
    -- or event == hs.caffeinate.watcher.sessionDidBecomeActive
    if event == hs.caffeinate.watcher.screensDidUnlock
    then
        obj.log.i("unlocked.")
        if string.len(obj.OnUnlockAppleScript) > 0 then
            local ok, text, desc = hs.osascript._osascript(obj.OnUnlockAppleScript, "AppleScript")
            if ok then
                obj.log.f("OnUnlockAppleScript => %s %s %s", ok2str(ok), text, desc)
            else
                obj.log.w("OnUnlockAppleScript => %s %s %s", ok2str(ok), text, desc)
            end
        end
        return
    end
    -- if event == hs.caffeinate.watcher.screensDidSleep
    -- or event == hs.caffeinate.watcher.systemWillSleep
    -- or event == hs.caffeinate.watcher.systemWillPowerOff
    -- or event == hs.caffeinate.watcher.sessionDidResignActive
    if event == hs.caffeinate.watcher.screensDidLock
    then
        obj.log.i("locked.")
        if string.len(obj.OnLockAppleScript) > 0 then
            local ok, text, desc = hs.osascript._osascript(obj.OnLockAppleScript, "AppleScript")
            if ok then
                obj.log.f("OnLockAppleScript => %s %s %s", ok2str(ok), text, desc)
            else
                obj.log.w("OnLockAppleScript => %s %s %s", ok2str(ok), text, desc)
            end
        end
        return
    end
end

obj.pow = hs.caffeinate.watcher.new(on_pow)

return obj
