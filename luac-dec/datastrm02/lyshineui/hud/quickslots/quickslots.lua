local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local QuickSlots = {
  Properties = {
    QuickSlotsContainer = {
      default = EntityId()
    },
    QuickslotComponentNamePrefix = {default = "quickslot-"},
    GatherableSlot = {
      default = EntityId()
    },
    ActiveWeaponHighlight = {
      default = EntityId()
    },
    HighlightLineTop = {
      default = EntityId()
    },
    HighlightLineBottom = {
      default = EntityId()
    },
    HighlightLineLeft = {
      default = EntityId()
    },
    HighlightLineRight = {
      default = EntityId()
    },
    QuickslotDropTargets = {
      QuickslotWeapon1 = {
        default = EntityId()
      },
      QuickslotWeapon2 = {
        default = EntityId()
      },
      QuickslotConsumable1 = {
        default = EntityId()
      },
      QuickslotConsumable2 = {
        default = EntityId()
      },
      QuickslotConsumable3 = {
        default = EntityId()
      },
      QuickslotConsumable4 = {
        default = EntityId()
      }
    },
    QuickslotArrows = {
      default = {
        EntityId()
      }
    },
    QuickslotCartridges = {
      default = {
        EntityId()
      }
    },
    QuickslotOffhands = {
      default = {
        EntityId()
      }
    },
    CraftingAnimation = {
      default = EntityId()
    },
    InputBlocker = {
      default = EntityId()
    },
    Message = {
      default = EntityId()
    },
    WeaponQuickslots = {
      default = EntityId()
    },
    ItemQuickslots = {
      default = EntityId()
    },
    Encumbrance = {
      default = EntityId()
    },
    EncumbranceMasterContainer = {
      default = EntityId()
    },
    EncumbranceDivider = {
      default = EntityId()
    },
    PvpDivider = {
      default = EntityId()
    }
  },
  CONSUMABLE_COOLDOWN = 0.5,
  enableActiveAmmo = false,
  confirmConsumePopupEventId = "Confirm_Consume_Popup",
  isFtue = false,
  isLoadingScreenShowing = nil,
  offsetForChat = 84,
  cycleAmount = 0,
  isDead = false,
  isInDeathsDoor = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(QuickSlots)
local ClickRecognizer = RequireScript("LyShineUI._Common.ClickRecognizer")
local equipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
function QuickSlots:OnInit()
  BaseScreen.OnInit(self)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
    if self.hudSettingsEnabled then
      if not self.tickBusHandler then
        self.tickBusHandler = DynamicBus.UITickBus.Connect(self.entityId, self)
      end
    elseif self.tickBusHandler then
      DynamicBus.UITickBus.Disconnect(self.entityId, self)
      self.tickBusHandler = nil
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Options.Video.HudShowAllWeapons", function(self, hudShowAllWeapons)
    if hudShowAllWeapons ~= nil then
      self.hudShowAllWeapons = hudShowAllWeapons
      self.showingAllWeaponSlots = nil
      self.isUnsheathingSameItem = false
      self.queueUpdateHudVisibility = true
      if self.weaponDropTargets then
        for i = 1, #self.weaponDropTargets do
          self.ScriptedEntityTweener:Stop(self.weaponDropTargets[i].entityId)
        end
        self.ScriptedEntityTweener:Stop(self.activeSlot.entityId)
      end
    end
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    if data then
      self:BusConnect(PlayerComponentNotificationsBus, data)
    end
  end)
  self.offsetStatesRight = {}
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_chatChannels", function(self, isEnabled)
    self.offsetStatesRight[3766762380] = isEnabled
  end)
  self.hideStates = {}
  self.hideStates[3406343509] = true
  self.hideStates[2478623298] = true
  self.hideStates[3024636726] = true
  self.hideStates[3901667439] = true
  self.hideStates[3777009031] = true
  self.hideStates[3576764016] = true
  self.hideStates[2477632187] = true
  self.hideStates[1967160747] = true
  self.hideStates[4143822268] = true
  self.hideStates[1628671568] = true
  self.hideStates[2815678723] = true
  self.hideStates[3175660710] = true
  self.hideStates[1823500652] = true
  self.hideStates[156281203] = true
  self.hideStates[3784122317] = true
  self.hideStates[2609973752] = true
  self.hideStates[3211015753] = true
  self.hideStates[849925872] = true
  self.hideStates[640726528] = true
  self.hideStates[3370453353] = true
  self.hideStates[2896319374] = true
  self.hideStates[828869394] = true
  self.hideStates[3211015753] = true
  self.hideStates[2640373987] = true
  self.hideStates[2437603339] = true
  self.hideStates[1319313135] = true
  self.hideStates[1468490675] = true
  self.hideStates[1101180544] = true
  self.hideStates[2972535350] = true
  self.hideStates[476411249] = true
  self.hideStates[3349343259] = true
  self.hideStates[2552344588] = true
  self.hideStates[2230605386] = true
  self.hideStates[1809891471] = true
  self.hideStates[3664731564] = true
  self.hideStates[4119896358] = true
  self.hideStates[3666413045] = true
  self.hideStates[3940276153] = true
  self.hideStates[663562859] = true
  self.hideStates[1634988588] = true
  self.hideStates[319051850] = true
  self.hideStates[921202721] = true
  self.hideStates[3160088100] = true
  self.hideStates[4241440342] = true
  self.hideStates[4283914359] = true
  self:OnCanvasSizeOrScaleChange(self.canvasId)
  self:BusConnect(UiCanvasSizeNotificationBus, self.canvasId)
  self.dropTargetsOfSlotType = {}
  DynamicBus.QuickslotsBus.Connect(self.entityId, self)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
  self.notificationHandlers[#self.notificationHandlers + 1] = TutorialComponentNotificationsBus.Connect(self, self.canvasId)
  self.cyclableActions = {
    {
      virtualInput = "Use_MainHandSlot_1",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotWeapon1,
      enum = ePaperDollSlotTypes_MainHandOption1,
      isWeaponSwitch = true
    },
    {
      virtualInput = "Use_MainHandSlot_2",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotWeapon2,
      enum = ePaperDollSlotTypes_MainHandOption2,
      isWeaponSwitch = true
    }
  }
  for index, actionData in pairs(self.cyclableActions) do
    actionData.index = index
  end
  self.actionToVirtualActionMap = {
    ["quickslot-weapon1"] = self.cyclableActions[1],
    ["quickslot-weapon2"] = self.cyclableActions[2],
    ["quickslot-consumable-1"] = {
      virtualInput = "Use_Quickslot_1",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotConsumable1,
      enum = ePaperDollSlotTypes_QuickSlot1
    },
    ["quickslot-consumable-2"] = {
      virtualInput = "Use_Quickslot_2",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotConsumable2,
      enum = ePaperDollSlotTypes_QuickSlot2
    },
    ["quickslot-consumable-3"] = {
      virtualInput = "Use_Quickslot_3",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotConsumable3,
      enum = ePaperDollSlotTypes_QuickSlot3
    },
    ["quickslot-consumable-4"] = {
      virtualInput = "Use_Quickslot_4",
      dropTarget = self.Properties.QuickslotDropTargets.QuickslotConsumable4,
      enum = ePaperDollSlotTypes_QuickSlot4
    },
    ["quickslot-cycle-up"] = {
      isCycle = true,
      cycleDirUp = true,
      isWeaponSwitch = true
    },
    ["quickslot-cycle-down"] = {
      isCycle = true,
      cycleDirUp = false,
      isWeaponSwitch = true
    },
    ["quickslot-weaponSwap"] = {
      virtualInput = "swap_weapon",
      quickSwap = true,
      isWeaponSwitch = true
    }
  }
  local playFlash = function(self, durationOverride)
    self.ScriptedEntityTweener:Stop(self.usedFlash)
    self.ScriptedEntityTweener:Play(self.usedFlash, durationOverride or 0.85, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  end
  local playCoverShow = function(self, durationOverride)
    UiElementBus.Event.SetIsEnabled(self.cover, true)
  end
  local playCoverHide = function(self, durationOverride)
    UiElementBus.Event.SetIsEnabled(self.cover, false)
  end
  for actionName, actionData in pairs(self.actionToVirtualActionMap) do
    actionData.handler = self:BusConnect(CryActionNotificationsBus, actionName)
    local actionDataDropTarget = actionData.dropTarget
    if actionDataDropTarget then
      actionData.usedFlash = UiElementBus.Event.FindDescendantByName(actionDataDropTarget, "UsedFlash")
      actionData.itemDraggable = UiElementBus.Event.FindDescendantByName(actionDataDropTarget, "ItemDraggable")
      actionData.cover = UiElementBus.Event.FindDescendantByName(actionDataDropTarget, "Cover")
      actionData.entityTable = self.registrar:GetEntityTable(actionData.dropTarget)
      actionData.ScriptedEntityTweener = self.ScriptedEntityTweener
      actionData.PlayFlash = playFlash
      actionData.PlayCoverShow = playCoverShow
      actionData.PlayCoverHide = playCoverHide
    end
  end
  self.nameToPaperdollSlotMap = equipmentCommon.nameToPaperdollSlotMap
  self.paperdollSlotToEntityMap = {
    [ePaperDollSlotTypes_MainHandOption1] = self.Properties.QuickslotDropTargets.QuickslotWeapon1,
    [ePaperDollSlotTypes_MainHandOption2] = self.Properties.QuickslotDropTargets.QuickslotWeapon2,
    [ePaperDollSlotTypes_QuickSlot1] = self.Properties.QuickslotDropTargets.QuickslotConsumable1,
    [ePaperDollSlotTypes_QuickSlot2] = self.Properties.QuickslotDropTargets.QuickslotConsumable2,
    [ePaperDollSlotTypes_QuickSlot3] = self.Properties.QuickslotDropTargets.QuickslotConsumable3,
    [ePaperDollSlotTypes_QuickSlot4] = self.Properties.QuickslotDropTargets.QuickslotConsumable4,
    [ePaperDollSlotTypes_Arrow] = {},
    [ePaperDollSlotTypes_Cartridge] = {}
  }
  for i = 0, #self.Properties.QuickslotArrows do
    self.paperdollSlotToEntityMap[ePaperDollSlotTypes_Arrow][i + 1] = self.Properties.QuickslotArrows[i]
  end
  for i = 0, #self.Properties.QuickslotCartridges do
    self.paperdollSlotToEntityMap[ePaperDollSlotTypes_Cartridge][i + 1] = self.Properties.QuickslotCartridges[i]
  end
  if self.hudSettingsEnabled then
    self.paperdollSlotToEntityMap[ePaperDollSlotTypes_OffHandOption1] = {}
    for i = 0, #self.Properties.QuickslotOffhands do
      self.paperdollSlotToEntityMap[ePaperDollSlotTypes_OffHandOption1][i + 1] = self.Properties.QuickslotOffhands[i]
    end
  end
  self.weaponDropTargets = {
    self.QuickslotDropTargets.QuickslotWeapon1,
    self.QuickslotDropTargets.QuickslotWeapon2
  }
  self.consumablesDropTargets = {
    self.Properties.QuickslotDropTargets.QuickslotConsumable1,
    self.Properties.QuickslotDropTargets.QuickslotConsumable2,
    self.Properties.QuickslotDropTargets.QuickslotConsumable3,
    self.Properties.QuickslotDropTargets.QuickslotConsumable4
  }
  self.weaponSlotIndexToDisplayIndex = {
    [ePaperDollSlotTypes_MainHandOption1] = 0,
    [ePaperDollSlotTypes_MainHandOption2] = 1
  }
  self.weaponSlotYPositions = {61, 166}
  self.activeSlot = self.registrar:GetEntityTable(self.Properties.QuickslotDropTargets.QuickslotWeapon1)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableActiveAmmo", function(self, enableActiveAmmo)
    self.enableActiveAmmo = enableActiveAmmo
  end)
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.OnLocalPlayerSet", function(self, isSet)
    if isSet then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
        if paperdollId then
          self.paperdollId = paperdollId
          for i = 0, ePaperDollSlotTypes_Cartridge - ePaperDollSlotTypes_Arrow do
            local slotType = i + ePaperDollSlotTypes_Arrow
            local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotType)
            self:OnPaperdollSlotUpdate(slotType, slot)
          end
          self:BusConnect(PaperdollEventBus, self.paperdollId)
          for i = 0, ePaperDollSlotTypes_OffHandOption2 - ePaperDollSlotTypes_GatherableHand do
            local slotType = i + ePaperDollSlotTypes_GatherableHand
            local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotType)
            self:OnPaperdollSlotUpdate(slotType, slot)
          end
          self:OnPaperdollSlotProgressionChanged()
        end
      end)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    if inventoryId then
      self.inventoryId = inventoryId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GatheringEntityId", function(self, gatheringId)
    if gatheringId then
      self:BusConnect(UiGatheringComponentNotificationsBus, gatheringId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ItemRepairEntityId", function(self, repairId)
    if repairId then
      self.repairId = repairId
    end
  end)
  UiElementBus.Event.SetIsEnabled(self.Properties.ActiveWeaponHighlight, false)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Equipment.ActiveWeaponSlot", function(self, paperdollSlotType)
    if paperdollSlotType then
      self:DockPositionOfEntityToSlotType(self.Properties.ActiveWeaponHighlight, paperdollSlotType, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.ActiveWeaponHighlight, true)
      self.ScriptedEntityTweener:Play(self.Properties.HighlightLineRight, 1.2, {scaleX = 0}, {scaleX = -1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.HighlightLineLeft, 1.2, {scaleX = 0}, {scaleX = 1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.HighlightLineBottom, 1.2, {scaleX = 0}, {scaleX = -1, ease = "QuadOut"})
      self.ScriptedEntityTweener:Play(self.Properties.HighlightLineTop, 1.2, {scaleX = 0}, {scaleX = 1, ease = "QuadOut"})
    end
    for index, actionData in pairs(self.cyclableActions) do
      if actionData.enum == paperdollSlotType then
        actionData:PlayCoverHide()
        actionData.entityTable:SetAbilitiesActive(true)
        actionData.entityTable:MoveDownAbilities(false)
      else
        actionData:PlayCoverShow()
        actionData.entityTable:SetAbilitiesActive(false)
        actionData.entityTable:MoveDownAbilities(true)
      end
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Equipment.SetConsumeSlot", function(self, slotBeingConsumed)
    if slotBeingConsumed then
      self.isConsuming = true
      self:SetItemCooldown(true, slotBeingConsumed)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Equipment.ConsumeSlot", function(self, slotConsumed)
    if slotConsumed then
      self.isConsuming = false
      self:SetItemCooldown(false, slotConsumed)
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Equipment.CancelConsumeSlot", function(self, slotConsumed)
    if slotConsumed then
      if self.isConsuming then
        self:SetItemCooldown(false, slotConsumed)
      end
      self.isConsuming = false
    end
  end)
  self.dataLayer:RegisterDataCallback(self, "Hud.LocalPlayer.Gather.OriginalToolSlot", function(self, paperdollSlotType)
    self.gatherDockedToOriginalSlot = paperdollSlotType and paperdollSlotType ~= ePaperDollSlotTypes_Invalid
    if self.gatherDockedToOriginalSlot and not self.hudSettingsEnabled then
      self:DockPositionOfEntityToSlotType(self.Properties.GatherableSlot, paperdollSlotType, true)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.TurretVitalsEntityId", function(self, vitalsEntityId)
    local hideCanvas = vitalsEntityId and vitalsEntityId:IsValid()
    UiCanvasBus.Event.SetEnabled(self.canvasId, not hideCanvas)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.GDERootEntityId", function(self, rootEntityId)
    if rootEntityId then
      self.vitalsId = rootEntityId
      if self.vitalsHandler then
        self:BusDisconnect(self.vitalsHandler)
      end
      self.vitalsHandler = self:BusConnect(VitalsComponentNotificationBus, self.vitalsId)
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Vitals.IsDead", function(self, isDead)
    if isDead ~= nil then
      self:OnDeathChanged(isDead)
    end
  end)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self:BusConnect(CryActionNotificationsBus, "cam_zoom_modifer")
  self:BusConnect(CryActionNotificationsBus, "quickslot-cycle-mod")
  local hudSettingCommon = RequireScript("LyShineUI._Common.HudSettingCommon")
  hudSettingCommon:RegisterEntityToFadeOnSprint(self.entityId)
  ClickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.OnDoubleClick, self.OpenContextMenu, nil)
  self:DarkenSlots(false)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Message, "@cr_add_quickslot", eUiTextSet_SetLocalized)
  SetTextStyle(self.Properties.Message, self.UIStyle.FONT_STYLE_CRAFTING_FAMILY)
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    UiElementBus.Event.SetIsEnabled(self.Properties.QuickSlotsContainer, false)
  end
  self:SetVisualElements()
