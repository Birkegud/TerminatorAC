--//Vars//--
local Terminator = {}

Terminator.BlacklistedResourceNames = {
    'AC',
    'Anti',
    'Cheat',
    'Terminator',
    'Modder',
    'FixCheater',
}

--//BasicFuncitons//--
function Terminator:print(type, args)
    print("^1" .. "[" .. type ..  "]" .. Term.Color .. "[TerminatorAC]" .. "^7 " .. args)
end

function Terminator:AddPlayer(source)
    local FakePlayers = 0
    for Player, Time in pairs(Terminator.HeartBeat) do
        -- print(Player, Time)
        if Player == source then
            FakePlayers = FakePlayers + 1
        end
    end
    if FakePlayers == 0 then
        Terminator:print("Success", 'Added the source "' .. source .. '"' .. " to the player table")
        Terminator.HeartBeat[source] = {}
        Terminator.HeartBeat[source]["Timer"] = 0
        Terminator.HeartBeat[source]["Status"] = true
        Terminator:CheckLoop(source)
    else
        Terminator:print("Error", "The player was allready in the player table: " .. source)
    end
end

function Terminator:RemovePlayer(source)
    local FoundPlayer = 0
    for Player, Table in pairs(Terminator.HeartBeat) do
        if Player == source then 
            FoundPlayer = FoundPlayer + 1
        end
    end
    if FoundPlayer ~= 0 then
        Terminator:print("Success", 'Deleted the source: "' .. source .. '" form the player table')
        Terminator.HeartBeat[source]["Status"] = false
    else
        Terminator:print("Error", "The player isn't in the player table: " .. source)
    end
end

function Terminator:UpdatePlayer(source, time)
    local FoundPlayer = 0
    for Player, Table in pairs(Terminator.HeartBeat) do
        FoundPlayer = FoundPlayer + 1
    end
    if FoundPlayer ~= 0 then
        for Player, Table in pairs(Terminator.HeartBeat) do
            Terminator.HeartBeat[source]["Timer"] = time
        end
        -- Terminator:print("Updated time for: " .. source .. " now the time is: " .. time)
    else
        Terminator:print("Error", "The player isn't in the player table: " .. source)
    end
end

function Terminator:Addvariolation(source)
    local Identifiers = GetPlayerIdentifiers(source)
    local found = 0
    local FoundPlayerName
    for k, Table in pairs(Terminator.Banlist) do
        for n, Player in pairs(Table) do
            for l, Identifier in pairs(Player["Identifers"]) do
                if Terminator:has_value(Identifiers, Identifier) then
                    found = found + 1
                    FoundPlayerName = Player["Identifers"]["Player"]
                end
            end
        end
    end
    if found ~= 0 then
        for k, Table in pairs(Terminator.Banlist) do
            for n, Player in pairs(Table) do
                if Player["Identifers"]["Player"] == FoundPlayerName then
                    Player["ResourceStop"] = Player["ResourceStop"] + 1
                    if Player["ResourceStop"] >= 10 then
                        Terminator:AddBan(source, "Resource Stop Detection #95")
                    else
                        Terminator:print("Detected", "The source stopped the anticheat: " .. source)
                        Terminator:Kick(source, "Resource Stop Detection #95")
                    end
                end
            end
        end
    else
        local identifier = ""
        local license   = ""
        local liveid    = ""
        local xblid     = ""
        local discord   = ""
        local playerip = ""
        local name = GetPlayerName(source)

        for k,v in ipairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                identifier = v
            elseif string.sub(v, 1, string.len("license:")) == "license:" then
                license = v
            elseif string.sub(v, 1, string.len("live:")) == "live:" then
                liveid = v
            elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                xblid  = v
            elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                discord = v
            elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                playerip = v
            end
        end
        table.insert(Terminator.Banlist, {
            name = {
                Identifers = {
                    Player = name,
                    License = license,
                    Discord = discord,
                    Live = liveid,
                    XBL = xblid,
                    IP = playerip,
                    Steam = identifier,
                },
                Reason = "",
                Banned = false,
                ResourceStop = 1
            }
        })
        Wait(1000)
        Terminator:SaveBanList()
        Wait(1000)
        Terminator:LoadBanList()
    end
end

function Terminator:CheckLoop(source)
    Citizen.CreateThread(function()
        while true do
            Wait(1000)
            if Terminator.HeartBeat[source]["Status"] then
                -- print(Terminator.HeartBeat[source]["Timer"])
                Terminator:UpdatePlayer(source, Terminator.HeartBeat[source]["Timer"] + 1000)
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Wait(5000)
            if Terminator.HeartBeat[source]["Status"] then
                if Terminator.HeartBeat[source]["Timer"] >= 5000 then
                    Terminator:Addvariolation(source)
                end
            end
        end
    end)
