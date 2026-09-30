-- Worm Facts :: options panel
--
-- Registered under Options > AddOns > Worm Facts, or /wf config.
--
-- Deliberately built from plain frames, UIPanelButtonTemplate,
-- UICheckButtonTemplate and InputBoxTemplate. No UIDropDownMenu (deprecated
-- in 11.0) and no scroll templates, since Blizzard keeps churning those.
-- Paging instead of scrolling for the same reason.
--
-- Layout is two columns. A Settings canvas panel does not scroll, so anything
-- that overflows the bottom edge is simply unreachable. The panel is much
-- wider than it is tall, so the lists go side by side and everything fits.

local WF = WormFacts

local ROWS  = 8      -- visible rows per list
local ROW_H = 22
local COL_W = 340    -- horizontal gap between the two list columns

local panel, category
local kwPage, exPage = 0, 0
local kwRows, exRows = {}, {}
local enableCB, cdBox, cdReadout, testBox, testResult, statusText

-- Quick-set buttons for the cooldown, so you don't have to do arithmetic.
local CD_PRESETS = {
    { "Off", 0 }, { "1m", 60 }, { "5m", 300 }, { "15m", 900 }, { "1h", 3600 },
}

-- On the addon table so the test harness can exercise it directly.
function WF.HumanTime(s)
    s = math.max(0, math.floor(tonumber(s) or 0))
    if s == 0 then return "no cooldown - every request gets an answer" end
    if s < 60 then return s .. (s == 1 and " second" or " seconds") end
    -- math.floor keeps these integers. Lua 5.1 would stringify 300/60 as "5",
    -- but newer Lua gives "5.0", so don't depend on the division's type.
    if s % 3600 == 0 then
        local h = math.floor(s / 3600)
        return h .. (h == 1 and " hour" or " hours")
    end
    if s % 60 == 0 then
        local m = math.floor(s / 60)
        return m .. (m == 1 and " minute" or " minutes")
    end
    return ("%dm %ds"):format(math.floor(s / 60), s % 60)
end

---------------------------------------------------------------------------
-- Small builders
---------------------------------------------------------------------------

local function Label(parent, text, size)
    local fs = parent:CreateFontString(nil, "ARTWORK",
        size == "big" and "GameFontNormalLarge" or
        size == "small" and "GameFontDisableSmall" or "GameFontNormal")
    fs:SetText(text)
    return fs
end

local function Button(parent, text, w, h, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, h or 22)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

local function Input(parent, w, onEnter)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(w, 20)
    e:SetAutoFocus(false)
    e:SetMaxLetters(32)
    e:SetScript("OnEscapePressed", e.ClearFocus)
    if onEnter then
        e:SetScript("OnEnterPressed", function(self)
            onEnter(self:GetText())
            self:ClearFocus()
        end)
    end
    return e
end

local MODE_LABEL = {
    word     = "exact word",
    prefix   = "starts with",
    anywhere = "anywhere",
}
local MODE_NEXT = { word = "prefix", prefix = "anywhere", anywhere = "word" }

local MODE_HELP = {
    word     = "Fires only when the whole word matches. \"sum\" will not match \"summary\".",
    prefix   = "Fires on any word starting with this. \"summ\" catches summon, summons, summy.",
    anywhere = "Fires anywhere in the message, even mid-word. Use sparingly -- this is the one that causes false positives.",
}

---------------------------------------------------------------------------
-- Refresh
---------------------------------------------------------------------------