end
function QuickSlots:OnShutdown()
  ClickRecognizer:OnDeactivate(self)
  DynamicBus.QuickslotsBus.Disconnect(self.entityId, self)
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  if self.tickBusHandler then
    DynamicBus.UITickBus.Disconnect(self.entityId, self)
    self.tickBusHandler = nil
  end
  BaseScreen.OnShutdown(self)
end
function QuickSlots:SetVisualElements()
  SetTextStyle(self.Message, self.UIStyle.FONT_STYLE_CRAFTING_FAMILY)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Message, "@cr_add_quickslot", eUiTextSet_SetLocalized)
end
function QuickSlots:SetScreenVisible(isVisible)
  timingUtils:StopDelay(self, self.SetScreenDisabled)
  if isVisible then
    UiElementBus.Event.SetIsEnabled(self.entityId, true)
  else
    timingUtils:Delay(0.12, self, self.SetScreenDisabled)
  end
  self:SetActionListenersEnabled(isVisible)
end
function QuickSlots:SetScreenDisabled()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
end
function QuickSlots:SetIsUsingSiegeWeapon(isUsingSiegeWeapon)
  if isUsingSiegeWeapon then
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.25, tweenerCommon.fadeOutQuadOut)
  else
    self.ScriptedEntityTweener:Stop(self.entityId)
    self.ScriptedEntityTweener:PlayC(self.entityId, 0.25, tweenerCommon.fadeInQuadOut, 0.25)
  end