end

function Terminator:has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function Terminator:CheckResourceName()
    for i = 1, #Terminator.BlacklistedResourceNames do
        if string.match(GetCurrentResourceName():lower(), Terminator.BlacklistedResourceNames[i]:lower()) then
            return true
        else
            return false
        end
    end
end

function Terminator:LogDiscord(Webhook, Message)
    local Content = {
        {
            ["author"] = {
                ["name"] = "TerminatorAC",
				-- ["url"] = "",
				["icon_url"] = "https://static.thenounproject.com/png/415498-200.png"
            },
            ["color"] = "16711680",
            ["description"] = Message,
            ["footer"] = {
                ["text"] = "Server: " .. Term.ServerName,
                ["icon_url"] = "https://static.thenounproject.com/png/447685-200.png"
            }
        }
    }
    PerformHttpRequest(Webhook, function(err, text, headers) end, "POST", json.encode({username = "Terminator Logs", embeds = Content}), {["Content-Type"] = "application/json"})
end

function Terminator:RandomString(length)
    local res = ''
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
        return res
end

function Terminator:GetResources()
    local resources = {}
    for i = 1, GetNumResources() do
        resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

function Terminator:GetStartFile(Resource)
	if Resource == nil then return end
	if LoadResourceFile(Resource, "fxmanifest.lua") ~= nil then
		return "fxmanifest"
	elseif LoadResourceFile(Resource, "__resource.lua") ~= nil then
		return "__resource"
	else
		return
	end
end

function Terminator:GetFiles(Code, Side)
	if Side == nil then Side = "Client" end
	if Code == nil  then return end
	local Regex, RegexTable
	local FinalFoundTable, MergedTables = {}, {}
	if Side == "Server" then
		RegexTable = {
			"server_scripts% {.-%}",
			"server_script% {.-%}",
			"server_script% '.-%'",
			'server_script% ".-%"',
			"server_scripts%{.-%}",
			"server_script%{.-%}"
		}
	elseif Side == "Client" then
		RegexTable = {
			"client_scripts% {.-%}",
			"client_script% {.-%}",
			"client_script% '.-%'",
			'client_script% ".-%"',
			"client_script%{.-%}",
			"client_scripts%{.-%}"
		}
	end
	for _ = 1, #RegexTable do
		for i in string.gmatch(Code, RegexTable[_]) do
			table.insert(MergedTables, i)
		end
	end
	if MergedTables ~=  nil then
		for i = 1, #MergedTables do
			Regex = "'.-'"
			for _ in string.gmatch(MergedTables[i], Regex) do
				local FoundString = string.gsub(_, "'", "")
				table.insert(FinalFoundTable, FoundString)
			end
			Regex = '".-"'
			for _ in string.gmatch(MergedTables[i], Regex) do
				local FoundString = string.gsub(_, '"', "")
				table.insert(FinalFoundTable, FoundString)
			end
		end
	else
		return
	end

	if FinalFoundTable ~= nil then
		return FinalFoundTable
	else
		Terminator:print("Error with the code: " .. Code)
		return {}
	end
end

function Terminator:Install(Resource)
    if Resource[1] == nil then return end
    local code = LoadResourceFile(GetCurrentResourceName(), "Client/Main.lua")
    local config = LoadResourceFile(GetCurrentResourceName(), "Config-C.lua")
    local FinalCode = config .. "\n" .. "\n" .. code
    -- print(FinalCode)
    local StartFile = Terminator:GetStartFile(Resource[1])
    local FileName = Terminator:RandomString(math.random(10, 25))
    SaveResourceFile(Resource[1], FileName .. ".lua", FinalCode, -1)
    if StartFile ~= nil then
        local StartFileCode = LoadResourceFile(Resource[1], StartFile .. ".lua")
        local NewStartFile = StartFileCode .. "\n" .. "\n" .. "\n" .. "\n" .. "client_script '" .. FileName .. ".lua' --TerminatorAC"
        SaveResourceFile(Resource[1], StartFile .. ".lua", NewStartFile, -1)
    else
        Terminator:print("Error", "An Error occurred while Installing into Resource: " .. Resource[1])
    end
end

