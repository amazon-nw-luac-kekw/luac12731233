local SocialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local TerritoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local TerritoryInfoScreen = {
  Properties = {
    ScreenHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    GuildCrestIcon = {
      default = EntityId()
    },
    UnclaimedCrest = {
      default = EntityId()
    },
    TerritoryName = {
      default = EntityId()
    },
    TerritoryNameBg = {
      default = EntityId()
    },
    TerritoryLevel = {
      default = EntityId()
    },
    TerritoryStanding = {
      default = EntityId()
    },
    TerritoryStatus = {
      default = EntityId()
    },
    InfoTab = {
      default = EntityId()
    },
    LogTab = {
      default = EntityId()
    },
    InfoTabContent = {
      default = EntityId()
    },
    LogTabContent = {
      default = EntityId()
    },
    LineTop = {
      default = EntityId()
    },
    LineBottom = {
      default = EntityId()
    },
    LineLeft = {
      default = EntityId()
    },
    LineRight = {
      default = EntityId()
    },
    HorizontalDivider = {
      default = EntityId()
    },
    VerticalDivider = {
      default = EntityId()
    },
    BannerMask = {
      default = EntityId()
    },
    BannerImage = {
      default = EntityId()
    },
    DOFTweenDummyElement = {
      default = EntityId()
    }
  },
  STATE_TERRITORY_INFO = 1,
  DEBUGGING_PREVIEW_MODE = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(TerritoryInfoScreen)
function TerritoryInfoScreen:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterOpenEvent("TerritoryInfoScreen", self.canvasId)
  self.territoryInfoHandler = DynamicBus.TerritoryInfoScreen.Connect(self.entityId, self)
  self.InfoTab.territoryInfoScreen = self
  self.LogTab.territoryInfoScreen = self
  self.v2enabled = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTerritoryMechanicsV2", function(self, enable)
    self.v2enabled = enable
  end)
  self.logTabEnabled = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableTerritoryLogTab", function(self, enable)
    self.logTabEnabled = enable
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsLandClaimManagerAvailable", function(self, isLandClaimManagerAvailable)
    self.isLandClaimManagerAvailable = isLandClaimManagerAvailable
    if isLandClaimManagerAvailable and LyShineManagerBus.Broadcast.IsInState(3211015753) then
      self:TryShowScreenOnDataReady()
    end
  end)
  if self.DEBUGGING_PREVIEW_MODE then
    Log("TerritoryInfoScreen DEBUGGING_PREVIEW_MODE is true")
    self:OnTransitionIn("", "", "", 0)
  end
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.LineTop:SetLength(970)
  self.LineBottom:SetLength(970)
  self.LineLeft:SetLength(870)
  self.LineRight:SetLength(870)
  self.HorizontalDivider:SetLength(970)
  self.VerticalDivider:SetLength(450)
  self.ScreenHeader:SetText("@ui_governorsdesk.")
  self.ScreenHeader:SetHintCallback(self.OnExit, self)
  self.Frame:SetFrameStyle(self.Frame.FRAME_STYLE_FULLSCREEN_RIGHT)
end
function TerritoryInfoScreen:OnReceivedTerritoryGovernanceData()
  local completedUpgrades = TerritoryGovernanceRequestBus.Broadcast.GetCompletedTerritoryUpgrades()
  UiTextBus.Event.SetText(self.Properties.TerritoryLevel, tostring(completedUpgrades))
  self:OnTransitionIn()
end
function TerritoryInfoScreen:IsScreenReadyToShow()
  return self.territoryId and self.territoryId ~= 0 and self.isLandClaimManagerAvailable
end
function TerritoryInfoScreen:TryShowScreenOnDataReady()
  if UiCanvasBus.Event.GetEnabled(self.canvasId) and self:IsScreenReadyToShow() then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
    self:OnTransitionIn()
  end