end
function QuickSlots:DockPositionOfEntityToSlotType(entityId, paperdollSlotType, doReparent)
  local activeWeaponDropTargetId = self:GetDropTargetsWithSlotType(paperdollSlotType)
  if activeWeaponDropTargetId and activeWeaponDropTargetId[1] then
    if doReparent then
      local numberEntity = UiElementBus.Event.FindDescendantByName(activeWeaponDropTargetId[1], "Number")
      UiElementBus.Event.Reparent(entityId, activeWeaponDropTargetId[1], numberEntity)
    else
      local position = UiTransformBus.Event.GetViewportPosition(activeWeaponDropTargetId[1])
      UiTransformBus.Event.SetViewportPosition(entityId, position)
    end
  end
end
function QuickSlots:OnDoubleClick(entityId)
  if LocalPlayerUIRequestsBus.Broadcast.IsItemTransferEnabled() then
    local slotsRemaining = CommonDragDrop:GetInventorySlotsRemaining()
    if slotsRemaining == 0 then
      DynamicBus.NotificationsRequestBus.Broadcast.NotifyInventorySlotsRemaining(true, slotsRemaining)
      return
    end
    self:ContextInventoryUnequipItem(entityId, nil)
  end
end
function QuickSlots:ClearItem(draggableId, itemIndex)
  local dropTargetParent = UiElementBus.Event.GetParent(draggableId)
  local quickslotName = UiElementBus.Event.GetName(dropTargetParent)
  local slotIndex = self.nameToPaperdollSlotMap[quickslotName]
  local isAmmoSlot = slotIndex == ePaperDollSlotTypes_Arrow or slotIndex == ePaperDollSlotTypes_Cartridge
  if isAmmoSlot then
    self:SetAmmoSlotEnabled(false, draggableId, dropTargetParent)
  end
  local emptyIcon = UiElementBus.Event.FindDescendantByName(dropTargetParent, "EmptyQuickslotIcon")
  UiElementBus.Event.SetIsEnabled(emptyIcon, true)
  if UiElementBus.Event.IsEnabled(draggableId) then
    local itemDraggable = self.registrar:GetEntityTable(draggableId)
    itemDraggable:OnReturnedToCache()
  end
  UiElementBus.Event.SetIsEnabled(draggableId, false)
  self:UpdateAdditionalSlotVisibility(slotIndex)