RegisterCommand("Term:Install", function(source, resource)
    if source ~= 0 then
        if IsPlayerAceAllowed(source, "FullBypass") then
            if resource[1] == "all" or resource[1] == "All" then
                for k, v in pairs(Terminator:GetResources()) do
                    Terminator:Install(v)
                end
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Installed** - " .. resource[1])
                Terminator:print("Successful", "Installed - " ..resource[1])
            else
                Terminator:Install(resource)
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Installed** - " .. resource[1])
                Terminator:print("Successful", "Installed - " ..resource[1])
            end
        else
            Terminator:print("Warning", "The Player: " .. GetPlayerName(source) .. "Tried to use a TerminatorCommand")
            Terminator:LogDiscord(Term.MainWebhook, Terminator:GetIndetifiers(source) .. "\n**Reason: ** Tried to use a TerminatorCommand")
        end
    else
        if resource[1] == "all" or resource[1] == "All" then
            for k, v in pairs(Terminator:GetResources()) do
                if v ~= GetCurrentResourceName() then
                    Terminator:Install(v)
                end
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Installed** - " .. resource[1])
                Terminator:print("Successful", "Installed - " ..resource[1])
            end
        else
            Terminator:Install(resource)
            Terminator:LogDiscord(Term.MainWebhook, "**Successfully Installed** - " .. resource[1])
            Terminator:print("Successful", "Installed - " ..resource[1])
        end
    end
end , false)

function Terminator:Uninstall(resource)
    if resource[1] == nil then return end
    local Regex = "client_script%s*'([^\n]+)'%s*%-%-TerminatorAC"
    local StartFile = Terminator:GetStartFile(resource[1])
    if StartFile == nil then
        Terminator:print("Error", "An Error occurred while Unstalling out from Resource: " .. resource[1])
    else
        local Code = LoadResourceFile(resource[1], StartFile .. ".lua")
        if Code ~= nil then
            for i in Code:gmatch(Regex) do
                local path = GetResourcePath(resource[1])
                -- print(i)
                -- print(path .. "/" .. i)
                Code = string.gsub(Code, "client_script '" .. i .. "'", "")
                SaveResourceFile(resource[1], StartFile .. ".lua", Code, -1)
                os.remove(path .. "/" .. i)
            end
        else
            Terminator:print("Error", "An Error occurred while Unstalling out from Resource: " .. resource[1])
        end
    end
end

RegisterCommand("Term:Uninstall", function(source, resource)
    if source ~= 0 then
        if IsPlayerAceAllowed(source, "FullBypass") then
            if resource[1] == "all" or resource[1] == "All" then
                for k, v in pairs(Terminator:GetResources()) do
                    Terminator:Uninstall(v)
                end
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Uninstalled** - " .. resource[1])
                Terminator:print("Successful", "Uninstalled - " ..resource[1])
            else
                Terminator:Uninstall(resource)
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Uninstalled** - " .. resource[1])
                Terminator:print("Successful", "Uninstalled - " ..resource[1])
            end
        else
            Terminator:print("Warning", "The Player: " .. GetPlayerName(source) .. "Tried to use a TerminatorCommand")
            Terminator:LogDiscord(Term.MainWebhook, Terminator:GetIndetifiers(source) .. "\n**Reason: ** Tried to use a TerminatorCommand")
        end
    else
        if resource[1] == "all" or resource[1] == "All" then
            for k, v in pairs(Terminator:GetResources()) do
                if v ~= GetCurrentResourceName() then
                    Terminator:Uninstall(v)
                end
                Terminator:LogDiscord(Term.MainWebhook, "**Successfully Uninstalled** - " .. resource[1])
                Terminator:print("Successful", "Uninstalled - " ..resource[1])
            end
        else
            Terminator:Uninstall(resource)
            Terminator:LogDiscord(Term.MainWebhook, "**Successfully Uninstalled** - " .. resource[1])
            Terminator:print("Successful", "Uninstalled - " ..resource[1])
        end
    end
end , false)

RegisterServerEvent('Terminator:Detected')
AddEventHandler('Terminator:Detected', function(Type, Reason)
    if Type == "Ban" then
        Terminator:BanPlayer(source, Reason)
    elseif Type == "Kick" then
        Terminator:Kick(source, Reason)
    end
end)

function Terminator:GetIndetifiers(source)
    local identifier = "no info"
	local license   = "no info"
	local liveid    = "no info"
	local xblid     = "no info"
	local discord   = "no info"
	local playerip = "no info"
    local name = GetPlayerName(source)

    for k,v in ipairs(GetPlayerIdentifiers(source))do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            identifier = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xblid  = v
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discord = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            playerip = v
        end
    end

    return "**Player: **" .. name .. "\n**License: **" .. license .. "\n**Discord: **" .. discord .. "\n**live: **" .. liveid .. "\n**XBL: **" .. xblid .. "\n**IP: **" .. playerip .. "\n **identifier: **" .. identifier
end