end
function TerritoryInfoScreen:OnTransitionIn(stateName, levelName, toState, toLevel)
  self.territoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if not self:IsScreenReadyToShow() then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(true, 5, self, function(self)
      LyShineManagerBus.Broadcast.SetState(2702338936)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "@ui_screen_unavailable"
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end)
    self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey", function(self, claimKey)
      if claimKey and claimKey ~= 0 then
        self.territoryId = claimKey
        self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
        self:TryShowScreenOnDataReady()
      end
    end)
    return
  end
  if not self.gameCameraSet then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
    JavCameraControllerRequestBus.Broadcast.OverrideCameraState("UI_TerritoryInfoScreen", 0.5)
    self.gameCameraSet = true
  end
  self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  JavelinCameraRequestBus.Broadcast.EnableDepthOfField(true)
  self.previousDOFDistance = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldDistance()
  self.previousDOFBlur = JavelinCameraRequestBus.Broadcast.GetCurrentDepthOfFieldBlur()
  self.targetDOFDistance = 4
  self.targetDOFBlur = 0.5
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = 0.5,
    opacity = 1,
    onUpdate = function(currentValue, currentProgressPercent)
      self:UpdateDepthOfField(currentValue)
    end
  })
  self.LineTop:SetVisible(true, 1.2, {delay = 0.35})
  self.LineLeft:SetVisible(true, 1.2, {delay = 0.35})
  self.LineBottom:SetVisible(true, 1.2, {delay = 0.35})
  self.LineRight:SetVisible(true, 1.2, {delay = 0.35})
  self.HorizontalDivider:SetVisible(true, 1.2, {delay = 0.35})
  self.VerticalDivider:SetVisible(true, 1.2, {delay = 0.35})
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.BannerMask, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BannerMask, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.BannerMask)
  self.guildId = TerritoryDataHandler:GetGoverningGuildId(self.territoryId)
  local playerGuildId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Id")
  UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryName, TerritoryDataHandler:GetTerritoryNameFromTerritoryId(self.territoryId), eUiTextSet_SetLocalized)
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.TerritoryName)
  local textWidth = textSize.x
  local textHeight = textSize.y
  local paddingX = 100
  local paddingY = 50
  textWidth = textWidth + paddingX
  textHeight = textWidth + paddingY
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TerritoryNameBg, textWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.TerritoryNameBg, textHeight)
  if self.guildId then
    if self.guildId == playerGuildId then
      local guildData = OtherGuildData()
      guildData.guildId = playerGuildId
      guildData.guildName = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Name")
      guildData.crestData = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Guild.Crest")
      self:SetGuildData(guildData)
    else
      SocialDataHandler:GetGuildDetailedData_ServerCall(self, function(self, result)
        local guildData
        if 0 < #result then
          guildData = type(result[1]) == "table" and result[1].guildData or result[1]
        else
          Log("ERR - GuildMenu:OnShowWarNotification: GuildData request returned with no data")
          UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestIcon, false)
          UiElementBus.Event.SetIsEnabled(self.Properties.UnclaimedCrest, true)
          UiImageBus.Event.SetColor(self.Properties.BannerImage, self.UIStyle.COLOR_GRAY_30)
          self.InfoTab:SetGuildData(nil)
          return
        end
        if guildData and guildData:IsValid() then
          self:SetGuildData(guildData)
        end
      end, function()
        Log("ERROR: GetGuildDetailedData failed.")
      end, self.guildId)
    end
  else
    Log("ERROR: self.guildId not set")
  end
  self.InfoTab:OnScreenOpened()
  self.LogTab:OnScreenOpened()
  self:OnInfoTab()
  DynamicBus.UITickBus.Connect(self.entityId, self)
  self.tickConnected = true
  if not self.escapeKeyHandler then
    self.escapeKeyHandler = DynamicBus.EscapeKeyNotificationBus.Connect(self.entityId, self)
  end
  if not self.interfaceComponentHandler then
    local territoryEntityId = self.dataLayer:GetDataFromNode("Hud.TerritoryGovernance.EntityId")
    self.interfaceComponentHandler = self:BusConnect(TerritoryInterfaceComponentNotificationsBus, territoryEntityId)
  end
end
function TerritoryInfoScreen:SetGuildData(otherGuildData)
  self.GuildCrestIcon:SetSmallIcon(otherGuildData.crestData)
  self.InfoTab:SetGuildData(otherGuildData)
  UiImageBus.Event.SetColor(self.Properties.BannerImage, otherGuildData.crestData.backgroundColor)
  UiElementBus.Event.SetIsEnabled(self.Properties.GuildCrestIcon, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.UnclaimedCrest, false)