end
function QuickSlots:GetDropTargetsWithSlotType(localSlotId)
  ClearTable(self.dropTargetsOfSlotType)
  if localSlotId == ePaperDollSlotTypes_GatherableHand then
    table.insert(self.dropTargetsOfSlotType, self.Properties.GatherableSlot)
    return self.dropTargetsOfSlotType
  end
  local dropTargets = self.paperdollSlotToEntityMap[localSlotId]
  if dropTargets then
    if type(dropTargets) == "table" then
      for _, dropTarget in ipairs(dropTargets) do
        table.insert(self.dropTargetsOfSlotType, dropTarget)
      end
    else
      table.insert(self.dropTargetsOfSlotType, dropTargets)
    end
  end
  return self.dropTargetsOfSlotType
end
function QuickSlots:FindDraggableFromDropTarget(dropTargetEntityId)
  local draggableName = "ItemDraggable"
  local draggableId = UiElementBus.Event.FindDescendantByName(dropTargetEntityId, draggableName)
  if not draggableId:IsValid() then
    local children = UiElementBus.Event.GetChildren(dropTargetEntityId)
    for i = 1, #children do
      local childName = UiElementBus.Event.GetName(children[i])
      if string.match(childName, draggableName) then
        draggableId = children[i]
        break
      end
    end
  end
  return draggableId
end
function QuickSlots:OnPaperdollSlotUpdate(localSlotId, slot)
  local wasAmmoUpdate = false
  local activeWeaponSlotId = PaperdollRequestBus.Event.GetActiveSlot(self.paperdollId, ePaperdollSlotAlias_ActiveWeapon)
  local dropTargets = self:GetDropTargetsWithSlotType(localSlotId)
  for _, dropTargetId in ipairs(dropTargets) do
    if dropTargetId:IsValid() then
      local draggableId = self:FindDraggableFromDropTarget(dropTargetId)
      local isGatheringTool = localSlotId == ePaperDollSlotTypes_GatherableHand
      if isGatheringTool then
        local showGatherableTool = slot and slot:IsValid()
        UiElementBus.Event.SetIsEnabled(dropTargetId, showGatherableTool)
        if showGatherableTool and not self.gatherDockedToOriginalSlot and not self.hudSettingsEnabled then
          self:DockPositionOfEntityToSlotType(dropTargetId, activeWeaponSlotId, true)
        end
        self.showGatherableTool = showGatherableTool
      end
      if (not slot or not slot:IsValid()) and not isGatheringTool then
        if draggableId and draggableId:IsValid() then
          self:ClearItem(draggableId)
        end
      elseif slot and slot:IsValid() then
        if draggableId:IsValid() then
          self:SetItem(draggableId, slot, localSlotId)
        else
          Debug.Log("Error: No quickslot item preloaded for localSlotId = " .. tostring(localSlotId))
        end
      end
      local dropTarget = self.registrar:GetEntityTable(dropTargetId)
      if dropTarget then
        local isActiveSlot = localSlotId == activeWeaponSlotId
        local showSheathHint = false
        if isActiveSlot then
          local isSheathed = PaperdollRequestBus.Event.IsSheathed(self.paperdollId, localSlotId)
          local hideWhenSheathedDisabled = PaperdollRequestBus.Event.IsHideWhenSheathedDisabled(self.paperdollId, localSlotId)
          showSheathHint = slot and slot:IsValid() and isSheathed and not hideWhenSheathedDisabled
          LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ActiveWeapon.IsSheathed", isSheathed)
          self.isActiveSlotSheathed = isSheathed and not hideWhenSheathedDisabled and not self.isConsuming
          if self.activeSlot ~= dropTarget then
            self.activeSlot = dropTarget
            self.cycleAmount = 0
            local draggableTable = self.registrar:GetEntityTable(draggableId)
            local weaponAttributes = draggableTable.ItemLayout.mItemData_itemDescriptor:GetWeaponAttributes()
          end
        end
        dropTarget:SetIsSheathedHintVisible(showSheathHint)
        if self.hudSettingsEnabled then
          dropTarget:SetSlot(localSlotId, slot)
        end
      end
    end
  end
  if not wasAmmoUpdate then
    self.queueUpdateHudVisibility = true
  end
