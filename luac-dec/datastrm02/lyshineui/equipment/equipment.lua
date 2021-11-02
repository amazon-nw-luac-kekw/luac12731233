local Equipment = {
  Properties = {
    Content = {
      default = EntityId()
    },
    ArmorStatsContainer = {
      default = EntityId()
    },
    SlotContainer = {
      default = EntityId()
    },
    SpawnerComponent = {
      default = EntityId()
    },
    HeadDropTarget = {
      default = EntityId()
    },
    ChestDropTarget = {
      default = EntityId()
    },
    HandsDropTarget = {
      default = EntityId()
    },
    LegsDropTarget = {
      default = EntityId()
    },
    FeetDropTarget = {
      default = EntityId()
    },
    AmuletDropTarget = {
      default = EntityId()
    },
    TokenDropTarget = {
      default = EntityId()
    },
    RingDropTarget = {
      default = EntityId()
    },
    BagSlotDropTarget1 = {
      default = EntityId()
    },
    BagSlotDropTarget2 = {
      default = EntityId()
    },
    BagSlotDropTarget3 = {
      default = EntityId()
    },
    ArrowDropTarget = {
      default = EntityId()
    },
    CartridgeDropTarget = {
      default = EntityId()
    },
    OffHandOption1DropTarget = {
      default = EntityId()
    },
    EquipmentStatsTooltip = {
      default = EntityId()
    },
    ToolDropTargets = {
      SickleSlot = {
        default = EntityId()
      },
      FishingRodSlot = {
        default = EntityId()
      },
      LoggingAxeSlot = {
        default = EntityId()
      },
      SkinningKnifeSlot = {
        default = EntityId()
      },
      PickaxeSlot = {
        default = EntityId()
      },
      AzothStaffSlot = {
        default = EntityId()
      }
    },
    QuickslotDropTargets = {
      QuickslotWeapon1 = {
        default = EntityId()
      },
      QuickslotWeapon2 = {
        default = EntityId()
      },
      QuickslotWeapon3 = {
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
    QuickslotHints = {
      QuickslotWeaponHint1 = {
        default = EntityId()
      },
      QuickslotWeaponHint2 = {
        default = EntityId()
      },
      QuickslotWeaponHint3 = {
        default = EntityId()
      },
      QuickslotConsumableHint1 = {
        default = EntityId()
      },
      QuickslotConsumableHint2 = {
        default = EntityId()
      },
      QuickslotConsumableHint3 = {
        default = EntityId()
      },
      QuickslotConsumableHint4 = {
        default = EntityId()
      }
    },
    ToolHints = {
      FishingPoleHint = {
        default = EntityId()
      }
    },
    OverburdenedHighlight = {
      default = EntityId()
    },
    EquipmentBgSlots2 = {
      default = EntityId()
    },
    EquipmentBgSlots3 = {
      default = EntityId()
    },
    EquipmentBgSlots4 = {
      default = EntityId()
    },
    EquipmentBgSlots5 = {
      default = EntityId()
    },
    WeightBar = {
      default = EntityId()
    },
    WeightText = {
      default = EntityId()
    },
    EquipLoadTooltip = {
      HitArea = {
        default = EntityId(),
        description = "Element that opens the tooltip when hovered. Must have button component."
      },
      Container = {
        default = EntityId(),
        description = "Full tooltip element"
      },
      Frame = {
        default = EntityId()
      },
      Title = {
        default = EntityId()
      },
      Description = {
        default = EntityId()
      },
      Fast = {
        default = EntityId()
      },
      FastTitle = {
        default = EntityId()
      },
      FastText = {
        default = EntityId()
      },
      Normal = {
        default = EntityId()
      },
      NormalTitle = {
        default = EntityId()
      },
      NormalText = {
        default = EntityId()
      },
      Slow = {
        default = EntityId()
      },
      SlowTitle = {
        default = EntityId()
      },
      SlowText = {
        default = EntityId()
      },
      Encumbered = {
        default = EntityId()
      },
      EncumberedTitle = {
        default = EntityId()
      },
      EncumberedText = {
        default = EntityId()
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
    MessageText = {
      default = EntityId()
    },
    AbilitySelection = {
      default = EntityId()
    },
    ArmorStats = {
      GearScoreStat = {
        default = EntityId()
      },
      PhysicalDefenseStat = {
        default = EntityId()
      },
      ElementalDefenseStat = {
        default = EntityId()
      },
      StrengthStat = {
        default = EntityId()
      },
      DexterityStat = {
        default = EntityId()
      },
      IntelligenceStat = {
        default = EntityId()
      },
      FocusStat = {
        default = EntityId()
      },
      ConstitutionStat = {
        default = EntityId()
      }
    },
    PurchaseSkins = {
      default = EntityId()
    },
    RepairAll = {
      default = EntityId()
    },
    BalanceText = {
      default = EntityId()
    },
    MarksOfFortuneIcon = {
      default = EntityId()
    },
    ButtonContainer = {
      default = EntityId()
    }
  },
  STATE_NAME_INVENTORY = 2972535350,
  STATE_NAME_CONTAINER = 3349343259,
  equipLoadThreshold = eEquipLoad_Fast,
  equipLoadValue = 0,
  updateWeight = true,
  equipLoadNotifications = {
    [-1] = {
      icon = "lyshineui/images/icons/equipload/encumberedbar.png",
      text = "@inv_equipLoadEncumberedNotification"
    },
    [eEquipLoad_Fast] = {
      icon = "lyshineui/images/icons/equipload/speedfastbar.png",
      text = "@inv_equipLoadFastNotification"
    },
    [eEquipLoad_Normal] = {
      icon = "lyshineui/images/icons/equipload/speednormalbar.png",
      text = "@inv_equipLoadNormalNotification"
    },
    [eEquipLoad_Slow] = {
      icon = "lyshineui/images/icons/equipload/speedslowbar.png",
      text = "@inv_equipLoadSlowNotification"
    },
    [eEquipLoad_Overburdened] = {
      icon = "lyshineui/images/icons/equipload/speedoverbar.png",
      text = "@inv_equipLoadOverburdenedNotification"
    }
  },
  suppressNotification = false,
  repairAllEnabled = false,
  isLoadingScreenShowing = nil,
  ITEM_DRAGGABLE_SLICE_PATH = "LyShineUI/Slices/ItemDraggable",
  ARMOR_STAT_SLICE_PATH = "LyShineUI/Slices/ArmorStat",
  REPAIR_PARTS_CRC = 2817455512,
  isInInventoryTutorial = false,
  minStatRowWidth = 130,
  physicalStatWidth = 0,
  elementalStatWidth = 0,
  gearScoreWidth = 0,
  enableBalanceText = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(Equipment)
local Spawner = RequireScript("LyShineUI._Common.Spawner")
Spawner:AttachSpawner(Equipment)
local CommonDragDrop = RequireScript("LyShineUI.CommonDragDrop")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local InventoryUtility = RequireScript("LyShineUI.Automation.Utilities.InventoryUtility")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local EquipmentCommon = RequireScript("LyShineUI.Equipment.EquipmentCommon")
RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
function Equipment:OnInit()
  BaseScreen.OnInit(self)
  self.slotEnumToEntityIdMap = {
    [tonumber(ePaperDollSlotTypes_Head)] = self.Properties.HeadDropTarget,
    [tonumber(ePaperDollSlotTypes_Chest)] = self.Properties.ChestDropTarget,
    [tonumber(ePaperDollSlotTypes_Hands)] = self.Properties.HandsDropTarget,
    [tonumber(ePaperDollSlotTypes_Legs)] = self.Properties.LegsDropTarget,
    [tonumber(ePaperDollSlotTypes_Feet)] = self.Properties.FeetDropTarget,
    [tonumber(ePaperDollSlotTypes_Amulet)] = self.Properties.AmuletDropTarget,
    [tonumber(ePaperDollSlotTypes_Token)] = self.Properties.TokenDropTarget,
    [tonumber(ePaperDollSlotTypes_Ring)] = self.Properties.RingDropTarget,
    [ePaperDollSlotTypes_BagSlot1] = self.Properties.BagSlotDropTarget1,
    [ePaperDollSlotTypes_BagSlot2] = self.Properties.BagSlotDropTarget2,
    [ePaperDollSlotTypes_BagSlot3] = self.Properties.BagSlotDropTarget3,
    [tonumber(ePaperDollSlotTypes_Arrow)] = self.Properties.ArrowDropTarget,
    [tonumber(ePaperDollSlotTypes_Cartridge)] = self.Properties.CartridgeDropTarget,
    [tonumber(ePaperDollSlotTypes_OffHandOption1)] = self.Properties.OffHandOption1DropTarget,
    [ePaperDollSlotTypes_MainHandOption1] = self.Properties.QuickslotDropTargets.QuickslotWeapon1,
    [ePaperDollSlotTypes_MainHandOption2] = self.Properties.QuickslotDropTargets.QuickslotWeapon2,
    [ePaperDollSlotTypes_MainHandOption3] = self.Properties.QuickslotDropTargets.QuickslotWeapon3,
    [ePaperDollSlotTypes_QuickSlot1] = self.Properties.QuickslotDropTargets.QuickslotConsumable1,
    [ePaperDollSlotTypes_QuickSlot2] = self.Properties.QuickslotDropTargets.QuickslotConsumable2,
    [ePaperDollSlotTypes_QuickSlot3] = self.Properties.QuickslotDropTargets.QuickslotConsumable3,
    [ePaperDollSlotTypes_QuickSlot4] = self.Properties.QuickslotDropTargets.QuickslotConsumable4,
    [ePaperDollSlotTypes_Chopping] = self.Properties.ToolDropTargets.LoggingAxeSlot,
    [ePaperDollSlotTypes_Cutting] = self.Properties.ToolDropTargets.SickleSlot,
    [ePaperDollSlotTypes_Dressing] = self.Properties.ToolDropTargets.SkinningKnifeSlot,
    [ePaperDollSlotTypes_Mining] = self.Properties.ToolDropTargets.PickaxeSlot,
    [ePaperDollSlotTypes_Fishing] = self.Properties.ToolDropTargets.FishingRodSlot,
    [ePaperDollSlotTypes_AzothStaff] = self.Properties.ToolDropTargets.AzothStaffSlot
  }
  self.slotsToUseWeaponLayout = {
    [ePaperDollSlotTypes_MainHandOption1] = true,
    [ePaperDollSlotTypes_MainHandOption2] = true,
    [ePaperDollSlotTypes_MainHandOption3] = true
  }
  for slotIndex, dropTargetId in pairs(self.slotEnumToEntityIdMap) do
    if not dropTargetId or type(dropTargetId) == "table" or not dropTargetId:IsValid() then
      self.slotEnumToEntityIdMap[slotIndex] = nil
    else
      local data = {
        slotIndex = slotIndex,
        item = nil,
        parentId = dropTargetId
      }
      self:SpawnSlice(self.Properties.SpawnerComponent, self.ITEM_DRAGGABLE_SLICE_PATH, self.OnItemDraggableSpawned, data)
    end
  end
  if self.Properties.AbilitySelection:IsValid() then
    local slotsWithAbilities = {
      self.Properties.QuickslotDropTargets.QuickslotWeapon1,
      self.Properties.QuickslotDropTargets.QuickslotWeapon2,
      self.Properties.QuickslotDropTargets.QuickslotWeapon3
    }
    for _, dropTarget in pairs(slotsWithAbilities) do
      local dropTargetTable = self.registrar:GetEntityTable(dropTarget)
      dropTargetTable:SetAbilityClickedCallback(self, function(self, itemSlot, abilityIndex)
        self.AbilitySelection:SetAbilitySource(itemSlot, abilityIndex)
        local screenPos = CursorBus.Broadcast.GetCursorPosition()
        PositionEntityOnScreen(self.Properties.AbilitySelection, screenPos)
      end)
    end
  end
  self.hideStates = {}
  self.hideStates[3548394217] = true
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_enableActiveAmmo", function(self, enableActiveAmmo)
    UiElementBus.Event.SetIsEnabled(self.Properties.ArrowDropTarget, not enableActiveAmmo)
    UiElementBus.Event.SetIsEnabled(self.Properties.CartridgeDropTarget, not enableActiveAmmo)
    UiElementBus.Event.SetIsEnabled(self.Properties.EquipmentBgSlots2, not enableActiveAmmo)
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableHudSettings", function(self, hudSettingsEnabled)
    self.hudSettingsEnabled = hudSettingsEnabled
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableEntitlements", function(self, enableEntitlements)
    self.enableEntitlements = enableEntitlements
  end)
  self:BusConnect(UiSpawnerNotificationBus, self.SpawnerComponent)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  self.dataLayer:RegisterOpenEvent("Equipment", self.canvasId)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.ItemRepairEntityId", function(self, repairId)
    if repairId then
      self.repairId = repairId
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Inventory.SuppressNotificationsWhileCrafting", function(self, data)
    if data ~= nil then
      self.suppressNotification = data
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Inventory.SuppressNotificationsWhileItemSkinning", function(self, data)
    if data ~= nil then
      self.suppressNotification = data
    end
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PaperdollEntityId", function(self, paperdollId)
    if not paperdollId then
      return
    end
    self.paperdollId = paperdollId
  end)
  self.coreAttributes = {
    {
      name = "Strength",
      type = CharacterAttributeType_Strength,
      width = 0
    },
    {
      name = "Dexterity",
      type = CharacterAttributeType_Dexterity,
      width = 0
    },
    {
      name = "Intelligence",
      type = CharacterAttributeType_Intelligence,
      width = 0
    },
    {
      name = "Focus",
      type = CharacterAttributeType_Focus,
      width = 0
    },
    {
      name = "Constitution",
      type = CharacterAttributeType_Constitution,
      width = 0
    }
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    if playerEntityId then
      for _, attribute in pairs(self.coreAttributes) do
        local attributeStatEntity = self.ArmorStats[attribute.name .. "Stat"]
        if attributeStatEntity then
          attributeStatEntity:SetLabel("@ui_" .. attribute.name .. "_short")
          attributeStatEntity:SetStatType(attribute.type)
          self.dataLayer:RegisterAndExecuteDataObserver(self, string.format("Hud.LocalPlayer.Attributes.%s.Spent", attribute.name), function(self, attributeValue)
            if attributeValue ~= nil then
              attributeStatEntity:UpdateStatValues()
              attribute.width = attributeStatEntity:GetWidth()
            end
            self:UpdateEquipmentStatsBackdrop()
          end)
        end
      end
    end
  end)
  self.HeadDropTarget:SetEmptyTooltip("@ui_head_slot_tooltip")
  self.ChestDropTarget:SetEmptyTooltip("@ui_chest_slot_tooltip")
  self.HandsDropTarget:SetEmptyTooltip("@ui_hands_slot_tooltip")
  self.LegsDropTarget:SetEmptyTooltip("@ui_legs_slot_tooltip")
  self.FeetDropTarget:SetEmptyTooltip("@ui_feet_slot_tooltip")
  self.AmuletDropTarget:SetEmptyTooltip("@ui_amulet_slot_tooltip")
  self.TokenDropTarget:SetEmptyTooltip("@ui_unlock_token_slot")
  self.RingDropTarget:SetEmptyTooltip("@ui_ring_slot_tooltip")
  self.BagSlotDropTarget1:SetEmptyTooltip("@ui_bag_slot_tooltip")
  self.BagSlotDropTarget2:SetEmptyTooltip("@ui_bag_slot_tooltip")
  self.BagSlotDropTarget3:SetEmptyTooltip("@ui_bag_slot_tooltip")
  self.ArrowDropTarget:SetEmptyTooltip("@ui_arrow_slot_tooltip")
  self.CartridgeDropTarget:SetEmptyTooltip("@ui_cartridge_slot_tooltip")
  self.OffHandOption1DropTarget:SetEmptyTooltip("@ui_shield_slot_tooltip")
  self.QuickslotDropTargets.QuickslotWeapon1:SetEmptyTooltip("@ui_quickslot_mainhand_tooltip")
  self.QuickslotDropTargets.QuickslotWeapon2:SetEmptyTooltip("@ui_quickslot_mainhand_tooltip")
  self.QuickslotDropTargets.QuickslotWeapon3:SetEmptyTooltip("@ui_quickslot_mainhand_tooltip")
  self.QuickslotDropTargets.QuickslotConsumable1:SetEmptyTooltip("@ui_quickslot_consumable_tooltip")
  self.QuickslotDropTargets.QuickslotConsumable2:SetEmptyTooltip("@ui_quickslot_consumable_tooltip")
  self.QuickslotDropTargets.QuickslotConsumable3:SetEmptyTooltip("@ui_quickslot_consumable_tooltip")
  self.QuickslotDropTargets.QuickslotConsumable4:SetEmptyTooltip("@ui_quickslot_consumable_tooltip")
  self.ToolDropTargets.SickleSlot:SetEmptyTooltip("@ui_quickslot_sickle_tooltip")
  self.ToolDropTargets.FishingRodSlot:SetEmptyTooltip("@ui_quickslot_fishing_tooltip")
  self.ToolDropTargets.LoggingAxeSlot:SetEmptyTooltip("@ui_quickslot_logging_tooltip")
  self.ToolDropTargets.SkinningKnifeSlot:SetEmptyTooltip("@ui_quickslot_skinning_tooltip")
  self.ToolDropTargets.PickaxeSlot:SetEmptyTooltip("@ui_quickslot_pickaxe_tooltip")
  self.ToolDropTargets.AzothStaffSlot:SetEmptyTooltip("@ui_quickslot_azoth_tooltip")
  self.ArmorStats.PhysicalDefenseStat:SetLabel("@ui_physical_defense_short")
  self.ArmorStats.PhysicalDefenseStat:SetValueForColorShift(200)
  self.ArmorStats.PhysicalDefenseStat:SetDecimalCount(1)
  self.ArmorStats.ElementalDefenseStat:SetLabel("@ui_elemental_defense_short")
  self.ArmorStats.ElementalDefenseStat:SetValueForColorShift(200)
  self.ArmorStats.ElementalDefenseStat:SetDecimalCount(1)
  self.ArmorStats.GearScoreStat:SetLabel("@cr_gearscore")
  UiElementBus.Event.SetIsEnabled(self.Properties.ArmorStats.GearScoreStat, true)
  self.clickRecognizer = RequireScript("LyShineUI._Common.ClickRecognizer")
  self.clickRecognizer:OnActivate(self, "ItemUpdateDragData", "ItemInteract", self.OnDoubleClick, self.OpenContextMenu, nil)
  DynamicBus.EquipmentBus.Connect(self.entityId, self)
  self.WeightBar:SetOverageText("@inv_equipLoadOverburdened")
  self.WeightBar:SetOverageIcon("lyshineui/images/icons/equipload/speedover.png")
  self.WeightBar:SetMaxOveragePercent(0.15)
  self:SetEquipLoadThresholds()
  self.EQUIP_LOAD_TOOLTIP_SECTION_OPACITY = 0.4
  self.EQUIP_LOAD_TOOLTIP_INTENT_TIME = 0.25
  local oldHoverStart = UiInteractableActionsBus.Event.GetHoverStartActionName(self.Properties.EquipLoadTooltip.HitArea)
  if oldHoverStart == "" then
    UiInteractableActionsBus.Event.SetHoverStartActionName(self.Properties.EquipLoadTooltip.HitArea, "OnEquipLoadHoverStart")
    UiInteractableActionsBus.Event.SetHoverEndActionName(self.Properties.EquipLoadTooltip.HitArea, "OnEquipLoadHoverEnd")
  end
  SetTextStyle(self.EquipLoadTooltip.Description, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP)
  SetTextStyle(self.EquipLoadTooltip.Title, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP_TITLE)
  local tooltipTitles = {
    self.EquipLoadTooltip.FastTitle,
    self.EquipLoadTooltip.NormalTitle,
    self.EquipLoadTooltip.SlowTitle,
    self.EquipLoadTooltip.EncumberedTitle
  }
  for _, element in pairs(tooltipTitles) do
    SetTextStyle(element, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP_SUBTITLE)
  end
  local tooltipTexts = {
    self.EquipLoadTooltip.FastText,
    self.EquipLoadTooltip.NormalText,
    self.EquipLoadTooltip.SlowText,
    self.EquipLoadTooltip.EncumberedText
  }
  for _, element in pairs(tooltipTexts) do
    SetTextStyle(element, self.UIStyle.FONT_STYLE_EQUIP_LOAD_TOOLTIP)
  end
  self:SizeEquipLoadTooltip()
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Equipment.EquipLoadMax", self.SetEquipLoadMax)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Equipment.EquipLoad", self.SetEquipLoad)
  self.dataLayer:RegisterDataObserver(self, "Hud.LocalPlayer.Equipment.EquipLoadCategory", self.SetEquipLoadCategory)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Encumbrance.ShouldUpdateWeight", function(self, data)
    if data == nil then
      data = true
    end
    self.updateWeight = data
  end)
  self.dataLayer:RegisterDataObserver(self, "Hud.StackSplitter.EquippedStackWeight", function(self, stackWeight)
    if stackWeight then
      self.WeightBar:SetStackSplitValue(stackWeight)
      local equipLoadMax = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Equipment.EquipLoadMax")
      if equipLoadMax == 0 then
        return
      end
      local equipLoad = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Equipment.EquipLoad")
      local adjustedEquipLoad = equipLoad - stackWeight
      local equipRatio = adjustedEquipLoad / equipLoadMax
      local overburdenedRatio = PaperdollRequestBus.Event.GetEquipLoadRatio(self.paperdollId, eEquipLoad_Overburdened) / 100
      local slowRatio = PaperdollRequestBus.Event.GetEquipLoadRatio(self.paperdollId, eEquipLoad_Slow) / 100
      if equipRatio >= overburdenedRatio then
        self.ScriptedEntityTweener:Set(self.Properties.OverburdenedHighlight, {
          imgColor = self.UIStyle.COLOR_RED_DARK,
          opacity = 0.35
        })
      else
        self.ScriptedEntityTweener:Set(self.Properties.OverburdenedHighlight, {opacity = 0})
      end
    end
  end)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Message, "@cr_add_equipment", eUiTextSet_SetLocalized)
  SetTextStyle(self.Message, self.UIStyle.FONT_STYLE_CRAFTING_FAMILY)
  UiImageBus.Event.SetColor(self.Properties.OverburdenedHighlight, self.UIStyle.COLOR_RED_DARK)
  UiCanvasBus.Event.SetDrawOrder(self.Properties.OverburdenedHighlight, 5)
  self:SetEquipLoadCategory()
  if self.hudSettingsEnabled then
    self:SetVisualElements()
  end
  self.PurchaseSkins:SetText("@ui_store")
  self.PurchaseSkins:SetFontSize(self.UIStyle.FONT_SIZE_BUTTON_SIMPLE)
  self.PurchaseSkins:SetCallback(function()
    if FtueSystemRequestBus.Broadcast.IsFtue() then
      return
    end
    if EntitlementsDataHandler:IsStoreEnabled() then
      DynamicBus.StoreScreenBus.Broadcast.InvokeStoreFromButton("equipment_screen")
    end
  end, self)
  self.PurchaseSkins:SetTextAlignment(self.enableBalanceText and self.PurchaseSkins.TEXT_ALIGN_LEFT or self.PurchaseSkins.TEXT_ALIGN_CENTER)
  self.RepairAll:SetText("@ui_repair_all", false, true)
  self.RepairAll:SetFontSize(self.UIStyle.FONT_SIZE_BUTTON_SIMPLE)
  self.RepairAll:SetCallback("OnRepairAllButton", self)
  UiElementBus.Event.SetIsEnabled(self.Properties.RepairAll, true)
  self.RepairAll:SetTooltip("@ui_repair_all")
  self.isFtue = FtueSystemRequestBus.Broadcast.IsFtue()
  if self.isFtue then
    DynamicBus.FtueMessageBus.Connect(self.entityId, self)
  end
