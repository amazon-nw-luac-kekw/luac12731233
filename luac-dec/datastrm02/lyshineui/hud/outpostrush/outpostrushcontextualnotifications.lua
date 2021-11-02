local OutpostRushContextualNotifications = {
  Properties = {}
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OutpostRushContextualNotifications)
local BitwiseHelper = RequireScript("LyShineUI._Common.BitwiseHelpers")
function OutpostRushContextualNotifications:OnInit()
  self.tutorials = {}
  self.tutorials[ORTutorialEvent_Rules_Win] = {
    title = "@or_tutorial_rules_win_title",
    description = "@or_tutorial_rules_win_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_victory.dds"
  }
  self.tutorials[ORTutorialEvent_Rules_Capture] = {
    title = "@or_tutorial_rules_capture_title",
    description = "@or_tutorial_rules_capture_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_capture.dds"
  }
  self.tutorials[ORTutorialEvent_Rules_Score] = {
    title = "@or_tutorial_rules_score_title",
    description = "@or_tutorial_rules_score_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_score.dds"
  }
  self.tutorials[ORTutorialEvent_Rules_Portal] = {
    title = "@or_tutorial_rules_portal_title",
    description = "@or_tutorial_rules_portal_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_portal.dds"
  }
  self.tutorials[ORTutorialEvent_Boss_Spawn] = {
    title = "@or_tutorial_boss_spawn_title",
    description = "@or_tutorial_boss_spawn_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_boss.dds"
  }
  self.tutorials[ORTutorialEvent_Boss_Near] = {
    title = "@or_tutorial_boss_near_title",
    description = "@or_tutorial_boss_near_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_boss.dds"
  }
  self.tutorials[ORTutorialEvent_Outpost_Gates] = {
    title = "@or_tutorial_outpost_gates_title",
    description = "@or_tutorial_outpost_gates_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_gate.dds"
  }
  self.tutorials[ORTutorialEvent_Outpost_Ward] = {
    title = "@or_tutorial_outpost_ward_title",
    description = "@or_tutorial_outpost_ward_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_protection.dds"
  }
  self.tutorials[ORTutorialEvent_Outpost_SiegeWeapons] = {
    title = "@or_tutorial_outpost_siegeweapons_title",
    description = "@or_tutorial_outpost_siegeweapons_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_siegeweapon.dds"
  }
  self.tutorials[ORTutorialEvent_Outpost_CommandPost] = {
    title = "@or_tutorial_outpost_commandpost_title",
    description = "@or_tutorial_outpost_commandpost_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_commandpost.dds"
  }
  self.tutorials[ORTutorialEvent_Outpost_Contribute] = {
    title = "@or_tutorial_outpost_contribute_title",
    description = "@or_tutorial_outpost_contribute_body",
    icon = "lyshineui/images/icons/outpostrush/icon_outpostrush.dds"
  }
  self.tutorials[ORTutorialEvent_Armory_Purpose] = {
    title = "@or_tutorial_armory_purpose_title",
    description = "@or_tutorial_armory_purpose_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_armory.dds"
  }
  self.tutorials[ORTutorialEvent_Armory_AboutEssence] = {
    title = "@or_tutorial_armory_aboutessence_title",
    description = "@or_tutorial_armory_aboutessence_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_armory.dds"
  }
  self.tutorials[ORTutorialEvent_Armory_SpendEssence] = {
    title = "@or_tutorial_armory_spendessence_title",
    description = "@or_tutorial_armory_spendessence_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_armory.dds"
  }
  self.tutorials[ORTutorialEvent_Summoning_HowTo] = {
    title = "@or_tutorial_summoning_howto_title",
    description = "@or_tutorial_summoning_howto_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_summoningstone.dds"
  }
  self.tutorials[ORTutorialEvent_Summoning_Reminder] = {
    title = "@or_tutorial_summoning_reminder_title",
    description = "@or_tutorial_summoning_reminder_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_summoningstone.dds"
  }
  self.tutorials[ORTutorialEvent_Summoning_FindStone] = {
    title = "@or_tutorial_summoning_findstone_title",
    description = "@or_tutorial_summoning_findstone_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_summoningstone.dds"
  }
  self.tutorials[ORTutorialEvent_Summoning_NoStone] = {
    title = "@or_tutorial_summoning_nostone_title",
    description = "@or_tutorial_summoning_nostone_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_summoningstone.dds"
  }
  self.tutorials[ORTutorialEvent_Summoning_Creature] = {
    title = "@or_tutorial_summoning_creature_title",
    description = "@or_tutorial_summoning_creature_body",
    icon = "lyshineui/images/icons/outpostrush/icon_tutorial_summoningstone.dds"
  }
  self.summonStoneIds = {
    3898673229,
    4002565342,
    1743054195
  }
  self.azothEssenceId = 324048019
  self.applyAllResourcesOptionId = 1414681419
  self.addSummoningStoneOptionId = 1852123030
  self.hasMadeArmoryPurchase = false
  self.hasSummoningStone = false
  self.azothEssenceThreshold = 100
  self.azothEssenceAmount = 0
  self.stoneReminderTimeSeconds = 120
  self.checkSummoningCount = not OptionsDataBus.Broadcast.CheckOutpostRushTutorial(ORTutorialEvent_Summoning_NoStone)