end
function QuickSlots:OnPaperdollSlotProgressionChanged()
  for slotEnum, entityId in pairs(self.paperdollSlotToEntityMap) do
    local dropTargetTable = self.registrar:GetEntityTable(entityId)
    if dropTargetTable then
      local hasLevelReqForSlot = PaperdollRequestBus.Event.HasLevelRequirementForSlot(self.paperdollId, slotEnum)
      dropTargetTable:SetLockIconVisible(not hasLevelReqForSlot)
      if not hasLevelReqForSlot then
        local isWeapon = slotEnum == ePaperDollSlotTypes_MainHandOption1 or slotEnum == ePaperDollSlotTypes_MainHandOption2
        local lockedText = isWeapon and "@ui_slot_unlock_at" or "@ui_slot_unlock_at_abbr"
        local levelReq = PaperdollRequestBus.Event.GetLevelRequirementForSlot(self.paperdollId, slotEnum)
        dropTargetTable:SetLockText(GetLocalizedReplacementText(lockedText, {
          level = levelReq + 1
        }))
      end
    end
  end
end
function QuickSlots:ClearWeaponSwitchedRecently()
  self.weaponSwitchedRecently = false
  self.queueUpdateHudVisibility = true
  self.weaponSwitchedDelayTimer = nil
end
function QuickSlots:OnTick(deltaTime)
  if self.queueUpdateHudVisibility then
    self.queueUpdateHudVisibility = false
    self:UpdateHudVisibility()
  end
end
function QuickSlots:OnGatheringStart()
  self:DarkenSlots(true)
end
function QuickSlots:OnGatheringEnd()
  self:DarkenSlots(false)
end
function QuickSlots:DarkenSlots(darken)
  for _, entityId in pairs(self.Properties.QuickslotDropTargets) do
    local draggable = self:FindDraggableFromDropTarget(entityId)
    if draggable:IsValid() then
      local draggableTable = self.registrar:GetEntityTable(draggable)
      draggableTable.ItemLayout:SetDimVisible(darken)
      draggableTable:SetCanDrag(not darken)
    end
  end
  LocalPlayerUIRequestsBus.Broadcast.SetEnableUIInteractions(true, not darken, true)
end
function QuickSlots:SetItemCooldown(isActivated, slot)
  for _, entityId in pairs(self.consumablesDropTargets) do
    local draggable = self:FindDraggableFromDropTarget(entityId)
    if draggable:IsValid() then
      local draggableTable = self.registrar:GetEntityTable(draggable)
      if not draggableTable.ItemLayout:IsOnCooldown() then
        draggableTable.ItemLayout:SetDimVisible(isActivated)
      end
    end
  end
end
local module_paperdollId
function slotProviderFunction(p1, entityId, slotIndex)
  return PaperdollRequestBus.Event.GetSlot(module_paperdollId, slotIndex)
end
function QuickSlots:SetItem(entityId, item, localSlotId)
  local wasItemEnabled = UiElementBus.Event.IsEnabled(entityId)
  local dropTargetParent = UiElementBus.Event.GetParent(entityId)
  local quickslotName = UiElementBus.Event.GetName(dropTargetParent)
  local slotIndex = self.nameToPaperdollSlotMap[quickslotName]
  module_paperdollId = self.paperdollId
  DynamicBus.ItemLayoutSlotProvider.Event.SetItemAndSlotProvider(entityId, item, slotIndex, slotProviderFunction)
  UiElementBus.Event.SetIsEnabled(entityId, true)
  local isAmmoSlot = slotIndex == ePaperDollSlotTypes_Arrow or slotIndex == ePaperDollSlotTypes_Cartridge
  if isAmmoSlot then
    self:SetAmmoSlotEnabled(true, entityId, dropTargetParent)
  end
  ItemContainerBus.Event.SetSlotName(entityId, slotIndex)
  self:UpdateAdditionalSlotVisibility(slotIndex)
  local draggableTable = self.registrar:GetEntityTable(entityId)
  if not wasItemEnabled then
    draggableTable.ItemLayout:OnItemMoved()
  end
  draggableTable:SetModeType(draggableTable.ItemLayout.MODE_TYPE_EQUIPPED)
  local emptyIcon = UiElementBus.Event.FindDescendantByName(dropTargetParent, "EmptyQuickslotIcon")
  UiElementBus.Event.SetIsEnabled(emptyIcon, false)
end
function QuickSlots:SetAmmoSlotEnabled(isEnabled, draggableEntityId, ammoContainer)
  local ammoCountId = UiElementBus.Event.FindDescendantByName(ammoContainer, "AmmoQuantity")
  local emptyIconId = UiElementBus.Event.FindDescendantByName(ammoContainer, "EmptyIcon")
  if isEnabled then
    local draggableTable = self.registrar:GetEntityTable(draggableEntityId)
    local quantity = draggableTable.ItemLayout:GetQuantity()
    UiElementBus.Event.SetIsEnabled(draggableTable.ItemLayout.ItemQuantity, false)
    UiTextBus.Event.SetText(ammoCountId, tostring(quantity))
    local ammoColor = tonumber(quantity) == 0 and self.UIStyle.COLOR_RED_MEDIUM or self.UIStyle.COLOR_WHITE
    self.ScriptedEntityTweener:Set(ammoCountId, {textColor = ammoColor})
    self.ScriptedEntityTweener:Set(emptyIconId, {imgColor = ammoColor})
  else
    UiTextBus.Event.SetText(ammoCountId, "0")
    self.ScriptedEntityTweener:Set(ammoCountId, {
      textColor = self.UIStyle.COLOR_RED_MEDIUM
    })
    self.ScriptedEntityTweener:Set(emptyIconId, {
      imgColor = self.UIStyle.COLOR_RED_MEDIUM
    })
  end
end
function QuickSlots:UpdateAdditionalSlotVisibility(slotIndex)
  local displayIndex = self.weaponSlotIndexToDisplayIndex[slotIndex]
  if displayIndex then
    local itemSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
    local ammoType
    if itemSlot then
      ammoType = itemSlot:GetAmmoType()
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.QuickslotArrows[displayIndex], ammoType == eAmmoType_Arrow)
    UiElementBus.Event.SetIsEnabled(self.Properties.QuickslotCartridges[displayIndex], ammoType == eAmmoType_Shot)
    if self.hudSettingsEnabled then
      local itemName = ""
      if itemSlot then
        itemName = itemSlot:GetItemName()
      end
      local hasOffhandDisplay = itemCommon:DoesItemSupportShieldOffhand(itemName)
      UiElementBus.Event.SetIsEnabled(self.Properties.QuickslotOffhands[displayIndex], hasOffhandDisplay)
    end
  end