end
function Equipment:SetScreenVisible(IsVisible)
  UiElementBus.Event.SetIsEnabled(self.Properties.Content, IsVisible)
end
function Equipment:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.EquipmentBus.Disconnect(self.entityId, self)
  if self.containerNotificationHandler then
    self.containerNotificationHandler:Disconnect()
    self.containerNotificationHandler = nil
  end
  if self.isFtue then
    DynamicBus.FtueMessageBus.Disconnect(self.entityId, self)
  end
  self.clickRecognizer:OnDeactivate(self)
end
function Equipment:SetVisualElements()
  self.QuickslotHints.QuickslotWeaponHint1:SetKeybindMapping("quickslot-weapon1")
  self.QuickslotHints.QuickslotWeaponHint2:SetKeybindMapping("quickslot-weapon2")
  self.QuickslotHints.QuickslotWeaponHint3:SetKeybindMapping("quickslot-weapon3")
  self.QuickslotHints.QuickslotConsumableHint1:SetKeybindMapping("quickslot-consumable-1")
  self.QuickslotHints.QuickslotConsumableHint2:SetKeybindMapping("quickslot-consumable-2")
  self.QuickslotHints.QuickslotConsumableHint3:SetKeybindMapping("quickslot-consumable-3")
  self.QuickslotHints.QuickslotConsumableHint4:SetKeybindMapping("quickslot-consumable-4")
  self.ToolHints.FishingPoleHint:SetKeybindMapping("fishing_activate")
  self.QuickslotHints.QuickslotWeaponHint1:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotWeaponHint2:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotWeaponHint3:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotConsumableHint1:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotConsumableHint2:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotConsumableHint3:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
  self.QuickslotHints.QuickslotConsumableHint4:SetTextStyle(self.UIStyle.FONT_STYLE_HINT_HUD)
