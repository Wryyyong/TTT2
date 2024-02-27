tCooldown = tCooldown or {
    ["sqlName"] = sql.SQLStr("ttt2_tcooldown"),
    ["list"] = {},
    ["addedThisRound"] = {},
    ["cv"] = {
        ---
        -- @realm server
        ["minRounds"] = CreateConVar("ttt2_tcooldown_min_rounds", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sets the minimum amount of rounds that a player can be assigned in the traitor cooldown system. Does nothing if ttt2_tcooldown_max_rounds is set to 0.", 0),

        ---
        -- @realm server
        ["maxRounds"] = CreateConVar("ttt2_tcooldown_max_rounds", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Sets the maximum amount of rounds that a player can be assigned in the traitor cooldown system. Set to 0 to disable the cooldown system completely.", 0)
    }
}

local function TraitorCooldownInit()
    sql.Query("CREATE TABLE IF NOT EXISTS " .. tCooldown.sqlName .. "(id64 TEXT PRIMARY KEY, roundsLeft INTEGER) WITHOUT ROWID;")

    for _, data in ipairs(sql.Query("SELECT * FROM " .. tCooldown.sqlName) or {}) do
        tCooldown.list[data.id64] = data.roundsLeft
    end
end

for _, hookName in ipairs({"Initialize", "OnReloaded"}) do
    hook.Add(hookName, "TTT2TraitorCooldownInit", TraitorCooldownInit)
end

hook.Add("TTTEndRound", "TTT2TraitorCooldownProgress", function()
    if not tCooldown.cv.maxRounds:GetBool() then return end
    local cdMinRounds, cdMaxRounds = tCooldown.cv.minRounds:GetInt(), tCooldown.cv.maxRounds:GetInt()
    local updatedValues = {}

    for id64, plyValue in pairs(tCooldown.addedThisRound) do
        updatedValues[id64] = math.max(math.random(cdMinRounds, cdMaxRounds), plyValue)
    end

    for _, ply in ipairs(player.GetAll()) do
        local id64 = ply:SteamID64()
        local plyValue = tCooldown.list[id64]
        if updatedValues[id64] or not plyValue then continue end

        local newValue = plyValue - 1
        tCooldown.list[id64] = newValue > 0 and newValue or nil
        updatedValues[id64] = newValue
    end

    -- Setup string for SQL UPSERT query
    local upsertStr = ""
    for id64, updValue in pairs(updatedValues) do
        upsertStr = upsertStr -- prepend whatever's already assigned
            .. (upsertStr ~= "" and ", " or upsertStr) -- if string isn't empty, append comma to previous statement, else just reuse empty string
            .. "(" .. id64 .. ", " .. updValue .. ")" -- set updated value to id64 key
    end
    if upsertStr == "" then return end

    -- use upsertStr to update the SQL database to match the live table
    sql.Query("INSERT INTO " .. tCooldown.sqlName .. " VALUES " .. upsertStr .. " ON CONFLICT(id64) DO UPDATE SET roundsLeft = excluded.roundsLeft; DELETE FROM " .. tCooldown.sqlName .. " WHERE roundsLeft < 1;")
end)