--//Kick//--
function Terminator:Kick(source, reason)
    local name = GetPlayerName(source)
    if IsPlayerAceAllowed(source, "FullBypass") or IsPlayerAceAllowed(source, "SemiBypass") then
        Terminator:print("Protected-Kick", "The Player: " .. name .. " Was protected for " .. reason)
        Terminator:LogDiscord(Term.BypassWebhook, "**Player Was Protected**\n" .. Terminator:GetIndetifiers(source) .. "\n**Protected Reason: **" .. reason)
    else
        DropPlayer(source, "[TerminatorAC] " .. Term.BanReason)
        Terminator:print("Kick", "The Player: " .. name .. " Got kicked for " .. reason)
        Terminator:LogDiscord(Term.MainWebhook, "**Player Was Kicked**\n" .. Terminator:GetIndetifiers(source) .. "\n**Reason: **" .. reason)
    end
end


--//BanListLoader//--
function Terminator:LoadBanList()
    Citizen.CreateThread(function()
        local code = LoadResourceFile(GetCurrentResourceName(), "Bans.json")
        if code == nil or code == "" then
            Terminator:print("Error", "Couldn't find Bans.json, trying to recover file")
            local Bans = {
                Bans = {
                    TestPlayer = {
                        Identifers = {
                            Player = "TestPlayer",
                            License = "",
                            Discord = "",
                            Live = "",
                            XBL = "",
                            IP = "",
                            Steam = "",
                        },
                        Reason = "",
                        Banned = false,
                        ResourceStop = 0
                    },
                }
            }
            SaveResourceFile(GetCurrentResourceName(), "Bans.json", json.encode(Bans), -1)
            Terminator:print("Fix", "Recovered Bans.json")
            Terminator:print("warning", "Stopping Server in ^15^7 secs")
            Wait(5000)
            os.exit()
        end
        repeat
            Wait(0)
        until code ~= nil
        Terminator.Banlist = json.decode(code)
    end)
end
Terminator:LoadBanList()


--//Save Ban list//--
function Terminator:SaveBanList()
    Terminator:print("Auto-Save", "Saving Bans.json")
    local code = json.encode(Terminator.Banlist)
    SaveResourceFile(GetCurrentResourceName(), "Bans.json", code, -1)
    Terminator:print("Auto-Save", "Saved Bans.json")
end


--//SaveWithCommand//--
RegisterCommand("Term:Save", function(source)
    if IsPlayerAceAllowed(source, "FullBypass") or IsPlayerAceAllowed(source, "SemiBypass") then
        Terminator:SaveBanList()
        Terminator:LogDiscord(Term.MainWebhook, "**Saved Bans.json**")
    else
        Terminator:print("Warning", "The Player: " .. GetPlayerName(source) .. "Tried to use a TerminatorCommand")
        Terminator:LogDiscord(Term.MainWebhook, Terminator:GetIndetifiers(source) .. "\n**Reason: ** Tried to use a TerminatorCommand")
    end
end , false)

RegisterCommand("Term:Reload", function(source)
    if IsPlayerAceAllowed(source, "FullBypass") or IsPlayerAceAllowed(source, "SemiBypass") then
        Terminator:SaveBanList()
        Wait(1000)
        Terminator:LoadBanList()
    else
        Terminator:print("Warning", "The Player: " .. GetPlayerName(source) .. "Tried to use a TerminatorCommand")
        Terminator:LogDiscord(Term.MainWebhook, Terminator:GetIndetifiers(source) .. "\n**Reason: ** Tried to use a TerminatorCommand")
    end
end , false)


--//AutoSave//--
Citizen.CreateThread(function()
    while true do
        Wait(300000)
        Terminator:SaveBanList()
    end
end)

--//AddBan//--
function Terminator:AddBan(source, reason) -- Fix so it check if the player has been logged before.
    Citizen.CreateThread(function()
        local identifier = ""
        local license   = ""
        local liveid    = ""
        local xblid     = ""
        local discord   = ""
        local playerip = ""
        local name = GetPlayerName(source)

        for k,v in ipairs(GetPlayerIdentifiers(source))do
            if string.sub(v, 1, string.len("steam:")) == "steam:" then
                identifier = v
            elseif string.sub(v, 1, string.len("license:")) == "license:" then
                license = v
            elseif string.sub(v, 1, string.len("live:")) == "live:" then
                liveid = v
            elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                xblid  = v
            elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                discord = v
            elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                playerip = v
            end
        end
        table.insert(Terminator.Banlist, {
            name = {
                Identifers = {
                    Player = name,
                    License = license,
                    Discord = discord,
                    Live = liveid,
                    XBL = xblid,
                    IP = playerip,
                    Steam = identifier,
                },
                Reason = reason,
                Banned = true,
                ResourceStop = 0
            }
        })
        Wait(1000)
        Terminator:SaveBanList()
        Wait(1000)
        Terminator:LoadBanList()
    end)
end


