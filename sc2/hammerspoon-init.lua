-- ==============================================================================
-- CONFIGURATION
-- ==============================================================================
local INITIAL_DELAY_SEC   = 0.120   -- 120ms before standard rapid fire starts
local RAPID_FIRE_SEC      = 0.005   -- 5ms repeat interval
local MACRO_LOOP_SEC      = 0.015   -- Loop interval per base iteration (Zerg Inject)
local SPACE_TAP_HOLD_SEC  = 0.001   -- Hold duration for single Space tap (bump to 0.008-0.015 if SC2 drops taps)

local CHRONO_KEY          = "w"     -- In-game hotkey bound to "Chrono Boost" on Nexus
local PROTOSS_CHRONO_CAMS = {"q", "w", "e"} -- Camera locations cycled for Protoss Chrono Boost
local CAMERA_MOD          = "cmd"   -- Use "cmd" (Command) or "alt" (Option) to match your SC2 camera bindings
local race                = "Z"     -- Default race on startup: "Z", "P", or "T"

local spaceDown = false
local spaceUsedWithCombo = false

-- ==============================================================================
-- HELPER: CHECK IF STARCRAFT II IS FRONTMOST
-- ==============================================================================
local function isSC2Active()
    local app = hs.application.frontmostApplication()
    if not app then return false end
    local name = (app:name() or ""):lower()
    local bundle = (app:bundleID() or ""):lower()
    return name:find("sc2") ~= nil
        or name:find("starcraft") ~= nil
        or bundle:find("starcraft2") ~= nil
end

-- ==============================================================================
-- HELPER: ICONIC RACE AUDIO CUES
-- ==============================================================================
local function playRaceSound(selectedRace)
    if selectedRace == "Z" then
        -- Zerg: Low, organic double-pulse
        local s1 = hs.sound.getByName("Frog")
        if s1 then s1:play() end
        hs.timer.doAfter(0.12, function()
            local s2 = hs.sound.getByName("Bottle")
            if s2 then s2:play() end
        end)
    elseif selectedRace == "P" then
        -- Protoss: Crisp, crystalline Probe-selection double chirp
        local s1 = hs.sound.getByName("Glass")
        if s1 then s1:play() end
        hs.timer.doAfter(0.09, function()
            local s2 = hs.sound.getByName("Ping")
            if s2 then s2:play() end
        end)
    elseif selectedRace == "T" then
        -- Terran: Sharp military comm-link triple pip
        local s1 = hs.sound.getByName("Tink")
        if s1 then s1:play() end
        hs.timer.doAfter(0.07, function()
            local s2 = hs.sound.getByName("Tink")
            if s2 then s2:play() end
            hs.timer.doAfter(0.07, function()
                local s3 = hs.sound.getByName("Pop")
                if s3 then s3:play() end
            end)
        end)
    end
end

-- ==============================================================================
-- HELPER: ALL-CHAT MACROS
-- ==============================================================================
local function sendAllChat(text)
    hs.timer.doAfter(0.06, function()
        hs.eventtap.keyStroke({"shift"}, "return", 0)
        hs.timer.doAfter(0.03, function()
            hs.eventtap.keyStrokes(text)
            hs.timer.doAfter(0.02, function()
                hs.eventtap.keyStroke({}, "return", 0)
            end)
        end)
    end)
end

-- ==============================================================================
-- HELPER: SYNTHETIC KEY EMISSION
-- ==============================================================================
local function postSyntheticKey(mods, key, isDown)
    local ev = hs.eventtap.event.newKeyEvent(mods, key, isDown)
    if mods and #mods > 0 then
        local flagTable = {}
        for _, m in ipairs(mods) do flagTable[m] = true end
        ev:setFlags(flagTable)
    end
    ev:setProperty(hs.eventtap.event.properties.eventSourceUserData, 9999)
    ev:post()
end