end
function QuickSlots:OnCryAction(actionName, value)
  local actionData = self.actionToVirtualActionMap[actionName]
  if actionData then
    local hasWeaponSwitched = actionData.isWeaponSwitch
    if actionData.isCycle and self.hudSettingsEnabled then
      hasWeaponSwitched = false
      if not self.camZoomModifierPressed and self.quickslotCycleModiferPressed or not LyShineManagerBus.Broadcast.IsKeybindBound("quickslot-cycle-mod", "player") then
        self.cycleAmount = self.cycleAmount + (actionData.cycleDirUp and -1 or 1)
        local cycledActionData = self:GetDesiredCycleActionData(self.cycleAmount)
        self:ConsumeAction(cycledActionData)
        hasWeaponSwitched = actionData.isWeaponSwitch
      end
    elseif actionData.quickSwap ~= true or not self.hudSettingsEnabled then
      local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
      local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, actionData.enum)
      local isOnCooldown
      if slot then
        local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
        local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(slot:GetItemId())
        isOnCooldown = staticConsumableData:IsValid() and CooldownTimersComponentBus.Event.IsConsumableOnCooldown(rootEntityId, staticConsumableData.cooldownId)
      else
        return
      end
      if not isOnCooldown then
        if slot and slot:ShouldConfirmBeforeUse() then
          PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_confirm_before_use_title", "@ui_confirm_before_use_message", self.confirmConsumePopupEventId, self, self.OnPopupResult)
          self.pendingConfirmActionData = actionData
        else
          self:ConsumeAction(actionData)
        end
      end
    end
    if hasWeaponSwitched then
      local weaponSwitchedTimeSec = 1
      if not self.weaponSwitchedDelayTimer then
        self.weaponSwitchedRecently = true
        self.weaponSwitchedDelayTimer = timingUtils:Delay(weaponSwitchedTimeSec, self, self.ClearWeaponSwitchedRecently)
        self.queueUpdateHudVisibility = true
      else
        self.weaponSwitchedDelayTimer.currentTime = weaponSwitchedTimeSec
      end
    end
  elseif actionName == "cam_zoom_modifer" then
    self.camZoomModifierPressed = 0 < value
  elseif actionName == "quickslot-cycle-mod" then
    self.quickslotCycleModiferPressed = 0 < value
  end
end
function QuickSlots:GetDesiredCycleActionData(cycleAmount)
  local curActionData
  if self.activeSlot then
    for _, actionData in ipairs(self.cyclableActions) do
      if self.activeSlot.entityId == actionData.dropTarget then
        curActionData = actionData
        break
      end
    end
  end
  if curActionData then
    local cycleDir = 0 < cycleAmount and 1 or -1
    local nextIndex, nextActionData
    local timesChecked = 0
    local numActions = #self.cyclableActions
    while (not nextActionData or self.registrar:GetEntityTable(nextActionData.dropTarget):IsLocked()) and timesChecked <= numActions do
      nextIndex = (curActionData.index - 1 + cycleAmount) % numActions + 1
      nextActionData = self.cyclableActions[nextIndex]
      cycleAmount = cycleAmount + cycleDir
      timesChecked = timesChecked + 1
    end
    return nextActionData
  end
end
function QuickSlots:OnPopupResult(result, eventId)
  if eventId == self.confirmConsumePopupEventId and result == ePopupResult_Yes then
    self:ConsumeAction(self.pendingConfirmActionData)
  end
end
function QuickSlots:ConsumeAction(actionData)
  LocalPlayerUIRequestsBus.Broadcast.SendVirtualInput(actionData.virtualInput, true, 0)
  actionData:PlayFlash()
  local itemDraggable = actionData.itemDraggable
  local isDraggableEnabled = UiElementBus.Event.IsEnabled(itemDraggable)
  if isDraggableEnabled then
    self.audioHelper:PlaySound(self.audioHelper.OnQuickBarPress)
  else
    self.audioHelper:PlaySound(self.audioHelper.OnQuickBarPressEmpty)
  end
  self.pendingConfirmActionData = nil
  self.lastConsumedActionData = actionData
