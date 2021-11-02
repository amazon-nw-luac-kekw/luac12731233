local WarsTab = {
  Properties = {
    WarsList = {
      default = EntityId()
    },
    WarDisplay = {
      default = EntityId()
    },
    NoWarsMessageText = {
      default = EntityId()
    },
    CurrentTime = {
      default = EntityId()
    }
  },
  contentEntity = nil,
  warEntryHeight = 120,
  guildWars = {},
  lastTime = 0,
  noWarsDisplayOpacity = 0.2,
  SORT_TIME_ASCENDING = 1,
  SORT_TIME_DESCENDING = 2,
  SORT_NAME_ASCENDING = 3,
  SORT_NAME_DESCENDING = 4
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WarsTab)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function WarsTab:OnInit()
  BaseElement:OnInit(self)
  self.socialDataHandler = SocialDataHandler
  self.socialDataHandler:OnActivate()
  self.dataLayer = dataLayer
  self:BusConnect(UiDynamicScrollBoxDataBus, self.WarsList)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.WarsList)
  self.contentEntity = UiScrollBoxBus.Event.GetContentEntity(self.WarsList)
  self.warSortFunctions = {
    [self.SORT_TIME_ASCENDING] = function(first, second)
      local firstWarEndTime = first.warEndTime
      local secondWarEndTime = second.warEndTime
      if firstWarEndTime ~= secondWarEndTime then
        return firstWarEndTime < secondWarEndTime
      end
      return self.warSortFunctions[self.SORT_NAME_ASCENDING](first, second)
    end,
    [self.SORT_TIME_DESCENDING] = function(first, second)
      local firstWarEndTime = first.warEndTime
      local secondWarEndTime = second.warEndTime
      if firstWarEndTime ~= secondWarEndTime then
        return firstWarEndTime > secondWarEndTime
      end
      return self.warSortFunctions[self.SORT_NAME_ASCENDING](first, second)
    end,
    [self.SORT_NAME_ASCENDING] = function(first, second)
      return string.upper(first.guildName) < string.upper(second.guildName)
    end,
    [self.SORT_NAME_DESCENDING] = function(first, second)
      return string.upper(first.guildName) > string.upper(second.guildName)
    end
  }
  self.sortOption = self.SORT_TIME_ASCENDING
  self:SetWarData({})
end
function WarsTab:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.socialDataHandler:OnDeactivate()
end
function WarsTab:SetVisible(isVisible)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  self:SetTicking(isVisible)
end
function WarsTab:SetTicking(isTicking)
  if isTicking then
    if not self.tickHandler then
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function WarsTab:OnTick(delta, timePoint)
  local childList = UiElementBus.Event.GetChildren(self.contentEntity)
  for i = 1, #childList do
    local listItem = self.registrar:GetEntityTable(childList[i])
    listItem:UpdatePhases(true)
  end
  local now = timeHelpers:ServerSecondsSinceEpoch()
  if now ~= self.lastTime then
    self.lastTime = now
    local time = os.date("%c", now)
    local timeText = GetLocalizedReplacementText("@ui_current_time", {time = time})
    UiTextBus.Event.SetTextWithFlags(self.Properties.CurrentTime, timeText, eUiTextSet_SetAsIs)
  end
end
function WarsTab:SetWarData(warList)
  local warCountDelta = #warList - #self.guildWars
  self.guildWars = warList
  table.sort(self.guildWars, self.warSortFunctions[self.sortOption])
  if warCountDelta < 0 then
    UiDynamicScrollBoxBus.Event.RemoveElementsFromFront(self.WarsList, -warCountDelta)
  elseif 0 < warCountDelta then
    UiDynamicScrollBoxBus.Event.AddElementsToEnd(self.WarsList, warCountDelta, false)
  end
  UiScrollBoxBus.Event.SetScrollOffset(self.WarsList, Vector2(0, 0))
  UiDynamicScrollBoxBus.Event.RefreshContent(self.WarsList)
end
function WarsTab:ShowNoWarsMessage(enable)
  UiElementBus.Event.SetIsEnabled(self.NoWarsMessageText, enable)
  UiFaderBus.Event.SetFadeValue(self.WarDisplay, enable and self.noWarsDisplayOpacity or 1)
end
function WarsTab:GetNumElements()
  local numElements = #self.guildWars
  return numElements
end
function WarsTab:OnElementBecomingVisible(rootEntity, index)
  if index + 1 > #self.guildWars then
    return
  end
  local guildData
  guildData = self.guildWars[index + 1]
  if guildData then
    local listItem = self.registrar:GetEntityTable(rootEntity)
    if listItem ~= nil then
      local listItemData = {
        guildId = guildData.guildId,
        guildName = guildData.guildName,
        crestData = guildData.crestData,
        guildMasterCharacterIdString = guildData.guildMasterCharacterIdString,
        numMembers = guildData.numMembers,
        numClaims = guildData.numClaims,
        warId = guildData.warId,
        warEndTime = guildData.warEndTime,
        faction = guildData.faction,
        territoryId = guildData.territoryId,
        territoryName = guildData.territoryName,
        siegeStartTime = guildData.siegeStartTime,
        siegeWindow = guildData.siegeWindow,
        isInvasion = guildData.isInvasion
      }
      listItem:SetData(listItemData)
    end
  end
end
function WarsTab:OnMyGuildTabSelected()
  self.audioHelper:PlaySound(self.audioHelper.Roster_MyGuildTabSelected)
end
function WarsTab:OnWarsTabSelected()
  self.audioHelper:PlaySound(self.audioHelper.Roster_Tab_Selected)
end
return WarsTab