end
function OutpostRushContextualNotifications:EnteredGameMode(gameModeEntityId)
  DynamicBus.NotificationsRequestBus.Broadcast.AdjustNotificationYPos(170)
  self.gameModeEntityId = gameModeEntityId
  self.uiTriggerAreaHandler = self:BusConnect(UiTriggerAreaEventNotificationBus)
  self.uiDebugCommandBus = self:BusConnect(UiDebugCommandBus)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    self.inventoryId = inventoryId
    self.containerEventHandler = self:BusConnect(ContainerEventBus, self.inventoryId)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InteractorEntityId", function(self, interactorId)
    self.interactorId = interactorId
    self:BusDisconnect(self.uiInteractorComponentNotificationsHandler)
    if interactorId ~= nil then
      self.uiInteractorComponentNotificationsHandler = self:BusConnect(UiInteractorComponentNotificationsBus, interactorId)
    end
  end)
end
function OutpostRushContextualNotifications:ExitedGameMode()
  DynamicBus.NotificationsRequestBus.Broadcast.ResetYPos()
  self.dataLayer:UnregisterObserver("Hud.LocalPlayer.HudComponent.InventoryEntityId")
  self:BusDisconnect(self.uiTriggerAreaHandler)
  self.uiTriggerAreaHandler = nil
  self:BusDisconnect(self.uiDebugCommandBus)
  self.uiDebugCommandBus = nil
  self.dataLayer:UnregisterObserver("Hud.LocalPlayer.HudComponent.InteractorEntityId")
  self:BusDisconnect(self.uiInteractorComponentNotificationsHandler)
  self.uiInteractorComponentNotificationsHandler = nil
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function OutpostRushContextualNotifications:OnUiTriggerAreaEventEntered(enteringEntityId, triggerEntityId, eventId, identifier)
  if eventId == 1662066115 then
    self:ShowTutorialIfOwned(enteringEntityId, triggerEntityId, ORTutorialEvent_Outpost_Gates)
  elseif eventId == 1970050107 then
    self:ShowTutorialIfOwned(enteringEntityId, triggerEntityId, ORTutorialEvent_Outpost_Ward)
  elseif eventId == 2442474101 then
    self:ShowTutorialIfOwned(enteringEntityId, triggerEntityId, ORTutorialEvent_Outpost_SiegeWeapons)
  elseif eventId == 168696847 then
    self:ShowTutorialIfOwned(enteringEntityId, triggerEntityId, ORTutorialEvent_Outpost_CommandPost)
  elseif eventId == 1150146850 or eventId == 3389185729 or eventId == 111730271 then
    local capturePointStatus = self.dataLayer:GetDataFromNode(self:GetGameModeDataPath(eventId))
    if capturePointStatus then
      local owningTeamIdx = BitwiseHelper:And(capturePointStatus, OutpostRush_CapturePointStatusMask)
      if owningTeamIdx ~= self.playerTeamIndex then
        self:ShowTutorialNotification(ORTutorialEvent_Rules_Capture)
      end
    end
  elseif eventId == 1711027566 then
    if SpawnerRequestBus.Event.GetNumActiveSpawns(triggerEntityId) > 0 then
      self:ShowTutorialNotification(ORTutorialEvent_Summoning_Creature)
    end
  elseif eventId == 4201674546 then
    self:ShowTutorialNotification(ORTutorialEvent_Boss_Near)
  elseif eventId == 3320700044 then
    self:ShowTutorialNotification(ORTutorialEvent_Rules_Portal)
  end
