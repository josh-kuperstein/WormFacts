-- Worm Facts :: core
-- Auto-replies to unsolicited summon requests with a complimentary worm fact.
--
--   /wf                    status
--   /wf config             open the options panel
--   /wf on | off           open or pause subscriptions
--   /wf test               print a fact to your own chat frame
--   /wf match <text>       check whether some text would trigger a reply
--   /wf cd <seconds>       per-person cooldown
--   /wf add <word>         add an exact-word trigger
--   /wf prefix <word>      add a starts-with trigger
--   /wf remove <word>      drop a trigger
--   /wf exclude <word>     never trigger on this word
--   /wf list               print the current trigger and exclusion lists
--   /wf stats | lint | reset | defaults

local ADDON_NAME = ...

WormFacts = WormFacts or {}
local WF = WormFacts

---------------------------------------------------------------------------
-- Tunables
---------------------------------------------------------------------------

WF.THANKS     = "Thank you for subscribing to Worm Facts!"
WF.MAX_LEN    = 255   -- SendChatMessage truncates past this
local GAP        = 0.8   -- seconds between the thanks line and the fact
local QUEUE_TICK = 1.2   -- seconds between outgoing whispers, globally
local DEFAULT_CD = 300

-- Shipped defaults. Everything here is editable in game; these are only
-- used on a fresh install and by "/wf defaults".
WF.DEFAULT_KEYWORDS = {
    { text = "summ",  mode = "prefix" },  -- summ, summon, summons, summoning, summy
    { text = "sumon", mode = "prefix" },  -- common typo
    { text = "sum",   mode = "word"   },
    { text = "sumn",  mode = "word"   },
    { text = "smn",   mode = "word"   },
}

-- Words that start with a trigger but obviously aren't a request.
WF.DEFAULT_EXCLUDES = {
    "summer", "summers", "summertime", "summery",
    "summit", "summits",
    "summary", "summaries", "summarize", "summarise",
    "summarized", "summarised", "summarizing", "summarising",
    "summed", "summing", "summa",
}

-- Not editable: stops the addon answering its own reply or another
-- auto-responder and starting a whisper loop.
local LOOP_GUARDS = { "worm fact", "subscribing to worm" }

---------------------------------------------------------------------------
-- Corpus
---------------------------------------------------------------------------

local facts = {}

local function Hash(s)
    local h = 5381
    for i = 1, #s do h = (h * 33 + s:byte(i)) % 4294967296 end
    return h
end