end
function QuickSlots:OnAction(entityId, actionName)
  BaseScreen.OnAction(self, entityId, actionName)
  BaseScreen.OnAction(self.Encumbrance, entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function QuickSlots:OnLoadingScreenDismissed()
  self.isLoadingScreenShowing = false
end
function QuickSlots:ItemUpdateDragData(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_Paperdoll)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", self.paperdollId)
  local slotIndex = ItemContainerBus.Event.GetSlotName(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotIndex)
  if tonumber(slotIndex) >= ePaperDollSlotTypes_QuickSlot1 and tonumber(slotIndex) <= ePaperDollSlotTypes_QuickSlot6 then
    local itemSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
    local stackSize = 0
    if itemSlot then
      stackSize = itemSlot:GetStackSize()
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
  else
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", 1)
  end
end
function QuickSlots:OpenContextMenu(entityId)
end
function QuickSlots:ContextInventoryUnequipItem(entityId, actionName)
  if not self.isLookingThroughLoadout then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local dropTarget = UiElementBus.Event.GetParent(entityId)
  local slotName = UiElementBus.Event.GetName(dropTarget)
  local slotIndex = self.nameToPaperdollSlotMap[slotName]
  local targetItem = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
  if targetItem and targetItem:IsValid() then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(self.paperdollId, slotIndex)
    if isSlotBlocked then
      EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
    end
    LocalPlayerUIRequestsBus.Broadcast.UnequipItem(slotIndex, -1, targetItem:GetStackSize(), inventoryId)
  end
end
function QuickSlots:ContextInventoryRepairItem(entityId)
  if not self.isLookingThroughLoadout then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local dropTarget = UiElementBus.Event.GetParent(entityId)
  local slotName = UiElementBus.Event.GetName(dropTarget)
  LocalPlayerUIRequestsBus.Broadcast.RepairItem(slotName, false)
end
function QuickSlots:OnDeathsDoorChanged(isInDeathsDoor, timeRemaining, deathsDoorCooldownRemaining)
  if isInDeathsDoor ~= self.isInDeathsDoor then
    self.isInDeathsDoor = isInDeathsDoor
    local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
    self:UpdateScreenState(currentState)
  end
end
function QuickSlots:OnDeathChanged(isDead)
  if self.isDead ~= isDead then
    self.isDead = isDead
    local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
    self:UpdateScreenState(currentState)
  end
end
function QuickSlots:UpdateScreenState(state)
  if self.isDead or self.isInDeathsDoor then
    self:SetScreenVisible(false)
  else
    if self.hideStates[state] then
      self:SetScreenVisible(false)
      return
    end
    self:SetScreenVisible(true)
  end
end
function QuickSlots:OnIsLookingThroughLoadoutChanged(isLookingThroughLoadout)
  self.isLookingThroughLoadout = isLookingThroughLoadout
end
function QuickSlots:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self.Encumbrance:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  self:UpdateScreenState(toState)
end
function QuickSlots:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  self.Encumbrance:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.hideStates[fromState] and not self.hideStates[toState] then
    self:SetScreenVisible(true)
  end
end
function QuickSlots:SetActionListenersEnabled(enabled)
  for actionName, actionData in pairs(self.actionToVirtualActionMap) do
    if enabled then
      if not actionData.handler then
        actionData.handler = self:BusConnect(CryActionNotificationsBus, actionName)
      end
    elseif actionData.handler then
      self:BusDisconnect(actionData.handler)
      actionData.handler = nil
    end
  end
end
function QuickSlots:ClearNewHighlights()
end
function QuickSlots:PlayCraftAnimation(toSlot)
  if KeyIsInsideTable(self.paperdollSlotToEntityMap, toSlot) then
    do
      local slotEntity = self.paperdollSlotToEntityMap[toSlot]
      local entityCenter = Vector2(0, 0)
      local entityRect = UiTransformBus.Event.GetViewportSpaceRect(slotEntity)
      entityCenter = entityRect:GetCenter()
      UiTransformBus.Event.SetViewportPosition(self.Properties.CraftingAnimation, entityCenter)
      UiCanvasBus.Event.SetEnabled(self.canvasId, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, true)
      self.screenStateOnCraft = LyShineManagerBus.Broadcast.GetCurrentState()
      local highlightElement
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingAnimation, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.CraftingAnimation)
      self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
      self.animationEndedEarly = false
      self.ScriptedEntityTweener:Play(self.Properties.CraftingAnimation, 0.4, {
        scaleX = -1,
        onComplete = function()
          local entityTable = self.registrar:GetEntityTable(slotEntity)
          highlightElement = entityTable.HighlightElement
          UiElementBus.Event.SetIsEnabled(highlightElement, true)
          UiElementBus.Event.SetIsEnabled(self.Properties.Message, true)
          self.ScriptedEntityTweener:Play(self.Properties.Message, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.Properties.Message, 0.5, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 1,
            onComplete = function()
              if not self.animationEndedEarly then
                self:HideCraftAnimation(toSlot)
              end
            end
          })
        end
      })
      local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, toSlot)
      DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, nil, slot:GetItemDescriptor())
    end
  end
end
function QuickSlots:HideCraftAnimation(toSlot)
  if KeyIsInsideTable(self.paperdollSlotToEntityMap, toSlot) then
    local slotEntity = self.paperdollSlotToEntityMap[toSlot]
    local entityCenter = Vector2(0, 0)
    local entityRect = UiTransformBus.Event.GetViewportSpaceRect(slotEntity)
    entityCenter = entityRect:GetCenter()
    UiTransformBus.Event.SetViewportPosition(self.Properties.CraftingAnimation, entityCenter)
    UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, true)
    local highlightElement
    local entityTable = self.registrar:GetEntityTable(slotEntity)
    highlightElement = entityTable.HighlightElement
    if highlightElement then
      UiElementBus.Event.SetIsEnabled(highlightElement, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.CraftingAnimation, false)
    local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
    if currentState == self.screenStateOnCraft then
      UiCanvasBus.Event.SetEnabled(self.canvasId, false)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Message, false)
    self.animationEndedEarly = true
  end
end
function QuickSlots:OnTutorialRevealUIElement(elementName)
  if elementName == "QuickSlots" then
    UiElementBus.Event.SetIsEnabled(self.Properties.QuickSlotsContainer, true)
    self.ScriptedEntityTweener:Play(self.Properties.QuickSlotsContainer, 0.25, {opacity = 0}, {opacity = 1, ease = "QuadIn"})
  end
end
function QuickSlots:SetElementVisibleForFtue(isVisible)
  self.ScriptedEntityTweener:Set(self.Properties.QuickSlotsContainer, {
    x = isVisible and 0 or 1000000
  })