end
function Equipment:OnDoubleClick(entityId)
  if LocalPlayerUIRequestsBus.Broadcast.IsItemTransferEnabled() and not self.isInInventoryTutorial then
    local slotName = ItemContainerBus.Event.GetSlotName(entityId)
    if not slotName then
      return
    end
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    if not inventoryId then
      return
    end
    local sourceSlotId = tonumber(slotName)
    local targetItem = PaperdollRequestBus.Event.GetSlot(self.paperdollId, sourceSlotId)
    if targetItem and targetItem:IsValid() then
      local slotsRemaining = CommonDragDrop:GetInventorySlotsRemaining()
      if slotsRemaining == 0 then
        DynamicBus.NotificationsRequestBus.Broadcast.NotifyInventorySlotsRemaining(true, slotsRemaining)
        return
      end
      local isSlotBlocked = PaperdollRequestBus.Event.SlotBlockedByCooldown(self.paperdollId, sourceSlotId)
      if isSlotBlocked then
        EquipmentCommon:TriggerEquipErrorNotification("@ui_equipment_cooldown_error")
      end
      LocalPlayerUIRequestsBus.Broadcast.UnequipItem(sourceSlotId, -1, targetItem:GetStackSize(), inventoryId)
      LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    end
  end
end
function Equipment:UpdateEquipmentStatsBackdrop()
  local longestWidth = 0
  longestWidth = math.max(longestWidth, self.elementalStatWidth, self.physicalStatWidth, self.gearScoreWidth)
  for _, attribute in pairs(self.coreAttributes) do
    longestWidth = math.max(longestWidth, attribute.width)
  end
  self.ScriptedEntityTweener:Play(self.Properties.ArmorStatsContainer, 0.1, {
    w = math.max(self.minStatRowWidth, longestWidth),
    ease = "QuadOut"
  })
