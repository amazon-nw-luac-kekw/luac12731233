local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local SlashCommands = RequireScript("LyShineUI.SlashCommands")
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local layouts = RequireScript("LyShineUI.Banner.Layouts")
local SiegeMarkerData = RequireScript("LyShineUI.Markers.SiegeMarkerData")
local FactionControlPointHUD = {
  Properties = {
    ClaimPointHolder = {
      default = EntityId()
    },
    ClaimPointIcon = {
      default = EntityId()
    },
    OwnerIcon = {
      default = EntityId()
    },
    LineHolder = {
      default = EntityId()
    },
    TextHolder = {
      default = EntityId()
    }
  }
}
BaseScreen:CreateNewScreen(FactionControlPointHUD)
function FactionControlPointHUD:OnInit()
  BaseScreen.OnInit(self)
  self.factionControlPointHUDHandler = DynamicBus.FactionControlPointHUD.Connect(self.entityId, self)
  self.rootDataPath = "Hud.LocalPlayer.Siege.ClaimPoints."
  self.meterDataPath = self.rootDataPath .. "1."
  self.factionIconDataPath = self.rootDataPath .. "3."
  self.ClaimPointIcon:SetName("Empty")
  self.ClaimPointIcon:SetState(eCapturePointStateFlag_Contested)
  self.ClaimPointIcon.shownContestedNotification = false
  self.ClaimPointIcon:SetMeterBGColor(self.UIStyle.COLOR_GRAY_50)
  self.ClaimPointIcon:SetProgress(0)
  self.lastProgress = 0
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", function(self, faction)
    self.faction = faction
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.raidId = raidId
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
    local previousSettlement = self.settlementId
    self.settlementId = claimKey
    if self.isLandClaimManagerAvailable and previousSettlement ~= self.settlementId then
      self:SwitchToDifferentTerritory()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isLandClaimManagerAvailable)
    if isLandClaimManagerAvailable == true then
      self.isLandClaimManagerAvailable = isLandClaimManagerAvailable
      self:SwitchToDifferentTerritory()
    else
      self:BusDisconnect(self.landClaimHandler)
      self.landClaimHandler = nil
      self.isLandClaimManagerAvailable = false
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead then
      self:ShowHud(false)
    end
  end)
  self.factionBroadcastControlHandler = self:BusConnect(FactionControlClientBroadcastNotificationBus)
  SetTextStyle(self.Properties.TextHolder, self.UIStyle.FONT_STYLE_FACTIONCONTROL_HUD_STATUS)
  self:ShowHud(false)
end
function FactionControlPointHUD:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.factionControlPointHUDHandler then
    DynamicBus.FactionControlPointHUD.Disconnect(self.entityId, self)
    self.factionControlPointHUDHandler = nil
  end
  self:BusDisconnect(self.landClaimHandler)
  self.landClaimHandler = nil
end
function FactionControlPointHUD:ShowHud(show)
  if self.settlementId == nil and show then
    return
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimPointHolder, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineHolder, show)
  UiElementBus.Event.SetIsEnabled(self.Properties.TextHolder, show)
  self.isVisible = show
  if show then
    if self.factionDataControlHandler then
      self:BusDisconnect(self.factionDataControlHandler)
    end
    self.factionDataControlHandler = self:BusConnect(FactionControlClientDataNotificationBus, self.settlementId)
    local worldPos = FactionControlClientDataRequestBus.Broadcast.GetFactionControlCapturePointWorldPos()
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Reset", true)
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Name", "-")
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "WorldPosition", worldPos)
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "BGColor", self.UIStyle.COLOR_GRAY_50)
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Color", self.UIStyle.COLOR_GRAY_50)
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Enabled", SiegeMarkerData.USAGE_FCP)
    local factionSettings = FactionCommon.factionInfoTable[self.ownerFaction]
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "Reset", true)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "CustomIcon", factionSettings.crestFgSmall)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "IconColor", factionSettings.crestBgColor)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "IconScale", Vector2(0.5, 0.5))
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "WorldPosition", worldPos)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "BGColor", self.UIStyle.COLOR_GRAY_50)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "Color", self.UIStyle.COLOR_GRAY_50)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "Enabled", SiegeMarkerData.USAGE_FCP)
  else
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Disabled", SiegeMarkerData.USAGE_FCP)
    LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "Disabled", SiegeMarkerData.USAGE_FCP)
    self:BusDisconnect(self.factionDataControlHandler)
    self.factionDataControlHandler = nil
  end
end
function FactionControlPointHUD:OnTransitionIn(fromState, fromLevel, toState, toLevel)
end
function FactionControlPointHUD:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function FactionControlPointHUD:UpdateControlPointOwner(ownerFaction)
  local warDetails = self.raidId and WarDataServiceBus.Broadcast.GetWarForRaid(self.raidId) or nil
  if warDetails then
    local warId = warDetails:GetWarId()
    if warId ~= nil and not warId:IsNull() then
      return
    end
  end
  local factionSettings = FactionCommon.factionInfoTable[ownerFaction]
  local factionColor = factionSettings.crestBgColor
  self.ClaimPointIcon:SetMeterColor(factionColor)
  UiImageBus.Event.SetColor(self.Properties.OwnerIcon, factionColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.OwnerIcon, factionSettings.crestFgSmall)
  LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "CustomIcon", factionSettings.crestFgSmall)
  LyShineDataLayerBus.Broadcast.SetData(self.factionIconDataPath .. "IconColor", factionSettings.crestBgColor)
  local objectiveText = "@ui_factioncontrol_defend_controlpoint"
  if self.faction ~= ownerFaction then
    objectiveText = "@ui_factioncontrol_claim_controlpoint"
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TextHolder, objectiveText, eUiTextSet_SetLocalized)
end
function FactionControlPointHUD:OnFactionControlStatusChanged(settlementId, faction, captureStatus, isActive)
  if settlementId == self.settlementId and not self.isVisible and isActive then
    if self.ownerFaction ~= faction then
      self:UpdateControlPointOwner(faction)
      self:AnnounceOwnerChange(faction)
      self.ownerFaction = faction
    end
    if self.captureStatus ~= captureStatus then
      if self.captureStatus == eFactionControlCaptureStatus_Uncontested and captureStatus == eFactionControlCaptureStatus_Contested then
        self:AnnounceStatusChange(captureStatus)
      end
      self.captureStatus = captureStatus
    end
  end
  if settlementId == self.settlementId and self.isVisible and not isActive then
    self:ShowHud(false)
  end