local function ClampPages()
    local db = WormFactsDB
    local kwMax = math.max(0, math.ceil(#db.keywords / ROWS) - 1)
    local exMax = math.max(0, math.ceil(#db.excludes / ROWS) - 1)
    kwPage = math.min(math.max(0, kwPage), kwMax)
    exPage = math.min(math.max(0, exPage), exMax)
    return kwMax, exMax
end

function WF.RefreshOptions()
    if not panel then return end
    local db = WormFactsDB
    local kwMax, exMax = ClampPages()

    -- Never let a nil or junk value reach the box. A blank cooldown field is
    -- ambiguous in the worst possible way, so repair it rather than show it.
    local cd = tonumber(db.cooldown)
    if not cd then cd = 300; db.cooldown = cd end

    enableCB:SetChecked(db.enabled)
    if not cdBox:HasFocus() then cdBox:SetText(tostring(math.floor(cd))) end
    cdReadout:SetText("Currently: |cffffff78" .. WF.HumanTime(cd) .. "|r")

    for i, row in ipairs(kwRows) do
        local kw = db.keywords[kwPage * ROWS + i]
        if kw then
            row.text:SetText(kw.text)
            row.mode:SetText(MODE_LABEL[kw.mode] or kw.mode)
            row.kw = kw
            row:Show()
        else
            row.kw = nil
            row:Hide()
        end
    end

    for i, row in ipairs(exRows) do
        local word = db.excludes[exPage * ROWS + i]
        if word then
            row.text:SetText(word)
            row.word = word
            row:Show()
        else
            row.word = nil
            row:Hide()
        end
    end

    panel.kwPageText:SetText(("%d/%d"):format(kwPage + 1, kwMax + 1))
    panel.exPageText:SetText(("%d/%d"):format(exPage + 1, exMax + 1))

    statusText:SetText(("%d triggers, %d exclusions, %d facts loaded, %d requests deflected")
        :format(#db.keywords, #db.excludes, #WF.GetFacts(), db.stats.requests))

    -- Re-run the tester so edits show their effect immediately.
    if testBox and testBox:GetText() ~= "" then
        panel.RunTest(testBox:GetText())
    end
end

---------------------------------------------------------------------------
-- Panel
---------------------------------------------------------------------------

function WF.BuildOptionsPanel()
    if panel then return end

    panel = CreateFrame("Frame")
    panel.name = "Worm Facts"

    local title = Label(panel, "Worm Facts", "big")
    title:SetPoint("TOPLEFT", 16, -16)

    local sub = Label(panel, "Answers unsolicited summon requests with a complimentary worm fact.", "small")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

    ---------------------------------------------------------------- toggles
    enableCB = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    enableCB:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -12)
    enableCB.label = Label(enableCB, "Auto-reply to summon requests")
    enableCB.label:SetPoint("LEFT", enableCB, "RIGHT", 4, 0)
    enableCB:SetScript("OnClick", function(self)
        WormFactsDB.enabled = self:GetChecked() and true or false
    end)

    local cdLabel = Label(panel, "Per-person cooldown (seconds):")
    cdLabel:SetPoint("TOPLEFT", enableCB, "BOTTOMLEFT", 4, -12)

    -- Commit whatever is typed. Anything unparseable (including an empty
    -- box) leaves the stored value alone and gets repainted by RefreshOptions,
    -- so a blank field can never silently mean "no cooldown".
    local function CommitCooldown(text)
        local n = tonumber(text)
        if n then WormFactsDB.cooldown = math.max(0, math.floor(n)) end
        WF.RefreshOptions()
    end

    cdBox = Input(panel, 60, CommitCooldown)
    cdBox:SetPoint("LEFT", cdLabel, "RIGHT", 10, 0)
    -- Deliberately NOT SetNumeric(true): on some builds it fights with
    -- SetText and leaves the box rendering empty. Validation is done above.
    cdBox:SetScript("OnEditFocusLost", function(self)
        CommitCooldown(self:GetText())
    end)

    local prevBtn = cdBox
    for _, preset in ipairs(CD_PRESETS) do
        local label, secs = preset[1], preset[2]
        local b = Button(panel, label, 40, 20, function()
            WormFactsDB.cooldown = secs
            cdBox:ClearFocus()
            WF.RefreshOptions()
        end)
        b:SetPoint("LEFT", prevBtn, "RIGHT", 6, 0)
        prevBtn = b
    end

    cdReadout = Label(panel, "", "small")
    cdReadout:SetPoint("TOPLEFT", cdLabel, "BOTTOMLEFT", 0, -6)

    local cdHelp = Label(panel, "How long before the same player can be served another fact. Type a value in seconds or use a preset.", "small")
    cdHelp:SetPoint("TOPLEFT", cdReadout, "BOTTOMLEFT", 0, -4)

    -------------------------------------------------- left column: triggers
    local kwTitle = Label(panel, "Trigger words")
    kwTitle:SetPoint("TOPLEFT", cdHelp, "BOTTOMLEFT", -4, -18)

    local kwHelp = Label(panel, "Click a mode button to cycle exact word / starts with / anywhere.", "small")
    kwHelp:SetPoint("TOPLEFT", kwTitle, "BOTTOMLEFT", 0, -4)

    for i = 1, ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(COL_W - 20, ROW_H)
        if i == 1 then
            row:SetPoint("TOPLEFT", kwHelp, "BOTTOMLEFT", 0, -6)
        else
            row:SetPoint("TOPLEFT", kwRows[i - 1], "BOTTOMLEFT", 0, 0)
        end

        row.text = Label(row, "")
        row.text:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.text:SetWidth(100)
        row.text:SetJustifyH("LEFT")

        row.mode = Button(row, "", 104, 20, function(self)
            local kw = self:GetParent().kw
            if not kw then return end
            kw.mode = MODE_NEXT[kw.mode] or "word"
            WF.RefreshOptions()
        end)
        row.mode:SetPoint("LEFT", row, "LEFT", 112, 0)
        row.mode:SetScript("OnEnter", function(self)
            local kw = self:GetParent().kw
            if not kw then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(MODE_LABEL[kw.mode], 1, 1, 1)
            GameTooltip:AddLine(MODE_HELP[kw.mode], nil, nil, nil, true)
            GameTooltip:Show()
        end)
        row.mode:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row.del = Button(row, "Remove", 68, 20, function(self)
            local kw = self:GetParent().kw
            if kw then WF.RemoveKeyword(kw.text); WF.RefreshOptions() end
        end)
        row.del:SetPoint("LEFT", row, "LEFT", 222, 0)

        kwRows[i] = row
    end

    local kwPrev = Button(panel, "<", 22, 20, function() kwPage = kwPage - 1; WF.RefreshOptions() end)
    kwPrev:SetPoint("TOPLEFT", kwRows[ROWS], "BOTTOMLEFT", 6, -6)

    panel.kwPageText = Label(panel, "1/1", "small")
    panel.kwPageText:SetPoint("LEFT", kwPrev, "RIGHT", 5, 0)

    local kwNext = Button(panel, ">", 22, 20, function() kwPage = kwPage + 1; WF.RefreshOptions() end)
    kwNext:SetPoint("LEFT", panel.kwPageText, "RIGHT", 5, 0)

    local kwInput = Input(panel, 110)
    kwInput:SetPoint("LEFT", kwNext, "RIGHT", 14, 0)

    local kwAdd = Button(panel, "Add", 54, 20, function()
        local t = kwInput:GetText()
        if t and t ~= "" then
            WF.AddKeyword(t, "word")
            kwInput:SetText(""); kwInput:ClearFocus()
            WF.RefreshOptions()
        end
    end)
    kwAdd:SetPoint("LEFT", kwInput, "RIGHT", 8, 0)
    kwInput:SetScript("OnEnterPressed", function() kwAdd:Click() end)

    ----------------------------------------------- right column: exclusions
    local exTitle = Label(panel, "Never trigger on")
    exTitle:SetPoint("TOPLEFT", kwTitle, "TOPLEFT", COL_W, 0)

    local exHelp = Label(panel, "Words that would otherwise match. This keeps \"summer\" quiet.", "small")
    exHelp:SetPoint("TOPLEFT", exTitle, "BOTTOMLEFT", 0, -4)

    for i = 1, ROWS do
        local row = CreateFrame("Frame", nil, panel)
        row:SetSize(COL_W - 20, ROW_H)
        if i == 1 then
            row:SetPoint("TOPLEFT", exHelp, "BOTTOMLEFT", 0, -6)
        else
            row:SetPoint("TOPLEFT", exRows[i - 1], "BOTTOMLEFT", 0, 0)
        end

        row.text = Label(row, "")
        row.text:SetPoint("LEFT", row, "LEFT", 6, 0)
        row.text:SetWidth(200)
        row.text:SetJustifyH("LEFT")

        row.del = Button(row, "Remove", 68, 20, function(self)
            local word = self:GetParent().word
            if word then WF.RemoveExclude(word); WF.RefreshOptions() end
        end)
        row.del:SetPoint("LEFT", row, "LEFT", 222, 0)

        exRows[i] = row
    end

    local exPrev = Button(panel, "<", 22, 20, function() exPage = exPage - 1; WF.RefreshOptions() end)
    exPrev:SetPoint("TOPLEFT", exRows[ROWS], "BOTTOMLEFT", 6, -6)

    panel.exPageText = Label(panel, "1/1", "small")
    panel.exPageText:SetPoint("LEFT", exPrev, "RIGHT", 5, 0)

    local exNext = Button(panel, ">", 22, 20, function() exPage = exPage + 1; WF.RefreshOptions() end)
    exNext:SetPoint("LEFT", panel.exPageText, "RIGHT", 5, 0)

    local exInput = Input(panel, 110)
    exInput:SetPoint("LEFT", exNext, "RIGHT", 14, 0)

    local exAdd = Button(panel, "Add", 54, 20, function()
        local t = exInput:GetText()
        if t and t ~= "" then
            WF.AddExclude(t)
            exInput:SetText(""); exInput:ClearFocus()
            WF.RefreshOptions()
        end
    end)
    exAdd:SetPoint("LEFT", exInput, "RIGHT", 8, 0)
    exInput:SetScript("OnEnterPressed", function() exAdd:Click() end)

    --------------------------------------------------------------- tester
    local testTitle = Label(panel, "Try a whisper")
    testTitle:SetPoint("TOPLEFT", kwPrev, "BOTTOMLEFT", -6, -20)

    testBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    testBox:SetSize(300, 20)
    testBox:SetAutoFocus(false)
    testBox:SetMaxLetters(255)
    testBox:SetPoint("TOPLEFT", testTitle, "BOTTOMLEFT", 6, -8)
    testBox:SetScript("OnEscapePressed", testBox.ClearFocus)

    testResult = Label(panel, "")
    testResult:SetPoint("LEFT", testBox, "RIGHT", 12, 0)

    function panel.RunTest(text)
        if not text or text == "" then testResult:SetText(""); return end
        local hit, kw = WF.IsSummonRequest(text)
        if hit then
            testResult:SetText(("|cff40ff40replies|r  (\"%s\", %s)"):format(kw.text, MODE_LABEL[kw.mode] or kw.mode))
        else
            testResult:SetText("|cffff7f7fignored|r")
        end
    end
    testBox:SetScript("OnTextChanged", function(self) panel.RunTest(self:GetText()) end)

    local testHelp = Label(panel, "Type what someone might whisper you and see whether it would earn them a fact.", "small")
    testHelp:SetPoint("TOPLEFT", testBox, "BOTTOMLEFT", -6, -6)

    -------------------------------------------------------------- footer
    local defaults = Button(panel, "Restore default lists", 150, 22, function()
        WF.RestoreDefaults()
        kwPage, exPage = 0, 0
        WF.RefreshOptions()
        WF.Print("trigger and exclusion lists restored to defaults.")
    end)
    defaults:SetPoint("TOPLEFT", testHelp, "BOTTOMLEFT", 6, -14)

    local preview = Button(panel, "Preview a fact", 130, 22, function()
        local fact = WF.PickFact()
        if fact then
            WF.Print(WF.THANKS)
            WF.Print(("[%s] %s"):format(fact.cat, fact.text))
        end
    end)
    preview:SetPoint("LEFT", defaults, "RIGHT", 8, 0)

    statusText = Label(panel, "", "small")
    statusText:SetPoint("TOPLEFT", defaults, "BOTTOMLEFT", 0, -10)

    ------------------------------------------------------------- register
    panel:SetScript("OnShow", WF.RefreshOptions)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        category = Settings.RegisterCanvasLayoutCategory(panel, "Worm Facts")
        -- Do NOT overwrite category.ID. The Settings system assigns a numeric
        -- id there, GetID() just hands that field back, and OpenToCategory
        -- wants an int32. Setting it to a string breaks opening the panel.
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then   -- very old clients
        InterfaceOptions_AddCategory(panel)
    end

    WF.RefreshOptions()
end

function WF.OpenOptions()
    if not panel then WF.BuildOptionsPanel() end

    if Settings and Settings.OpenToCategory and category then
        local id = category.GetID and category:GetID() or category.ID
        if type(id) == "number" and pcall(Settings.OpenToCategory, id) then
            return
        end
        -- Some builds accept the category name instead. Try that before
        -- giving up, so a changed id type doesn't make the panel unreachable.
        if pcall(Settings.OpenToCategory, "Worm Facts") then
            return
        end
        WF.Print("couldn't open the panel. It's still listed under |cffffff78Options > AddOns > Worm Facts|r.")

    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)   -- the old double-call bug
    else
        WF.Print("couldn't open the settings panel on this client.")
    end
end
