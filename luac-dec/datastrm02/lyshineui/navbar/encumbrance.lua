local Encumbrance = {
  Properties = {
    EncumbranceHolder = {
      default = EntityId()
    },
    EncumbranceWarningWeight = {
      default = EntityId()
    },
    InventoryHint = {
      default = EntityId()
    },
    InventoryImage = {
      default = EntityId()
    },
    EncumbranceFill = {
      default = EntityId()
    },
    EncumbranceTweenValue = {
      default = EntityId()
    },
    InventoryTooltip = {
      default = EntityId()
    },
    PvpHolder = {
      default = EntityId()
    },
    PvpFactionIcon = {
      default = EntityId()
    },
    PvpStatusIcon = {
      default = EntityId()
    },
    PvpHint = {
      default = EntityId()
    },
    PvpTooltip = {
      default = EntityId()
    },
    PvpTimerHolder = {
      default = EntityId()
    },
    PvpCountdownTimer = {
      default = EntityId()
    },
    PvpTimerLabel = {
      default = EntityId()
    },
    PvpDivider = {
      default = EntityId()
    },
    PvpTimerBg = {
      default = EntityId()
    },
    PvpTimerFill = {
      default = EntityId()
    },
    CraftItemSwirlAnim1 = {
      default = EntityId()
    },
    CraftItemSwirlAnim2 = {
      default = EntityId()
    },
    RingAnim = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    MessageText = {
      default = EntityId()
    },
    LootTickerItem = {
      default = EntityId()
    },
    HorizontalLine = {
      default = EntityId()
    },
    VerticalLine = {
      default = EntityId()
    },
    QuickslotsContainer = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    }
  },
  STATE_NAME_BUILDMODE = 3406343509,
  isInitialUpdate = true,
  updateWeight = true,
  isEncumberedWarningShown = nil,
  isAlmostEncumberedWarningShown = nil,
  wasEncumbered = false,
  isEncumbered = false,
  isAtWar = false,
  isLoadingScreenShowing = nil,
  isFtue = false,
  queuedEncumbrance = nil,
  faction = eFactionType_None,
  masterContainerCraftAnimPos = -10,
  screenStatesToDisable = {
    [2477632187] = true,
    [2478623298] = true,
    [3406343509] = true,
    [3024636726] = true,
    [3901667439] = true,
    [3777009031] = true,
    [3493198471] = true,
    [3576764016] = true,
    [1967160747] = true,
    [4143822268] = true,
    [1628671568] = true,
    [2815678723] = true,
    [3175660710] = true,
    [1823500652] = true,
    [156281203] = true,
    [3784122317] = true,
    [2609973752] = true,
    [849925872] = true,
    [640726528] = true,
    [3370453353] = true,
    [2896319374] = true,
    [828869394] = true,
    [3211015753] = true,
    [2640373987] = true,
    [2437603339] = true,
    [1319313135] = true,
    [1468490675] = true,
    [1101180544] = true,
    [3664731564] = true,
    [4119896358] = true,
    [1634988588] = true,
    [319051850] = true,
    [921202721] = true
  },
  pvpStateIcons = {
    [ePvpFlag_Off] = "lyshineui/images/icons/encumbrance/icon_pveflag.dds",
    [ePvpFlag_Pending] = "lyshineui/images/icons/encumbrance/icon_pvpflag.dds",
    [ePvpFlag_On] = "lyshineui/images/icons/encumbrance/icon_pvpflag.dds"
  },
  pvpStateTexts = {
    [ePvpFlag_Off] = "@ui_toggle_pvp_off",
    [ePvpFlag_Pending] = "@ui_toggle_pvp_on",
    [ePvpFlag_On] = "@ui_toggle_pvp_on"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Encumbrance)
