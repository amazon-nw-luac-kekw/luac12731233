local FlyoutRow_Options = {
  Properties = {
    Header1 = {
      default = EntityId()
    },
    Header2 = {
      default = EntityId()
    },
    Header3 = {
      default = EntityId()
    },
    OptionsContainer1 = {
      default = EntityId()
    },
    OptionsContainer2 = {
      default = EntityId()
    },
    OptionsContainer3 = {
      default = EntityId()
    },
    OptionsCache = {
      default = EntityId()
    },
    UseCircularPositioning = {default = false},
    CircularRing = {
      default = EntityId()
    }
  },
  spawnCount = 0,
  context = nil,
  optionSlice = "",
  USE_HOTKEYS = false,
  circularOffset = 45
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_Options)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(FlyoutRow_Options)
function FlyoutRow_Options:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.OptionsContainer1)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.OptionsContainer2)
  self:BusConnect(UiSpawnerNotificationBus, self.Properties.OptionsContainer3)
  self:BusConnect(UiCanvasNotificationBus, self.canvasId)
  self.options = {}
  self.optionSlice = self.USE_HOTKEYS and "LyShineUI\\FlyoutMenu\\FlyoutMenuOption" or "LyShineUI\\FlyoutMenu\\FlyoutMenuOptionNoHint"
  self.blockUIInput = self.USE_HOTKEYS
  if self.Properties.UseCircularPositioning then
    self.optionsSlice = "LyShineUI\\FlyoutMenu\\FlyoutMenuOptionCircular"
  end
  self.cachedElements = {}
  local childElements = UiElementBus.Event.GetChildren(self.Properties.OptionsCache)
  for i = 1, #childElements do
    table.insert(self.cachedElements, self.registrar:GetEntityTable(childElements[i]))
  end
  childElements = UiElementBus.Event.GetChildren(self.Properties.OptionsContainer1)
  if childElements then
    for i = 1, #childElements do
      table.insert(self.cachedElements, self.registrar:GetEntityTable(childElements[i]))
      UiElementBus.Event.Reparent(childElements[i], self.Properties.OptionsCache, EntityId())
    end
  end
  childElements = UiElementBus.Event.GetChildren(self.Properties.OptionsContainer2)
  if childElements then
    for i = 1, #childElements do
      table.insert(self.cachedElements, self.registrar:GetEntityTable(childElements[i]))
      UiElementBus.Event.Reparent(childElements[i], self.Properties.OptionsCache, EntityId())
    end
  end
  childElements = UiElementBus.Event.GetChildren(self.Properties.OptionsContainer3)
  if childElements then
    for i = 1, #childElements do
      table.insert(self.cachedElements, self.registrar:GetEntityTable(childElements[i]))
      UiElementBus.Event.Reparent(childElements[i], self.Properties.OptionsCache, EntityId())
    end
  end
  SetTextStyle(self.Properties.Header1, self.UIStyle.FONT_STYLE_TOOLTIP_ACTIONS_HEADER)
  SetTextStyle(self.Properties.Header2, self.UIStyle.FONT_STYLE_TOOLTIP_ACTIONS_HEADER)
  SetTextStyle(self.Properties.Header3, self.UIStyle.FONT_STYLE_TOOLTIP_ACTIONS_HEADER)
end
function FlyoutRow_Options:OnShutdown()
  if self.USE_HOTKEYS then
    for actionName, optionData in pairs(self.options) do
      self:BusDisconnect(optionData.handler, actionName)
    end
  end
  self.options = nil
end
function FlyoutRow_Options:OnCryAction(action)
  if self.USE_HOTKEYS then
    local optionData = self.options[action]
    if optionData and optionData.entity:IsHandlingEvents() and optionData.callback and self.context then
      optionData.callback(self.context, optionData.callbackData)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
  end
end
function FlyoutRow_Options:OnAction(entityId, action)
  local canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  local canvasEnabled = UiCanvasBus.Event.GetEnabled(canvasId)
  local isStillEnabled = UiElementBus.Event.GetAreElementAndAncestorsEnabled(self.entityId)
  if not canvasEnabled or not isStillEnabled then
    return
  end
  local optionData = self.options[action]
  if optionData and optionData.entity:IsHandlingEvents() and optionData.callback and self.context then
    optionData.callback(self.context, optionData.callbackData)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    self.audioHelper:PlaySound(self.audioHelper.Accept)
  end
end
function FlyoutRow_Options:SetData(data)
  if not (data and (data.options or data.sections)) or not data.context then
    Log("[FlyoutRow_Options] Error: invalid data passed to SetData()")
    return
  end
  for i = 1, 3 do
    local container = self.Properties["OptionsContainer" .. i]
    local childElements = UiElementBus.Event.GetChildren(container)
    if childElements then
      for j = 1, #childElements do
        local element = self.registrar:GetEntityTable(childElements[j])
        if element then
          table.insert(self.cachedElements, element)
        else
          table.insert(self.cachedElements, childElements[j])
        end
        UiElementBus.Event.Reparent(childElements[j], self.Properties.OptionsCache, EntityId())
      end
    end
  end
  ClearTable(self.options)
  self.optionsRowActionSuffix = data.optionsRowActionSuffix ~= nil and data.optionsRowActionSuffix or ""
  self.useClickBehavior = data.useClickBehavior == true
  self.context = data.context
  if data.options then
    self.spawnCount = #data.options
    for i = 1, self.spawnCount do
      local optionData = data.options[i]
      self:AddOption(optionData, self.Properties.OptionsContainer1)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Header1, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Header2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Header3, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer1, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer3, false)
  else
    self.spawnCount = 0
    for i = 1, #data.sections do
      if data.sections[i].options then
        self.spawnCount = self.spawnCount + #data.sections[i].options
      end
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Header1, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Header2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.Header3, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer1, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer2, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.OptionsContainer3, false)
    for i = 1, #data.sections do
      local options = data.sections[i].options
      if options and 0 < #options then
        local header = self.Properties["Header" .. i]
        local container = self.Properties["OptionsContainer" .. i]
        local headerText = data.sections[i].title
        UiElementBus.Event.SetIsEnabled(header, headerText and headerText ~= "")
        UiTextBus.Event.SetTextWithFlags(header, headerText, eUiTextSet_SetLocalized)
        UiElementBus.Event.SetIsEnabled(container, true)
        for j = 1, #options do
          local optionData = options[j]
          self:AddOption(optionData, container)
        end
      end
    end
  end