end
function OutpostRushContextualNotifications:OnSlotUpdate(localSlotId, slot, updateReason)
  if not slot then
    return
  end
  local itemId = slot:GetItemId()
  if itemId == self.azothEssenceId then
    self.azothEssenceAmount = ContainerRequestBus.Event.GetItemCount(self.inventoryId, slot:GetItemDescriptor(), true, true, false)
    self:CheckSpendEssence()
  end
  self.hasSummoningStone = not self.checkSummoningCount
  for i = 1, #self.summonStoneIds do
    if itemId == self.summonStoneIds[i] then
      self:ShowTutorialNotification(ORTutorialEvent_Summoning_HowTo)
      if not OptionsDataBus.Broadcast.CheckOutpostRushTutorial(ORTutorialEvent_Summoning_Reminder) and not self.tickHandler then
        self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
        self.stoneObtainedTime = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
      end
    end
    if self.checkSummoningCount then
      local itemDescriptor = ItemDescriptor()
      itemDescriptor.itemId = self.summonStoneIds[i]
      self.hasSummoningStone = self.hasSummoningStone or ContainerRequestBus.Event.GetItemCount(self.inventoryId, itemDescriptor, true, true, false) > 0
    end
  end
  if not self.hasSummoningStone and self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function OutpostRushContextualNotifications:OnInteractFocus(onFocus)
  for i = 1, #onFocus.unifiedInteractOptions do
    local option = onFocus.unifiedInteractOptions[i]
    if option.interactionOptionId == self.applyAllResourcesOptionId or option.interactionOptionId == self.addSummoningStoneOptionId then
      self.currentInteraction = option.interactionOptionId
    end
  end
end
function OutpostRushContextualNotifications:OnInteractUnfocus(onFadeCallback)
  self.currentInteraction = nil
end
function OutpostRushContextualNotifications:OnInteractExecute(onExecute)
  if self.currentInteraction == self.addSummoningStoneOptionId and not self.hasSummoningStone then
    self.checkSummoningCount = false
    self:ShowTutorialNotification(ORTutorialEvent_Summoning_NoStone)
  end
end
function OutpostRushContextualNotifications:OnInteractFail(onFail)
  if self.currentInteraction == self.applyAllResourcesOptionId then
    self:ShowTutorialNotification(ORTutorialEvent_Outpost_Contribute)
  end
end
function OutpostRushContextualNotifications:OnTick(deltaTime, timePoint)
  local now = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  local timeElapsed = now:Subtract(self.stoneObtainedTime):ToSeconds()
  if timeElapsed > self.stoneReminderTimeSeconds then
    self:ShowTutorialNotification(ORTutorialEvent_Summoning_Reminder)
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function OutpostRushContextualNotifications:ShowTutorialIfOwned(playerId, ownershipId, tutorialId)
  local isOwnedByTeam = OwnershipRequestBus.Event.PlayerHasPermissions(ownershipId, playerId, GuildId())
  if isOwnedByTeam then
    self:ShowTutorialNotification(tutorialId)
  end
end
function OutpostRushContextualNotifications:PlayOutpostRushTutorial(id)
  if self.tutorials[id] then
    local notificationData = NotificationData()
    notificationData.type = "ORTutorial"
    notificationData.title = self.tutorials[id].title
    notificationData.text = self.tutorials[id].description
    notificationData.icon = self.tutorials[id].icon
    notificationData.contextId = self.entityId
    notificationData.maximumDuration = 8
    UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
  end
end
function OutpostRushContextualNotifications:CheckSpendEssence(hasMadePurchase)
  if hasMadePurchase then
    self.hasMadeArmoryPurchase = hasMadePurchase
  end
  if not self.hasMadeArmoryPurchase and self.azothEssenceAmount >= self.azothEssenceThreshold then
    self:ShowTutorialNotification(ORTutorialEvent_Armory_SpendEssence)
  end
end
function OutpostRushContextualNotifications:ShowTutorialNotification(id)
  if id > #self.tutorials or id < 0 then
    Debug.Log("No Tutorial Data exists for id: " .. tostring(id) .. ". Add data in OutpostRushContextualNotifications.lua. Ignoring ShowTutorialNotification call.")
    return
  end
  if not OptionsDataBus.Broadcast.CheckOutpostRushTutorial(id) then
    self:PlayOutpostRushTutorial(id)
    OptionsDataBus.Broadcast.CompleteOutpostRushTutorial(id)
  end
end
function OutpostRushContextualNotifications:SetPlayerTeamIndex(playerTeamIndex)
  self.playerTeamIndex = playerTeamIndex
end
function OutpostRushContextualNotifications:GetGameModeDataPath(valueName)
  return "GameMode." .. tostring(self.gameModeEntityId) .. "." .. valueName
end
return OutpostRushContextualNotifications
