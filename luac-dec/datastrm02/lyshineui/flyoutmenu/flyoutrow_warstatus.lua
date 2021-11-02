local dominionCommon = RequireScript("LyShineUI._Common.DominionCommon")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local FlyoutRow_WarStatus = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    AtWarText = {
      default = EntityId()
    },
    AtWarTimeText = {
      default = EntityId()
    }
  },
  iconPath = "LyShineUI\\Images\\Icons\\Misc\\icon_warSmall_white.png",
  atWarText = "@ui_settlementatwarfor",
  noLongerAtWarText = "@ui_settlementnolongeratwar",
  warTimeRemaining = 0,
  warTimeRemainingText = "",
  warEndTimePoint = WallClockTimePoint(),
  tickTimer = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_WarStatus)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
function FlyoutRow_WarStatus:OnInit()
  BaseElement.OnInit(self)
  self.timeHelpers = timeHelpers
  self.dataLayer = dataLayer
  self.Icon:SetIcon(self.iconPath, self.UIStyle.COLOR_WHITE)
  UiTextBus.Event.SetColor(self.AtWarText, self.UIStyle.COLOR_RED)
  UiTextBus.Event.SetColor(self.AtWarTimeText, self.UIStyle.COLOR_RED)
end
function FlyoutRow_WarStatus:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function FlyoutRow_WarStatus:SetData(data)
  if not data or not data.guildId and not data.settlementKey then
    Log("[FlyoutRow_WarStatus] Error: invalid data passed to SetData")
    return
  end
  if data.guildId ~= nil then
    self.guildId = data.guildId
    self:UpdateGuildWarState()
  elseif data.settlementKey ~= nil then
    self.settlementKey = data.settlementKey
    if self.landClaimHandler then
      self:BusDisconnect(self.landClaimHandler)
    end
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementKey)
    local ownerData = LandClaimRequestBus.Broadcast.GetClaimOwnerData(self.settlementKey)
    self:OnClaimOwnerChanged(self.settlementKey, ownerData)
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Guild.Id", self.UpdateGuildWarState)
  self.dataLayer:RegisterCallback(self, "Hud.LocalPlayer.Guild.LastModifiedGuildWarId", self.UpdateGuildWarState)
end
function FlyoutRow_WarStatus:OnClaimOwnerChanged(claimKey, newOwnerData)
  if claimKey ~= self.settlementKey then
    return
  end
  self:UpdateOwnership(newOwnerData.guildId)
end
function FlyoutRow_WarStatus:UpdateOwnership(newGuildId)
  self.guildId = newGuildId
  self:UpdateGuildWarState()
end
function FlyoutRow_WarStatus:UpdateGuildWarState()
  local isAtWarScoutingPhase = dominionCommon:IsAtWarScoutingPhase(self.guildId, true)
  local isAtWar = IsAtWarWithGuild(self.guildId) or isAtWarScoutingPhase
  if isAtWar then
    self.warEndTimePoint = WarRequestBus.Broadcast.GetWarEndTime(WarDataClientRequestBus.Broadcast.GetWarId(self.guildId))
    self.warPhase = dominionCommon:GetWarDetailsFromGuildId(self.guildId):GetWarPhase()
    if self.tickBusHandler == nil then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  else
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  UiElementBus.Event.SetIsEnabled(self.AtWarTimeText, isAtWar)
  UiTextBus.Event.SetTextWithFlags(self.AtWarText, isAtWar and self.atWarText or self.noLongerAtWarText, eUiTextSet_SetLocalized)
end
function FlyoutRow_WarStatus:OnTick(deltaTime, timePoint)
  self.tickTimer = self.tickTimer + deltaTime
  if self.tickTimer > 1 then
    self.tickTimer = 0
    local isScouting, scoutingTimeText = dominionCommon:IsAtWarScoutingPhase(self.guildId, true)
    if isScouting then
      self.warTimeRemainingText = scoutingTimeText
      self.atWarText = "@ui_settlementwarBeginsIn"
    else
      local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      local warTimeRemaining = self.warEndTimePoint:Subtract(now):ToSeconds()
      self.warTimeRemainingText = self.timeHelpers:ConvertToShorthandString(warTimeRemaining, false)
      if self.warPhase == eWarPhase_Resolution then
        self.atWarText = "@ui_settlementWarResolvesIn"
      else
        self.atWarText = "@ui_settlementatwarfor"
      end
    end
    local warColor = dominionCommon:GetWarPhaseColor(self.warPhase)
    self.Icon:SetColor(warColor)
    UiTextBus.Event.SetTextWithFlags(self.AtWarText, string.format("<font color=%s> %s <font face=\"lyshineui/fonts/Nimbus_semibold.font\">%s</font></font>", ColorRgbaToHexString(warColor), self.atWarText, self.warTimeRemainingText), eUiTextSet_SetLocalized)
  end
end
return FlyoutRow_WarStatus