end
function QuickSlots:UpdateHudVisibility()
  if not self.hudSettingsEnabled then
    return
  end
  local weaponSlotsVisible = true
  local showingAllWeaponSlots = false
  local consumableSlotsVisible = true
  if not self.hudShowAllWeapons then
    if self.showGatherableTool then
      weaponSlotsVisible = false
      showingAllWeaponSlots = false
      consumableSlotsVisible = true
    elseif self.weaponSwitchedRecently then
      weaponSlotsVisible = true
      showingAllWeaponSlots = true
      consumableSlotsVisible = false
    elseif self.isActiveSlotSheathed then
      weaponSlotsVisible = false
      showingAllWeaponSlots = false
      consumableSlotsVisible = true
    else
      weaponSlotsVisible = true
      showingAllWeaponSlots = false
      consumableSlotsVisible = true
    end
    if showingAllWeaponSlots ~= self.showingAllWeaponSlots or weaponSlotsVisible ~= self.weaponSlotsVisible then
      self.showingAllWeaponSlots = showingAllWeaponSlots
      self.weaponSlotsVisible = weaponSlotsVisible
      for i = 1, #self.weaponDropTargets do
        local currentEntityTable = self.weaponDropTargets[i]
        local isActiveSlot = currentEntityTable.entityId == self.activeSlot.entityId
        local startPosY = self.showingAllWeaponSlots and self.weaponSlotYPositions[2] or self.weaponSlotYPositions[i]
        local newPosY = self.showingAllWeaponSlots and self.weaponSlotYPositions[i] or self.weaponSlotYPositions[2]
        local directionOpacity = self.showingAllWeaponSlots and 1 or 0
        if isActiveSlot and weaponSlotsVisible then
          directionOpacity = weaponSlotsVisible and 1 or 0
        end
        if self.isUnsheathingSameItem then
          UiElementBus.Event.SetIsEnabled(self.activeSlot.entityId, true)
          self.ScriptedEntityTweener:Play(self.activeSlot.entityId, 0.25, {y = startPosY}, {
            y = newPosY,
            opacity = 1,
            ease = "QuadOut"
          })
        else
          if directionOpacity ~= 0 then
            UiElementBus.Event.SetIsEnabled(currentEntityTable.entityId, true)
          end
          self.ScriptedEntityTweener:Play(currentEntityTable.entityId, 0.25, {y = startPosY}, {
            y = newPosY,
            opacity = directionOpacity,
            ease = "QuadOut",
            onComplete = function()
              if directionOpacity == 0 then
                UiElementBus.Event.SetIsEnabled(currentEntityTable.entityId, false)
              end
              if self.showingAllWeaponSlots and self.lastConsumedActionData and self.lastConsumedActionData.dropTarget == currentEntityTable.entityId then
                self.lastConsumedActionData:PlayFlash()
              end
            end
          })
        end
        if self.showingAllWeaponSlots then
          if isActiveSlot then
            currentEntityTable:SetAbilitiesVisible(true)
            currentEntityTable:PlayWeaponDeselectLineAnim(0.25)
          else
            currentEntityTable:SetAbilitiesVisible(true)
          end
          currentEntityTable:SetHintVisible(false)
        elseif isActiveSlot then
          if not weaponSlotsVisible then
            currentEntityTable:SetAbilitiesVisible(false)
          else
            currentEntityTable:SetAbilitiesVisible(true)
          end
          currentEntityTable:SetAbilitiesActive(true)
          currentEntityTable:MoveDownAbilities(false)
        else
          currentEntityTable:SetAbilitiesVisible(false)
          currentEntityTable:SetAbilitiesActive(false)
          currentEntityTable:MoveDownAbilities(false)
        end
      end
    else
      for i = 1, #self.weaponDropTargets do
        local currentEntityTable = self.weaponDropTargets[i]
        local isActiveSlot = currentEntityTable.entityId == self.activeSlot.entityId
        if self.showingAllWeaponSlots and isActiveSlot then
          currentEntityTable:PlayWeaponDeselectLineAnim(0)
        end
      end
    end
  else
    weaponSlotsVisible = true
    showingAllWeaponSlots = true
    consumableSlotsVisible = true
    if self.showGatherableTool then
      weaponSlotsVisible = false
      showingAllWeaponSlots = false
      consumableSlotsVisible = true
    end
    if showingAllWeaponSlots ~= self.showingAllWeaponSlots then
      self.showingAllWeaponSlots = showingAllWeaponSlots
      for i = 1, #self.weaponDropTargets do
        local currentEntityTable = self.weaponDropTargets[i]
        local isActiveSlot = currentEntityTable.entityId == self.activeSlot.entityId
        local startPosY = self.showingAllWeaponSlots and self.weaponSlotYPositions[2] or self.weaponSlotYPositions[i]
        local newPosY = self.showingAllWeaponSlots and self.weaponSlotYPositions[i] or self.weaponSlotYPositions[2]
        local directionOpacity = self.showingAllWeaponSlots and 1 or 0
        if isActiveSlot and weaponSlotsVisible then
          directionOpacity = weaponSlotsVisible and 1 or 0
        end
        if self.isUnsheathingSameItem then
          UiElementBus.Event.SetIsEnabled(self.activeSlot.entityId, true)
          self.ScriptedEntityTweener:Play(self.activeSlot.entityId, 0.25, {y = startPosY}, {
            y = newPosY,
            opacity = 1,
            ease = "QuadOut"
          })
        else
          if directionOpacity ~= 0 then
            UiElementBus.Event.SetIsEnabled(currentEntityTable.entityId, true)
          end
          self.ScriptedEntityTweener:Play(currentEntityTable.entityId, 0.25, {y = startPosY}, {
            y = newPosY,
            opacity = directionOpacity,
            ease = "QuadOut",
            onComplete = function()
              if directionOpacity == 0 then
                UiElementBus.Event.SetIsEnabled(currentEntityTable.entityId, false)
              end
            end
          })
        end
        if self.showingAllWeaponSlots then
          currentEntityTable:SetAbilitiesVisible(true)
          currentEntityTable:SetAbilitiesDimmed(not isActiveSlot)
          currentEntityTable:SetHintVisible(isActiveSlot)
          currentEntityTable:MoveDownAbilities(not isActiveSlot)
        end
      end
    end
  end
  local encumbranceXPos, itemSlotYPos
  if self.hudShowAllWeapons then
    if self.showGatherableTool then
      itemSlotYPos = -120
    else
      itemSlotYPos = -225
    end
    encumbranceXPos = -476
    DynamicBus.QuickslotNotifications.Broadcast.OnWeaponSlotsVisible(true)
  else
    if self.showGatherableTool then
      itemSlotYPos = -120
    elseif self.showingAllWeaponSlots then
      itemSlotYPos = -225
    elseif weaponSlotsVisible then
      itemSlotYPos = -120
    else
      itemSlotYPos = -46
    end
    encumbranceXPos = weaponSlotsVisible and -476 or -250
    DynamicBus.QuickslotNotifications.Broadcast.OnWeaponSlotsVisible(weaponSlotsVisible)
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemQuickslots, 0.25, {y = itemSlotYPos, ease = "QuadOut"})
  UiElementBus.Event.SetIsEnabled(self.Properties.EncumbranceDivider, weaponSlotsVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.PvpDivider, weaponSlotsVisible)
  self.ScriptedEntityTweener:Play(self.Properties.EncumbranceMasterContainer, 0.25, {x = encumbranceXPos, ease = "QuadOut"})
end
function QuickSlots:OnCanvasSizeOrScaleChange(canvasId)
  if self.canvasId == canvasId then
    AdjustElementToCanvasSize(self.Properties.QuickSlotsContainer, self.canvasId)
    AdjustElementToCanvasSize(self.Properties.Encumbrance, self.canvasId)
  end
end
return QuickSlots