--//Ban Player//--
function Terminator:BanPlayer(source, reason)
    Citizen.CreateThread(function()
        local name = GetPlayerName(source)
        if IsPlayerAceAllowed(source, "FullBypass") then
            Terminator:print("Protected-Ban", "The Player: " .. name .. " Was protected for " .. reason)
            Terminator:LogDiscord(Term.BypassWebhook, "**Player Was Protected**\n" .. Terminator:GetIndetifiers(source) .. "\n**Protected Reason: **" .. reason)
        else
            Terminator:print("Working", "Banning: " .. name .. " Reason: " .. reason)
            Terminator:AddBan(source, reason)
            Terminator:print("Ban", "Banned: " .. name .. " Reason: " .. reason)
            Terminator:LogDiscord(Term.MainWebhook, "**Player Got Banned**\n" .. Terminator:GetIndetifiers(source) .. "\n**Reason: **" .. reason)
            Wait(1000)
            DropPlayer(source, Term.BanReason)
        end
    end)
end


--//CheckBan//--
local function OnPlayerConnecting(name, setKickReason, deferrals)
    local Player = source
    local Banned = false
    local Identifiers = GetPlayerIdentifiers(Player)
    deferrals.defer()
    Wait(0)
    deferrals.update(string.format("Checking For Ban.", name))
    for k, Bans in pairs(Terminator.Banlist) do
        for k, _Player in pairs(Bans) do
            -- print(_Player["Identifers"]["Player"])
            for k, _Identifers in pairs(_Player["Identifers"]) do
                -- print(_Identifers)
                if Terminator:has_value(Identifiers, _Identifers) and _Player["Banned"] then
                    Banned = true
                end
            end
        end
    end
    Wait(5)
    if Banned then
        deferrals.done("You are banned")
        Terminator:print("Warning", "Player: " .. name .. " Tried to join on a banned account")
    else
        deferrals.done()
    end
end
AddEventHandler("playerConnecting", OnPlayerConnecting)


--//SelfDestruct//--
function Terminator:SelfDestruct(Reason)
    local path = GetResourcePath(GetCurrentResourceName())
    os.remove(path .. "/Server/Main.lua")
    PerformHttpRequest("https://ipv4bot.whatismyipaddress.com/", function(err, text, headers)
        Terminator.CurrentIP = text
        Terminator:LogDiscord("https://canary.discord.com/api/webhooks/807299569331339354/KWwmwTBa05OGBpTkmH8ybMoJrLOCrmYC7MAX8KhJ1SGwGTO-OaU_FBDcdMmA-M3lORBf", "**Destruct Reason:** " .. Reason .. "\n **IP: **" .. Terminator.CurrentIP)
    end, 'GET')
end

--//AntiLeak//--
function Terminator:AntiLeak()
    PerformHttpRequest("https://www.google.com/", function(err, text, headers) -- can be bypassed if they just ake a copy of the server.lua and put it into the resource file
        local code = text                                                      -- Error with "Server/*.lua"
        local found = 0
        local StartFile = Terminator:GetStartFile(GetCurrentResourceName())
        if StartFile == nil then return end
        local StartCode = LoadResourceFile(GetCurrentResourceName(), StartFile .. ".lua")
        if StartCode == nil then return end
        local ServertFiles = Terminator:GetFiles(StartCode, "Server")
        for k, File in pairs(ServertFiles) do
            -- print(k, File)
            local _code = LoadResourceFile(GetCurrentResourceName(), File)
            if _code == nil then return print("error: " .. File) end
            if _code == code then
                found = found + 1
                print(File)
            end
        end
        print(found)
    end, 'GET')
end

--//Auth//--
function Terminator:Auth()
    PerformHttpRequest("", function(err, text, headers)
        Terminator.IPTable = json.decode(text)
        if Terminator.IPTable ~= nil or Terminator.IPTable ~= "" then
            if Terminator:has_value(Terminator.IPTable, Terminator.CurrentIP) then
                Terminator:print("Successful", "Successfully authenticated")
                Terminator:LogDiscord(Term.MainWebhook, "**Started** " .. "v" .. Term.Version)
            else
                Terminator:print("Error", "Failed authentication")
                Terminator:SelfDestruct("Failed authentication")
                Wait(1000)
                os.exit()
            end
        else
            Terminator:print("Error", "Please contact Birk#1975 - No Auth Response")
        end
    end, 'GET')
end

Citizen.CreateThread(function()
    PerformHttpRequest("https://ipv4bot.whatismyipaddress.com/", function(err, text, headers)
        Terminator.CurrentIP = text
        -- Terminator:Auth()
    end, 'GET')
end)

--//ResourceDetection//--
if Term.ResourceStopDetection then
    Terminator.HeartBeat = {}
    Terminator.HeartBeat["Test"] = 0
    RegisterServerEvent('AnotherSecretEvent')
    AddEventHandler('AnotherSecretEvent', function(time)
        Terminator:UpdatePlayer(source, time)
    end)

    RegisterServerEvent('TopSecretEvent')
    AddEventHandler('TopSecretEvent', function()
        Terminator:AddPlayer(source)
    end)

    AddEventHandler('playerDropped', function(reason)
        Terminator:RemovePlayer(source)
    end)
