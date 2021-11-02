local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local SlashCommands = {}
function SlashCommands:RegisterSlashCommand(name, _callback, _context, enabledInRelease, _commandType)
  local slashCommandsOn = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableAnySlashCommands")
  if not slashCommandsOn then
    return
  end
  if g_slashCommands == nil then
    Debug.Log("g_slashCommands not defined. Make sure Globals.lua is run.")
    return
  end
  if type(name) ~= "string" or type(_callback) ~= "function" then
    Debug.Log("Usage: SlashCommands:RegisterSlashCommand(name (string), callback (function), context (optional, table))")
    return
  end
  g_slashCommands[name] = {
    callback = _callback,
    context = _context,
    enabledInRelease = enabledInRelease,
    commandType = _commandType
  }
end
function SlashCommands:UnregisterSlashCommand(name)
  if type(g_slashCommands) == "table" then
    g_slashCommands[name] = nil
  end
end
function SlashCommands:HandleSlashCommand(command)
  if not command or command == "" then
    return
  end
  if string.sub(command, 1, 1) == "/" then
    command = string.sub(command, 2)
  end
  local args = {}
  for word in string.gmatch(command, "%S+") do
    args[#args + 1] = word
  end
  local t = g_slashCommands[args[1]]
  if t and type(t) == "table" and type(t.callback) == "function" then
    local debugSlashCommandsOn = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableDebugSlashCommands")
    if not t.enabledInRelease and not debugSlashCommandsOn then
      return
    end
    if type(t.context) == "table" then
      t.callback(t.context, args)
    else
      t.callback(args)
    end
  else
    Debug.Log(string.format("Unknown slash command %s", tostring(args[1])))
  end
end
return SlashCommands
