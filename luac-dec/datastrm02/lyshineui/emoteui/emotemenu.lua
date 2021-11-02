local EmoteMenu = {
  Properties = {
    FrameHeader = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    EmoteHolder = {
      default = EntityId()
    },
    EmoteButtonClone = {
      default = EntityId()
    },
    CloseEmoteWindow = {
      default = EntityId()
    },
    SimpleGridItemList = {
      default = EntityId()
    }
  },
  emoteButtons = {},
  allEmotes = {},
  isScreenVisible = false,
  iconPathRoot = "lyShineui/images/icons/emotes/",
  cooldowns = {}
}
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(EmoteMenu)
function EmoteMenu:OnInit()
  BaseScreen.OnInit(self)
  self.rowTypes = {
    header = {name = "header", maxItems = 1},
    emote = {name = "emote", maxItems = 100}
  }
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      self:SetVisualElements()
      if not self.cryActionHandler then
        self.cryActionHandler = self:BusConnect(CryActionNotificationsBus, "toggleEmoteWindow")
      end
    end
  end)
  self.SimpleGridItemList:Initialize(self.EmoteButtonClone, self.rowTypes)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enableEntitlements)
    self.entitlementsEnabled = enableEntitlements
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.AccountLocked", function(self, locked)
    self.accountLocked = locked
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
    if self.emoteHandler then
      self:BusDisconnect(self.emoteHandler)
    end
    if self.playerEntityId then
      self.emoteHandler = self:BusConnect(EmoteControllerComponentNotificationBus, self.playerEntityId)
    end
  end)
end
function EmoteMenu:SetVisualElements()
  self.FrameHeader:SetText("@ui_emotes")
  self.FrameHeader:SetHintKeybindMapping("toggleEmoteWindow")
end
function EmoteMenu:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.audioHelper:PlaySound(self.audioHelper.Emote_Popup_Show)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(false)
  self:SetAllEmotes()
  self.entitlementBus = self:BusConnect(EntitlementNotificationBus)
  self:SetScreenVisible(true)
end
function EmoteMenu:OnEntitlementsChange()
  self:SetAllEmotes()
end
function EmoteMenu:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self:SetScreenVisible(false)
  self.audioHelper:PlaySound(self.audioHelper.Emote_Popup_Hide)
  JavCameraControllerRequestBus.Broadcast.SetCameraEnableMouseInput(true)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  self:BusDisconnect(self.entitlementBus)
