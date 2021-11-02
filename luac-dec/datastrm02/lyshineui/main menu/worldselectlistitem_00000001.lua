local WorldSelectListItem = {
  Properties = {
    WorldName = {
      default = EntityId()
    },
    WorldSet = {
      default = EntityId()
    },
    CharacterName = {
      default = EntityId()
    },
    OnlineFriendCount = {
      default = EntityId()
    },
    OnlineFriendIcon = {
      default = EntityId()
    },
    QueueTime = {
      default = EntityId()
    },
    QueueSize = {
      default = EntityId()
    },
    Population = {
      default = EntityId()
    },
    ButtonScrim = {
      default = EntityId()
    },
    ListItemBg = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  POPULATION_LOW = 0,
  POPULATION_MED = 1,
  POPULATION_HIGH = 2,
  isDisabled = false,
  isServerDown = false,
  isServerMessageVisible = false,
  worldInfo = nil,
  tickBusHandler = nil,
  timeRemainingSeconds = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WorldSelectListItem)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WorldSelectListItem:OnInit()
  BaseElement.OnInit(self)
end
function WorldSelectListItem:GetWorldId()
  if self.worldInfo then
    return self.worldInfo.worldData.worldId
  else
    return nil
  end
end
function WorldSelectListItem:SetWorldInfo(worldInfo)
  self.worldInfo = worldInfo
  self:UpdateWorldName()
  local populationStatus = "@ui_population_low"
  local populationColor = self.UIStyle.COLOR_POPULATION_LOW
  if self.worldInfo.population == self.POPULATION_MED then
    populationStatus = "@ui_population_med"
    populationColor = self.UIStyle.COLOR_POPULATION_MEDIUM
  elseif self.worldInfo.population == self.POPULATION_HIGH then
    populationStatus = "@ui_population_high"
    populationColor = self.UIStyle.COLOR_POPULATION_HIGH
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Population, populationStatus, eUiTextSet_SetLocalized)
  self.ScriptedEntityTweener:Set(self.Properties.Population, {textColor = populationColor})
  if self.worldInfo.mergeTime > 0 then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  elseif self.tickHandler ~= nil then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self.isAtCharacterLimit = self.worldInfo.characterCount >= self.worldInfo.worldData.maxAccountCharacters
  self:SetIsSelectable(not self.isAtCharacterLimit)
  self:SetStatus(self.worldInfo.worldData.status, self.worldInfo.worldData.publicStatusCode)
  self:UpdateMergeTimer()
  if self.Properties.QueueTime:IsValid() then
    self.dataLayer:OnChange(self, "UIFeatures.showQueueTimes", function(self, showQueueTimeDataNode)
      if showQueueTimeDataNode then
        local showQueueTime = showQueueTimeDataNode:GetData()
        UiElementBus.Event.SetIsEnabled(self.Properties.QueueTime, showQueueTime)
      end
    end)
    local queueWaitTimeSec = self.worldInfo.worldData.worldMetrics.queueWaitTimeSec
    local isUnknownQueueWaitTime = queueWaitTimeSec <= 0
    local timeToWait
    if 0 < queueWaitTimeSec then
      timeToWait = timeHelpers:ConvertToShorthandString(queueWaitTimeSec, false, true)
    elseif isUnknownQueueWaitTime then
      timeToWait = "@ui_unknown"
    end
    local waitTime
    if timeToWait then
      waitTime = timeToWait
    else
      waitTime = "-"
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.QueueTime, waitTime, eUiTextSet_SetLocalized)
  end
  if self.Properties.QueueSize:IsValid() then
    local queueSize = self.worldInfo.worldData.worldMetrics.queueSize
    UiTextBus.Event.SetTextWithFlags(self.Properties.QueueSize, 0 < queueSize and queueSize or 0, eUiTextSet_SetLocalized)
  end
  if self.Properties.WorldSet:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSet, self.worldInfo.worldSetName, eUiTextSet_SetLocalized)
  end
  if self.Properties.CharacterName:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CharacterName, worldInfo.characterName and worldInfo.characterName or "-", eUiTextSet_SetLocalized)
  end
  if self.Properties.OnlineFriendCount:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.OnlineFriendCount, worldInfo.numFriends and worldInfo.numFriends or "-", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendIcon, worldInfo.numFriends and 0 < worldInfo.numFriends)
  end
end
function WorldSelectListItem:OnTick(deltaTime, timePoint)
  self:UpdateMergeTimer()