local timeHelpers = RequireScript("LyShineUI._Common.TimeHelperFunctions")
local audioHelper = RequireScript("LyShineUI.AudioEvents")
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function Encumbrance:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  self:SetVisualElements()
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self:BusConnect(TutorialComponentNotificationsBus, self.canvasId)
  self:BusConnect(GroupsUINotificationBus)
  self:BusConnect(CryActionNotificationsBus, "togglePvpFlag")
  self.dataLayer:RegisterOpenEvent("Encumbrance", self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Encumbrance.ShouldUpdateWeight", function(self, data)
    if data == nil then
      data = true
    end
    self.updateWeight = data
    if self.updateWeight and self.localPlayerIsSet then
      self:OnEncumbranceChanged()
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, data)
    if data then
      self.inventoryId = data
      self.encumbrancePercentageToWarn = ContainerRequestBus.Event.GetEncumbranceWarningPercent(self.inventoryId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    self.localPlayerIsSet = isSet
    if isSet then
      self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Inventory.CurrentEncumbrance", self.OnEncumbranceChanged)
    end
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.StackSplitter.InventoryStackWeight", function(self, stackWeight)
    if stackWeight then
      local maxEncumbranceValue = LocalPlayerUIRequestsBus.Broadcast.GetMaximumEncumbrance()
      if maxEncumbranceValue == 0 then
        return
      end
      local encumbranceValue = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Inventory.CurrentEncumbrance")
      local adjustedValue = encumbranceValue - stackWeight
      local isEncumbered = maxEncumbranceValue <= adjustedValue
      local color = isEncumbered and self.UIStyle.COLOR_WARNING_ENCUMBERED or self.UIStyle.COLOR_WHITE
      local newFillAmount = adjustedValue / maxEncumbranceValue
      UiImageBus.Event.SetFillAmount(self.EncumbranceFill, newFillAmount)
      self.ScriptedEntityTweener:Set(self.EncumbranceFill, {imgColor = color})
      self.ScriptedEntityTweener:Set(self.InventoryImage, {imgColor = color})
      if isEncumbered then
        self.timeline:Play()
        self.timelineInventory:Play()
      else
        self.ScriptedEntityTweener:Play(self.EncumbranceFill, 0, {opacity = 1})
        self.ScriptedEntityTweener:Play(self.InventoryImage, 0, {opacity = 0.5})
      end
    end
  end)
  local screenOpenedDataPath = self.dataLayer:GetIsScreenOpenDatapath("NewInventory")
  self.dataLayer:RegisterAndExecuteDataObserver(self, screenOpenedDataPath, function(self, isShowing)
    self.isInventoryOpen = isShowing
    self:SetElementsVisible(not self.isInventoryOpen)
    self:SetEncumbranceWarningTextVisible(not self.isInventoryOpen)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PvpFlagPendingEndTime", self.UpdatePvpProtectionTimerEndTime)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Faction", self.UpdatePvpAvailable)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.PvpFlag", self.UpdatePvpState)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HasSanctuary", self.UpdateSanctuary)
  self.ScriptedEntityTweener:Set(self.Properties.PvpHolder, {x = -47})
  DynamicBus.EncumbranceBus.Connect(self.entityId, self)
  UiTextBus.Event.SetTextWithFlags(self.MessageText, "@ui_added_to_inventory", eUiTextSet_SetLocalized)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", function(self, setLang)
    local inventoryKey = LyShineManagerBus.Broadcast.GetKeybind("toggleInventoryWindow", "ui")
    self.InventoryTooltip:SetSimpleTooltip(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_inventory_tooltip", inventoryKey))
    self.PvpTooltip:SetSimpleTooltip("@ui_notification_pvp_flagging_message")
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Video.HudAlwaysFade", function(self, hudAlwaysFade)
    if hudAlwaysFade ~= nil then
      self.hudAlwaysFade = hudAlwaysFade
      self:UpdateEncumbranceHolderVisibility()
      if self.hudAlwaysFade then
        self:SetEncumbranceVisible(self.encumbered or self.shouldWarn)
      else
        self:SetEncumbranceVisible(true)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Raid.Id", function(self, raidId)
    self.isInRaid = raidId and raidId:IsValid()
    self:UpdatePvpAvailable(self.faction, true)
  end)
  DynamicBus.LootTickerNotifications.Connect(self.entityId, self)
  local hudSettingCommon = RequireScript("LyShineUI._Common.HudSettingCommon")
  hudSettingCommon:RegisterEntityToFadeOnSprint(self.entityId)
end
function Encumbrance:OnSiegeWarfareStarted(warId)
  self.isAtWar = true
  self:SetElementsVisible(not self.isInventoryOpen)
end
function Encumbrance:OnSiegeWarfareEnded(isWinner, resolutionPhaseEndTimePoint)
  self:OnSiegeWarfareCompleted()
end
function Encumbrance:OnSiegeWarfareCompleted()
  self.isAtWar = false
  self:SetElementsVisible(not self.isInventoryOpen)
end
function Encumbrance:OnAllOutboundGroupInvitesRemoved()
  if self.togglePvPFlagWhenAllOutboundGroupInvitesRemoved then
    local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    FactionRequestBus.Event.RequestTogglePvpFlag(playerRootEntityId)
    self.togglePvPFlagWhenAllOutboundGroupInvitesRemoved = false
  end