function WF.BuildCorpus()
    wipe(facts)
    local corpus = WormFacts_Corpus
    if type(corpus) ~= "table" then return end
    for cat, list in pairs(corpus) do
        for _, text in ipairs(list) do
            facts[#facts + 1] = { text = text, cat = cat, key = Hash(text) }
        end
    end
    table.sort(facts, function(a, b) return a.key < b.key end)
end

function WF.GetFacts() return facts end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

local SendChat = (C_ChatInfo and C_ChatInfo.SendChatMessage) or SendChatMessage

function WF.Print(msg)
    print("|cffc77b4aWorm Facts|r: " .. msg)
end
local Print = WF.Print

local function IsSecret(v)
    -- Midnight-era clients hand addons unreadable values during locked-down
    -- content. Touching one throws, so check before looking at it.
    return issecretvalue ~= nil and issecretvalue(v)
end

-- /wf debug traces every incoming whisper through each decision point, so
-- "it didn't fire" becomes a log line naming the reason instead of a guess.
local function Debug(fmt, ...)
    if WormFactsDB and WormFactsDB.debug then
        print("|cff8888ffWF|r " .. string.format(fmt, ...))
    end
end

---------------------------------------------------------------------------
-- Matching. Driven entirely by the saved lists, so the options panel and
-- the slash commands are editing the same thing the matcher reads.
---------------------------------------------------------------------------

local excludeSet = {}

function WF.RebuildExcludes()
    wipe(excludeSet)
    for _, word in ipairs(WormFactsDB.excludes) do
        excludeSet[word:lower()] = true
    end
end

-- Returns true plus the keyword that matched, or false.
function WF.IsSummonRequest(msg)
    if not msg or msg == "" then return false end
    local lower = msg:lower()

    for _, guard in ipairs(LOOP_GUARDS) do
        if lower:find(guard, 1, true) then return false end
    end

    local keywords = WormFactsDB.keywords

    -- Substring rules run against the whole message.
    for _, kw in ipairs(keywords) do
        if kw.mode == "anywhere" and lower:find(kw.text, 1, true) then
            return true, kw
        end
    end

    -- Word and prefix rules run per word, and respect the exclusion list.
    for word in lower:gmatch("[%a']+") do
        if not excludeSet[word] then
            for _, kw in ipairs(keywords) do
                if kw.mode == "word" then
                    if word == kw.text then return true, kw end
                elseif kw.mode == "prefix" then
                    if word:sub(1, #kw.text) == kw.text then return true, kw end
                end
            end
        end
    end

    return false
end

---------------------------------------------------------------------------
-- List editing, shared by the panel and the slash commands
---------------------------------------------------------------------------

function WF.AddKeyword(text, mode)
    text = (text or ""):lower():gsub("%s", "")
    if text == "" then return false, "empty" end
    for _, kw in ipairs(WormFactsDB.keywords) do
        if kw.text == text then kw.mode = mode or kw.mode; return true, "updated" end
    end
    table.insert(WormFactsDB.keywords, { text = text, mode = mode or "word" })
    return true, "added"
end

function WF.RemoveKeyword(text)
    text = (text or ""):lower()
    for i, kw in ipairs(WormFactsDB.keywords) do
        if kw.text == text then table.remove(WormFactsDB.keywords, i); return true end
    end
    return false
end

function WF.AddExclude(word)
    word = (word or ""):lower():gsub("%s", "")
    if word == "" then return false end
    for _, w in ipairs(WormFactsDB.excludes) do
        if w == word then return false end
    end
    table.insert(WormFactsDB.excludes, word)
    WF.RebuildExcludes()
    return true
end

function WF.RemoveExclude(word)
    word = (word or ""):lower()
    for i, w in ipairs(WormFactsDB.excludes) do
        if w == word then
            table.remove(WormFactsDB.excludes, i)
            WF.RebuildExcludes()
            return true
        end
    end
    return false
end

function WF.RestoreDefaults()
    wipe(WormFactsDB.keywords)
    for _, kw in ipairs(WF.DEFAULT_KEYWORDS) do
        table.insert(WormFactsDB.keywords, { text = kw.text, mode = kw.mode })
    end
    wipe(WormFactsDB.excludes)
    for _, w in ipairs(WF.DEFAULT_EXCLUDES) do
        table.insert(WormFactsDB.excludes, w)
    end
    WF.RebuildExcludes()
end

---------------------------------------------------------------------------
-- Fact selection: a shuffle bag, so nobody sees a repeat until the whole
-- corpus has been through. Persisted, so it survives a logout too.
---------------------------------------------------------------------------

function WF.PickFact()
    if #facts == 0 then return nil end
    local db = WormFactsDB

    local pool = {}
    for _, f in ipairs(facts) do
        if not db.served[f.key] and #f.text <= WF.MAX_LEN then
            pool[#pool + 1] = f
        end
    end

    if #pool == 0 then
        wipe(db.served)
        for _, f in ipairs(facts) do
            if #f.text <= WF.MAX_LEN then pool[#pool + 1] = f end
        end
        if #pool == 0 then return nil end
    end

    local pick = pool[math.random(#pool)]
    db.served[pick.key] = true
    return pick
end

---------------------------------------------------------------------------
-- Outgoing queue. Whispers go out one at a time on a timer so a wave of
-- beggars can't get you throttled or squelched by the server's spam filter.
---------------------------------------------------------------------------

local queue, draining = {}, false

local function Drain()
    local item = table.remove(queue, 1)
    if not item then draining = false; return end

    local ok, err = pcall(SendChat, item.text, "WHISPER", nil, item.target)
    if not ok then
        Print("couldn't whisper " .. tostring(item.target) .. " (" .. tostring(err) .. ")")
    end

    C_Timer.After(item.gap or QUEUE_TICK, Drain)
end

local function Enqueue(target, text, gap)
    queue[#queue + 1] = { target = target, text = text, gap = gap }
    if not draining then
        draining = true
        C_Timer.After(0, Drain)
    end
end

local function ServeFact(target)
    local fact = WF.PickFact()
    if not fact then
        Print("no usable facts in the corpus. Check Data/Facts.lua.")
        return
    end

    Enqueue(target, WF.THANKS, GAP)   -- thanks first, on its own
    Enqueue(target, fact.text)        -- then the fact, one whisper

    local db = WormFactsDB
    db.stats.served = db.stats.served + 1
    db.stats.byCat[fact.cat] = (db.stats.byCat[fact.cat] or 0) + 1
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------

local function OnWhisper(msg, sender)
    local db = WormFactsDB
    if not db then return end

    if IsSecret(msg) or IsSecret(sender) then
        Debug("whisper arrived but the client marked it secret (locked-down content). Skipped.")
        return
    end

    Debug("whisper from %s: %q", tostring(sender), tostring(msg))

    if not db.enabled then
        Debug("  -> ignored: addon is paused (/wf on)")
        return
    end
    if not msg or not sender or sender == "" then
        Debug("  -> ignored: empty message or sender")
        return
    end

    local hit, kw = WF.IsSummonRequest(msg)
    if not hit then
        Debug("  -> ignored: no trigger matched")
        return
    end
    Debug("  -> matched \"%s\" (%s)", kw.text, kw.mode)

    local now = GetTime()
    local last = db.lastReply[sender]
    if last and (now - last) < db.cooldown then
        Debug("  -> suppressed: %s is on cooldown for another %ds",
              tostring(sender), math.ceil(db.cooldown - (now - last)))
        return
    end

    db.lastReply[sender] = now
    db.stats.requests = db.stats.requests + 1
    Debug("  -> sending")
    ServeFact(sender)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("CHAT_MSG_WHISPER")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if ... ~= ADDON_NAME then return end

        WormFactsDB = WormFactsDB or {}
        local db = WormFactsDB
        if db.enabled == nil then db.enabled = true end
        db.cooldown = tonumber(db.cooldown) or DEFAULT_CD
        db.served   = db.served or {}
        db.stats    = db.stats or {}
        db.stats.served   = db.stats.served or 0
        db.stats.requests = db.stats.requests or 0
        db.stats.byCat    = db.stats.byCat or {}

        -- Seed the editable lists on first run (or after a wipe).
        if type(db.keywords) ~= "table" or #db.keywords == 0
        or type(db.excludes) ~= "table" then
            db.keywords = db.keywords or {}
            db.excludes = db.excludes or {}
            WF.RestoreDefaults()
        end
        WF.RebuildExcludes()

        -- Not persisted: a session-length cooldown is plenty, and this keeps
        -- the saved variables file from growing a row per beggar forever.
        db.lastReply = {}

        WF.BuildCorpus()
        if WF.BuildOptionsPanel then WF.BuildOptionsPanel() end
        f:UnregisterEvent("ADDON_LOADED")

    elseif event == "CHAT_MSG_WHISPER" then
        local msg, sender = ...
        OnWhisper(msg, sender)
    end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

SLASH_WORMFACTS1 = "/wormfacts"
SLASH_WORMFACTS2 = "/wf"

SlashCmdList.WORMFACTS = function(input)
    local db = WormFactsDB
    local cmd, arg = (input or ""):match("^(%S*)%s*(.-)%s*$")
    cmd = (cmd or ""):lower()

    if cmd == "config" or cmd == "options" then
        if WF.OpenOptions then WF.OpenOptions()
        else Print("options panel unavailable.") end

    elseif cmd == "on" then
        db.enabled = true
        Print("subscriptions are |cff40ff40OPEN|r.")

    elseif cmd == "off" then
        db.enabled = false
        Print("subscriptions |cffff4040paused|r.")

    elseif cmd == "cd" and tonumber(arg) then
        db.cooldown = math.max(0, tonumber(arg))
        Print(("per-person cooldown set to %ds."):format(db.cooldown))

    elseif cmd == "test" then
        local fact = WF.PickFact()
        if fact then
            Print(WF.THANKS)
            Print(("[%s] %s"):format(fact.cat, fact.text))
        else
            Print("no usable facts found.")
        end

    elseif cmd == "debug" then
        db.debug = not db.debug
        Print(db.debug and "debug tracing |cff40ff40ON|r. Every incoming whisper will be logged with the reason it did or didn't get a fact."
                        or "debug tracing off.")

    elseif cmd == "match" and arg ~= "" then
        local hit, kw = WF.IsSummonRequest(arg)
        if hit then
            Print(("|cff40ff40MATCH|r via \"%s\" (%s) -- this would get a fact."):format(kw.text, kw.mode))
        else
            Print("|cffff4040no match|r -- this would be ignored.")
        end

    elseif cmd == "add" and arg ~= "" then
        local ok, how = WF.AddKeyword(arg, "word")
        Print(ok and ("%s exact-word trigger \"%s\"."):format(how, arg:lower())
                 or "couldn't add that.")

    elseif cmd == "prefix" and arg ~= "" then
        local ok, how = WF.AddKeyword(arg, "prefix")
        Print(ok and ("%s starts-with trigger \"%s\"."):format(how, arg:lower())
                 or "couldn't add that.")

    elseif cmd == "remove" and arg ~= "" then
        Print(WF.RemoveKeyword(arg) and ("removed trigger \"%s\"."):format(arg:lower())
                                     or ("no trigger called \"%s\"."):format(arg:lower()))

    elseif cmd == "exclude" and arg ~= "" then
        Print(WF.AddExclude(arg) and ("will never trigger on \"%s\"."):format(arg:lower())
                                  or "already excluded (or empty).")

    elseif cmd == "list" then
        Print("triggers:")
        for _, kw in ipairs(db.keywords) do
            print(("   %-10s %s"):format(kw.text, kw.mode))
        end
        Print("exclusions: " .. table.concat(db.excludes, ", "))

    elseif cmd == "defaults" then
        WF.RestoreDefaults()
        if WF.RefreshOptions then WF.RefreshOptions() end
        Print("trigger and exclusion lists restored to defaults.")

    elseif cmd == "stats" then
        Print(("%d requests deflected, %d facts served, %d facts loaded.")
            :format(db.stats.requests, db.stats.served, #facts))
        local seen = 0
        for _ in pairs(db.served) do seen = seen + 1 end
        Print(("%d of %d facts used this cycle."):format(seen, #facts))

    elseif cmd == "lint" then
        local over, longest = 0, 0
        for _, fact in ipairs(facts) do
            longest = math.max(longest, #fact.text)
            if #fact.text > WF.MAX_LEN then
                over = over + 1
                Print(("|cffff4040%d chars|r [%s] %s..."):format(#fact.text, fact.cat, fact.text:sub(1, 60)))
            end
        end
        Print(("%d facts, longest %d chars, %d over the %d limit.")
            :format(#facts, longest, over, WF.MAX_LEN))

    elseif cmd == "reset" then
        wipe(db.served)
        db.stats.served, db.stats.requests, db.stats.byCat = 0, 0, {}
        Print("seen-facts pool and stats cleared.")

    else
        local meta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
        local ver = meta and meta("WormFacts", "Version") or "?"
        Print(("|cffffff78v%s|r | %s | cooldown %ds | %d facts | %d triggers")
            :format(ver,
                    db.enabled and "|cff40ff40enabled|r" or "|cffff4040paused|r",
                    db.cooldown, #facts, #db.keywords))
        Print("|cffffff78/wf config|r for the options panel, or: on, off, test, match <text>,")
        Print("   add/prefix/remove <word>, exclude <word>, list, cd <sec>, stats, lint, reset, defaults, debug")
        if db.debug then Print("|cff8888ffdebug tracing is ON|r") end
    end
end
