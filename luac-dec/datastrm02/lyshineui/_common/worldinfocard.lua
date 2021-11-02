local WorldInfoCard = {
  Properties = {
    ServerName = {
      default = EntityId()
    },
    LastPlayed = {
      default = EntityId()
    },
    ServerPopulation = {
      default = EntityId()
    },
    ServerDownMessage = {
      default = EntityId()
    },
    ServerDownIcon = {
      default = EntityId()
    },
    ServerImage = {
      default = EntityId()
    },
    ButtonFrame = {
      default = EntityId()
    },
    ButtonFocus = {
      default = EntityId()
    },
    ButtonGlow = {
      default = EntityId()
    },
    ButtonScrim = {
      default = EntityId()
    },
    QueueTime = {
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
    }
  },
  focusColor = nil,
  unfocusColor = nil,
  disabledColor = nil,
  isDisabled = false,
  isServerDown = false,
  isServerMessageVisible = false,
  textDisabledAlpha = 0.5,
  imagePathRoot = "lyshineui/images/landingscreen/serverimage/serverImageSmall",
  POPULATION_LOW = 0,
  POPULATION_MED = 1,
  POPULATION_HIGH = 2,
  worldInfo = nil,
  tickBusHandler = nil,
  timeRemainingSeconds = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WorldInfoCard)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WorldInfoCard:OnInit()
  BaseElement.OnInit(self)
  self.focusColor = self.UIStyle.COLOR_WHITE
  self.unfocusColor = self.UIStyle.COLOR_TAN
  self.disabledColor = self.UIStyle.COLOR_TAN
  UiTextBus.Event.SetColor(self.Properties.ServerName, self.unfocusColor)
  UiTextBus.Event.SetColor(self.Properties.LastPlayed, self.unfocusColor)
  UiTextBus.Event.SetColor(self.Properties.ServerPopulation, self.unfocusColor)
end
function WorldInfoCard:OnShutdown()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function WorldInfoCard:GetWorldId()
  if self.worldInfo then
    return self.worldInfo.worldData.worldId
  else
    return nil
  end
end
function WorldInfoCard:SetWorldInfo(worldInfo)
  self.worldInfo = worldInfo
  self:UpdateWorldName()
  local playerStatus = "@ui_population_low"
  if self.worldInfo.population == self.POPULATION_MED then
    playerStatus = "@ui_population_med"
  elseif self.worldInfo.population == self.POPULATION_HIGH then
    playerStatus = "@ui_population_high"
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerPopulation, playerStatus, eUiTextSet_SetLocalized)
  if self.LastPlayed:IsValid() then
    if self.worldInfo.lastPlayed == nil or self.worldInfo.lastPlayed == 0 then
      UiTextBus.Event.SetTextWithFlags(self.Properties.LastPlayed, "-", eUiTextSet_SetLocalized)
    else
      local timestring = timeHelpers:ConvertToLargestTimeEstimate(self.worldInfo.lastPlayed, true)
      UiTextBus.Event.SetTextWithFlags(self.Properties.LastPlayed, timestring, eUiTextSet_SetLocalized)
    end
  end
  if self.worldInfo.imageId then
    local imagePath = self.imagePathRoot .. self.worldInfo.imageId .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.ServerImage, imagePath)
  end
  if 0 < self.worldInfo.mergeTime then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  elseif self.tickHandler ~= nil then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
  self:SetStatus(self.worldInfo.worldData.status, self.worldInfo.worldData.publicStatusCode)
  self:UpdateMergeTimer()
  if self.Properties.QueueTime:IsValid() then
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
      waitTime = GetLocalizedReplacementText("@ui_expected_wait_time", {time = timeToWait})
    else
      waitTime = "-"
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.QueueTime, waitTime, eUiTextSet_SetAsIs)
  end
  if self.Properties.WorldSet:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.WorldSet, self.worldInfo.worldSetName, eUiTextSet_SetLocalized)
  end
  if self.Properties.CharacterName:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.CharacterName, worldInfo.characterName, eUiTextSet_SetLocalized)
  end
  if self.Properties.OnlineFriendCount:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.OnlineFriendCount, worldInfo.numFriends and worldInfo.numFriends or 0, eUiTextSet_SetLocalized)
  end
end
function WorldInfoCard:OnTick(deltaTime, timePoint)
  self:UpdateMergeTimer()
end
function WorldInfoCard:UpdateMergeTimer()
  local serverNameoffsetPosY = (self.isServerMessageVisible or self.worldInfo.mergeTime > 0) and -8 or 0
  self.ScriptedEntityTweener:Set(self.Properties.ServerName, {y = serverNameoffsetPosY})
  if not self.isServerMessageVisible and self.worldInfo.mergeTime > 0 then
    local now = os.time()
    if now < self.worldInfo.mergeTime then
      local timeRemainingSeconds = self.worldInfo.mergeTime - now
      if timeRemainingSeconds ~= self.timeRemainingSeconds then
        self.timeRemainingSeconds = timeRemainingSeconds
        local timeUntilMergeText = timeHelpers:ConvertToShorthandString(timeRemainingSeconds, false)
        local mergeMessage = GetLocalizedReplacementText("@ui_mergewarning_short", {timeRemaining = timeUntilMergeText})
        UiElementBus.Event.SetIsEnabled(self.Properties.ServerDownMessage, true)
        UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.ServerDownMessage, eUiHAlign_Left)
        self.ScriptedEntityTweener:Set(self.Properties.ServerDownMessage, {opacity = 1, x = 0})
        UiTextBus.Event.SetTextWithFlags(self.Properties.ServerDownMessage, mergeMessage, eUiTextSet_SetAsIs)
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.ServerDownMessage, false)
    end
  end
