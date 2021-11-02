local CompaniesAtWarList = {
  Properties = {
    ScrollBox = {
      default = EntityId()
    },
    ScrollBoxContent = {
      default = EntityId()
    },
    Spinner = {
      default = EntityId()
    },
    NoDataContainer = {
      default = EntityId()
    },
    NoDataText = {
      default = EntityId()
    },
    NoDataButton = {
      default = EntityId()
    },
    PageNumberContainer = {
      default = EntityId()
    },
    PageNumberText = {
      default = EntityId()
    },
    NextPageButton = {
      default = EntityId()
    },
    PrevPageButton = {
      default = EntityId()
    },
    WARS_PER_PAGE = {default = 5}
  },
  wars = {},
  guilds = {},
  uniqueGuildIds = {},
  currentPage = 1,
  delayTimer = 0,
  delayIntervalSeconds = 1,
  lastRequestTime = WallClockTimePoint()
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CompaniesAtWarList)
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function CompaniesAtWarList:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiDynamicScrollBoxDataBus, self.Properties.ScrollBox)
  self:BusConnect(UiDynamicScrollBoxElementNotificationBus, self.Properties.ScrollBox)
  self.NoDataButton:SetText("@ui_mapmenu_warlist_retry")
  self.NoDataButton:SetCallback(self.OnRefreshPressed, self)
  self.NextPageButton:SetCallback(self.OnNextPage, self)
  self.PrevPageButton:SetCallback(self.OnPrevPage, self)
end
function CompaniesAtWarList:OnTick(deltaTime, timePoint)
  self.delayTimer = self.delayTimer - deltaTime
  if self.delayTimer <= 0 then
    self:StopTick()
    local isDelayed = true
    self:RequestGuildData(isDelayed)
  end
end
function CompaniesAtWarList:StartTick()
  if not self.tickHandler then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function CompaniesAtWarList:StopTick()
  self:BusDisconnect(self.tickHandler)
  self.tickHandler = nil
end
function CompaniesAtWarList:GetWars()
  local wars
  if self.warsGuildId and self.warsGuildId:IsValid() then
    wars = WarDataServiceBus.Broadcast.GetWarsForGuild(self.warsGuildId)
  else
    wars = WarDataServiceBus.Broadcast.GetWars()
  end
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local activeWars = {}
  for i = 1, #wars do
    local warDetails = wars[i]
    local warPhase = warDetails:GetWarPhase()
    if warPhase ~= eWarPhase_Resolution and warPhase ~= eWarPhase_Complete then
      table.insert(activeWars, {
        timeRemainingSeconds = warDetails:GetWarEndTime():Subtract(now):ToSeconds(),
        warPhase = warPhase,
        isInvasion = warDetails:IsInvasion(),
        territoryId = warDetails:GetTerritoryId(),
        siegeStartTime = warDetails:GetConquestStartTime():Subtract(WallClockTimePoint()):ToSecondsRoundedUp(),
        attackerGuildId = warDetails:GetAttackerGuildId(),
        defenderGuildId = warDetails:GetDefenderGuildId()
      })
    end
  end
  return activeWars
end
function CompaniesAtWarList:SetIsVisible(isVisible, guildId, forceUpdate)
  if self.isVisible == isVisible and not forceUpdate then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  if isVisible then
    if #self.guilds > 0 then
      ClearTable(self.guilds)
    end
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
    self.warsGuildId = guildId
    local wars = self:GetWars()
    if wars and 0 < #wars then
      self.currentPage = 1
      self:UpdatePageData()
    end
  else
    ClearTable(self.guilds)
    self:StopTick()
    self:SetSpinnerShowing(false)
  end
end
function CompaniesAtWarList:RequestGuildData(isDelayed, isRefresh)
  local needsNewGuildData = false
  if isDelayed or isRefresh then
    needsNewGuildData = true
  else
    ClearTable(self.uniqueGuildIds)
    local wars = self:GetWars()
    local numWars = #wars
    for i = self.resultStartIndex, self.resultEndIndex do
      if i < 0 or i > numWars then
        break
      end
      local warDetails = wars[i]
      local attackerGuildId = warDetails.attackerGuildId
      local attackerGuildIdString = attackerGuildId:ToString()
      if not self.uniqueGuildIds[attackerGuildIdString] and not self.guilds[attackerGuildIdString] then
        self.uniqueGuildIds[attackerGuildIdString] = attackerGuildId
        needsNewGuildData = true
      end
      local defenderGuildId = warDetails.defenderGuildId
      local defenderGuildIdString = defenderGuildId:ToString()
      if not self.uniqueGuildIds[defenderGuildIdString] and not self.guilds[defenderGuildIdString] then
        self.uniqueGuildIds[defenderGuildIdString] = defenderGuildId
        needsNewGuildData = true
      end
    end
  end
  if needsNewGuildData then
    local timeSinceLastRequest = timeHelpers:ServerNow():Subtract(self.lastRequestTime):ToSecondsUnrounded()
    if not isDelayed and timeSinceLastRequest < self.delayIntervalSeconds then
      self.delayTimer = self.delayIntervalSeconds - timeSinceLastRequest
      self:StartTick()
    else
      local guildIds = vector_GuildId()
      for _, guildId in pairs(self.uniqueGuildIds) do
        guildIds:push_back(guildId)
      end
      socialDataHandler:RequestGetGuilds_ServerCall(self, self.GuildDataSuccess, self.GuildDataFailed, guildIds)
      self.lastRequestTime = timeHelpers:ServerNow()
    end
    self:SetSpinnerShowing(true)
  else
    UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
  end
