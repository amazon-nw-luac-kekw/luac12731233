local PlayerInspect = {
  Properties = {
    Background = {
      default = EntityId()
    },
    FlyoutAnchor = {
      default = EntityId()
    },
    HintContainer = {
      default = EntityId()
    },
    Hint = {
      default = EntityId()
    }
  },
  playerInspectEnabled = true,
  showInspectHint = true,
  isFlyoutShowing = false,
  markerScale = 1,
  HINT_HORIZONTAL_OFFSET = -16,
  HINT_VERTICAL_OFFSET = -16,
  DIST_FROM_CENTER_TOLERANCE = 100,
  DIST_SCALE_START = 1,
  DIST_SCALE_MAX = 35,
  MAX_SCALE = 1,
  MIN_SCALE = 0.8,
  DIST_VISIBILITY_MAX = 35,
  pressCount = 0,
  hitCount = 0,
  telemetryTimer = 0,
  TELEMETRY_SEND_PERIOD_SECONDS = 300
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(PlayerInspect)
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
local PlayerFlyoutHandler = RequireScript("LyShineUI.FlyoutMenu.PlayerFlyoutHandler")
PlayerFlyoutHandler:AttachPlayerFlyoutHandler(PlayerInspect)
function PlayerInspect:OnInit()
  BaseScreen.OnInit(self)
  self:InitPlayerFlyoutHandler(false)
  self:BusConnect(UiCanvasSizeNotificationBus)
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self.PFH.locationPreference = 2
  self.PFH.stopPositionalExitHover = true
  self.PFH.ignoreHoverExit = true
  self.Hint:SetActionMap("player")
  self.Hint:SetKeybindMapping("social_align")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "javelin.social.enable-player-inspect", function(self, enabled)
    self.playerInspectEnabled = enabled
    if self.playerInspectEnabled and not self.tickHandler then
      self.TELEMETRY_SEND_PERIOD_SECONDS = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.player-inspect-telemetry-send-period-seconds")
      self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
    elseif not self.playerInspectEnabled and self.tickHandler then
      self:BusDisconnect(self.tickHandler)
      self.tickHandler = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Markers.RootPlayer.MarkerComponentId", function(self, playerMarkerId)
    if playerMarkerId and playerMarkerId:IsValid() then
      self.playerMarkerId = playerMarkerId
      self.playerId = MarkerRequestBus.Event.GetPlayerId(self.playerMarkerId)
      if self.markerHandler then
        self:BusDisconnect(self.markerHandler)
      end
      self.markerHandler = self:BusConnect(MarkerNotificationBus, self.playerMarkerId)
    else
      self.playerMarkerId = nil
      self.playerId = nil
      if self.markerHandler then
        self:BusDisconnect(self.markerHandler)
      end
      UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
    end
  end)
  cryActionCommon:RegisterActionListener(self, "social_align", 0, function(self, actionName, value)
    if self.isFlyoutShowing then
      self:OnClickBackground()
      return
    end
    if not self.playerInspectEnabled or not self.isOnHud then
      return
    end
    self.pressCount = self.pressCount + 1
    if not (self.playerMarkerId and self.isWithinDistance and self.isMarkerVisible) or not self:IsWithinInspectBounds() then
      if self.notification and DynamicBus.NotificationsRequestBus.Broadcast.IsNotificationValid(self.notification) then
        return
      end
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = GetLocalizedReplacementText("@ui_inspect_player_notarget", {
        keyName = string.upper(LyShineManagerBus.Broadcast.GetKeybind("social_align", "player"))
      })
      self.notification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      return
    end
    self:ShowFlyout()
  end)
  cryActionCommon:RegisterActionListener(self, "camera_free_look_activate", 0, function(self, actionName, value)
    if self.isFlyoutShowing then
      self:OnClickBackground()
      return
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Controls.ShowInspectHint", function(self, showInspectHint)
    if not showInspectHint then
      UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
    end
    self.showInspectHint = showInspectHint
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Flyout.IsVisible", function(self, isVisible)
    self.isFlyoutShowing = isVisible
    if not isVisible then
      self:OnFlyoutClose()
    end
  end)
end
function PlayerInspect:IsWithinInspectBounds()
  local distFromCenterSq = MarkerRequestBus.Event.GetDistanceFromScreenCenterSq(self.playerMarkerId)
  return distFromCenterSq <= self.DIST_FROM_CENTER_TOLERANCE * self.DIST_FROM_CENTER_TOLERANCE
