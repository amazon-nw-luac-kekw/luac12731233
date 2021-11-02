local Pinging = {
  Properties = {
    PrototypePing = {
      default = EntityId()
    },
    PrototypeShoutPing = {
      default = EntityId()
    },
    PingWheel = {
      default = EntityId()
    },
    PingTarget = {
      default = EntityId()
    },
    PingContainer = {
      default = EntityId()
    }
  },
  doubleClickTimeTolerance = 0.3,
  singleClickTimeTolerance = 0.3,
  holdClickTimeTolerance = 0.3,
  pingThrottleTime = 0.5,
  timeSinceLastClick = 0,
  timeClickDown = 0,
  timeHoldDown = 0,
  isCurrentlyClicking = false,
  unlockedCameraTime = 0,
  CAMERA_UNLOCK_THRESHOLD = 0.25,
  maxNumPings = ePingSource_Count * 2
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Pinging)
local profiler = RequireScript("LyShineUI._Common.Profiler")
function Pinging:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_pingingEnabled", function(self, isEnabled)
    self.isEnabled = isEnabled and not FtueSystemRequestBus.Broadcast.IsFtue()
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead then
      self.PingWheel:SetWheelVisibility(false, self.isMapShowing)
      JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
    end
  end)
  self:BusConnect(CryActionNotificationsBus, "target_tag")
  self:BusConnect(CryActionNotificationsBus, "target_tag_selection")
  self:BusConnect(DynamicBus.UITickBus)
  self:BusConnect(PingNotificationBus)
  self.optionalActionsToPingType = {
    target_tag_move = ePingType_Move,
    target_tag_attack = ePingType_Attack,
    target_tag_someone = ePingType_Someone,
    target_tag_need_help = ePingType_NeedHelp,
    target_tag_need_healing = ePingType_NeedHealing,
    target_tag_loot = ePingType_Loot,
    target_tag_repair = ePingType_Repair,
    target_tag_defend = ePingType_Defend,
    target_tag_caution = ePingType_Caution,
    target_tag_danger = ePingType_Danger
  }
  for cryAction, _ in pairs(self.optionalActionsToPingType) do
    self:BusConnect(CryActionNotificationsBus, cryAction)
  end
  local parent = UiElementBus.Event.GetParent(self.Properties.PrototypePing)
  self.allPings = {
    self.PrototypePing
  }
  self.allShoutPings = {
    self.PrototypeShoutPing
  }
  for i = 1, self.maxNumPings - 1 do
    local pingTable = CloneUiElement(self.canvasId, self.registrar, self.Properties.PrototypePing, parent, false)
    table.insert(self.allPings, pingTable)
    pingTable = CloneUiElement(self.canvasId, self.registrar, self.Properties.PrototypeShoutPing, parent, false)
    table.insert(self.allShoutPings, pingTable)
  end
  self.pingTypeToPingTable = {}
  local pingsPerSource = 2
  for i = 0, ePingSource_Count - 1 do
    local pingTables = {
      pings = {},
      shoutPings = {}
    }
    for j = 1, pingsPerSource do
      table.insert(pingTables.pings, self.allPings[i * pingsPerSource + j])
      table.insert(pingTables.shoutPings, self.allShoutPings[i * pingsPerSource + j])
    end
    self.pingTypeToPingTable[i] = pingTables
  end
  local aimingReticles = {
    bow = true,
    pistol = true,
    rifle = true,
    spear = true
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ReticleToShow", function(self, weaponName)
    self.isAiming = aimingReticles[weaponName]
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.IsCameraLocked", function(self, isCameraLocked)
    self.isCameraLocked = isCameraLocked
  end)
  self.pingTypesToChatText = {
    [ePingType_NeedRevive] = "@ui_ping_type_chat_NeedRevive"
  }
  self.pingTypesToShoutText = {
    [ePingType_Danger] = "@ui_shout_ping_notification_Danger",
    [ePingType_Move] = "@ui_shout_ping_notification_Move",
    [ePingType_Attack] = "@ui_shout_ping_notification_Attack",
    [ePingType_Defend] = "@ui_shout_ping_notification_Defend",
    [ePingType_Caution] = "@ui_shout_ping_notification_Caution",
    [ePingType_Someone] = "@ui_shout_ping_notification_Someone",
    [ePingType_Loot] = "@ui_shout_ping_notification_Loot",
    [ePingType_Repair] = "@ui_shout_ping_notification_Repair",
    [ePingType_NeedHelp] = "@ui_ping_type_notification_NeedHelp",
    [ePingType_NeedHealing] = "@ui_ping_type_notification_NeedHealing"
  }
  local CanvasCommon = RequireScript("LyShineUI._Common.CanvasCommon")
  local originalDrawOrder = UiCanvasBus.Event.GetDrawOrder(self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.dataLayer:GetIsScreenOpenDatapath("MagicMap"), function(self, isMapShowing)
    self.isMapShowing = isMapShowing
    UiCanvasBus.Event.SetDrawOrder(self.canvasId, isMapShowing and CanvasCommon.MAP_DRAW_ORDER + 1 or originalDrawOrder)
    UiElementBus.Event.SetIsEnabled(self.Properties.PingContainer, not self.isMapShowing)
  end)
  self.selfPingName = "@ui_self"
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      self.selfPingName = PlayerComponentRequestsBus.Event.GetPlayerIdentification(playerEntityId).playerName
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_pingingThrottle", function(self, pingThrottleTime)
    if pingThrottleTime then
      self.pingThrottleTime = pingThrottleTime
    end
  end)