end
function Equipment:UpdateArmorRatings()
  local vitalsEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.VitalsEntityId")
  local powerLevel = PaperdollRequestBus.Event.GetPowerLevel(self.paperdollId)
  local physicalDefense = VitalsComponentRequestBus.Event.GetVitalsArmorModifierValueById(vitalsEntityId, 3609800712)
  local elementalDefense = VitalsComponentRequestBus.Event.GetVitalsArmorModifierValueById(vitalsEntityId, 4218213731)
  self.ArmorStats.PhysicalDefenseStat:SetBaseValue(physicalDefense)
  self.ArmorStats.ElementalDefenseStat:SetBaseValue(elementalDefense)
  self.ArmorStats.GearScoreStat:SetBaseValue(powerLevel)
  local gearScoreValueWidth = self.ArmorStats.GearScoreStat:GetValueWidth()
  local gearScoreLabelWidth = self.ArmorStats.GearScoreStat:GetLabelWidth()
  local gearScoreTextPadding = 27
  self.gearScoreWidth = gearScoreValueWidth + gearScoreLabelWidth + gearScoreTextPadding
  self.physicalStatWidth = self.ArmorStats.PhysicalDefenseStat:GetWidth()
  self.elementalStatWidth = self.ArmorStats.ElementalDefenseStat:GetWidth()
  self:UpdateEquipmentStatsBackdrop()