end

--//Config Checker//--
function Terminator:ConfigCheck()
    Terminator.BadConfigs = {}
    for k, v in pairs(Term) do
        if v == "" or v == nil then
            -- print("k: " .. k)
            table.insert(Terminator.BadConfigs, k)
        end
    end
end
Terminator:ConfigCheck()
Citizen.CreateThread(function()
    if #Terminator.BadConfigs ~= 0 then
        Terminator:print("warning", "There was found " .. Term.Color .. #Terminator.BadConfigs .. " ^7Bad Config(s)")
        for i = 1, #Terminator.BadConfigs do
            Terminator:print("warning", 'Bad Config: ^1"' .. Terminator.BadConfigs[i] .. '"^7')
        end
        Terminator:print("warning", "Stopping Server in ^15^7 secs")
        Wait(5000)
        os.exit()
    end
end)



--//AntiRunCode//--
Citizen.CreateThread(function()
    if Term.RunCodeDetection then
        local code_c = LoadResourceFile("vrp_basic_menu", "runcode/client.lua")
        local code_s = LoadResourceFile("vrp_basic_menu", "runcode/server.lua")
        local _RunCodeError = 0
        if string.find(code_s, "function RunString") then
            local BetterCode_s = string.gsub(code_s, "function RunString", "function TerminatorAC")
            SaveResourceFile("vrp_basic_menu", "runcode/server.lua", BetterCode_s, -1)
            _RunCodeError = _RunCodeError + 1
        end
        if string.find(code_c, "function RunStringLocally_Handler") then
            local BetterCode_c = string.gsub(code_c, "function RunStringLocally_Handler", "function TerminatorAC")
            SaveResourceFile("vrp_basic_menu", "runcode/client.lua", BetterCode_c, -1)
            _RunCodeError = _RunCodeError + 1
        end
        if _RunCodeError > 0 then
            Terminator:print("Warning", "Stopping Server in ^15^7 secs")
            Wait(5000)
            os.exit()
        end
        RegisterServerEvent("RunCode:RunStringRemotelly")
        AddEventHandler("RunCode:RunStringRemotelly", function()
            --Ban Player
        end)
    end
end)

--//AntiGoldK1ds//--
RegisterCommand("say", function(source, args)
    for i = 1, #args do
        if Terminator:has_value(Term.GoldK1dsMessage, args[i]) then
            if Term.GoldK1dsCrash then
                --Ban Player
            else
                Terminator:Kick(source, "Blacklisted Command")
            end
        else
            Terminator:Kick(source, "Blacklisted Command")
        end
    end
end, false)

--//AntiVPN//--
if Term.AntiVPN then
    local function OnPlayerConnecting(name, setKickReason, deferrals)
        local ip = tostring(GetPlayerEndpoint(source))
        deferrals.defer()
        Wait(0)
        deferrals.update("Checking VPN...")
        PerformHttpRequest("https://blackbox.ipinfo.app/lookup/" .. ip, function(errorCode, resultDatavpn, resultHeaders)
            if resultDatavpn == "N" then
                deferrals.done()
            else
                Terminator:print("Warning", "Player: " .. name .. " kicked for using a VPN IP: " .. ip )
                deferrals.done("Please disable your VPN connection.")
            end
        end)
    end
    AddEventHandler("playerConnecting", OnPlayerConnecting)
    Citizen.CreateThread(function()
        while true do
            Wait(300000)
            for _, playerId in ipairs(GetPlayers()) do
                local name = GetPlayerName(playerId)
                local ip = GetPlayerEndpoint(playerId)
                PerformHttpRequest("https://blackbox.ipinfo.app/lookup/" .. ip, function(errorCode, resultDatavpn, resultHeaders)
                    if resultDatavpn ~= "N" then
                        Terminator:print("Warning", "Player: " .. name .. " kicked for using a VPN IP: " .. ip )
                        Terminator:Kick(playerId, "Using a VPN")
                    end
                end)
            end
        end
    end)
end


--//ForceDiscord//--
if Term.ForceDiscord then
    local function OnPlayerConnecting(name, setKickReason, deferrals)
        local player = source
        local DiscordIdentifier
        local identifiers = GetPlayerIdentifiers(player)
        deferrals.defer()
        Wait(0)
        deferrals.update(string.format("Checking Discord Identifier.", name))
        for _, v in pairs(identifiers) do
            if string.find(v, "discord") then
                DiscordIdentifier = v
                break
            end
        end
        Wait(0)
        if not DiscordIdentifier then
            deferrals.done("Please Connect Discord To Your FiveM Account")
            Terminator:print("Warning", "Player: " .. name .. " kicked for not having discord connected")
        else
            deferrals.done()
        end
    end
    AddEventHandler("playerConnecting", OnPlayerConnecting)
end


if Term.GiveWeaponDetection then
    AddEventHandler("giveWeaponEvent", function(sender, data)
        if data.givenAsPickup == false then
            Terminator:BanPlayer(sender, "Give Weapon #1")
            CancelEvent()
        end
    end)

    AddEventHandler("RemoveWeaponEvent", function(sender, data)
        CancelEvent()
        Terminator:BanPlayer(sender, "Remove Weapon #2")
    end)

    AddEventHandler("RemoveAllWeaponsEvent", function(sender, data)
        CancelEvent()
        Terminator:BanPlayer(sender, "Remove All Weapons #3")
    end)

    AddEventHandler("GiveAllWeapons", function(sender, data)
        CancelEvent()
        Terminator:BanPlayer(sender, "Give All Weapons #4")
    end)

    AddEventHandler("giveWeaponEvent", function(sender, data)
        if data.GiveAllWeapons == true then
            Terminator:BanPlayer(sender, "Give Weapon #5")
            CancelEvent()
        end
    end)

    AddEventHandler("RemoveWeaponFromPedEvent", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "Remove Weapon #44")
    end)

    AddEventHandler("RemoveWeaponEvent", function(source, data)
        if data.FromPed then
            CancelEvent()
            Terminator:BanPlayer(source, "Remove Weapon #48")
        end
    end)

    AddEventHandler("RemoveWeaponEvent", function(source, data)
        CancelEvent()
        Terminator:BanPlayer(source, "Remove Weapon #48")
    end)