end
function FlyoutRow_Options:SetRowHeightCallback(command, table)
  self.rowHeightCallback = command
  self.rowHeightCallbackSelf = table
end
function FlyoutRow_Options:AddOption(optionData, container)
  optionData.container = container
  if #self.cachedElements > 0 then
    local element = table.remove(self.cachedElements)
    local elementEntityId = element
    if type(element) == "table" then
      elementEntityId = element.entityId
    end
    UiElementBus.Event.Reparent(elementEntityId, container, EntityId())
    self:OnOptionSpawned(element, optionData)
  else
    Log("Spawning slice %s in FlyoutRow_Options. Add more elements to the cache to prevent spawning", self.optionSlice)
    self:SpawnSlice(container, self.optionSlice, self.OnOptionSpawned, optionData)
  end
end
function FlyoutRow_Options:OnOptionSpawned(entity, optionData)
  local container = optionData.container
  local childIndex = UiElementBus.Event.GetIndexOfChildByEntityId(container, entity.entityId)
  local actionName = string.format("%s-%s-action-%d%s", tostring(container), self.Properties.UseCircularPositioning and "c" or "", childIndex + 1, self.optionsRowActionSuffix)
  self.options[actionName] = {
    callback = optionData.callback,
    callbackData = optionData.data,
    entity = entity,
    index = childIndex
  }
  optionData.actionName = actionName
  optionData.callbackTable = self.context
  entity:SetData(optionData, self.USE_HOTKEYS, self.Properties.UseCircularPositioning)
  UiButtonBus.Event.SetUseClickBehavior(entity.entityId, self.useClickBehavior)
  if self.USE_HOTKEYS then
    local cryActionHandler = self:BusConnect(CryActionNotificationsBus, actionName)
    self.options[actionName].handler = cryActionHandler
  end
  self.spawnCount = self.spawnCount - 1
  if self.spawnCount == 0 then
    self:UpdateSize()
  end
end
function FlyoutRow_Options:UpdateSize()
  local optionsHeight = 0
  if self.Properties.UseCircularPositioning then
    local numOptions = CountAssociativeTable(self.options)
    local angleDiff = 360 / numOptions
    local startingAngle = 90 + angleDiff
    local highestY = 0
    local lowestY = 0
    for _, data in pairs(self.options) do
      local anglePos = startingAngle + data.index * angleDiff
      local pos = Vector2(math.cos(math.rad(anglePos)) * self.circularOffset, math.sin(math.rad(anglePos)) * self.circularOffset)
      highestY = math.max(highestY, pos.y)
      lowestY = math.min(lowestY, pos.y)
      UiTransformBus.Event.SetLocalPosition(data.entity.entityId, pos)
    end
    optionsHeight = highestY - lowestY
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, optionsHeight)
    UiElementBus.Event.SetIsEnabled(self.Properties.CircularRing, true)
  else
    for i = 1, 3 do
      local header = self.Properties["Header" .. i]
      local container = self.Properties["OptionsContainer" .. i]
      if UiElementBus.Event.IsEnabled(header) then
        UiTransformBus.Event.SetLocalPositionY(header, optionsHeight)
        optionsHeight = optionsHeight + UiTransform2dBus.Event.GetLocalHeight(header)
      end
      if UiElementBus.Event.IsEnabled(container) then
        UiTransformBus.Event.SetLocalPositionY(container, optionsHeight)
        local numChildren = UiElementBus.Event.GetNumChildElements(container)
        local width = UiTransform2dBus.Event.GetLocalWidth(container)
        local padding = UiLayoutGridBus.Event.GetPadding(container)
        local spacing = UiLayoutGridBus.Event.GetSpacing(container)
        local cellSize = UiLayoutGridBus.Event.GetCellSize(container)
        local numPerRow = (width - padding.left - padding.right + spacing.x) / (cellSize.x + spacing.x)
        local numRows = math.ceil(numChildren / numPerRow)
        local sectionHeight = padding.top + cellSize.y * numRows + spacing.y * (numRows - 1) + padding.bottom
        optionsHeight = optionsHeight + sectionHeight
      end
    end
    UiLayoutCellBus.Event.SetTargetHeight(self.entityId, optionsHeight)
  end
  if self.rowHeightCallback and self.rowHeightCallbackSelf and type(self.rowHeightCallback) == "function" then
    self.rowHeightCallback(self.rowHeightCallbackSelf, optionsHeight)
  end
end
return FlyoutRow_Options