-- ==============================================================================
-- RACE MACROS FOR SPACE + 4 (Zerg Queen Inject / Protoss Q/W/E Camera Chrono)
-- ==============================================================================
local macroTimer = nil
local fourHeld = false
local chronoLockedUntilRelease = false
local chronoCamIndex = 1

local function stopSpace4Macro()
    if macroTimer then
        macroTimer:stop()
        macroTimer = nil
    end
end

local function runZergInjectCycle()
    local win = hs.window.focusedWindow()
    if not win then return end
    local f = win:frame()

    local baseX = f.x + (f.w / 2)
    local baseY = f.y + (f.h / 2) - (0.04 * f.h)

    -- 20% screen-height selection box radius (matching AHK 0.2)
    local boxHalf = f.h * 0.2
    local x1, y1 = baseX - boxHalf, baseY - boxHalf
    local x2, y2 = baseX + boxHalf, baseY + boxHalf

    -- 1. Jump to next base camera (Tab)
    hs.eventtap.keyStroke({}, "tab", 0)

    -- 2. Drag selection box around Hatchery
    hs.mouse.absolutePosition({x = x1, y = y1})
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, {x = x1, y = y1}):post()
    hs.mouse.absolutePosition({x = x2, y = y2})
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, {x = x2, y = y2}):post()

    -- 3. Cast Spawn Larva (Q) and click center of Hatchery
    hs.eventtap.keyStroke({}, "q", 0)
    hs.mouse.absolutePosition({x = baseX, y = baseY})
    hs.eventtap.leftClick({x = baseX, y = baseY}, 0)
end

local function runProtossChronoStep()
    if not (fourHeld and spaceDown) or chronoLockedUntilRelease then
        stopSpace4Macro()
        return
    end

    local camKey = PROTOSS_CHRONO_CAMS[chronoCamIndex]
    if not camKey then
        chronoLockedUntilRelease = true
        stopSpace4Macro()
        return
    end

    local win = hs.window.focusedWindow()
    if not win then return end
    local f = win:frame()

    local baseX = f.x + (f.w / 2)
    local baseY = f.y + (f.h / 2) - (0.04 * f.h)

    -- 1. Jump to Camera Location (CAMERA_MOD + q/w/e)
    postSyntheticKey({CAMERA_MOD}, camKey, true)
    postSyntheticKey({CAMERA_MOD}, camKey, false)

    -- 2. Brief 10ms buffer for camera snap before clicking Nexus
    hs.timer.usleep(10000)

    -- 3. Select centered Nexus, press Chrono Boost ('w'), and click Nexus
    hs.mouse.absolutePosition({x = baseX, y = baseY})
    hs.eventtap.leftClick({x = baseX, y = baseY}, 0)
    hs.eventtap.keyStroke({}, CHRONO_KEY, 0)
    hs.eventtap.leftClick({x = baseX, y = baseY}, 0)

    chronoCamIndex = chronoCamIndex + 1
    if chronoCamIndex > #PROTOSS_CHRONO_CAMS then
        chronoLockedUntilRelease = true
        stopSpace4Macro()
    end
end

-- ==============================================================================
-- UNIFIED EVENT TAP (Race Switch, Chat, Space Cameras, Space+4, Rapid Fire)
-- ==============================================================================
local rapidKeys = { q=true, w=true, e=true, r=true, a=true, s=true, d=true, f=true, z=true, x=true, c=true }
local spaceComboKeys = { q=true, w=true, e=true, r=true, a=true, s=true, d=true }
local activeTimers = {}

local function stopRapidKey(key)
    if activeTimers[key] then
        activeTimers[key]:stop()
        activeTimers[key] = nil
    end
end

