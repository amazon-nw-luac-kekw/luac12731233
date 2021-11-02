local DataLayer = RequireScript("LyShineUI.UiDataLayer")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local EntityRegistrar = RequireScript("LyShineUI.EntityRegistrar")
local Woody = {
  Properties = {
    BackButton = {
      default = EntityId()
    },
    NodeName = {
      default = EntityId()
    },
    TitleElement = {
      default = EntityId()
    },
    ItemsList = {
      default = EntityId()
    },
    ItemPrototype = {
      default = EntityId()
    }
  },
  dataStack = {},
  watchStack = {},
  childrenNames = {},
  watchKeys = {},
  childEntitiesToKeys = {},
  showDataLayer = true
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Woody)
function Woody:OnInit()
  BaseScreen.OnInit(self)
  SlashCommands:RegisterSlashCommand("woody", self.OnSlashWoody, self)
  g_watchedVariables.RegisteredEntities = g_entityTables
  self.ItemsList:Initialize(self.ItemPrototype)
  self.ItemsList:OnListDataSet(nil)
  self:LoadNode("")
end
function Woody:OnShutdown()
  if self.tickBusHandler then
    self.tickBusHandler:Disconnect()
    self.tickBusHandler = nil
  end
  for index, handler in ipairs(self.notificationHandlers) do
    handler:Disconnect()
  end
  self.notificationHandlers = nil
  EntityRegistrar:UnregisterEntity(self)
end
function Woody:LoadNode(nodeName)
  UiTextBus.Event.SetText(self.Properties.NodeName, nodeName)
  local children, childrenNames
  if nodeName == "" then
    childrenNames = {
      "Hud",
      "MainMenu",
      "Map",
      "UIFeatures",
      "GameMode"
    }
    children = {}
    for i, name in ipairs(childrenNames) do
      table.insert(children, DataLayer:GetDataNode(name))
    end
  else
    local node = DataLayer:GetDataNode(nodeName)
    if not node then
      return
    end
    children = node:GetChildren()
    if #children == 0 then
      return
    end
    childrenNames = node:GetChildrenNames()
  end
  local sortedChildren = {}
  for i, child in ipairs(children) do
    table.insert(sortedChildren, {
      child = child,
      name = childrenNames[i]
    })
  end
  table.sort(sortedChildren, function(a, b)
    return string.lower(a.name) < string.lower(b.name)
  end)
  self.items = {}
  for i, childPair in ipairs(sortedChildren) do
    local grandchildren = childPair.child:GetChildren()
    local value = ""
    local expandable = false
    if #grandchildren == 0 then
      value = tostring(childPair.child:GetData())
    else
      value = "{}"
      expandable = true
    end
    table.insert(self.items, {
      index = i,
      expandable = expandable,
      name = childPair.name,
      varType = "",
      value = value,
      cb = self.OnItemClicked,
      context = self
    })
  end
  self.ItemsList:OnListDataSet(self.items)
  table.insert(self.dataStack, nodeName)
end
function Woody:LoadTable(name, t)
  local nodeName = ""
  for i, context in ipairs(self.watchStack) do
    nodeName = nodeName .. context.k .. "."
  end
  nodeName = nodeName .. name
  UiTextBus.Event.SetText(self.Properties.NodeName, nodeName)
  local context = {k = name, v = t}
  if type(t) ~= "table" then
    return
  end
  self.watchKeys = {}
  self.childEntitiesToKeys = {}
  for k, v in pairs(t) do
    table.insert(self.watchKeys, k)
  end
  table.sort(self.watchKeys, function(a, b)
    return string.lower(a) < string.lower(b)
  end)
  self.items = {}
  for i, key in ipairs(self.watchKeys) do
    table.insert(self.items, {
      index = i,
      name = key,
      varType = type(t[key]),
      expandable = type(t[key]) == "table",
      value = tostring(t[key]),
      cb = self.OnItemClicked,
      context = self
    })
  end
  self.ItemsList:OnListDataSet(self.items)
  self.watchStack[#self.watchStack + 1] = context
end
function Woody:OnItemClicked(item)
  if self.showDataLayer then
    local valueName = item.itemData.value
    local currentLevel = self.dataStack[#self.dataStack]
    local newNodeName = item.itemData.name
    if string.len(currentLevel) > 0 then
      newNodeName = currentLevel .. "." .. item.itemData.name
    end
    if valueName == "{}" then
      self:LoadNode(newNodeName)
    end
  else
    local context = self.watchStack[#self.watchStack]
    local key = item.itemData.name
    local newTable = context.v[key]
    if type(newTable) ~= "table" then
      return
    end
    self:LoadTable(tostring(key), newTable)
  end
end
function Woody:OnBack(entityId, action)
  if self.showDataLayer then
    if #self.dataStack <= 1 then
      return
    end
    table.remove(self.dataStack)
    local nodeName = table.remove(self.dataStack)
    self:LoadNode(nodeName)
  else
    if 1 >= #self.watchStack then
      return
    end
    table.remove(self.watchStack)
    local context = table.remove(self.watchStack)
    self:LoadTable(context.k, context.v)
  end
end
function Woody:OnRefresh(entityId, action)
  if self.showDataLayer and #self.dataStack >= 1 then
    local nodeName = table.remove(self.dataStack)
    self:LoadNode(nodeName)
  else
  end
end
function Woody:OnCloseWoody(entityId, action)
  LyShineManagerBus.Broadcast.TryHideById(self.canvasId)
end
function Woody:OnToggleContent(entityId, action)
  if self.showDataLayer then
    self.showDataLayer = false
    if #self.watchStack >= 1 then
      local context = table.remove(self.watchStack)
      self:LoadTable(context.k, context.v)
    else
      self:LoadTable("g_watchedVariables", g_watchedVariables)
    end
  else
    self.showDataLayer = true
    if 1 <= #self.dataStack then
      local nodeName = table.remove(self.dataStack)
      self:LoadNode(nodeName)
    else
      self:LoadNode("")
    end
  end
  UiTextBus.Event.SetText(self.Properties.TitleElement, self.showDataLayer and "DataLayer" or "Watch Variables")
end
function Woody:OnSlashWoody(args)
  if 2 <= #args then
    local root = args[2]
    self.dataStack = {}
    self:LoadNode(root)
  end
  LyShineManagerBus.Broadcast.TryShowById(self.canvasId)
  UiTextBus.Event.SetText(self.Properties.TitleElement, self.showDataLayer and "DataLayer" or "Watch Variables")
end
return Woody