end
function Equipment:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  local isContainerOpen = LyShineManagerBus.Broadcast.IsInState(3349343259)
  local isLootDrop = isContainerOpen and self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ActiveContainerIsLootDrop")
  local isGeneratorScreen = LyShineManagerBus.Broadcast.IsInState(1809891471)
  local isP2P = LyShineManagerBus.Broadcast.IsInState(2552344588)
  local repairButtonWidth = self.RepairAll:GetWidth()
  local purchaseButtonWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.PurchaseSkins)
  local spacing = 4
  local repairButtonPositionX = 0
  local storeKillSwitch = ConfigProviderEventBus.Broadcast.GetBool("javelin.red-button-disable-MTX-store")
  if self.enableEntitlements and not FtueSystemRequestBus.Broadcast.IsFtue() and not storeKillSwitch then
    UiElementBus.Event.SetIsEnabled(self.Properties.PurchaseSkins, true)
    local totalWidth = repairButtonWidth + purchaseButtonWidth + spacing
    local newPos = totalWidth / 2
    repairButtonPositionX = -newPos
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.PurchaseSkins, false)
    local newPos = repairButtonWidth / 2
    repairButtonPositionX = -newPos
  end
  self.ScriptedEntityTweener:Set(self.Properties.RepairAll, {x = repairButtonPositionX})
  local fictionalBalance = OmniDataHandler:GetEntitlementBalance(OmniDataHandler.FICTIONAL_CURRENCY_ENTITLEMENT_ID)
  local hasCurrency = 0 < fictionalBalance
  UiElementBus.Event.SetIsEnabled(self.Properties.BalanceText, hasCurrency and self.enableBalanceText)
  UiElementBus.Event.SetIsEnabled(self.Properties.MarksOfFortuneIcon, hasCurrency and self.enableBalanceText)
  if hasCurrency and self.enableBalanceText then
    local balanceText = GetFormattedNumber(fictionalBalance, 0)
    UiTextBus.Event.SetText(self.Properties.BalanceText, balanceText)
  end
  self.PurchaseSkins:SetEnabled(not FtueSystemRequestBus.Broadcast.IsFtue())
  self.PurchaseSkins:SetText("@ui_purchase_skin")
  if not (not isContainerOpen or isLootDrop) or isGeneratorScreen or isP2P then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, -640)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ArmorStatsContainer, 120)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonContainer, 128)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Content, -330)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ArmorStatsContainer, 25)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ButtonContainer, 84)
  end
  if fromState == self.STATE_NAME_INVENTORY and toState == self.STATE_NAME_CONTAINER then
    return
  end
  if self.hideStates[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
    self:SetStatRowsAllowAnimation(false)
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Quickslots.ExtraWeaponsVisible", true)
  self:SetEquipLoadThresholds()
  self:SetEquipLoadMax(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Equipment.EquipLoadMax"))
  self:SetEquipLoad(self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Equipment.EquipLoad"))
  self.WeightBar:AnimateIn()
  self:SetStatRowsAllowAnimation(true)
  if not self.containerNotificationHandler then
    self.containerNotificationHandler = PaperdollEventBus.Connect(self, self.paperdollId)
    for i = 0, ePaperDollSlotTypes_Num do
      local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, i)
      self:OnPaperdollSlotUpdate(i, slot)
    end
    self:OnPaperdollSlotProgressionChanged()
  end
  if self.Properties.AbilitySelection:IsValid() then
    self.AbilitySelection:SetVisibility(false)
  end
  if not self.inventoryNotificationHandler then
    local inventoryId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.InventoryEntityId")
    self.inventoryNotificationHandler = ContainerEventBus.Connect(self, inventoryId)
  end
  if not self.repairPartsProgressionHandler then
    local playerId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    self.repairPartsProgressionHandler = self:BusConnect(CategoricalProgressionNotificationBus, playerId)
  end
  self:UpdateArmorRatings()
  self.repairAllEnabled = true
  self:ComputeRepairAllAmount()
end
function Equipment:OnTransitionOut(fromState, fromLevel, toState, toLevel)
  LyShineManagerBus.Broadcast.TransitionOutComplete()
  if self.hideStates[toState] then
    UiCanvasBus.Event.SetEnabled(self.canvasId, true)
    self:SetStatRowsAllowAnimation(true)
  end
  if fromState ~= self.STATE_NAME_INVENTORY or toState ~= self.STATE_NAME_CONTAINER then
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Quickslots.ExtraWeaponsVisible", false)
    if self.containerNotificationHandler then
      self:BusDisconnect(self.containerNotificationHandler)
      self.containerNotificationHandler = nil
    end
    if self.inventoryNotificationHandler then
      self:BusDisconnect(self.inventoryNotificationHandler)
      self.inventoryNotificationHandler = nil
    end
    if self.repairPartsProgressionHandler then
      self:BusDisconnect(self.repairPartsProgressionHandler)
      self.repairPartsProgressionHandler = nil
    end
    self:SetStatRowsAllowAnimation(false)
  end
end
function Equipment:OnSlotUpdate(localSlotId, itemSlot, action)
  self:ComputeRepairAllAmount()
end
function Equipment:OnCategoricalProgressionPointsChanged(masteryNameCrc, oldPoints, newPoints)
  if masteryNameCrc == self.REPAIR_PARTS_CRC then
    self:ComputeRepairAllAmount()
  end
end
function Equipment:SetStatRowsAllowAnimation(allowAnimation)
  self.ArmorStats.PhysicalDefenseStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.ElementalDefenseStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.GearScoreStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.StrengthStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.DexterityStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.IntelligenceStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.FocusStat:SetAllowAnimation(allowAnimation)
  self.ArmorStats.ConstitutionStat:SetAllowAnimation(allowAnimation)
end
function Equipment:OnLoadingScreenDismissed()
  self.isLoadingScreenShowing = false
end
function Equipment:ComputeRepairAllAmount()
  self.totalRepairCost = ItemRepairRequestBus.Event.GetCostForRepairAllEquipment(self.repairId)
  if self.totalRepairCost.hasJobs then
    local hasEnoughKitsAndParts = false
    if self.totalRepairCost.repairParts > 0 or 0 < self.totalRepairCost.coin then
      hasEnoughKitsAndParts = InventoryUtility:GetGold() >= self.totalRepairCost.coin and InventoryUtility:GetRepairParts() >= self.totalRepairCost.repairParts
    else
      hasEnoughKitsAndParts = true
    end
    self:SetRepairAllActive(hasEnoughKitsAndParts, true)
  else
    self:SetRepairAllActive(false, false)
  end
end
function Equipment:SetRepairAllActive(active, hasDamagedItems)
  self.RepairAll:SetEnabled(active)
  if hasDamagedItems then
    self.RepairAll:SetTooltip(active and "@ui_repair_all" or "@ui_repair_all_equipment_disabled")
  else
    self.RepairAll:SetTooltip("@ui_repair_all_not_needed_equipment")
  end
end
function Equipment:OnRepairAllButton()
  if self.repairAllEnabled then
    local repairConfirmation = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_repair_all_equipment_confirmation")
    local totalRepairKits = 0
    for i = 1, #self.totalRepairCost.repairKits do
      totalRepairKits = totalRepairKits + self.totalRepairCost.repairKits[i]
    end
    if 0 < totalRepairKits then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@inv_repair_kit_count", totalRepairKits)
    end
    if 0 < self.totalRepairCost.coin then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_currency_value", GetLocalizedCurrency(self.totalRepairCost.coin))
    end
    if 0 < self.totalRepairCost.repairParts then
      repairConfirmation = repairConfirmation .. "\n" .. LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@inv_repairparts_quantity", self.totalRepairCost.repairParts)
    end
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, "@ui_repair_all", repairConfirmation, "repairAll", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        local paperdollId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PaperdollEntityId")
        for i = 0, ePaperDollSlotTypes_Num do
          local slot = PaperdollRequestBus.Event.GetSlot(paperdollId, i)
          if slot and slot:CanRepairItem() then
            local itemInstanceId = slot:GetItemInstanceId()
            DynamicBus.ItemRepairDynamicBus.Broadcast.OnItemRepaired(itemInstanceId)
          end
        end
        ItemRepairRequestBus.Event.RepairAllEquipment(self.repairId)
      end
    end)
  end
end
function Equipment:OnPaperdollSlotUpdate(localSlotId, slot)
  if localSlotId <= ePaperDollSlotTypes_Num then
    local dropTargetId = self.slotEnumToEntityIdMap[localSlotId]
    if not dropTargetId then
      return
    end
    local dropTargetTable = self.registrar:GetEntityTable(dropTargetId)
    local draggableId = dropTargetTable:GetDraggableId()
    if not draggableId then
      return
    end
    if not slot or not slot:IsValid() then
      if UiElementBus.Event.IsEnabled(draggableId) then
        local itemDraggable = self.registrar:GetEntityTable(draggableId)
        itemDraggable:OnReturnedToCache()
      end
      UiElementBus.Event.SetIsEnabled(draggableId, false)
      dropTargetTable:SetEmptyIconVisible(true)
    else
      if draggableId:IsValid() then
        UiElementBus.Event.SetIsEnabled(draggableId, true)
        self:SetItem(draggableId, slot, localSlotId)
      end
      dropTargetTable:SetEmptyIconVisible(false)
    end
    if self.hudSettingsEnabled then
      local offhandSlot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, tonumber(ePaperDollSlotTypes_OffHandOption1))
      local itemName = ""
      if offhandSlot then
        itemName = offhandSlot:GetItemName()
      end
      if itemName ~= "" then
        dropTargetTable:SetCompatibleIconPath(itemName)
      else
        dropTargetTable:SetCompatibleIconPath(nil)
      end
      dropTargetTable:SetItemSlot(slot, localSlotId)
    end
    self:UpdateArmorRatings()
    if self.repairAllEnabled then
      self:ComputeRepairAllAmount()
    end
  end