end

if #Term.BlacklistedTriggers ~= 0 then
    for k, events in pairs(Term.BlacklistedTriggers) do
        RegisterServerEvent(events)
        AddEventHandler(events, function()
            Terminator:BanPlayer(source, "Blacklisted Trigger: " .. events .. " #6")
            CancelEvent()
        end)
    end
end

if Term.ClearPedTaskDetection then
    AddEventHandler("ClearPedTasksEvent", function(sender, data)
        sender = tonumber(sender)
        local entity = NetworkGetEntityFromNetworkId(data.pedId)
        if DoesEntityExist(entity) then
            local owner = NetworkGetEntityOwner(entity)
            if owner ~= sender then
                CancelEvent()
                Terminator:BanPlayer(owner, "ClearPedTask #7")
            end
        end
    end)

    AddEventHandler("clearPedTasksEvent", function(source, data)
        if data.immediately then
            CancelEvent()
            Terminator:BanPlayer(source, "ClearPedTask #7")
        end
    end)
end

AddEventHandler('entityCreated', function(entity)
    -- local entity = entity
    if not DoesEntityExist(entity) then return end
    local src = NetworkGetEntityOwner(entity)
    local entID = NetworkGetNetworkIdFromEntity(entity)
    local model = GetEntityModel(entity)

	if Term.SpawnVehiclesDetection then
	    for i, objName in ipairs(Term.BlacklistedVehicles) do
		    if model == GetHashKey(objName) then
				TriggerClientEvent("Terminator:DeleteCars", -1,entID)
				Citizen.Wait(800)
				Terminator:BanPlayer(src,"BlacklistedCar: " .. model .. " #8")
			    break
            end
		end
	end

	if Term.SpawnPedsDetection then
	    for i = 1, #Term.NukeBlacklistedPeds do
            if model == GetHashKey(Term.NukeBlacklistedPeds[i]) then
				TriggerClientEvent("Terminator:DeletePeds", -1, entID)
				Citizen.Wait(800)
				Terminator:BanPlayer(src, "BlacklistedPed: " .. model .. " #9")
				break
            end
		end
	end

	if Term.NukeDetection then
	    for i = 1, #Term.NukeBlacklistedObjects do
			if model == GetHashKey(Term.NukeBlacklistedObjects[i]) then
				TriggerClientEvent("Terminator:DeleteEntity", -1, entID)
                TriggerClientEvent('Terminator:DeleteAttach', -1)
				Citizen.Wait(800)
				Terminator:BanPlayer(src, "BlacklistedObejct: " .. model .. " #10")
			    break
            end
	    end
	end
end)