end
function Encumbrance:OnCryAction(actionName, value)
  if actionName == "togglePvpFlag" then
    self:OnTogglePvpFlag()
  end
end
function Encumbrance:SetVisualElements()
  self.InventoryHint:SetKeybindMapping("toggleInventoryWindow")
  self.PvpHint:SetKeybindMapping("togglePvpFlag")
  self.InventoryHint:SetCallback(function()
    LocalPlayerUIRequestsBus.Broadcast.SetIsLookingThroughLoadout(true)
  end, self)
  self.PvpHint:SetCallback(self.OnTogglePvpFlag, self)
  if self.isFtue then
    self:HideUIElements()
  end
end
function Encumbrance:OnLoadingScreenDismissed()
  self.isLoadingScreenShowing = false
end
function Encumbrance:OnTick(deltaTime, timePoint)
  if self.updateProtectionTimer then
    local now = timeHelpers:ServerNow()
    if now >= self.pvpProtectionTimerEndTime then
      self.updateProtectionTimer = false
    else
      local timeRemaining = self.pvpProtectionTimerEndTime:Subtract(now):ToSecondsRoundedUp()
      if self.lastTimeRemaining ~= timeRemaining then
        self.lastTimeRemaining = timeRemaining
        UiTextBus.Event.SetTextWithFlags(self.Properties.PvpCountdownTimer, timeRemaining, eUiTextSet_SetAsIs)
        UiTextBus.Event.SetTextWithFlags(self.Properties.PvpTimerLabel, "@ui_pvp_protection_label", eUiTextSet_SetLocalized)
        local percent = timeRemaining / self.totalTime
        self.ScriptedEntityTweener:Set(self.Properties.PvpTimerFill, {imgFill = percent})
        UiElementBus.Event.SetIsEnabled(self.Properties.PvpTimerLabel, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.PvpTimerBg, true)
        UiElementBus.Event.SetIsEnabled(self.Properties.PvpCountdownTimer, true)
      end
    end
  end
  if not self.updateProtectionTimer then
    self:StopTicking()
    UiElementBus.Event.SetIsEnabled(self.Properties.PvpTimerLabel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.PvpTimerBg, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.PvpCountdownTimer, false)
  end
end
function Encumbrance:StartTicking()
  if not self.tickBusHandler then
    self.tickBusHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function Encumbrance:StopTicking()
  if self.tickBusHandler then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
end
function Encumbrance:OnShutdown()
  self.dataLayer:DeregisterOnScreenOpen("Encumbrance")
  self:StopTicking()
  DynamicBus.EncumbranceBus.Disconnect(self.entityId, self)
  DynamicBus.LootTickerNotifications.Disconnect(self.entityId, self)
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
  if self.timelineInventory ~= nil then
    self.timelineInventory:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timelineInventory)
  end