end
function PlayerInspect:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    self.canvasSize = UiCanvasBus.Event.GetCanvasSize(self.canvasId)
    self.canvasCenter = Vector2(self.canvasSize.x / 2, self.canvasSize.y / 2)
  end
end
function PlayerInspect:OnPositionChanged(screenPosition, isOnScreen)
  if not self.showInspectHint or not self.isOnHud then
    return
  end
  if not (self.playerMarkerId and self.isWithinDistance and self.isMarkerVisible) or self.isFlyoutShowing then
    return
  end
  if self:IsWithinInspectBounds() then
    local hintPos = Vector2(screenPosition.x + self.markerScale * self.HINT_HORIZONTAL_OFFSET, screenPosition.y + self.markerScale * self.HINT_VERTICAL_OFFSET)
    UiTransformBus.Event.SetViewportPosition(self.Properties.HintContainer, hintPos)
    UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, true)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
  end
end
function PlayerInspect:OnDistanceChanged(distance, markerTargetActive)
  local isWithinDistance = markerTargetActive or distance < self.DIST_VISIBILITY_MAX
  if self.isWithinDistance ~= isWithinDistance then
    self.isWithinDistance = isWithinDistance
    if not self.isWithinDistance then
      UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
    end
  end
  if not self.isWithinDistance then
    return
  end
  self.markerScale = math.max(self.MAX_SCALE - (distance - self.DIST_SCALE_START) / (self.DIST_SCALE_MAX - self.DIST_SCALE_START), self.MIN_SCALE)
end
function PlayerInspect:OnVisibilityChanged(isVisible)
  self.isMarkerVisible = isVisible
  if not self.isMarkerVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
  end
end
function PlayerInspect:ShowFlyout()
  if not self.playerId or not self.playerId:IsValid() then
    return
  end
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  LyShineManagerBus.Broadcast.EnableMouse(true)
  CursorBus.Broadcast.SetCursorPosition(self.canvasCenter)
  self.PFH.markerId = self.playerMarkerId
  self.PFH.isStreaming = MarkerRequestBus.Event.GetIsStreaming(self.playerMarkerId)
  self.PFH.twitchChannel = MarkerRequestBus.Event.GetTwitchChannel(self.playerMarkerId)
  self:PFH_SetPlayerId(self.playerId)
  self:PFH_ShowFlyout(self.Properties.FlyoutAnchor)
  UiElementBus.Event.SetIsEnabled(self.Properties.HintContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, true)
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Background, true)
  self.hitCount = self.hitCount + 1
end
function PlayerInspect:OnClickBackground()
  DynamicBus.FlyoutMenuBus.Broadcast.OnClickBackground()
  self:OnFlyoutClose()
end
function PlayerInspect:OnFlyoutClose()
  if self.isOnHud then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    LyShineManagerBus.Broadcast.ResetMouse()
  end
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.Background, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, false)
end
function PlayerInspect:UpdateCanvasVisibility()
  if self.isFlyoutShowing and not self.isOnHud then
    self:OnClickBackground()
  end
  UiCanvasBus.Event.SetEnabled(self.canvasId, self.isOnHud)
end
function PlayerInspect:OnScreenStateChanged(stateName, isTransitionIn)
  self.isOnHud = stateName == 2702338936 and isTransitionIn
  self:UpdateCanvasVisibility()
end
function PlayerInspect:OnTick(deltaTime, timePoint)
  self.telemetryTimer = self.telemetryTimer + deltaTime
  if self.telemetryTimer > self.TELEMETRY_SEND_PERIOD_SECONDS then
    self:SendTelemetry()
    self.telemetryTimer = self.telemetryTimer - self.TELEMETRY_SEND_PERIOD_SECONDS
  end
end
function PlayerInspect:SendTelemetry()
  local event = UiAnalyticsEvent("social_hotkey_usage")
  event:AddMetric("time_period_seconds", self.TELEMETRY_SEND_PERIOD_SECONDS)
  event:AddMetric("use_count", self.pressCount)
  event:AddMetric("hit_count", self.hitCount)
  event:Send()
  self.pressCount = 0
  self.hitCount = 0
end
return PlayerInspect