end
function Pinging:OnShutdown()
  BaseScreen.OnShutdown(self)
  for index, pingTable in ipairs(self.allPings) do
    if pingTable.entityId ~= self.Properties.PrototypePing then
      UiElementBus.Event.DestroyElement(pingTable.entityId)
    end
  end
  for index, pingTable in ipairs(self.allShoutPings) do
    if pingTable.entityId ~= self.Properties.PrototypeShoutPing then
      UiElementBus.Event.DestroyElement(pingTable.entityId)
    end
  end
end
function Pinging:OnTick(deltaTime, timePoint)
  if self.isCameraLocked then
    self.unlockedCameraTime = 0
  else
    self.unlockedCameraTime = self.unlockedCameraTime + deltaTime
  end
  if self.isCurrentlyClicking then
    self.timeClickDown = self.timeClickDown + deltaTime
  end
  if self.isHoldActive and not self.hasHeldTriggered then
    self.timeHoldDown = self.timeHoldDown + deltaTime
    if self.timeHoldDown >= self.holdClickTimeTolerance then
      self.hasHeldTriggered = true
      self:OnClickHold()
    end
  end
  self.timeSinceLastClick = self.timeSinceLastClick + deltaTime
  if self.queuedChatNotification then
    self.queuedChatNotificationTime = self.queuedChatNotificationTime - deltaTime
    if 0 >= self.queuedChatNotificationTime then
      self:SendChatNotification(self.queuedChatNotification, ePingSource_Self, self.queuedChatIsShout)
      self.queuedChatNotification = nil
    end
  end
end
function Pinging:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:SetIsTicking(true)
end
function Pinging:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:SetIsTicking(false)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
end
function Pinging:SetIsTicking(isTicking)
  if isTicking then
    if not self.tickBusHandler then
      self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
    end
  elseif self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
    self:ResetClick()
    self:ResetHold()
  end
end
function Pinging:DisablePingAfterLock()
  if self.isCameraLocked or self.unlockedCameraTime < self.CAMERA_UNLOCK_THRESHOLD then
    return true
  end
  return false
end
local zeroVec = Vector3(0, 0, 0)
function Pinging:OnSingleClick(pingTypeOverride)
  if self:DisablePingAfterLock() then
    return
  end
  local worldPos
  local pingType = pingTypeOverride
  if self.isMapShowing then
    worldPos = DynamicBus.MagicMap.Broadcast.GetCursorWorldPosition()
    if pingType == nil then
      pingType = ePingType_Move
    end
    DynamicBus.MagicMap.Broadcast.PingAtLocation("lyshineui/images/icons/pingtypes/pingTypeMove.png", self.UIStyle.COLOR_YELLOW_GOLD, worldPos)
  else
    worldPos = zeroVec
    if pingType == nil then
      pingType = self.isAiming and ePingType_Attack or ePingType_Contextual
    end
    if self:TryInteractPing(self.allPings) or self:TryInteractPing(self.allShoutPings) then
      return true
    end
  end
  PingRequestBus.Broadcast.RequestPing(pingType, false, self.pingThrottleTime, worldPos)
end
function Pinging:TryInteractPing(pingsToUse)
  for _, ping in ipairs(pingsToUse) do
    if ping:CanInteractWithPing() then
      if ping:IsOwnPing() then
        PingRequestBus.Broadcast.CancelPing()
      else
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = "@ui_waypoint_set_to_ping"
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
        WaypointsRequestBus.Broadcast.RequestSetWaypoint(ping:GetWorldPosition())
        PingRequestBus.Broadcast.OnPingedWaypoint()
      end
      return true
    end
  end
  return false
end
function Pinging:OnDoubleClick()
  if self.isMapShowing then
    return
  end
  if self:DisablePingAfterLock() then
    return
  end
  local doubleClickPingType = ePingType_Danger
  PingRequestBus.Broadcast.ModifyLastPingRequest(doubleClickPingType)
  local pingsToUse = self.pingTypeToPingTable[ePingSource_Self]
  for _, ping in ipairs(pingsToUse.pings) do
    if ping:IsPingActive() then
      ping:OnUpdatePing(doubleClickPingType)
      self:SendChatNotification(doubleClickPingType, ePingSource_Self, false)
      self.queuedChatNotification = nil
    end
  end