end
function FactionControlPointHUD:OnFactionControlPointChanged(claimKey, controllingFaction, captureStatus, contestingFaction, progress)
  if claimKey == self.settlementId then
    if self.ownerFaction ~= controllingFaction then
      self:UpdateControlPointOwner(controllingFaction)
      self:AnnounceOwnerChange(controllingFaction)
      self.ownerFaction = controllingFaction
    end
    if captureStatus == eFactionControlCaptureStatus_Contested then
      local factionColor = FactionCommon.factionInfoTable[contestingFaction].crestBgColor
      self.ClaimPointIcon:SetMeterColor(factionColor)
      LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Color", factionColor)
    end
    local firstThresholdReached = self.lastProgress <= 25 and 25 < progress * 100
    local secondThresholdReached = self.lastProgress <= 75 and progress * 100 > 75
    if firstThresholdReached or secondThresholdReached then
      self:AnnounceStatusChange(captureStatus)
    end
    self.captureStatus = captureStatus
    self.ClaimPointIcon:SetProgress(progress)
    self.lastProgress = progress * 100
    LyShineDataLayerBus.Broadcast.SetData(self.meterDataPath .. "Progress", progress)
  end
end
function FactionControlPointHUD:OnFactionControlLocalPlayerEntered(claimKey)
  if claimKey == self.settlementId then
    self:ShowHud(true)
  end
end
function FactionControlPointHUD:OnFactionControlLocalPlayerExited(claimKey)
  if claimKey == self.settlementId then
    self:ShowHud(false)
  end
end
function FactionControlPointHUD:SwitchToDifferentTerritory()
  if self.landClaimHandler then
    self:BusDisconnect(self.landClaimHandler)
    self.landClaimHandler = nil
  end
  if self.settlementId ~= nil then
    self.landClaimHandler = self:BusConnect(LandClaimNotificationBus, self.settlementId)
    local posData = LandClaimRequestBus.Broadcast.GetClaimPosData(self.settlementId)
    local territoryName = posData.territoryName
    if territoryName == nil or territoryName == "" then
      local vec2Pos = Vector2(posData.worldPos.x, posData.worldPos.y)
      local tract = MapComponentBus.Broadcast.GetTractAtPosition(vec2Pos)
      territoryName = "@" .. tract
    end
    self.territoryName = territoryName
    local tierInfo = TerritoryDataHandler:GetUpgradeTierInfoByTerritoryId(self.settlementId, eTerritoryUpgradeType_Fortress)
    local nameText = GetLocalizedReplacementText("@ui_fortress_header", {
      name = territoryName,
      tier = tierInfo.name
    })
    self.fortName = nameText
    self.ownerFaction = LandClaimRequestBus.Broadcast.GetFactionControlOwner(self.settlementId)
    self.captureStatus = LandClaimRequestBus.Broadcast.GetFactionControlCaptureStatus(self.settlementId)
    if self.ownerFaction ~= eFactionType_None then
      self:UpdateControlPointOwner(self.ownerFaction)
    end
  end
end
function FactionControlPointHUD:AnnounceStatusChange(newCaptureStatus)
  local messageText = GetLocalizedReplacementText("@ui_factioncontrol_fortcontested_announce", {
    fortName = self.fortName
  })
  if self.isVisible then
    self:ShowMessageOnNotification(messageText)
  else
    self:ShowMessageOnChat(messageText)
  end
end
function FactionControlPointHUD:AnnounceOwnerChange(controllingFaction)
  if self.ownerFaction ~= controllingFaction and controllingFaction ~= eFactionType_None then
    local messageText = GetLocalizedReplacementText("@ui_factioncontrol_ownerchange_announce", {
      fortName = self.fortName,
      factionName = FactionCommon.factionInfoTable[controllingFaction].factionName
    })
    if self.isVisible then
      self:ShowMessageOnBanner(messageText)
    else
      self:ShowMessageOnChat(messageText)
    end
  end
end
function FactionControlPointHUD:ShowMessageOnChat(messageText)
  local chatMessage = BaseGameChatMessage()
  chatMessage.type = eChatMessageType_Area_Announce
  chatMessage.body = messageText
  ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
end
function FactionControlPointHUD:ShowMessageOnBanner(messageText)
  local bannerData = {
    WarCard1 = {
      warTitleText = "@ui_factioncontrol_announce_titletext",
      warDetailText = messageText,
      isInvasion = false,
      isSiegeState = false,
      offsetY = 100,
      noIcons = true,
      bannerColor = 2
    }
  }
  local bannerDisplayTime = 5
  local priority = 3
  DynamicBus.Banner.Broadcast.EnqueueBanner(layouts.LAYOUT_WAR_CARD, bannerData, bannerDisplayTime, nil, nil, false, priority, layouts.WAR_BANNER_DRAW_ORDER)
end
function FactionControlPointHUD:ShowMessageOnNotification(messageText)
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = messageText
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function FactionControlPointHUD:IsVisible()
  return self.isVisible
end
return FactionControlPointHUD