end
function Encumbrance:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  if self.screenStatesToDisable[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function Encumbrance:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  if toLevel <= 0 then
    self.ScriptedEntityTweener:Stop(self.Properties.CraftItemSwirlAnim1)
    self.ScriptedEntityTweener:Stop(self.Properties.CraftItemSwirlAnim2)
    self.ScriptedEntityTweener:Stop(self.Properties.Message)
    self.ScriptedEntityTweener:Stop(self.Properties.MessageText)
    self.ScriptedEntityTweener:Stop(self.Properties.LootTickerItem)
    self:HideCraftAnimation()
  end
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.screenStatesToDisable[fromState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  end
end
function Encumbrance:SetElementsVisible(isVisible)
  if isVisible == true then
    local animDuration = 0.25
    local animDurationAlpha = 0.4
    if self.pvpAvailable then
      self:SetPvpFlagVisible(true)
    else
      self:SetPvpFlagVisible(false)
    end
  else
    local animDuration = 0.25
    local animDurationAlpha = 0.2
    local scaleHide = 0.2
    if self.isInventoryOpen and self.pvpAvailable then
      self:SetPvpFlagVisible(false)
    end
  end
  self:UpdateEncumbranceHolderVisibility()
end
function Encumbrance:UpdatePvpAvailable(faction, force)
  if self.faction == faction and not force then
    return
  end
  self.faction = faction
  self.pvpAvailable = faction ~= eFactionType_None
  self:SetElementsVisible(not self.isInventoryOpen)
  self:SetFactionIcon(faction)
end
function Encumbrance:SetFactionIcon(faction)
  if not self.pvpAvailable or faction == eFactionType_None then
    return
  end
  local data = factionCommon.factionInfoTable[faction]
  if not data then
    return
  end
  self.PvpFactionIcon:SetBackground(data.crestFgSmallOutline, self.UIStyle.COLOR_BLACK)
  self.PvpFactionIcon:SetForeground(data.crestFgSmall, data.crestBgColor)
end
function Encumbrance:UpdatePvpState(pvpState)
  self.pvpState = pvpState
  if self.pvpAvailable then
    if self.pvpStateIcons[self.pvpState] then
      UiImageBus.Event.SetSpritePathname(self.Properties.PvpStatusIcon, self.pvpStateIcons[self.pvpState])
    end
    local animDurationAlpha = 0.2
    if self.pvpState ~= ePvpFlag_Pending then
      self.ScriptedEntityTweener:Play(self.Properties.PvpTimerHolder, animDurationAlpha, {opacity = 0, ease = "QuadOut"})
    end
    if not LoadScreenBus.Broadcast.IsLoadingScreenShown() then
      if self.pvpState == ePvpFlag_On then
        self.audioHelper:PlaySound(self.audioHelper.OnPvpFlag_On)
      elseif self.pvpState == ePvpFlag_Off then
        self.audioHelper:PlaySound(self.audioHelper.OnPvpFlag_Off)
      elseif self.pvpState == ePvpFlag_Pending then
        self.audioHelper:PlaySound(self.audioHelper.OnPvpFlag_Pending)
      end
    end
  end
end
function Encumbrance:UpdateSanctuary(hasSanctuary)
  self.hasSanctuary = hasSanctuary
  if self.pvpAvailable then
    self:SetElementsVisible(not self.isInventoryOpen)
    local animDuration = 0.25
    local animDurationAlpha = 0.2
    if self.hasSanctuary then
      self.updateProtectionTimer = false
      self.ScriptedEntityTweener:Play(self.Properties.PvpHint, animDurationAlpha, {opacity = 1, ease = "QuadOut"})
    else
      self.ScriptedEntityTweener:Play(self.Properties.PvpHint, animDurationAlpha, {opacity = 0, ease = "QuadOut"})
    end
  end
end
function Encumbrance:UpdatePvpProtectionTimerEndTime(endTime)
  if self.pvpAvailable then
    local now = timeHelpers:ServerNow()
    self.pvpProtectionTimerEndTime = endTime
    self.totalTime = self.pvpProtectionTimerEndTime:SubtractSeconds(now):ToSeconds()
    local animDurationAlpha = 0.2
    if now >= self.pvpProtectionTimerEndTime then
      self.updateProtectionTimer = false
      self.ScriptedEntityTweener:Play(self.Properties.PvpTimerHolder, animDurationAlpha, {opacity = 0, ease = "QuadOut"})
      self.ScriptedEntityTweener:Set(self.Properties.PvpHolder, {opacity = 0.5})
      return
    end
    self.ScriptedEntityTweener:Play(self.Properties.PvpTimerHolder, animDurationAlpha, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Set(self.Properties.PvpHolder, {opacity = 1})
    self.updateProtectionTimer = true
    self:StartTicking()
    self.audioHelper:PlaySound(self.audioHelper.OnPvpFlag_Timer)
  end
end
function Encumbrance:SetGloryBarAvailablePoints(hasAvailablePoints)
  if hasAvailablePoints == nil then
    return
  end
  self.isGloryAvailable = hasAvailablePoints
  self:SetGloryBarVisible(self.isGloryAvailable)
  self.GloryHint:SetHighlightVisible(self.isGloryAvailable)
end
function Encumbrance:OnTogglePvpFlag()
  if self.faction == eFactionType_None then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_pvp_error_no_faction"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  if not self.hasSanctuary then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    if self.pvpState == ePvpFlag_Off then
      notificationData.text = "@ui_pvp_error_no_sanctuary_flag_off"
    else
      notificationData.text = "@ui_pvp_error_no_sanctuary_flag_on"
    end
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local objEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.ObjectiveEntityId")
  if ObjectivesComponentRequestBus.Event.HasPvpObjective(objEntityId) then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@ui_pvp_error_has_pvp_objective"
    notificationData.allowDuplicates = true
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  local playerRootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  if GroupsRequestBus.Broadcast.IsInGroup() then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_togglepvpblocked_title", "@ui_togglepvpblocked_ingroup", "pvpToggleBlocked_InGroup", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Group.Id", function(self, groupId)
          self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.Group.Id")
          FactionRequestBus.Event.RequestTogglePvpFlag(playerRootEntityId)
        end)
        GroupsRequestBus.Broadcast.RequestLeaveGroup()
      end
    end)
    return
  end
  if GroupsRequestBus.Broadcast.HasPendingNewGroupInvite() then
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_togglepvpblocked_title", "@ui_togglepvpblocked_pendinginvites", "pvpToggleBlocked_PendingInvites", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        self.togglePvPFlagWhenAllOutboundGroupInvitesRemoved = true
        GroupsRequestBus.Broadcast.RequestWithdrawInvites()
      end
    end)
    return
  end
  FactionRequestBus.Event.RequestTogglePvpFlag(playerRootEntityId)