end
function EmoteMenu:SetScreenVisible(isVisible)
  if isVisible == true and self.isScreenVisible ~= true then
    self.isScreenVisible = true
    self.ScriptedEntityTweener:Play(self.Properties.EmoteHolder, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  elseif isVisible == false and self.isScreenVisible ~= false then
    self.isScreenVisible = false
    self.ScriptedEntityTweener:Play(self.Properties.EmoteHolder, 0.2, {
      opacity = 0,
      ease = "QuadOut",
      onComplete = function()
        UiCanvasBus.Event.SetEnabled(self.canvasId, false)
      end
    })
  end
end
function EmoteMenu:OnCryAction(actionName)
  LyShineManagerBus.Broadcast.ToggleState(663562859)
end
function EmoteMenu:OnClose()
  LyShineManagerBus.Broadcast.ExitState(663562859)
end
function EmoteMenu:SetAllEmotes()
  OmniDataHandler:GetOmniOffers(self, function(self, offers)
    local allEmotes = EmoteDataManagerBus.Broadcast.GetEmoteList()
    local allEmotesWithCallbacks = {}
    table.insert(allEmotesWithCallbacks, {
      rowType = self.rowTypes.header,
      headerText = "@ui_emotes",
      locName = ""
    })
    for i = 1, #allEmotes do
      local currentEmoteDef = allEmotes[i]
      local emoteTable = {}
      if not currentEmoteDef.isEntitlement then
        emoteTable.id = currentEmoteDef.id
        emoteTable.locName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(currentEmoteDef.displayName)
        emoteTable.description = currentEmoteDef.displayDescription or "@ui_emote_description_default"
        emoteTable.emoteData = currentEmoteDef
        emoteTable.callbackSelf = self
        emoteTable.callbackFn = self.SelectEmote
        emoteTable.isAvailable = true
        emoteTable.quantity = self:GetConsumableQuantity(currentEmoteDef.id)
        emoteTable.rowType = self.rowTypes.emote
        emoteTable.tooltipText = nil
        emoteTable.isNew = false
        emoteTable.cooldown = self.cooldowns[currentEmoteDef.id]
        table.insert(allEmotesWithCallbacks, emoteTable)
      end
    end
    if self.entitlementsEnabled then
      table.insert(allEmotesWithCallbacks, {
        rowType = self.rowTypes.header,
        headerText = "@ui_emotes_premium"
      })
    end
    local entitleAllEmotes = ConfigProviderEventBus.Broadcast.GetBool("javelin.entitle-all-emotes")
    for i = 1, #allEmotes do
      local currentEmoteDef = allEmotes[i]
      local emoteTable = {}
      if currentEmoteDef.isEntitlement and self.entitlementsEnabled and (entitleAllEmotes or EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEmote, currentEmoteDef.id or 0)) then
        emoteTable.id = currentEmoteDef.id
        emoteTable.grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeEmote, currentEmoteDef.id or 0)
        emoteTable.locName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(currentEmoteDef.displayName)
        emoteTable.description = currentEmoteDef.displayDescription or "@ui_emote_description_default"
        emoteTable.emoteData = currentEmoteDef
        emoteTable.callbackSelf = self
        emoteTable.callbackFn = self.SelectEmote
        emoteTable.isAvailable = true
        emoteTable.quantity = self:GetConsumableQuantity(currentEmoteDef.id)
        emoteTable.rowType = self.rowTypes.emote
        emoteTable.tooltipText = nil
        emoteTable.isNew = EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeNew(eRewardTypeEmote, currentEmoteDef.id or 0)
        emoteTable.cooldown = self.cooldowns[currentEmoteDef.id]
        table.insert(allEmotesWithCallbacks, emoteTable)
      end
    end
    for i = 1, #allEmotes do
      local currentEmoteDef = allEmotes[i]
      local emoteTable = {}
      if currentEmoteDef.isEntitlement and self.entitlementsEnabled and not EntitlementRequestBus.Broadcast.IsEntryIdOfRewardTypeEntitled(eRewardTypeEmote, currentEmoteDef.id or 0) then
        emoteTable.id = currentEmoteDef.id
        emoteTable.grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeEmote, currentEmoteDef.id or 0)
        emoteTable.locName = LyShineScriptBindRequestBus.Broadcast.LocalizeText(currentEmoteDef.displayName)
        emoteTable.description = currentEmoteDef.displayDescription or "@ui_emote_description_default"
        emoteTable.emoteData = currentEmoteDef
        emoteTable.callbackSelf = self
        emoteTable.callbackFn = self.SelectEmote
        emoteTable.isAvailable = true
        emoteTable.rowType = self.rowTypes.emote
        emoteTable.isNew = false
        emoteTable.isAvailable = false
        emoteTable.quantity = 0
        emoteTable.availableProducts = OmniDataHandler:SearchOffersForRewardTypeAndKey(offers, eRewardTypeEmote, currentEmoteDef.id or 0)
        emoteTable.tooltipText = "@ui_do_not_own"
        emoteTable.cooldown = self.cooldowns[currentEmoteDef.id]
        table.insert(allEmotesWithCallbacks, emoteTable)
      end
    end
    self.SimpleGridItemList:OnListDataSet(allEmotesWithCallbacks)
  end)
end
function EmoteMenu:GetConsumableQuantity(emoteId)
  if not emoteId then
    return 0
  end
  local entitlementId = EntitlementRequestBus.Broadcast.GetEntitlementForConsumable(eRewardTypeEmote, emoteId)
  if entitlementId and entitlementId ~= 0 then
    local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(entitlementId)
    if entitlementData.isConsumable then
      local entitlementBalance = EntitlementRequestBus.Broadcast.GetEntitlementBalance(entitlementId)
      return entitlementBalance
    end
  end
  return 0
end
function EmoteMenu:SelectEmote(entity)
  if entity.isEntitlement and self.accountLocked then
    UiPopupBus.Broadcast.ShowPopup(ePopupButtons_OK, "@ui_locked_account_title", "@ui_locked_account_description", "AccountLockedPopup")
    return
  end
  if entity.isPremiumEmote and not EmoteControllerComponentRequestsBus.Event.IsEmoteAllowedInCurrentGameMode(self.playerEntityId, entity.emoteId) then
    local notificationData = NotificationData()
    notificationData.type = "Minor"
    notificationData.text = "@emote_unable_to_use_emote"
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    return
  end
  LocalPlayerUIRequestsBus.Broadcast.StartEmoteById(entity.emoteId)
  self:OnClose()
end
function EmoteMenu:OnShutdown()
  BaseScreen.OnShutdown(self)
  self.cryActionHandler = nil
  for i = 1, #self.emoteButtons do
    UiElementBus.Event.DestroyElement(self.emoteButtons[i].entityId)
  end
end
function EmoteMenu:OnEmoteStarted(emoteId)
end
function EmoteMenu:OnEmoteEnded(emoteId, cooldownEndTimePoint)
  local seconds = cooldownEndTimePoint:Subtract(TimePoint:Now()):ToSeconds()
  if 0 < seconds then
    self.cooldowns[emoteId] = {
      startTimePoint = TimePoint:Now(),
      endTimePoint = cooldownEndTimePoint
    }
    if self.isScreenVisible then
      self:SetAllEmotes()
    end
  end
end
return EmoteMenu