end
function Pinging:CanPing()
  return LyShineManagerBus.Broadcast.GetCurrentLevel() <= 0 or self.isMapShowing
end
function Pinging:OnClickHold()
  if self:DisablePingAfterLock() then
    return
  end
  self.PingWheel:SetWheelVisibility(true, self.isMapShowing)
end
function Pinging:OnCryAction(actionName, value)
  if not self.isEnabled or not self:CanPing() then
    return
  end
  local pingTypeOverride = self.optionalActionsToPingType[actionName]
  if pingTypeOverride then
    self:OnSingleClick(pingTypeOverride)
    return
  end
  local isPress = 0 < value
  if actionName == "target_tag" then
    if isPress then
      self.timeClickDown = 0
      self.isCurrentlyClicking = true
    elseif self.isCurrentlyClicking then
      if self.timeSinceLastClick < self.doubleClickTimeTolerance and not self.lastClickWasDouble then
        self:OnDoubleClick()
        self.lastClickWasDouble = true
      elseif self.timeClickDown <= self.singleClickTimeTolerance then
        self:OnSingleClick()
        self.lastClickWasDouble = false
      end
      self:ResetClick()
    end
  else
    if not isPress and self.isHoldActive then
      self.PingWheel:SetWheelVisibility(false)
      self:ResetHold()
    end
    self.isHoldActive = isPress
    self.hasHeldTriggered = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PingTarget, isPress)
  if not isPress then
    JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  end
end
function Pinging:ResetClick()
  self.timeSinceLastClick = 0
  self.isCurrentlyClicking = false
end
function Pinging:ResetHold()
  self.timeHoldDown = 0
  self.isHoldActive = false
end
function Pinging:OnPingShown(worldPos, pingSourceId, pingType, isShout, playerName)
  local pingsToUse = self.pingTypeToPingTable[pingSourceId]
  if not pingsToUse then
    Debug.Log([[
Warning, ping failed to display, failed to find 
 pings to use = ]] .. tostring(pingSourceId))
    return
  end
  local pingSet = isShout and pingsToUse.shoutPings or pingsToUse.pings
  local pingTable
  for _, ping in ipairs(pingSet) do
    if not ping:IsPingActive() then
      pingTable = ping
      break
    end
  end
  for _, pingSet in pairs(pingsToUse) do
    for _, ping in ipairs(pingSet) do
      if ping:IsPingActive() then
        ping:OnHidePing()
        pingTable = pingTable or ping
      end
    end
  end
  pingTable:OnShowPing(worldPos, pingSourceId, pingType, isShout, playerName)
  local isOwnPing = pingSourceId == ePingSource_Self
  if isOwnPing then
    self.queuedChatNotification = pingType
    self.queuedChatIsShout = isShout
    self.queuedChatNotificationTime = self.doubleClickTimeTolerance
  else
    self:SendChatNotification(pingType, pingSourceId, isShout, playerName)
  end
  if isShout then
    local shoutText = self.pingTypesToShoutText[pingType]
    if shoutText then
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = shoutText
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
end
local chatMessage = BaseGameChatMessage()
function Pinging:SendChatNotification(pingType, pingSourceId, isShout, playerName)
  local isOwnPing = pingSourceId == ePingSource_Self
  if isOwnPing then
    local groupId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.Id")
    local isInGroup = groupId and groupId:IsValid()
    if not isInGroup then
      return
    end
  end
  local pingChatText = self.pingTypesToChatText[pingType]
  if pingChatText then
    local chatType = eChatMessageType_Group
    local chatMessageText = GetLocalizedReplacementText(pingChatText, {
      playerName = isOwnPing and self.selfPingName or playerName
    })
    chatMessage.isPingMsg = true
    chatMessage.type = chatType
    chatMessage.body = chatMessageText
    ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    if isShout then
      chatMessage.type = eChatMessageType_GroupAlert
      chatMessage.body = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.pingTypesToShoutText[pingType])
      chatMessage.isPingMsg = false
      ChatComponentBus.Broadcast.WriteMessageToLocalChat(chatMessage)
    end
  end
end
function Pinging:OnPingCancelled(pingSourceId)
  local pingsToUse = self.pingTypeToPingTable[pingSourceId]
  for _, ping in ipairs(pingsToUse.pings) do
    ping:OnHidePing()
  end
  for _, ping in ipairs(pingsToUse.shoutPings) do
    ping:OnHidePing()
  end
end
function Pinging:OnScreenStateChanged(stateName, isTransitionIn)
  if isTransitionIn and self.isHoldActive then
    self.PingWheel:SetWheelVisibility(false)
    self:ResetHold()
  end
end
return Pinging
