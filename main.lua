PLUGIN = nil
internationTable = nil
function findVersion(pastebinid)
  local result = nil
  local newWeb = "http://pastebin.com/raw.php?i=" .. pastebinid .. ""
  local ConnectCallbacks =
  {
	OnConnected = function (a_Link)
		-- Connection succeeded, send the http request:
		a_Link:Send("GET " .. newWeb .. " HTTP/1.0\r\n")
	end,

	OnError = function (a_Link, a_ErrorCode, a_ErrorMsg)
		-- Log the error to console:
		LOG("An error has occurred while talking to " .. newWeb .. ": " .. a_ErrorCode .. " (" .. a_ErrorMsg .. ")")
	end,

	OnReceivedData = function (a_Link, a_Data)
		Player:SendMessage("[CYDIA] Script recieved!")
		result = a_Data
	end,
  }
	cNetwork:Connect(newWeb .. "", 80, ConnectCallbacks)
  return result
end

function Initialize(Plugin)
  Plugin:SetName("CydiaManager")
  Plugin:SetVersion(1)
  cPluginManager:BindCommand("/manage", "cmanage.main", manageCommand, " ~ The main command for Cydia Management.")
  local compatiblePlugins = {"CydiaScriptLoader"}
  internationTable = compatiblePlugins
  if cPluginManager:GetPlugin(compatiblePlugins[1]):GetStatus() == "psLoaded" then
    LOG("CydiaManager - has found CydiaScriptLoader! Comparing..")
    local localPastebin = cPluginManager:CallPlugin(compatiblePlugins[1], cydiaManagement())
    local plugin = cPluginManager:GetPlugin(compatiblePlugins[1])
    local localVersion = plugin:GetVersion()
    if findVersion(localPastebin) == localVersion then
      LOG("CydiaScriptLoader is at the latest version.")
    end
    if findVersion(localPastebin) > localVersion then
      LOG("CydiaScriptLoader is outdated, please update.")
    end
    if findVersion(localPastebin) < localVersion then
      LOG("CydiaScriptLoader is out of sync. Please recorrect this issue.")
    end
  else
    LOG("CydiaManager - cannot find CydiaScriptLoader.")
  end
  PLUGIN = Plugin
  return true
end

function manageCommand(Split, Player)
  if Player:HasPermission() then
  if (#Split ~= 2) then
    Player:SendMessage("Usage: /manage [command]")
    return true
  end
  if Split[2] == "refresh" then
    cPluginManager:RefreshPluginList()
  end
  if Split[2] == "version" then
    Player:SendMessage("CydiaManagement: is running build " .. PLUGIN:GetVersion())
  end
  if Split[2] == "recheck" then
    if cPluginManager:GetPlugin(internationTable[1]):GetStatus() == "psLoaded" then
      LOG("CydiaManager - has found CydiaScriptLoader! Comparing..")
      local localPastebin = cPluginManager:CallPlugin(internationTable[1], cydiaManagement())
      local plugin = cPluginManager:GetPlugin(internationTable[1])
      local localVersion = plugin:GetVersion()
      if findVersion(localPastebin) == localVersion then
        LOG("CydiaScriptLoader is at the latest version.")
      end
      if findVersion(localPastebin) > localVersion then
        LOG("CydiaScriptLoader is outdated, please update.")
      end
      if findVersion(localPastebin) < localVersion then
        LOG("CydiaScriptLoader is out of sync. Please recorrect this issue.")
      end
    else
      LOG("CydiaManager - cannot find CydiaScriptLoader.")
    end
  end
  if Split[2] == "help" then
    Player:SendMessage("Cydia Manager - help is not implemented in this build.")
  end
end
else
  Player:SendMessage("Sorry, you don't have permission.")
end

function OnDisable()
  LOG("Cydia Manager - shutted down. systems are off.")
end