end
function Equipment:OnPaperdollSlotProgressionChanged()
  for slotEnum, entityId in pairs(self.slotEnumToEntityIdMap) do
    local isLocked = not PaperdollRequestBus.Event.HasLevelRequirementForSlot(self.paperdollId, slotEnum)
    local dropTargetTable = self.registrar:GetEntityTable(entityId)
    dropTargetTable:SetLockIconVisible(isLocked)
    dropTargetTable:SetIsLocked(isLocked)
    if isLocked then
      local levelReq = PaperdollRequestBus.Event.GetLevelRequirementForSlot(self.paperdollId, slotEnum)
      dropTargetTable:SetLockText(levelReq + 1)
    end
  end
end
function Equipment:OnAction(entityId, actionName)
  BaseScreen.OnAction(self, entityId, actionName)
  if type(self[actionName]) == "function" then
    self[actionName](self, entityId, actionName)
  end
end
function Equipment:ItemUpdateDragData(entityId)
  local slotName = ItemContainerBus.Event.GetSlotName(entityId)
  local itemSlot = ContainerRequestBus.Event.GetSlot(self.paperdollId, slotName)
  local stackSize = itemSlot:GetStackSize()
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerType", eItemDragContext_Paperdoll)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerId", self.paperdollId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.ContainerSlotId", slotName)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.ItemDragging.StackSize", stackSize)
end
function Equipment:SetEquipLoadMax(value)
  if value == nil then
    return
  end
  self.WeightBar:SetMaxValue(value / 10)