end
function WorldSelectListItem:UpdateMergeTimer()
  if not self.isServerMessageVisible and self.worldInfo.mergeTime > 0 then
    local now = os.time()
    if now < self.worldInfo.mergeTime then
      local timeRemainingSeconds = self.worldInfo.mergeTime - now
      if timeRemainingSeconds ~= self.timeRemainingSeconds then
        self.timeRemainingSeconds = timeRemainingSeconds
        local timeUntilMergeText = timeHelpers:ConvertToShorthandString(timeRemainingSeconds, false)
        local mergeMessage = GetLocalizedReplacementText("@ui_mergewarning_short", {timeRemaining = timeUntilMergeText})
        UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSet, tostring(self.worldInfo.worldSetName) .. " - " .. mergeMessage, eUiTextSet_SetAsIs)
      end
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSet, tostring(self.worldInfo.worldSetName), eUiTextSet_SetAsIs)
    end
  end
end
function WorldSelectListItem:UpdateWorldName()
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldName, tostring(self.worldInfo.worldData.name), eUiTextSet_SetAsIs)
end
function WorldSelectListItem:SetEnabled(enabled)
  local maintenanceBypass = LyShineScriptBindRequestBus.Broadcast.IsMaintenanceBypass()
  if maintenanceBypass then
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, true)
    return
  end
  if not self.isDisabled then
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enabled)
  else
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, false)
  end
end
function WorldSelectListItem:SetStatus(status, publicStatus)
  self.isDisabled = status ~= "ACTIVE" or bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DISABLED)
  self:SetEnabled(not self.isDisabled)
  self.isServerDown = bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
  self.isCharacterCreationDisabled = bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_CHARACTERCREATIONDISABLED)
  self.isServerMessageVisible = self.isDisabled or self.isServerDown or self.isAtCharacterLimit or self.isCharacterCreationDisabled
  local scrimDisabledAlpha = self.isServerMessageVisible and 0.5 or 0
  local serverMessageColor = self.UIStyle.COLOR_WHITE
  local characterMessageColor = self.UIStyle.COLOR_WHITE
  local serverMessage = tostring(self.worldInfo.worldData.name)
  if self.isDisabled then
    serverMessage = tostring(self.worldInfo.worldData.name) .. " - " .. "@mm_serverdisabled"
    serverMessageColor = self.UIStyle.COLOR_RED
  elseif self.isServerDown then
    serverMessage = tostring(self.worldInfo.worldData.name) .. " - " .. "@mm_serverdown"
    serverMessageColor = self.UIStyle.COLOR_YELLOW
  elseif self.isCharacterCreationDisabled then
    serverMessageColor = self.UIStyle.COLOR_YELLOW
  end
  if self.isAtCharacterLimit then
    serverMessageColor = self.UIStyle.COLOR_RED
    characterMessageColor = self.UIStyle.COLOR_RED
    self:SetTooltip("@mm_world_character_limit")
  elseif self.isCharacterCreationDisabled then
    self:SetTooltip("@mm_characterCreateDisabled")
  else
    self:SetTooltip("")
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldName, serverMessage, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.WorldName, serverMessageColor)
  UiTextBus.Event.SetColor(self.Properties.CharacterName, characterMessageColor)
  self.ScriptedEntityTweener:Set(self.Properties.ButtonScrim, {opacity = scrimDisabledAlpha})
end
function WorldSelectListItem:GetIsServerDown()
  return self.isServerDown
end
function WorldSelectListItem:SetTooltip(value)
  if value == nil or value == "" then
    self.isUsingTooltip = false
    UiElementBus.Event.SetIsEnabled(self.Properties.TooltipSetter, false)
  else
    self.isUsingTooltip = true
    self.TooltipSetter:SetSimpleTooltip(value)
    UiElementBus.Event.SetIsEnabled(self.Properties.TooltipSetter, true)
  end
end
function WorldSelectListItem:OnFocus()
  if self.isUsingTooltip then
    self.TooltipSetter:OnTooltipSetterHoverStart()
  end
  self.ListItemBg:OnFocus(true)
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnServerSelectHover)
end
function WorldSelectListItem:OnUnfocus()
  if self.isUsingTooltip then
    self.TooltipSetter:OnTooltipSetterHoverEnd()
  end
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState == true and self.isSelectable then
    self:OnSelected()
  else
    self:OnUnselected()
  end
end
function WorldSelectListItem:OnSelected()
  if not self.isSelectable then
    return
  end
  self.ListItemBg:OnFocus()
end
function WorldSelectListItem:OnUnselected()
  self.ListItemBg:OnUnfocus()
end
function WorldSelectListItem:SetIsSelectable(isSelectable)
  if self.isAtCharacterLimit then
    self.isSelectable = false
  else
    self.isSelectable = isSelectable
  end
  self:OnUnfocus()
end
function WorldSelectListItem:GetIsSelectable()
  return self.isSelectable
end
function WorldSelectListItem:OnShutdown()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
return WorldSelectListItem