end
function WorldInfoCard:UpdateWorldName()
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerName, tostring(self.worldInfo.worldData.name), eUiTextSet_SetAsIs)
end
function WorldInfoCard:SetEnabled(enabled)
  if not self.isDisabled then
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, enabled)
  else
    UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, false)
  end
end
function WorldInfoCard:SetStatus(status, publicStatus)
  self.isDisabled = status ~= "ACTIVE" or bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DISABLED)
  self:SetEnabled(not self.isDisabled)
  self.isServerDown = bitHelpers:TestFlag(publicStatus, bitHelpers.SERVERSTATUS_DOWNFORMAINTENANCE)
  self.isServerMessageVisible = self.isDisabled or self.isServerDown
  local isPopulationVisible = not self.isServerMessageVisible
  local scrimDisabledAlpha = self.isServerMessageVisible and 0.8 or 0
  local textDisabledAlpha = self.isServerMessageVisible and self.textDisabledAlpha or 1
  local serverMessageColor = self.UIStyle.COLOR_WHITE
  local serverMessage = ""
  if self.isDisabled then
    serverMessage = "@mm_serverdisabled"
    serverMessageColor = self.UIStyle.COLOR_RED
  elseif self.isServerDown then
    serverMessage = "@mm_serverdown"
    serverMessageColor = self.UIStyle.COLOR_YELLOW
  end
  local serverDownOffsetX = 0
  local serverDownAlignment = eUiHAlign_Left
  local isLastPlayedVisible = true
  if self.isServerMessageVisible then
    serverDownOffsetX = 180
    serverDownAlignment = eUiHAlign_Right
    isLastPlayedVisible = false
  end
  UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.ServerDownMessage, serverDownAlignment)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ServerDownMessage, serverMessage, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.ServerDownMessage, serverMessageColor)
  UiImageBus.Event.SetColor(self.Properties.ServerDownIcon, serverMessageColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerDownMessage, self.isServerMessageVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerDownIcon, self.isServerMessageVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.ServerPopulation, isPopulationVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.LastPlayed, isLastPlayedVisible)
  self.ScriptedEntityTweener:Set(self.Properties.ServerName, {opacity = textDisabledAlpha})
  self.ScriptedEntityTweener:Set(self.Properties.ServerDownMessage, {opacity = textDisabledAlpha, x = serverDownOffsetX})
  self.ScriptedEntityTweener:Set(self.Properties.ButtonScrim, {opacity = scrimDisabledAlpha})
end
function WorldInfoCard:GetIsServerDown()
  return self.isServerDown
end
function WorldInfoCard:OnFocus()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ServerName, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.Properties.LastPlayed, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.Properties.ServerDownMessage, animDuration, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.ServerPopulation, animDuration, {
    textColor = self.focusColor
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ButtonGlow, 0.35, {opacity = 0.5})
    self.timeline:Add(self.Properties.ButtonGlow, 0.05, {opacity = 0.5})
    self.timeline:Add(self.Properties.ButtonGlow, 0.3, {
      opacity = 0.2,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.timeline:Play()
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnServerSelectHover)
end
function WorldInfoCard:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState == true then
    local animDuration = 0.15
    self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, animDuration, {opacity = 0.1})
  else
    self:OnUnselected()
  end
end
function WorldInfoCard:OnSelected()
  local animDuration = 0.15
  self.ScriptedEntityTweener:Play(self.Properties.ServerName, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.Properties.LastPlayed, animDuration, {
    textColor = self.focusColor,
    opacity = 1
  })
  self.ScriptedEntityTweener:Play(self.Properties.ServerDownMessage, animDuration, {opacity = 1})
  self.ScriptedEntityTweener:Play(self.Properties.ServerPopulation, animDuration, {
    textColor = self.focusColor
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, animDuration, {opacity = 0.8, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, animDuration, {opacity = 0.1, ease = "QuadIn"})
end
function WorldInfoCard:OnUnselected()
  local animDuration = 0.15
  local serverMessageAlpha = self.isServerMessageVisible and self.textDisabledAlpha or 1
  self.ScriptedEntityTweener:Play(self.Properties.ServerName, animDuration, {
    textColor = self.unfocusColor,
    opacity = serverMessageAlpha,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.LastPlayed, animDuration, {
    textColor = self.unfocusColor,
    opacity = serverMessageAlpha,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ServerDownMessage, animDuration, {opacity = serverMessageAlpha, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ServerPopulation, animDuration, {
    textColor = self.unfocusColor,
    ease = "QuadIn"
  })
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFrame, animDuration, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, animDuration, {opacity = 0, ease = "QuadIn"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonGlow, animDuration, {opacity = 0, ease = "QuadIn"})
end
function WorldInfoCard:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function WorldInfoCard:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function WorldInfoCard:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function WorldInfoCard:GetHorizontalSpacing()
  return 5
end
function WorldInfoCard:SetGridItemData(worldInfoData)
  self:SetWorldInfo(worldInfoData)
end
return WorldInfoCard