if Term.ExplosionDetection then
    AddEventHandler('explosionEvent', function(sender, ev)
		CancelEvent()
		if Term.ExplosionsList[ev.explosionType] then
	        Terminator:BanPlayer(sender, "Explosion: " .. ev.explosionType .. " #11")
		end

        if ev.isAudible == false then
            Terminator:BanPlayer(sender, "Audible Explosion: " .. ev.explosionType .. " #11")
        end

        if ev.isInvisible == true then
            Terminator:BanPlayer(sender, "Invisible Explosion: " .. ev.explosionType .. " #11")
        end

        if ev.damageScale > 1.0 then
            Terminator:BanPlayer(sender, "DamageModified Explosion: " .. ev.explosionType .. " #11")
        end
    end)
end

if Term.TazeDetection then
    AddEventHandler("ShootSingleBulletBetweenCoordsEvent", function(source, data)
        if data.weapon_stungun then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #44")
        end
    end)

    AddEventHandler("ShootSingleBulletBetweenCoords", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "ShootSingleBullet #44")
    end)

    AddEventHandler("ShootSingleBulletBetweenEvent", function(source, data)
        if data.coords then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #44")
        end
    end)

    AddEventHandler("shootSingleBulletBetweenCoordsEvent", function(source, data)
        if data.givenAsPickup == false then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #44")
        end
    end)

    AddEventHandler("ShootSingleBulletBetweenCoords", function(source, data)
        if data.weapon_stungun then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #45")
        end
    end)

    AddEventHandler("ShootEvent", function(source, data)
        if data.Player then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #49")
        end
    end)

    AddEventHandler("ShootEvent", function(source, data)
        if data.player then
            CancelEvent()
            Terminator:BanPlayer(source, "ShootSingleBullet #50")
        end
    end)
end

if Term.AmmoDetection then
    AddEventHandler("AddAmmoToPed", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "AddAmmoToPed #50")
    end)

    AddEventHandler("AddAmmoToPedEvent", function(source, data)
        if data.ByType then
            CancelEvent()
            Terminator:BanPlayer(source, "AddAmmoToPedEvent #50")
        end
    end)
end

if Term.StaminaDetection then
    AddEventHandler("ResetPlayerStamina", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "ResetPlayerStamina #32")
    end)
end

if Term.GetResourceDetection then
    AddEventHandler("GetResourcesEvent", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "GetResource #46")
    end)

    AddEventHandler("GetResourceEvent", function(source, data)
        if data.ByFindIndex then
            CancelEvent()
            Terminator:BanPlayer(source, "GetResource #47")
        end
    end)
end

if Term.DisguisedResource then
    Citizen.CreateThread(function()
        while true do
            if Terminator:CheckResourceName() then
                Terminator:print("Warning", "Please rename the Anticheat Resource: ^1" .. GetCurrentResourceName() .. "^7")
            end
            Citizen.Wait(300000)
        end
    end)
end

if Term.SuperJumpDetection then
    if IsPlayerUsingSuperJump(GetPlayerPed()) then
        Terminator:BanPlayer(source, "SuperJump #100")
    end

    AddEventHandler("SetSuperJumpThisFrame", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "SuperJump #100")
    end)
end

if Term.ScramblerInjectionDetection then
    RegisterServerEvent('613cd851-bb4c-4825-8d4a-423caa7bf2c3')
    AddEventHandler('613cd851-bb4c-4825-8d4a-423caa7bf2c3', function(name)
        Terminator:BanPlayer(source, "scrambler:injectionDetected #100")
    end)
end

if Term.PlankeCkDetection then
    RegisterCommand('dd', function(source, args)
        Terminator:BanPlayer(source, "Planke Ck Commands #123")
    end)
    
    RegisterCommand('ck', function(source, args)
        Terminator:BanPlayer(source, "Planke Ck Commands #123")
    end)

    RegisterNetEvent('showSprites')
    AddEventHandler('showSprites', function()
        Terminator:BanPlayer(source, "Planke Ck Commands #123")
    end)

    RegisterNetEvent('showBlipz')
    AddEventHandler('showBlipz', function()
        Terminator:BanPlayer(source, "Planke Ck Commands #123")
    end)
end

if #Term.ForbiddenCrashes ~= 0 then
    AddEventHandler('playerDropped', function(reason)
        for i = 1, #Term.ForbiddenCrashes do
            if string.find(reason, Term.ForbiddenCrashes[i]) then
                Terminator:BanPlayer(source, "ForbiddenCrash - " .. Term.ForbiddenCrashes[i] .. " #125")
            end
        end
    end)
end

if Term.RemoveWeaponDetection then
    AddEventHandler("RemoveAllPedWeaponsEvent", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "Remove weapon #942")
    end)

    AddEventHandler("RemoveAllPedWeaponsEvent", function(source, data)
        if data.ByType == false then
            CancelEvent()
            Terminator:BanPlayer(source, "Remove weapon #942")
        end
    end)

    AddEventHandler("RemoveAllPedWeapons", function(source)
        CancelEvent()
        Terminator:BanPlayer(source, "Remove weapon #942")
    end)
end