end
function Encumbrance:SetEncumbranceVisible(isVisible, delay, onCompleteFunction)
  if self.encumbranceHidden then
    return
  end
  if delay == nil then
    delay = 0
  end
  if isVisible then
    local animDurationAlpha = 0.5
    self.ScriptedEntityTweener:Play(self.Properties.EncumbranceHolder, animDurationAlpha, {
      opacity = 1,
      ease = "QuadOut",
      delay = delay
    })
    self.ScriptedEntityTweener:Play(self.Properties.PvpHolder, animDurationAlpha, {x = -123, ease = "QuadOut"})
    self.ScriptedEntityTweener:PlayC(self.Properties.PvpDivider, 0.25, tweenerCommon.fadeOutQuadOut)
  else
    local animDurationAlpha = 0.5
    if not self.isEncumbered and not self.isAlmostEncumberedWarningShown then
      if onCompleteFunction then
        self.ScriptedEntityTweener:Play(self.Properties.EncumbranceHolder, 0.5, {
          opacity = 0,
          ease = "QuadOut",
          onComplete = onCompleteFunction
        })
      else
        self.ScriptedEntityTweener:Play(self.Properties.EncumbranceHolder, 0.5, {opacity = 0, ease = "QuadOut"})
      end
      self.ScriptedEntityTweener:Play(self.Properties.PvpHolder, animDurationAlpha, {x = -47, ease = "QuadOut"})
      self.ScriptedEntityTweener:PlayC(self.Properties.PvpDivider, 0.25, tweenerCommon.fadeInQuadOut)
    end
  end
end
function Encumbrance:SetPvpFlagVisible(isVisible)
  if isVisible and (self.pvpState ~= ePvpFlag_Off or self.hasSanctuary) and not self.isInRaid then
    local animDuration = 0.25
    local animDurationAlpha = 0.4
    local opacityAmount
    if self.updateProtectionTimer or self.hasSanctuary then
      opacityAmount = 1
    else
      opacityAmount = 0.5
    end
    self.ScriptedEntityTweener:Play(self.PvpHolder, animDurationAlpha, {opacity = opacityAmount, ease = "QuadOut"})
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PvpTooltip, true)
  else
    local animDuration = 0.25
    local animDurationAlpha = 0.2
    self.ScriptedEntityTweener:Play(self.PvpHolder, animDurationAlpha, {opacity = 0, ease = "QuadOut"})
    UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PvpTooltip, false)
  end