end
function Equipment:SetEquipLoad(value)
  if value == nil or not self.updateWeight then
    return
  end
  self.WeightBar:SetValue(value / 10)
  self.equipLoadValue = value
end
function Equipment:SetEquipLoadThresholds()
  if self.paperdollId ~= nil then
    local firstDividerPos = PaperdollRequestBus.Event.GetEquipLoadRatio(self.paperdollId, eEquipLoad_Normal) / 100
    local secondDividerPos = PaperdollRequestBus.Event.GetEquipLoadRatio(self.paperdollId, eEquipLoad_Slow) / 100
    self.WeightBar:SetDividerPositions(firstDividerPos, secondDividerPos)
  end
end
function Equipment:SetEquipLoadCategory()
  if not self.updateWeight then
    return
  end
  local category = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Equipment.EquipLoadCategory")
  local weightTextColor = self.UIStyle.COLOR_TAN_LIGHT
  if category == eEquipLoad_Overburdened then
    self.ScriptedEntityTweener:Play(self.Properties.OverburdenedHighlight, 0.3, {
      imgColor = self.UIStyle.COLOR_RED_DARK,
      opacity = 0.35
    })
    UiTextBus.Event.SetTextWithFlags(self.Properties.WeightText, "@inv_equipLoadOverburdened", eUiTextSet_SetLocalized)
    weightTextColor = self.UIStyle.COLOR_RED
  elseif category == eEquipLoad_Slow then
    self.ScriptedEntityTweener:Play(self.Properties.OverburdenedHighlight, 0.3, {opacity = 0})
    UiTextBus.Event.SetTextWithFlags(self.Properties.WeightText, "@inv_equipLoadSlow", eUiTextSet_SetLocalized)
    weightTextColor = self.UIStyle.COLOR_YELLOW
  elseif category == eEquipLoad_Normal then
    self.ScriptedEntityTweener:Play(self.Properties.OverburdenedHighlight, 0.3, {opacity = 0})
    UiTextBus.Event.SetTextWithFlags(self.Properties.WeightText, "@inv_equipLoadNormal", eUiTextSet_SetLocalized)
  elseif category == eEquipLoad_Fast then
    self.ScriptedEntityTweener:Play(self.Properties.OverburdenedHighlight, 0.3, {opacity = 0})
    UiTextBus.Event.SetTextWithFlags(self.Properties.WeightText, "@inv_equipLoadFast", eUiTextSet_SetLocalized)
    weightTextColor = self.UIStyle.COLOR_GREEN
  end
  self.ScriptedEntityTweener:Play(self.Properties.WeightText, 0.3, {textColor = weightTextColor, ease = "QuadOut"})
  local isEncumbered = LocalPlayerUIRequestsBus.Broadcast.IsEncumbered()
  if isEncumbered then
    category = -1
  end
  if category ~= self.equipLoadCategory then
    local elementMap = {
      [-1] = self.EquipLoadTooltip.Encumbered,
      [eEquipLoad_Fast] = self.EquipLoadTooltip.Fast,
      [eEquipLoad_Normal] = self.EquipLoadTooltip.Normal,
      [eEquipLoad_Slow] = self.EquipLoadTooltip.Slow,
      [eEquipLoad_Overburdened] = self.EquipLoadTooltip.Overburdened
    }
    for index, section in pairs(elementMap) do
      if index ~= category then
        self.ScriptedEntityTweener:Set(section, {
          opacity = self.EQUIP_LOAD_TOOLTIP_SECTION_OPACITY
        })
      else
        self.ScriptedEntityTweener:Set(section, {opacity = 1})
      end
    end
    if not self.suppressNotification and self.equipLoadCategory ~= nil then
      local message = LyShineScriptBindRequestBus.Broadcast.LocalizeText(self.equipLoadNotifications[category].text)
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = "<img src=\"" .. self.equipLoadNotifications[category].icon .. "\" height=\"32\" vAlign=\"center\" yOffset=\"2\" xPadding=\"12\" />" .. message
      notificationData.contextId = self.entityId
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
    if self.isLoadingScreenShowing == false then
      local soundToPlay = self.audioHelper.OnUnencumberedEquipment
      if category > self.equipLoadCategory and self.equipLoadCategory ~= -1 or category == -1 then
        soundToPlay = self.audioHelper.OnEncumberedEquipment
      end
      self.audioHelper:PlaySound(soundToPlay)
    end
    self.equipLoadCategory = category
  end
end
function Equipment:SizeEquipLoadTooltip()
  UiCanvasBus.Event.SetDrawOrder(self.EquipLoadTooltip.Container, 999)
  local sectionMargin = 24
  local descriptionOffsets = UiTransform2dBus.Event.GetOffsets(self.EquipLoadTooltip.Description)
  local lastY = descriptionOffsets.top + UiTransform2dBus.Event.GetLocalHeight(self.EquipLoadTooltip.Description)
  local lastHeight = 0
  local sections = {
    self.EquipLoadTooltip.Fast,
    self.EquipLoadTooltip.Normal,
    self.EquipLoadTooltip.Slow,
    self.EquipLoadTooltip.Encumbered
  }
  for _, section in ipairs(sections) do
    self.ScriptedEntityTweener:Set(section, {
      y = lastY + sectionMargin
    })
    local children = UiElementBus.Event.GetChildren(section)
    for j = 1, #children do
      lastHeight = math.max(lastHeight, UiTransform2dBus.Event.GetOffsets(children[j]).top + UiTransform2dBus.Event.GetLocalHeight(children[j]))
    end
    lastY = lastY + sectionMargin + lastHeight
    lastHeight = 0
  end
  self.EquipLoadTooltip.Frame:SetWidth(UiTransform2dBus.Event.GetLocalWidth(self.EquipLoadTooltip.Container))
  self.EquipLoadTooltip.Frame:SetHeight(lastY + sectionMargin)
end
function Equipment:OnEquipLoadHoverStart()
  local fadeInTime = 0.15
  self.ScriptedEntityTweener:Play(self.EquipLoadTooltip.Container, fadeInTime, {
    delay = self.EQUIP_LOAD_TOOLTIP_INTENT_TIME,
    opacity = 1
  })
  self.EquipLoadTooltip.Frame:SetLineVisible(true, fadeInTime * 4, {
    delay = self.EQUIP_LOAD_TOOLTIP_INTENT_TIME
  })
end
function Equipment:OnEquipLoadHoverEnd()
  local fadeOutTime = 0.15
  self.ScriptedEntityTweener:Stop(self.EquipLoadTooltip.Container)
  self.EquipLoadTooltip.Frame:SetLineVisible(false, fadeOutTime)
  self.ScriptedEntityTweener:Play(self.EquipLoadTooltip.Container, fadeOutTime, {opacity = 0})