end
function CompaniesAtWarList:GuildDataSuccess(results)
  if not self.isVisible then
    return
  end
  for i = 1, #results do
    local guildData = results[i]
    self.guilds[guildData.guildId:ToString()] = {
      guildName = guildData.guildName,
      crestData = guildData.crestData,
      guildMasterCharacterIdString = guildData.guildMasterCharacterIdString,
      numMembers = guildData.numMembers,
      siegeWindow = guildData.siegeWindow,
      faction = guildData.faction
    }
  end
  UiDynamicScrollBoxBus.Event.RefreshContent(self.Properties.ScrollBox)
  self:SetSpinnerShowing(false)
end
function CompaniesAtWarList:GuildDataFailed(reason)
  local reasonText = "@ui_mapmenu_warlist_failure_generic"
  if reason == eSocialRequestFailureReasonThrottled then
    reasonText = "@ui_mapmenu_warlist_failure_throttled"
  elseif reason == eSocialRequestFailureReasonTimeout then
    reasonText = "@ui_mapmenu_warlist_failure_timeout"
  end
  self:SetSpinnerShowing(false)
  self:SetNoDataContainerShowing(true, reasonText)
end
function CompaniesAtWarList:UpdatePageData()
  local wars = self:GetWars()
  local numWars = #wars
  self.numPages = math.ceil(numWars / self.WARS_PER_PAGE)
  self.resultStartIndex = self.WARS_PER_PAGE * (self.currentPage - 1) + 1
  local numPageResults = self.currentPage < self.numPages and self.WARS_PER_PAGE or numWars % self.WARS_PER_PAGE
  if numPageResults == 0 then
    numPageResults = self.WARS_PER_PAGE
  end
  self.resultEndIndex = self.resultStartIndex + numPageResults - 1
  UiElementBus.Event.SetIsEnabled(self.Properties.PageNumberContainer, self.numPages > 1)
  if self.numPages > 1 then
    local text = GetLocalizedReplacementText("@ui_page", {
      start = tostring(self.currentPage),
      ["end"] = tostring(self.numPages)
    })
    UiTextBus.Event.SetText(self.Properties.PageNumberText, text)
  end
  self:RequestGuildData()
end
function CompaniesAtWarList:OnRefreshPressed()
  local isDelayed = false
  local isRefresh = true
  self:RequestGuildData(isDelayed, isRefresh)
  self:SetNoDataContainerShowing(false)
end
function CompaniesAtWarList:OnNextPage()
  if self.currentPage < self.numPages then
    self.currentPage = self.currentPage + 1
    self:UpdatePageData()
  end
end
function CompaniesAtWarList:OnPrevPage()
  if self.currentPage > 1 then
    self.currentPage = self.currentPage - 1
    self:UpdatePageData()
  end
end
function CompaniesAtWarList:SetSpinnerShowing(isShowing)
  if self.spinnerIsShowing == isShowing then
    return
  end
  self.spinnerIsShowing = isShowing
  UiElementBus.Event.SetIsEnabled(self.Properties.Spinner, isShowing)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScrollBoxContent, not isShowing)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.NextPageButton, not isShowing)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PrevPageButton, not isShowing)
  if isShowing then
    self.ScriptedEntityTweener:Play(self.Properties.Spinner, 2.5, {rotation = 0}, {timesToPlay = -1, rotation = 359})
  else
    self.ScriptedEntityTweener:Stop(self.Properties.Spinner)
  end
end
function CompaniesAtWarList:SetNoDataContainerShowing(isShowing, reasonText)
  if self.noDataContainerIsShowing == isShowing then
    return
  end
  self.noDataContainerIsShowing = isShowing
  UiElementBus.Event.SetIsEnabled(self.Properties.NoDataContainer, isShowing)
  if isShowing then
    UiTextBus.Event.SetTextWithFlags(self.Properties.NoDataText, reasonText, eUiTextSet_SetLocalized)
  end
end
function CompaniesAtWarList:GetNumElements()
  local wars = self:GetWars()
  local numElements = 0
  if wars and 0 < #wars then
    if self.resultEndIndex then
      numElements = self.resultEndIndex - self.resultStartIndex + 1
    else
      return 0
    end
  end
  return numElements
end
function CompaniesAtWarList:OnElementBecomingVisible(rootEntity, index)
  local wars = self:GetWars()
  local resultIndex = self.resultStartIndex + index
  resultIndex = Clamp(resultIndex, 1, #wars)
  local warDetails = wars[resultIndex]
  local attackerGuildData = self.guilds[warDetails.attackerGuildId:ToString()]
  local defenderGuildData = self.guilds[warDetails.defenderGuildId:ToString()]
  local listItemData = {
    warIndex = resultIndex,
    GetWarDetails = self.GetWars,
    fnSelf = self,
    attackerGuildData = attackerGuildData,
    defenderGuildData = defenderGuildData,
    delay = 0.05 * index
  }
  local listItem = self.registrar:GetEntityTable(rootEntity)
  listItem:SetCompaniesAtWarListItemData(listItemData)
end
return CompaniesAtWarList