end
function TerritoryInfoScreen:OnTransitionOut(stateName, levelName, toState, toLevel)
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.CurrentAreaTerritory.ClaimKey")
  if DynamicBus.FullScreenSpinner.Broadcast.GetFullscreenSpinnerVisible() then
    DynamicBus.FullScreenSpinner.Broadcast.SetFullscreenSpinnerVisible(false)
  end
  JavCameraControllerRequestBus.Broadcast.RestoreCameraState("UI_TerritoryInfoScreen", 0.5)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  self.gameCameraSet = false
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, 0.1, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  local durationOut = 0.2
  self.ScriptedEntityTweener:StartAnimation({
    id = self.DOFTweenDummyElement,
    easeMethod = ScriptedEntityTweenerEasingMethod_Cubic,
    duration = durationOut,
    opacity = 0,
    onComplete = function()
      JavelinCameraRequestBus.Broadcast.ResetDepthOfField()
    end
  })
  self.LineTop:SetVisible(false, 0)
  self.LineBottom:SetVisible(false, 0)
  self.LineLeft:SetVisible(false, 0)
  self.LineRight:SetVisible(false, 0)
  self.HorizontalDivider:SetVisible(false, 0)
  self.VerticalDivider:SetVisible(false, 0)
  local interactorEntityNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  if interactorEntityNode then
    local interactorEntity = interactorEntityNode:GetData()
    UiInteractorComponentRequestsBus.Event.RequestCancelCommittedInteraction(interactorEntity)
  end
  if self.tickConnected then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickConnected = false
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  if self.interfaceComponentHandler then
    self:BusDisconnect(self.interfaceComponentHandler)
    self.interfaceComponentHandler = nil
  end
  self.ScriptedEntityTweener:Stop(self.Properties.BannerImage)
  UiMaskBus.Event.SetIsMaskingEnabled(self.Properties.BannerMask, false)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.BannerMask, 0)
  UiFlipbookAnimationBus.Event.Stop(self.Properties.BannerMask)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function TerritoryInfoScreen:OnExit()
  LyShineManagerBus.Broadcast.ExitState(3211015753)
end
function TerritoryInfoScreen:OnShutdown()
  if self.territoryInfoHandler then
    DynamicBus.TerritoryInfoScreen.Disconnect(self.entityId, self)
    self.territoryInfoHandler = nil
  end
  if self.tickConnected then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickConnected = false
  end
  if self.escapeKeyHandler then
    DynamicBus.EscapeKeyNotificationBus.Disconnect(self.entityId, self)
    self.escapeKeyHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
function TerritoryInfoScreen:OnCloseMissionDetailsButtonPressed()
  self:OnEscapeKeyPressed()
end
function TerritoryInfoScreen:OnEscapeKeyPressed()
  self:OnExit()
end
function TerritoryInfoScreen:OnInfoTab()
  UiElementBus.Event.SetIsEnabled(self.Properties.InfoTab, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.LogTab, false)
  self.ScriptedEntityTweener:Play(self.Properties.InfoTabContent, 0.6, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function TerritoryInfoScreen:OnLogTab()
  UiElementBus.Event.SetIsEnabled(self.Properties.InfoTab, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.LogTab, true)
  self.ScriptedEntityTweener:Play(self.Properties.LogTabContent, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
end
function TerritoryInfoScreen:OnTick(deltaTime, timePoint)
  self.lastSecond = (self.lastSecond or 0) - deltaTime
  if self.lastSecond < 0 then
    self.lastSecond = self.lastSecond + 1
    self.InfoTab:OnSecondTick()
  end
end
function TerritoryInfoScreen:OnEscapeKeyPressed()
  if self.InfoTab:OnEscapeKeyPressed() then
    return
  end
  LyShineManagerBus.Broadcast.SetState(2702338936)
end
function TerritoryInfoScreen:UpdateDepthOfField(currentValue)
  local currentDistance = self.previousDOFDistance + (self.targetDOFDistance - self.previousDOFDistance) * currentValue
  local currentBlur = self.previousDOFBlur + (self.targetDOFBlur - self.previousDOFBlur) * currentValue
  JavelinCameraRequestBus.Broadcast.SetDepthOfField(currentDistance, currentBlur, 0, 0, self.UIStyle.RANGE_DEPTH_OF_FIELD)
end
function TerritoryInfoScreen:OnExit()
  LyShineManagerBus.Broadcast.ExitState(3211015753)
end
return TerritoryInfoScreen