end
function Encumbrance:OnEncumbranceChanged(data)
  if data ~= nil then
    self.queuedEncumbrance = data
  end
  if self.queuedEncumbrance ~= nil and self.updateWeight then
    self.isEncumbered = LocalPlayerUIRequestsBus.Broadcast.IsEncumbered()
    self.shouldWarn = LocalPlayerUIRequestsBus.Broadcast.ShouldWarnAboutEncumbrance()
    local currentWeight = self.queuedEncumbrance / 10
    local maxWeight = LocalPlayerUIRequestsBus.Broadcast.GetMaximumEncumbrance() / 10
    local maxEncumbrance = LocalPlayerUIRequestsBus.Broadcast.GetMaximumEncumbrance() * ContainerRequestBus.Event.GetFullWhenEncumberedModifier(self.inventoryId)
    local weightText = LocalizeDecimalSeparators(string.format("%.1f/%.1f", currentWeight, maxWeight))
    local currentWeightText = LocalizeDecimalSeparators(string.format("%.1f", currentWeight))
    local maxWeightText = LocalizeDecimalSeparators(string.format("/%.1f", maxWeight))
    local colorEncumbered = self.UIStyle.COLOR_WARNING_ENCUMBERED
    local colorNormal = self.UIStyle.COLOR_WHITE
    local animDuration = 0.3
    if self.wasEncumbered ~= self.isEncumbered then
      DynamicBus.NotificationsRequestBus.Broadcast.EnableMovementWarnings(self.isEncumbered)
      self.wasEncumbered = self.isEncumbered
      self:UpdateEncumbranceHolderVisibility()
      if self.hudAlwaysFade then
        self:SetEncumbranceVisible(self.isEncumbered)
      end
    end
    local weightPercentage = self.queuedEncumbrance / maxEncumbrance
    if weightPercentage > self.encumbrancePercentageToWarn then
      if self.encumbranceNotification then
        UiNotificationsBus.Broadcast.RescindNotification(self.encumbranceNotification, true, true)
        self.encumbranceNotification = nil
      end
      if 0.99 <= weightPercentage then
        message = "@ui_inventoryMaxWeight"
      else
      end
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = message
      self.encumbranceNotification = UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    DynamicBus.EquipmentBus.Broadcast.SetEquipLoadCategory()
    if self.isEncumbered then
      if self.isEncumberedWarningShown ~= true then
        if self.isLoadingScreenShowing == false then
          self.audioHelper:PlaySound(self.audioHelper.OnEncumberedBackpack)
        end
        self.isEncumberedWarningShown = true
        self.isAlmostEncumberedWarningShown = false
        self.ScriptedEntityTweener:Play(self.EncumbranceWarningWeight, animDuration, {textColor = colorEncumbered, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.EncumbranceFill, animDuration, {imgColor = colorEncumbered, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.InventoryImage, animDuration, {imgColor = colorEncumbered, ease = "QuadOut"})
        if not self.timeline then
          self.timeline = self.ScriptedEntityTweener:TimelineCreate()
          self.timeline:Add(self.EncumbranceFill, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
          self.timeline:Add(self.EncumbranceFill, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 1})
          self.timeline:Add(self.EncumbranceFill, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
            opacity = 0.4,
            onComplete = function()
              self.timeline:Play()
            end
          })
        end
        self.timeline:Play()
        if not self.timelineInventory then
          self.timelineInventory = self.ScriptedEntityTweener:TimelineCreate()
          self.timelineInventory:Add(self.InventoryImage, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
          self.timelineInventory:Add(self.InventoryImage, self.UIStyle.DURATION_TIMELINE_HOLD, {opacity = 1})
          self.timelineInventory:Add(self.InventoryImage, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {
            opacity = 0.4,
            onComplete = function()
              self.timelineInventory:Play()
            end
          })
        end
        self.timelineInventory:Play()
      end
    else
      local shouldUpdateColors = false
      if self.shouldWarn and self.isAlmostEncumberedWarningShown ~= true then
        if self.isEncumberedWarningShown == true then
          self.audioHelper:PlaySound(self.audioHelper.OnUnencumberedBackpack)
        end
        self.isEncumberedWarningShown = false
        self.isAlmostEncumberedWarningShown = true
        shouldUpdateColors = true
        if self.hudAlwaysFade then
          self:SetEncumbranceVisible(self.shouldWarn)
        end
      elseif not self.shouldWarn and (self.isEncumberedWarningShown == true or self.isAlmostEncumberedWarningShown == true) then
        if self.isEncumberedWarningShown == true then
          self.audioHelper:PlaySound(self.audioHelper.OnUnencumberedBackpack)
        end
        self.isEncumberedWarningShown = false
        self.isAlmostEncumberedWarningShown = false
        shouldUpdateColors = true
        if self.hudAlwaysFade then
          self:SetEncumbranceVisible(false)
        end
      end
      if shouldUpdateColors then
        self.ScriptedEntityTweener:Play(self.EncumbranceWarningWeight, animDuration, {textColor = colorNormal, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.EncumbranceFill, animDuration, {imgColor = colorNormal, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.EncumbranceFill, animDuration, {opacity = 1, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.InventoryImage, animDuration, {imgColor = colorNormal, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.InventoryImage, animDuration, {opacity = 0.5, ease = "QuadOut"})
      end
    end
    UiTextBus.Event.SetText(self.EncumbranceWarningWeight, weightText)
    local isWarningWeightShowable = not self.isInventoryOpen and (self.isEncumbered or self.shouldWarn)
    self:SetEncumbranceWarningTextVisible(isWarningWeightShowable)
    local currentFillAmount = UiImageBus.Event.GetFillAmount(self.EncumbranceFill)
    local newFillAmount = currentWeight / maxWeight
    if self.isInitialUpdate then
      UiImageBus.Event.SetFillAmount(self.EncumbranceFill, newFillAmount)
      self.isInitialUpdate = false
    else
      local animDuration = 0.2
      self.ScriptedEntityTweener:Play(self.EncumbranceTweenValue, animDuration, {x = currentFillAmount}, {
        x = newFillAmount,
        ease = "QuadOut",
        onUpdate = function(currentValue, currentProgressPercent)
          if currentProgressPercent ~= 0 then
            UiImageBus.Event.SetFillAmount(self.EncumbranceFill, currentValue)
          end
        end
      })
    end
    self.queuedEncumbrance = nil
  end
end
function Encumbrance:SetEncumbranceWarningTextVisible(isVisible)
  local animDuration = 0.2
  if isVisible then
    if self.isEncumberedWarningShown or self.isAlmostEncumberedWarningShown then
      self.ScriptedEntityTweener:Play(self.EncumbranceWarningWeight, animDuration, {
        opacity = 1,
        y = -18,
        ease = "QuadOut"
      })
    end
  else
    self.ScriptedEntityTweener:Play(self.EncumbranceWarningWeight, animDuration, {
      opacity = 0,
      y = 0,
      ease = "QuadOut"
    })
  end
  self:UpdateEncumbranceHolderVisibility()
end
function Encumbrance:OnLootTickerVisibilityChange(isVisible)
  self.isLootTickerVisible = isVisible
  if self.hudAlwaysFade then
    if isVisible then
      self:SetEncumbranceVisible(true, 0.5)
      self:UpdateEncumbranceHolderVisibility()
    else
      self:SetEncumbranceVisible(false, 0, function()
        self:UpdateEncumbranceHolderVisibility()
      end)
    end
  else
    self:SetEncumbranceVisible(true)
    self:UpdateEncumbranceHolderVisibility()
  end
end
function Encumbrance:UpdateEncumbranceHolderVisibility()
  if self.encumbranceHidden then
    return
  end
  local isVisible = true
  if self.hudAlwaysFade then
    if self.isInventoryOpen then
      isVisible = false
    else
      isVisible = self.isLootTickerVisible or self.isEncumbered or self.isEncumberedWarningShown or self.isAlmostEncumberedWarningShown
    end
  else
    isVisible = not self.isInventoryOpen
  end
  if self.isEncumbranceVisible ~= isVisible then
    UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceHolder, isVisible)
    self.isEncumbranceVisible = isVisible
  end
end
function Encumbrance:ResetCraftAnimation()
  self.ScriptedEntityTweener:Stop(self.Properties.LootTickerItem)
  self.ScriptedEntityTweener:Stop(self.Properties.Message)
  self.ScriptedEntityTweener:Stop(self.entityId)
  self.ScriptedEntityTweener:Stop(self.Properties.EncumbranceHolder)
  self:HideCraftAnimation()
end
function Encumbrance:PlayCraftAnimation(messageText, delayTime, itemDescriptor, quantity)
  messageText = messageText or "@ui_added_to_inventory"
  if delayTime == nil then
    delayTime = 1
  end
  if self.originalMasterContainerPos then
    self:ResetCraftAnimation()
  end
  if itemDescriptor then
    self.HorizontalLine:SetVisible(true, 1)
    self.VerticalLine:SetVisible(true, 1)
  end
  local ancestorId = self.entityId
  while ancestorId:IsValid() do
    UiElementBus.Event.SetIsEnabled(ancestorId, true)
    self.ScriptedEntityTweener:Set(ancestorId, {opacity = 1})
    ancestorId = UiElementBus.Event.GetParent(ancestorId)
  end
  self.originalMasterContainerPos = UiTransformBus.Event.GetLocalPositionX(self.Properties.MasterContainer)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.MasterContainer, self.masterContainerCraftAnimPos)
  UiElementBus.Event.SetIsEnabled(self.PvpHolder, false)
  UiElementBus.Event.SetIsEnabled(self.QuickslotsContainer, false)
  self.screenStateOnCraft = LyShineManagerBus.Broadcast.GetCurrentState()
  UiCanvasBus.Event.SetEnabled(self.canvasId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceWarningWeight, false)
  self.ScriptedEntityTweener:Play(self.Properties.EncumbranceHolder, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadIn"})
  UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceHolder, true)
  UiElementBus.Event.SetIsEnabled(self.CraftItemSwirlAnim1, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.CraftItemSwirlAnim1, 0)
  UiFlipbookAnimationBus.Event.Start(self.CraftItemSwirlAnim1)
  UiElementBus.Event.SetIsEnabled(self.CraftItemSwirlAnim2, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.CraftItemSwirlAnim2, 0)
  UiFlipbookAnimationBus.Event.Start(self.CraftItemSwirlAnim2)
  if itemDescriptor then
    UiElementBus.Event.SetIsEnabled(self.Properties.LootTickerItem, true)
    self.LootTickerItem:SetDisplayData(itemDescriptor, quantity, "", nil, itemDescriptor:UsesRarity() and 0 < itemDescriptor:GetRarityLevel())
    self.ScriptedEntityTweener:Play(self.Properties.LootTickerItem, 0.4, {
      opacity = 1,
      onComplete = function()
        self.ScriptedEntityTweener:Play(self.Properties.LootTickerItem, 0.5, {
          scaleX = 1,
          ease = "QuadOut",
          delay = delayTime,
          onComplete = function()
            self.HorizontalLine:SetVisible(false, 0.5)
            self.VerticalLine:SetVisible(false, 0.5)
            self.ScriptedEntityTweener:Play(self.Properties.LootTickerItem, 0.5, {opacity = 0, ease = "QuadOut"})
            self.ScriptedEntityTweener:Play(self.entityId, 0.5, {opacity = 1}, {
              opacity = 0,
              onComplete = function()
                self:HideCraftAnimation()
              end
            })
          end
        })
      end
    })
  else
    UiTextBus.Event.SetTextWithFlags(self.MessageText, messageText, eUiTextSet_SetLocalized)
    self.ScriptedEntityTweener:Play(self.CraftItemSwirlAnim1, 0.4, {
      scaleX = 1,
      onComplete = function()
        UiElementBus.Event.SetIsEnabled(self.Message, true)
        self.ScriptedEntityTweener:Play(self.Message, 0.3, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.MessageText, 0.4, {opacity = 0, x = -32}, {
          opacity = 1,
          x = -57.49,
          ease = "QuadOut",
          delay = 0.3
        })
        self.ScriptedEntityTweener:Play(self.Message, 0.5, {opacity = 1}, {
          opacity = 0,
          ease = "QuadOut",
          delay = delayTime,
          onComplete = function()
            self:HideCraftAnimation()
          end
        })
        self.ScriptedEntityTweener:Play(self.Properties.EncumbranceHolder, 0.5, {opacity = 1}, {
          opacity = 0,
          ease = "QuadIn",
          delay = 1,
          onComplete = function()
            if not self.isEncumbranceVisible then
              UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceHolder, false)
            end
            self.ScriptedEntityTweener:Set(self.Properties.EncumbranceHolder, {opacity = 1})
          end
        })
      end
    })
    self.ScriptedEntityTweener:Play(self.Properties.RingAnim, 1, {rotation = 0}, {
      rotation = 359,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.RingAnim, 0.1, {opacity = 0}, {
      opacity = 1,
      ease = "QuadOut",
      delay = 0.2
    })
    self.ScriptedEntityTweener:Play(self.Properties.RingAnim, 0.4, {opacity = 1}, {
      opacity = 0,
      ease = "QuadOut",
      delay = 0.8
    })
  end
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
end
function Encumbrance:HideCraftAnimation()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == self.screenStateOnCraft then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
  UiElementBus.Event.SetIsEnabled(self.PvpHolder, true)
  UiElementBus.Event.SetIsEnabled(self.QuickslotsContainer, true)
  UiElementBus.Event.SetIsEnabled(self.Message, false)
  UiElementBus.Event.SetIsEnabled(self.CraftItemSwirlAnim1, false)
  UiElementBus.Event.SetIsEnabled(self.CraftItemSwirlAnim2, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.LootTickerItem, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceWarningWeight, true)
  self.HorizontalLine:SetVisible(false, 0)
  self.VerticalLine:SetVisible(false, 0)
  if self.originalMasterContainerPos then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.MasterContainer, self.originalMasterContainerPos)
    self.originalMasterContainerPos = nil
  end
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
end
function Encumbrance:HideUIElements()
  self.encumbranceHidden = true
  self.ScriptedEntityTweener:Set(self.EncumbranceHolder, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.PvpHolder, {opacity = 0})
  UiInteractableBus.Event.SetIsHandlingEvents(self.Properties.PvpTooltip, false)
end
function Encumbrance:OnTutorialRevealUIElement(elementName)
  if elementName == "Encumbrance_Inventory" then
    self.encumbranceHidden = false
    self.ScriptedEntityTweener:Play(self.EncumbranceHolder, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadIn"})
  end
end
function Encumbrance:HideElementForFtueOutro()
  self.ScriptedEntityTweener:Play(self.entityId, self.UIStyle.DURATION_FTUE_OUTRO, {opacity = 0, ease = "QuadOut"})
end
function Encumbrance:GetEncumbranceHolderViewportPos()
  return UiTransformBus.Event.GetViewportPosition(self.Properties.EncumbranceHolder)
end
return Encumbrance