end
function Equipment:SetItem(itemEntityId, itemSlot, slotIndex)
  local itemDraggable = self.registrar:GetEntityTable(itemEntityId)
  if self.slotsToUseWeaponLayout[slotIndex] then
    itemDraggable:SetModeType(itemDraggable.ItemLayout.MODE_TYPE_EQUIPMENT_WEAPON)
  else
    itemDraggable:SetModeType(itemDraggable.ItemLayout.MODE_TYPE_EQUIPPED)
  end
  DynamicBus.ItemLayoutSlotProvider.Event.SetItemAndSlotProvider(itemEntityId, itemSlot, slotIndex, function()
    local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, slotIndex)
    return slot
  end)
end
local invalidEntityId = EntityId()
function Equipment:OnItemDraggableSpawned(itemDraggable, data)
  if itemDraggable then
    itemDraggable.ItemLayout:OnItemMoved()
    local dropTargetId = data.parentId
    local equipmentItemDropTarget = self.registrar:GetEntityTable(dropTargetId)
    local insertBefore = invalidEntityId
    if equipmentItemDropTarget then
      insertBefore = equipmentItemDropTarget:GetDraggableInsertBeforeEntityId()
    end
    UiElementBus.Event.Reparent(itemDraggable.entityId, dropTargetId, insertBefore)
    if self.paperdollId and not data.item then
      data.item = PaperdollRequestBus.Event.GetSlot(self.paperdollId, data.slotIndex)
    end
    if data.item and data.item:IsValid() then
      self:SetItem(itemDraggable.entityId, data.item, data.slotIndex)
    else
      UiElementBus.Event.SetIsEnabled(itemDraggable.entityId, false)
    end
    equipmentItemDropTarget.draggableId = itemDraggable.entityId
  end
end
function Equipment:OpenContextMenu(entityId)
end
function Equipment:ContextInventoryUnequipItem(entityId, actionName)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local dropTarget = UiElementBus.Event.GetParent(entityId)
  local slotIndex
  for index, slotEntityId in ipairs(self.slotEnumToEntityIdMap) do
    if dropTarget == slotEntityId then
      slotIndex = index
    end
  end
  if slotIndex ~= nil then
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
end
function Equipment:ContextInventoryRepairItem(entityId)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local dropTarget = UiElementBus.Event.GetParent(entityId)
  local slotName = UiElementBus.Event.GetName(dropTarget)
  LocalPlayerUIRequestsBus.Broadcast.RepairItem(slotName, false)
end
function Equipment:PlayCraftAnimation(toSlot)
  if KeyIsInsideTable(self.slotEnumToEntityIdMap, toSlot) then
    do
      local slotEntity = self.slotEnumToEntityIdMap[toSlot]
      local entityRect = UiTransformBus.Event.GetViewportSpaceRect(slotEntity)
      local entityCenter = entityRect:GetCenter()
      UiTransformBus.Event.SetViewportPosition(self.Properties.CraftingAnimation, entityCenter)
      UiCanvasBus.Event.SetEnabled(self.canvasId, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.InputBlocker, true)
      local highlightElement
      UiElementBus.Event.SetIsEnabled(self.Properties.CraftingAnimation, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.CraftingAnimation)
      self.audioHelper:PlaySound(self.audioHelper.Crafting_Inventory_Add)
      self.ScriptedEntityTweener:Play(self.Properties.CraftingAnimation, 0.4, {
        scaleX = -1,
        onComplete = function()
          local entityTable = self.registrar:GetEntityTable(slotEntity)
          highlightElement = entityTable.HighlightElement
          UiElementBus.Event.SetIsEnabled(highlightElement, true)
          UiElementBus.Event.SetIsEnabled(self.Properties.Message, true)
          self.ScriptedEntityTweener:Play(self.Properties.Message, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
          self.ScriptedEntityTweener:Play(self.Properties.MessageText, 0.6, {opacity = 0, x = 19}, {
            opacity = 1,
            x = 49,
            ease = "QuadOut",
            delay = 0.3
          })
          self.ScriptedEntityTweener:Play(self.Properties.Message, 0.5, {opacity = 1}, {
            opacity = 0,
            ease = "QuadOut",
            delay = 1,
            onComplete = function()
              self:HideCraftAnimation(toSlot)
            end
          })
        end
      })
      local slot = PaperdollRequestBus.Event.GetSlot(self.paperdollId, toSlot)
      DynamicBus.EncumbranceBus.Broadcast.PlayCraftAnimation(nil, nil, slot:GetItemDescriptor())
    end
  end
end
function Equipment:HideCraftAnimation(toSlot)
  if KeyIsInsideTable(self.slotEnumToEntityIdMap, toSlot) then
    local slotEntity = self.slotEnumToEntityIdMap[toSlot]
    local entityRect = UiTransformBus.Event.GetViewportSpaceRect(slotEntity)
    local entityCenter = entityRect:GetCenter()
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
    UiElementBus.Event.SetIsEnabled(self.Properties.Message, false)
    UiCanvasBus.Event.SetEnabled(self.canvasId, false)
  end
end
function Equipment:SetInventoryTutorialActive(isActive)
  self.isInInventoryTutorial = isActive
end
function Equipment:OnHoverArmorStats()
  self:ShowGearScoreTooltip()
end
function Equipment:OnHoverEndArmorStats()
  self.ScriptedEntityTweener:PlayC(self.Properties.EquipmentStatsTooltip, 0.1, tweenerCommon.fadeOutQuadOut)
end
function Equipment:ShowGearScoreTooltip()
  UiCanvasBus.Event.RecomputeChangedLayouts(self.canvasId)
  local physicalDamageTypes = {
    Slash = true,
    Thrust = true,
    Strike = true
  }
  local physicalModifiers = {}
  local elementalModifiers = {}
  local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
  local damageTypes = LocalPlayerUIRequestsBus.Broadcast.GetDamageTypeKeys()
  for i = 1, #damageTypes do
    local damageTypeName = damageTypes[i]
    local weakness = VitalsComponentRequestBus.Event.GetWeaknessFromDamageType(rootEntityId, Math.CreateCrc32(damageTypeName))
    local absorption = VitalsComponentRequestBus.Event.GetAbsorptionFromDamageType(rootEntityId, Math.CreateCrc32(damageTypeName))
    local total = absorption - weakness
    if total ~= 0 then
      local damageTable = elementalModifiers
      if physicalDamageTypes[damageTypeName] then
        damageTable = physicalModifiers
      end
      table.insert(damageTable, {
        name = damageTypeName,
        weakness = weakness,
        absorption = absorption,
        total = total
      })
    end
  end
  self.EquipmentStatsTooltip:SetData({physicalModifiers = physicalModifiers, elementalModifiers = elementalModifiers})
  self.ScriptedEntityTweener:PlayC(self.Properties.EquipmentStatsTooltip, 0.3, tweenerCommon.fadeInQuadOut)
end
return Equipment
