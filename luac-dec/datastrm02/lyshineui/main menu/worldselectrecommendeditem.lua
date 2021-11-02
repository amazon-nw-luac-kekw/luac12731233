local WorldSelectRecommendedItem = {
  Properties = {
    Region = {
      default = EntityId()
    },
    RegionPingIcon = {
      default = EntityId()
    },
    WorldName = {
      default = EntityId()
    },
    WorldSet = {
      default = EntityId()
    },
    WorldSetTooltip = {
      default = EntityId()
    },
    OnlineFriendIcon = {
      default = EntityId()
    },
    OnlineFriendName = {
      default = EntityId()
    },
    OnlineFriendText = {
      default = EntityId()
    },
    OnlineFriendNoData = {
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
    ListItemBg = {
      default = EntityId()
    }
  },
  POPULATION_LOW = 0,
  POPULATION_MED = 1,
  POPULATION_HIGH = 2,
  callback = nil,
  callbackTable = nil,
  worldInfo = nil,
  worldNameInitWidth = 290,
  isSelected = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WorldSelectRecommendedItem)
local bitHelpers = RequireScript("LyShineUI._Common.BitwiseHelpers")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WorldSelectRecommendedItem:OnInit()
  BaseElement.OnInit(self)
  self.WorldSetTooltip:SetButtonStyle(self.WorldSetTooltip.BUTTON_STYLE_QUESTION_MARK)
  self.WorldSetTooltip:SetTooltip("@world_set_desc")
end
function WorldSelectRecommendedItem:SetCallback(command, table)
  self.callback = command
  self.callbackTable = table
end
function WorldSelectRecommendedItem:GetWorldId()
  if self.worldInfo then
    return self.worldInfo.worldData.worldId
  else
    return nil
  end
end
function WorldSelectRecommendedItem:SetWorldInfo(worldInfo)
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
  self.dataLayer:OnChange(self, "UIFeatures.showQueueTimes", function(self, showQueueTimeDataNode)
    if showQueueTimeDataNode then
      local showQueueTime = showQueueTimeDataNode:GetData()
      UiElementBus.Event.SetIsEnabled(self.Properties.QueueTime, showQueueTime)
    end
  end)
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
    local textWidth = UiTextBus.Event.GetTextWidth(self.Properties.WorldSet)
    local textPadding = 15
    self.ScriptedEntityTweener:Set(self.Properties.WorldSetTooltip, {
      x = textWidth + textPadding
    })
  end
  if self.Properties.OnlineFriendText:IsValid() then
    if worldInfo.numFriends and 0 < worldInfo.numFriends then
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendNoData, false)
      self.ScriptedEntityTweener:Set(self.Properties.WorldName, {
        w = self.worldNameInitWidth
      })
      self.ScriptedEntityTweener:Set(self.Properties.WorldSet, {
        w = self.worldNameInitWidth
      })
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendName, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendText, true)
      local friendsText = "@ui_world_select_one_friends_online"
      if worldInfo.numFriends > 1 then
        friendsText = GetLocalizedReplacementText("@ui_world_select_more_friends_online", {
          friendCount = worldInfo.numFriends
        })
      end
      UiTextBus.Event.SetTextWithFlags(self.Properties.OnlineFriendText, friendsText, eUiTextSet_SetLocalized)
      local friendId
      local friendName = ""
      local worldIdToFriends = GameRequestsBus.Broadcast.GetSteamPresenceFriendsWorldInfo()
      for i = 1, #worldIdToFriends do
        local worldId = worldIdToFriends[i].worldId
        if worldId == self.worldInfo.worldData.worldId then
          friendName = worldIdToFriends[i].friendName
          friendId = worldIdToFriends[i].friendSteamId
          break
        end
      end
      UiTextBus.Event.SetText(self.Properties.OnlineFriendName, friendName)
      if friendId then
        UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendIcon, true)
        self.dataLayer:Call(1404682658, self.Properties.OnlineFriendIcon, friendId)
      end
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendNoData, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendName, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.OnlineFriendIcon, false)
      local textWidthOffset = 300
      self.ScriptedEntityTweener:Set(self.Properties.WorldName, {
        w = self.worldNameInitWidth + textWidthOffset
      })
      self.ScriptedEntityTweener:Set(self.Properties.WorldSet, {
        w = self.worldNameInitWidth + textWidthOffset
      })
    end
  end
end
function WorldSelectRecommendedItem:UpdateWorldName()
  UiTextBus.Event.SetTextWithFlags(self.Properties.WorldName, tostring(self.worldInfo.worldData.name), eUiTextSet_SetAsIs)
end
function WorldSelectRecommendedItem:SetRegionPing(value)
  UiImageBus.Event.SetSpritePathname(self.Properties.RegionPingIcon, value)
end
function WorldSelectRecommendedItem:SetRegionText(value)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Region, value, eUiTextSet_SetLocalized)
end
function WorldSelectRecommendedItem:OnSelected()
  if not self.isSelected then
    self.isSelected = true
    self.ListItemBg:OnFocus()
  end
end
function WorldSelectRecommendedItem:OnUnselected()
  self.isSelected = false
  self.ListItemBg:OnUnfocus()
end
function WorldSelectRecommendedItem:OnFocus()
  self.ListItemBg:OnFocus()
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnServerSelectHover)
end
function WorldSelectRecommendedItem:OnUnfocus()
  if self.isSelected then
    self.ListItemBg:OnFocus()
  else
    self.ListItemBg:OnUnfocus()
  end
end
function WorldSelectRecommendedItem:OnPress()
  if type(self.callback) == "function" and self.callbackTable ~= nil then
    self.callback(self.callbackTable, self:GetWorldId())
  end
  self:OnSelected()
end
return WorldSelectRecommendedItem