sc2EventTap = hs.eventtap.new({
    hs.eventtap.event.types.keyDown,
    hs.eventtap.event.types.keyUp
}, function(event)
    if not isSC2Active() then return false end

    -- Ignore synthetic events generated by Hammerspoon itself
    if event:getProperty(hs.eventtap.event.properties.eventSourceUserData) == 9999 then
        return false
    end

    local keyCode = event:getKeyCode()
    local char = hs.keycodes.map[keyCode]
    local isDown = (event:getType() == hs.eventtap.event.types.keyDown)
    local isRepeat = (event:getProperty(hs.eventtap.event.properties.keyboardEventAutorepeat) == 1)
    local flags = event:getFlags()

    -- 0. CTRL + Z / P / T (RACE SWITCH) & CTRL + H / G (ALL CHAT)
    if flags.ctrl and not (flags.alt or flags.cmd or flags.shift) then
        if char == "z" or char == "p" or char == "t" then
            if isDown and not isRepeat then
                race = char:upper()
                playRaceSound(race)
            end
            return true
        elseif char == "h" then
            if isDown and not isRepeat then sendAllChat("(glhf)") end
            return true
        elseif char == "g" then
            if isDown and not isRepeat then sendAllChat("(gg)") end
            return true
        end
    end

    -- 1. SPACEBAR INTERCEPTOR (keyCode 49 = Space)
    if char == "space" or keyCode == 49 then
        if isDown then
            if not spaceDown then
                spaceDown = true
                spaceUsedWithCombo = false
            end
            return true
        else
            local wasCombo = spaceUsedWithCombo
            spaceDown = false
            spaceUsedWithCombo = false
            fourHeld = false
            stopSpace4Macro()
            if not wasCombo then
                postSyntheticKey({}, "space", true)
                hs.timer.doAfter(SPACE_TAP_HOLD_SEC, function()
                    postSyntheticKey({}, "space", false)
                end)
            end
            return true
        end
    end

    -- 2. SPACE + QWER/ASD -> CAMERA_MOD + KEY
    if spaceDown and spaceComboKeys[char] then
        if isDown and not isRepeat then
            spaceUsedWithCombo = true
            postSyntheticKey({CAMERA_MOD}, char, true)
            postSyntheticKey({CAMERA_MOD}, char, false)
        end
        return true
    end

    -- 3. SPACE + 4 -> ZERG RAPID INJECT / PROTOSS Q,W,E CAMERA CHRONO BOOST
    if char == "4" and (spaceDown or fourHeld) then
        if isDown then
            if not fourHeld then
                fourHeld = true
                spaceUsedWithCombo = true
                if race == "Z" then
                    runZergInjectCycle()
                    macroTimer = hs.timer.doEvery(MACRO_LOOP_SEC, function()
                        if fourHeld and spaceDown then
                            runZergInjectCycle()
                        else
                            stopSpace4Macro()
                        end
                    end)
                elseif race == "P" then
                    chronoCamIndex = 1
                    chronoLockedUntilRelease = false
                    runProtossChronoStep()
                    if not chronoLockedUntilRelease then
                        macroTimer = hs.timer.doEvery(MACRO_LOOP_SEC, runProtossChronoStep)
                    end
                else
                    -- Terran: Pass through normal 4
                    postSyntheticKey({}, "4", true)
                    postSyntheticKey({}, "4", false)
                end
            end
        else
            fourHeld = false
            chronoLockedUntilRelease = false
            chronoCamIndex = 1
            stopSpace4Macro()
        end
        return true
    end

    -- 4. RAPID FIRE KEYS (When Space is not held and no modifiers are pressed)
    if rapidKeys[char] and not spaceDown and not (flags.ctrl or flags.alt or flags.cmd) then
        if isDown then
            if isRepeat then return true end
            stopRapidKey(char)
            activeTimers[char] = hs.timer.doAfter(INITIAL_DELAY_SEC, function()
                activeTimers[char] = hs.timer.doEvery(RAPID_FIRE_SEC, function()
                    postSyntheticKey({}, char, true)
                    postSyntheticKey({}, char, false)
                end)
            end)
            return false
        else
            stopRapidKey(char)
            return false
        end
    end

    return false
end)

sc2EventTap:start()