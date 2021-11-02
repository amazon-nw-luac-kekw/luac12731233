local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ItemLayout = {
  Properties = {
    ItemTier = {
      default = EntityId()
    },
    ItemQuantity = {
      default = EntityId()
    },
    ItemSortValueText = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    ItemFrame = {
      default = EntityId()
    },
    ItemHighlight = {
      default = EntityId()
    },
    ItemRarityBg = {
      default = EntityId()
    },
    ItemBroken = {
      default = EntityId()
    },
    ItemDurabilityHolder = {
      default = EntityId()
    },
    ItemDurabilityFill = {
      default = EntityId()
    },
    DurabilityDivider = {
      default = EntityId()
    },
    ItemAnimatedIndicator = {
      default = EntityId()
    },
    ItemDimmer = {
      default = EntityId()
    },
    ItemCooldownHolder = {
      default = EntityId()
    },
    ItemCooldownText = {
      default = EntityId()
    },
    SalvageLockIcon = {
      default = EntityId()
    },
    QuantityBg = {
      default = EntityId()
    },
    IsEntitlementActiveIcon = {
      default = EntityId()
    },
    ObjectiveIcon = {
      default = EntityId()
    },
    GemSlotContainer = {
      default = EntityId()
    },
    GemIcon = {
      default = EntityId()
    },
    GemDropTarget = {
      default = EntityId()
    },
    RarityEffect = {
      default = EntityId()
    },
    RarityEffectFrame = {
      default = EntityId()
    },
    ConnectItemBus = {default = false},
    RectangleItemSlotOverride = {default = false},
    RepairAnimation = {
      default = EntityId()
    }
  },
  mCurrentLayout = nil,
  MODE_TYPE_EQUIPPED = 1,
  MODE_TYPE_CRAFTING = 2,
  MODE_TYPE_CONTAINER = 3,
  MODE_TYPE_CRAFTING_RARITY = 4,
  MODE_TYPE_BUILD_RESOURCE = 5,
  MODE_TYPE_INVENTORY = 6,
  MODE_TYPE_TRADING_POST = 7,
  MODE_TYPE_TRADING_POST_DETAILS = 8,
  MODE_TYPE_EQUIPMENT_WEAPON = 9,
  MODE_TYPE_LOOTTICKER = 10,
  MODE_TYPE_ITEM_PREVIEW = 11,
  MODE_TYPE_BANNER_REWARD = 12,
  MODE_TYPE_P2P_TRADING = 13,
  mCurrentMode = nil,
  IMAGE_PATH_FRAME_RARITY_RECTANGLE = "lyshineui/images/slices/itemLayout/itemBgLarge",
  IMAGE_PATH_FRAME_RARITY_CIRCLE = "lyshineui/images/slices/itemLayout/itemBgCircle",
  IMAGE_PATH_FRAME_RARITY_SQUARE = "lyshineui/images/slices/itemLayout/itemBgSquare",
  IMAGE_PATH_RARITY_RECTANGLE = "lyshineui/images/slices/itemLayout/itemRarityBgLarge",
  IMAGE_PATH_RARITY_CIRCLE = "lyshineui/images/slices/itemLayout/itemRarityBgCircle",
  IMAGE_PATH_RARITY_SQUARE = "lyshineui/images/slices/itemLayout/itemRarityBgSquare",
  IMAGE_PATH_HIGHLIGHT_RECTANGLE = "lyshineui/images/slices/itemLayout/itemHighlightLarge.dds",
  IMAGE_PATH_HIGHLIGHT_RECTANGLE_LARGE = "lyshineui/images/slices/itemLayout/itemHighlightLargeWeapon.dds",
  IMAGE_PATH_HIGHLIGHT_CIRCLE = "lyshineui/images/slices/itemLayout/itemHighlightCircle.dds",
  IMAGE_PATH_HIGHLIGHT_SQUARE = "lyshineui/images/slices/itemLayout/itemHighlightSquare.dds",
  IMAGE_PATH_RARITYEFFECT_RECTANGLE = "lyShineui/images/slices/itemlayout/spriteSheetRarityEffect_rectangle.sprite",
  IMAGE_PATH_RARITYEFFECT_SQUARE = "lyShineui/images/slices/itemlayout/spriteSheetRarityEffect_square.sprite",
  IMAGE_PATH_SHEEN_RECTANGLE = "lyShineui/images/slices/itemlayout/spriteSheet_sheen_rectangle.sprite",
  IMAGE_PATH_SHEEN_SQUARE = "lyShineui/images/slices/itemlayout/spriteSheet_sheen_square.sprite",
  INDICATOR_PATH_DAMAGED_RECTANGLE = "lyshineui/images/slices/itemlayout/spritesheetdamageditemrectangle.dds",
  INDICATOR_PATH_DAMAGED_SQUARE = "lyshineui/images/slices/itemlayout/spritesheetdamageditemsquare.dds",
  INDICATOR_PATH_NEW_RECTANGLE = "lyshineui/images/slices/itemlayout/spritesheetnewitemrectangle.dds",
  INDICATOR_PATH_NEW_SQUARE = "lyshineui/images/slices/itemlayout/spritesheetnewitemsquare.dds",
  INDICATOR_PATH_NEW_CIRCLE = "lyshineui/images/slices/itemlayout/spritesheetnewitemcircle.dds",
  INDICATOR_DURATION_NEW = 1.5,
  INDICATOR_DURATION_REPAIR = 3,
  ITEM_TYPE_WEAPON = "Weapon",
  ITEM_TYPE_AMMO = "Ammo",
  ITEM_TYPE_ARMOR = "Armor",
  ITEM_TYPE_BLUEPRINT = "Blueprint",
  ITEM_TYPE_CONSUMABLE = "Consumable",
  ITEM_TYPE_CURRENCY = "Currency",
  ITEM_TYPE_KIT = "Kit",
  ITEM_TYPE_PASSIVE_TOOL = "PassiveTool",
  ITEM_TYPE_RESOURCE = "Resource",
  ITEM_TYPE_LORE = "Lore",
  ITEM_TYPE_DYE = "Dye",
  ITEM_TYPE_HOUSING_ITEM = "HousingItem",
  ITEM_TYPE_BANNER_REWARD = "BannerReward",
  GEM_SLOT_CENTER = 0,
  GEM_SLOT_CORNER = 1,
  GEM_SLOT_CENTER_SCALE = 3.5,
  GEM_SLOT_CORNER_SCALE = 2,
  GEM_SLOT_CORNER_MARGIN = 5,
  DURABILITY_STATE_NORMAL = 0,
  DURABILITY_STATE_DAMAGED = 1,
  DURABILITY_STATE_BROKEN = 2,
  COOLDOWN_BASE_DATA_PATH = "Hud.LocalPlayer.Cooldowns",
  COOLDOWN_ITEM_ID_NODE = "ItemId",
  COOLDOWN_REMAINING_TIME_NODE = "TimeRemaining",
  mSlotName = nil,
  mItemInstanceId = nil,
  mRarityLevel = nil,
  mItemContainerSlot = nil,
  mIconPathRoot = "lyShineui/images/icons/items/",
  mIconHiResPathRoot = "lyShineui/images/icons/items_hires/",
  mWidth = nil,
  mHeight = nil,
  mCurrentNewSprite = nil,
  mCurrentDamageSprite = nil,
  mStartFrameDamageIndicator = 1,
  mIsBusConnected = nil,
  mIsTooltipEnabled = nil,
  tooltipsOnLeft = false,
  mIsInInventory = false,
  mIsItemDraggable = false,
  callback = nil,
  callbackTable = nil,
  isFixed = false,
  isNewIndicatorVisible = false,
  allowExternalCompare = false,
  isInPaperdoll = false,
  currentScale = 1,
  INVALID_SLOT = -1,
  entitlementTypeToIconMap = {
    HasEntitlement = "lyshineui/images/entitlements/icon_entitlement.dds",
    TwitchPrime = "lyshineui/images/entitlements/icon_entitlement_twitchprimebg.dds",
    DigitalDeluxe = "lyshineui/images/entitlements/icon_entitlement_defaultbg.dds"
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemLayout)
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local PopupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local ObjectiveTypeData = RequireScript("LyShineUI.Objectives.ObjectiveTypeData")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
function ItemLayout:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiItemDurabilityBus, self.entityId)
  if self.ConnectItemBus then
    self:ConnectContainerBus(self.entityId)
  end
  if self.Properties.GemDropTarget:IsValid() then
    self.GemDropTarget:SetCallback(eItemClass_Gem, self.OnGemDropped, self)
    self.GemDropTarget:SetOnInvalidDropCallback(eItemClass_Gem, self.OnGemDropFailed, self)
    self.GemDropTarget:SetCallback(eItemClass_RepairKit, self.OnRepairKitDropped, self)
  end
  self.entitlementsEnabled = false
  self.dataLayer:RegisterAndExecuteDataObserver(self, "UIFeatures.g_uiEnableItemEntitlements", function(self, entitlementsEnabled)
    self.entitlementsEnabled = entitlementsEnabled
  end)
  self:SetIndicatorsHidden()
  UiImageBus.Event.SetFillType(self.Properties.ItemDimmer, eUiFillType_Linear)
  UiImageBus.Event.SetEdgeFillOrigin(self.Properties.ItemDimmer, eUiFillEdgeOrigin_Bottom)
  if self.Properties.GemSlotContainer:IsValid() then
    self.gemSlotIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.GemSlotContainer) or 0
    self.gemSlotIconHeight = UiTransform2dBus.Event.GetLocalHeight(self.Properties.GemSlotContainer) or 0
  end
  self.itemRepairDynamicBus = DynamicBus.ItemRepairDynamicBus.Connect(self.entityId, self)
  if self.Properties.ObjectiveIcon:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.ObjectiveIcon, "LyShineUI/Images/OldWorldGuilds/ObjectiveIcon.dds")
  end
  self.damagedTimeline = self.ScriptedEntityTweener:TimelineCreate()
  if self.Properties.ItemDurabilityHolder:IsValid() then
    self.damagedTimeline:Add(self.Properties.ItemDurabilityHolder, 0.39, {
      imgColor = self.UIStyle.COLOR_RED_DARK
    })
    self.damagedTimeline:Add(self.Properties.ItemDurabilityHolder, 0.06, {
      imgColor = self.UIStyle.COLOR_RED_DARK
    })
    self.damagedTimeline:Add(self.Properties.ItemDurabilityHolder, 1.002, {
      imgColor = self.UIStyle.COLOR_GRAY_30,
      onComplete = function()
        self.damagedTimeline:Play(0)
      end
    })
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.GameMode.ParticipantFlags.DisableAmmoConsumption", function(self, disableAmmoConsumption)
    self.infiniteAmmo = disableAmmoConsumption
    if self.mItemData_isValid then
      self:SetLayout(self.mCurrentLayout)
    end
  end)
  self:RefreshItemToProcureDataNode()
end
function ItemLayout:RefreshItemToProcureDataNode()
  self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.ItemsToProcure")
  self.dataLayer:RegisterAndExecuteObserver(self, "Hud.LocalPlayer.ItemsToProcure.RefCount", function(self, dataNode)
    local isItemToProcure = false
    if self.itemName and self.itemName ~= "" then
      local childNames = dataNode:GetChildrenNames()
      for i = 1, #childNames do
        local childName = childNames[i]
        if childName == self.itemName then
          local childNode = dataNode[childName]
          local instanceIdCount = childNode:GetData()
          isItemToProcure = 0 < instanceIdCount
          if isItemToProcure then
            local objectiveIdNode = self.dataLayer:GetDataNode("Hud.LocalPlayer.ItemsToProcure.ObjectiveIds." .. childName)
            if objectiveIdNode then
              local objectiveTaskIds = objectiveIdNode:GetChildren()
              for i = 1, #objectiveTaskIds do
                local objectiveInstanceId = objectiveTaskIds[i]:GetData()
                if objectiveInstanceId then
                  local objectiveType = ObjectiveRequestBus.Event.GetType(objectiveInstanceId)
                  local typeData = ObjectiveTypeData:GetType(objectiveType)
                  UiImageBus.Event.SetSpritePathname(self.Properties.ObjectiveIcon, typeData.iconPath)
                  UiImageBus.Event.SetColor(self.Properties.ObjectiveIcon, typeData.iconColor)
                  break
                end
              end
            end
          end
          break
        end
      end
    end
    if self.Properties.ObjectiveIcon:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, isItemToProcure)
    end
  end)
end
function ItemLayout:SetCallback(cbTable, cbFunc)
  self.callback = cbFunc
  self.callbackTable = cbTable
  self:SetIsHandlingEvents(true)
end
function ItemLayout:SetFocusCallback(cbTable, cbFunc)
  self.focusCallback = cbFunc
  self.focusCallbackTable = cbTable
  self:SetIsHandlingEvents(true)
end
function ItemLayout:SetUnfocusCallback(cbTable, cbFunc)
  self.unfocusCallback = cbFunc
  self.unfocusCallbackTable = cbTable
  self:SetIsHandlingEvents(true)
end
function ItemLayout:ConnectContainerBus(entityId)
  if self.mIsBusConnected == nil then
    self.mIsBusConnected = true
    self:BusConnect(ItemContainerBus, entityId)
    self.ilsBusHandler = DynamicBus.ItemLayoutSlotProvider.Connect(entityId, self)
    self.itemFilterNotificationhandler = DynamicBus.ItemFilterNotificationBus.Connect(entityId, self)
    self.itemEntity = entityId
  end
end
function ItemLayout:SetIsHandlingEvents(isHandling)
  UiInteractableBus.Event.SetIsHandlingEvents(self.entityId, isHandling)
end
function ItemLayout:SetTooltipEnabled(isEnabled)
  self.mIsTooltipEnabled = isEnabled
  self:SetIsHandlingEvents(true)
end
function ItemLayout:SetAllowExternalCompare(allow)
  self.allowExternalCompare = allow
end
function ItemLayout:SetIsInPaperdoll(isInPaperdoll)
  self.isInPaperdoll = isInPaperdoll
end
function ItemLayout:SetIsItemDraggable(isItemDraggable)
  self.mIsItemDraggable = isItemDraggable
end
function ItemLayout:SetFixed(itemTable)
  self.isFixed = true
  self.compareToItemTable = itemTable
end
function ItemLayout:ShowFlyoutMenu()
  if not self.mItemData_isValid then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  if flyoutMenu:IsLocked() then
    return
  end
  local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
  if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
    return
  end
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  local rows = {}
  table.insert(rows, {
    slicePath = "LyShineUI/Tooltip/DynamicTooltip",
    itemTable = self:GetTooltipDisplayInfo(),
    allowExternalCompare = self.allowExternalCompare,
    isInPaperdoll = self.isInPaperdoll
  })
  if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
    flyoutMenu:SetOpenLocation(self.entityId)
    flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
    flyoutMenu:SetRowData(rows)
    flyoutMenu:SetSourceHoverOnly(true)
    flyoutMenu:DockToCursor(10, true)
    flyoutMenu:Unlock()
  end
end
function ItemLayout:OnFlyoutMenuClosed()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:Unlock()
end
function ItemLayout:SetShowTooltipInstantly(showInstantly)
  self.showTooltipInstantly = showInstantly
end
function ItemLayout:EnableHighlight(enable)
  if enable then
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.ItemHighlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.5})
      self.timeline:Add(self.ItemHighlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
      self.timeline:Add(self.ItemHighlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = 1,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 1,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.timeline:Play()
      end
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, 0.1, {opacity = 0, ease = "QuadIn"})
  end
end
function ItemLayout:SetHighlightVisible(isVisible)
  self.isHighlightSet = isVisible
  if isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, 0.1, {opacity = 0, ease = "QuadIn"})
  end
end
function ItemLayout:OnFocus()
  if self.mIsTooltipEnabled == true then
    if self.isFixed then
      DynamicBus.DynamicTooltip.Broadcast.ResetStatComparison()
    end
    if self.allowExternalCompare then
      self:ShowFlyoutMenu()
    else
      local tdi = self:GetTooltipDisplayInfo()
      DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(tdi, self, nil, self.showTooltipInstantly, true)
    end
  end
  if self.mIsItemDraggable == true and not self.isHighlightSet then
    self:EnableHighlight(true)
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ItemDraggable)
  if type(self.focusCallback) == "function" and self.focusCallbackTable ~= nil then
    self.focusCallback(self.focusCallbackTable, self)
  end
end
function ItemLayout:OnUnfocus()
  if self.mIsTooltipEnabled == true and not self.allowExternalCompare then
    DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  end
  if self.mIsItemDraggable == true and not self.isHighlightSet then
    self:EnableHighlight(false)
  end
  if type(self.unfocusCallback) == "function" and self.unfocusCallbackTable ~= nil then
    self.unfocusCallback(self.unfocusCallbackTable, self)
  end
end
function ItemLayout:OnPress()
  if type(self.callback) == "function" and self.callbackTable ~= nil then
    self.callback(self.callbackTable, self)
  end
  if self.mIsTooltipEnabled and self.allowExternalCompare then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    flyoutMenu:SetSourceHoverOnly(false)
    flyoutMenu:Lock()
  end
end
function ItemLayout:IsEntitled()
  if self.entitlementsEnabled and self.itemName then
    local entries = ItemSkinDataManagerBus.Broadcast.GetItemSkinEntries(self.itemId)
    if entries and 0 < #entries then
      return true
    end
  end
  return false
end
function ItemLayout:GetJson()
  Log("ItemLayout:GetJson is DEPRECATED.")
  return nil
end
function ItemLayout:SetItemAndSlotProvider(itemContainerSlot, slotName, getItemContainerSlotFn)
  self.slotNameForGemDrop = slotName
  self:SetItem(itemContainerSlot)
  self.getItemContainerSlotFn = getItemContainerSlotFn
  self.mSlotName = slotName
end
function ItemLayout:GetItemContainerSlot()
  if self.getItemContainerSlotFn then
    return self.getItemContainerSlotFn(nil, self.entityId, self.mSlotName)
  end
  return nil
end
function ItemLayout:GetTooltipDisplayInfo()
  local slot = self:GetItemContainerSlot()
  local tdi = StaticItemDataManager:GetTooltipDisplayInfo(self.mItemData_itemDescriptor, slot)
  if slot then
    tdi.deathDurabilityPenalty = slot:GetOnDeathDurabilityPenalty()
  else
    tdi.durability = self.mItemData_durability
    tdi.maxDurability = self.mItemData_maxDurability
  end
  return tdi
end
function ItemLayout:HasGemSlot()
  return self.mItemData_gemPerkId and self.mItemData_gemPerkId ~= 0
end
function ItemLayout:SetLayoutByItemType(itemType)
  local overridelayout = self.mCurrentMode == self.MODE_TYPE_BANNER_REWARD
  if self.RectangleItemSlotOverride and not overridelayout then
    self:SetLayout(self.UIStyle.ITEM_LAYOUT_RECTANGLE)
  elseif itemType == self.ITEM_TYPE_WEAPON or itemType == self.ITEM_TYPE_CONSUMABLE or itemType == self.ITEM_TYPE_BLUEPRINT or itemType == self.ITEM_TYPE_AMMO or itemType == self.ITEM_TYPE_ARMOR or itemType == self.ITEM_TYPE_WEAPON and overridelayout then
    self:SetLayout(self.UIStyle.ITEM_LAYOUT_SQUARE)
  elseif itemType == self.ITEM_TYPE_RESOURCE or itemType == self.ITEM_TYPE_LORE or itemType == self.ITEM_TYPE_DYE or itemType == self.ITEM_TYPE_HOUSING_ITEM then
    self:SetLayout(self.UIStyle.ITEM_LAYOUT_CIRCLE)
  else
    Log("ItemLayout.lua: SetItem() itemType -THIS IS A BAD TYPE: " .. tostring(itemType))
    self:SetLayout(itemType)
  end
end
function ItemLayout:SetItem(itemContainerSlot)
  self:GetItemData(itemContainerSlot)
  self.mItemInstanceId = itemContainerSlot:GetItemInstanceId()
  self:SetLayoutByItemType(self.mItemData_itemType)
  self.getItemContainerSlotFn = nil
  self.mSlotName = nil
  if self.wasJustRepaired then
    self:SetNewIndicatorVisible(true)
  end
  self.wasJustRepaired = nil
end
function ItemLayout:SetItemByDescriptor(itemDescriptor)
  self.itemId = itemDescriptor.itemId
  self.itemName = itemDescriptor:GetItemKey()
  self:ClearItemData()
  self.mItemData_staticItem = StaticItemDataManager:GetItem(self.itemId)
  self.mItemData_isValid = true
  self.mItemData_itemDescriptor = itemDescriptor
  self.mItemData_quantity = itemDescriptor.quantity
  self.mItemData_iconPath = self.mItemData_staticItem.icon
  self.mItemData_tierNumber = self.mItemData_staticItem.tier
  self.mItemData_durabilityPercent = 1
  self.mItemData_maxDurabilityPercent = 1
  self.mItemData_itemType = self.mItemData_staticItem.itemType
  self.mItemData_weight = self.mItemData_staticItem.weight * itemDescriptor.quantity
  self:SetGemPerkData()
  self:SetConsumableData()
  self:SetLayoutByItemType(self.mItemData_itemType)
  self.getItemContainerSlotFn = nil
  if self.wasJustRepaired then
    self:SetNewIndicatorVisible(true)
  end
  self.wasJustRepaired = nil
end
function ItemLayout:SetItemByName(itemName, displayName, quantity, itemType)
  if type(itemName) == "string" then
    self.itemId = Math.CreateCrc32(itemName)
    self.itemName = itemName
  else
    self.itemId = itemName
    local staticItem = StaticItemDataManager:GetItem(self.itemId)
    self.itemName = staticItem.key
  end
  local itemData = ItemDataManagerBus.Broadcast.GetItemData(self.itemId)
  if not itemData then
    Log("ItemLayout.lua: SetItemByName() failed to get itemData for item: " .. tostring(itemName))
    return
  end
  self:ClearItemData()
  self.mItemData_staticItem = StaticItemDataManager:GetItem(self.itemId)
  self.mItemData_itemDescriptor = ItemDescriptor()
  self.mItemData_itemDescriptor.itemId = self.itemId
  self.mItemData_itemDescriptor.quantity = quantity or 1
  self.mItemData_itemDescriptor:ApplyStaticPerkSettings()
  self.mItemData_iconPath = self.mItemData_staticItem.iconPath
  self.mItemData_tierNumber = self.mItemData_staticItem.tier
  self.mItemData_durabilityPercent = 1
  self.mItemData_maxDurabilityPercent = 1
  if itemType ~= nil then
    self.mItemData_itemType = itemType
  else
    self.mItemData_itemType = self.mItemData_staticItem.itemType
  end
  if quantity ~= nil and 0 <= quantity then
    self.mItemData_quantity = quantity
  end
  self:SetLayoutByItemType(self.mItemData_itemType)
  self.getItemContainerSlotFn = nil
  if self.wasJustRepaired then
    self:SetNewIndicatorVisible(true)
  end
  self.wasJustRepaired = nil
end
function ItemLayout:ClearItemData()
  self.mItemData_staticItem = nil
  self.mItemData_ammoType = nil
  self.mItemData_durability = nil
  self.mItemData_durabilityPercent = nil
  self.mItemData_durabilityState = nil
  self.mItemData_iconPath = nil
  self.mItemData_itemDescriptor = nil
  self.mItemData_quantity = nil
  self.mItemData_itemName = nil
  self.mItemData_itemId = nil
  self.mItemData_itemType = nil
  self.mItemData_tierNumber = nil
  self.mItemData_weight = nil
  self.mItemData_isValid = nil
  self.mItemData_maxDurability = nil
  self.mItemData_maxDurabilityPercent = nil
  self.mItemData_containerChrono = nil
  self.mItemData_isOutpostRushOnly = nil
end
function ItemLayout:GetItemData(itemContainerSlot)
  self.itemId = itemContainerSlot:GetItemId()
  local staticItem = StaticItemDataManager:GetItem(self.itemId)
  self.itemName = staticItem.key
  if self.showIconOnly then
    self:ClearItemData()
    self.mItemData_itemType = staticItem.itemType
    self.mItemData_iconPath = staticItem.iconPath
    self.mItemData_itemDescriptor = itemContainerSlot:GetItemDescriptor()
    return
  end
  self.mItemData_staticItem = staticItem
  self.mItemData_ammoType = staticItem.ammoType
  self.mItemData_locked = itemContainerSlot:IsLocked()
  self.mItemData_durability = itemContainerSlot:GetDurability()
  self.mItemData_maxDurability = itemContainerSlot:GetMaxDurability()
  self.mItemData_durabilityPercent = self.mItemData_maxDurability > 0 and self.mItemData_durability / self.mItemData_maxDurability or 0
  if self.mItemData_durabilityPercent < itemContainerSlot:GetOnDeathDurabilityPenalty() then
    self.mItemData_durabilityState = self.mItemData_durabilityPercent == 0 and self.DURABILITY_STATE_BROKEN or self.DURABILITY_STATE_DAMAGED
  elseif self.mItemData_maxDurability > 0 and self.mItemData_durabilityPercent == 0 then
    self.mItemData_durabilityState = self.DURABILITY_STATE_BROKEN
  else
    self.mItemData_durabilityState = self.DURABILITY_STATE_NORMAL
  end
  self.mItemData_iconPath = staticItem.iconPath
  self.mItemData_itemDescriptor = itemContainerSlot:GetItemDescriptor()
  self.mItemData_quantity = self.mItemData_itemDescriptor.quantity
  self.mItemData_itemName = staticItem.key
  self.mItemData_itemId = staticItem.id
  self.mItemData_itemType = staticItem.itemType
  self.mItemData_tierNumber = staticItem.tier
  self.mItemData_weight = self.mItemData_quantity * staticItem.weight
  self.mItemData_isValid = itemContainerSlot:IsValid()
  self.mItemData_maxDurabilityPercent = self.mItemData_maxDurability > 0 and 1
  self.mItemData_containerChrono = itemContainerSlot:GetContainerChrono()
  self.mItemData_isContainer = itemContainerSlot:HasItemClass(eItemClass_LootContainer)
  self.mItemData_isOutpostRushOnly = itemContainerSlot:HasItemClass(eItemClass_OutpostRushOnly)
  local boxOpeningPopupEnabled = self.dataLayer:GetDataFromNode("UIFeatures.enableBoxOpeningPopup")
  if boxOpeningPopupEnabled then
    self.mItemData_isFromRewardChest = itemContainerSlot:GetActionCausingSync() == eItemContainerSync_OpenRewardChest
  end
  self:SetGemPerkData()
  self:SetConsumableData()
end
function ItemLayout:SetItemIconLocalPosition(x, y)
  UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemIcon, x)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.ItemIcon, y)
end
function ItemLayout:SetShowIconOnly(showIconOnly)
  self.showIconOnly = showIconOnly
  if self.showIconOnly and self.Properties.ItemDurabilityHolder:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
  end
end
local layoutDurabilityAnchors = UiAnchors(1, 0, 1, 1)
function ItemLayout:SetLayout(layoutEnum, debugIndex)
  if not self.showIconOnly then
    if self.layout ~= layoutEnum then
      local parentId = UiElementBus.Event.GetParent(self.entityId)
      if UiTransformBus.Event.GetComputeTransformWhenHidden(parentId) == false then
        UiTransformBus.Event.SetRecomputeFlags(parentId, eUiRecompute_RectAndTransformForced)
      end
    end
    self:SetIndicatorsHidden()
  end
  local isValid = false
  local imagePathHighlight, imagePathIcon, imagePathRarityBg, isDurabilityVisible
  local imagePathFolder = self.mIconPathRoot
  if self.mItemData_itemType == self.ITEM_TYPE_RESOURCE or self.mItemData_itemType == self.ITEM_TYPE_AMMO or self.mItemData_itemType == self.ITEM_TYPE_ARMOR or self.mItemData_itemType == self.ITEM_TYPE_BLUEPRINT or self.mItemData_itemType == self.ITEM_TYPE_DYE or self.mItemData_itemType == self.ITEM_TYPE_LORE or self.mItemData_itemType == self.ITEM_TYPE_WEAPON or self.mItemData_itemType == self.ITEM_TYPE_CONSUMABLE or self.mItemData_itemType == self.ITEM_TYPE_CURRENCY or self.mItemData_itemType == self.ITEM_TYPE_HOUSING_ITEM or self.mItemData_itemType == self.ITEM_TYPE_KIT or self.mItemData_itemType == self.ITEM_TYPE_PASSIVE_TOOL then
    if self.Properties.RectangleItemSlotOverride then
      imagePathFolder = self.mIconHiResPathRoot
    else
      imagePathFolder = self.mIconPathRoot .. self.mItemData_itemType .. "/"
    end
  else
    Log("ItemLayout.lua: SetLayout() self.mItemData_itemType - THIS ITEM TYPE IS NOT SUPPORTED AND DOES NOT HAVE A TEXTURE ATLAS: " .. tostring(self.mItemData_itemType) .. "   ItemName: " .. tostring(self.mItemData_itemName))
  end
  imagePathIcon = imagePathFolder .. self.mItemData_iconPath .. ".dds"
  imagePathRarityBg = nil
  isDurabilityVisible = nil
  self:SetQuantityEnabled(true)
  if layoutEnum == self.UIStyle.ITEM_LAYOUT_RECTANGLE then
    isValid = true
    isDurabilityVisible = true
    imagePathRarityFrame = self.IMAGE_PATH_FRAME_RARITY_RECTANGLE
    imagePathRarityBg = self.IMAGE_PATH_RARITY_RECTANGLE
    imagePathHighlight = self.IMAGE_PATH_HIGHLIGHT_RECTANGLE
    self.mWidth = self.UIStyle.ITEM_LAYOUT_RECTANGLE_WIDTH
    self.mHeight = self.UIStyle.ITEM_LAYOUT_RECTANGLE_HEIGHT
    self.mCurrentDamageSprite = self.INDICATOR_PATH_DAMAGED_RECTANGLE
    self.mCurrentNewSprite = self.INDICATOR_PATH_NEW_RECTANGLE
    if self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON then
      self.mWidth = self.UIStyle.ITEM_LAYOUT_RECTANGLE_LARGE_WIDTH
      self.mHeight = self.UIStyle.ITEM_LAYOUT_RECTANGLE_LARGE_HEIGHT
      imagePathHighlight = self.IMAGE_PATH_HIGHLIGHT_RECTANGLE_LARGE
    end
    if self.Properties.RepairAnimation:IsValid() then
      local repairAnimationOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.RepairAnimation)
      repairAnimationOffsets.right = 64
      repairAnimationOffsets.left = -64
      UiTransform2dBus.Event.SetOffsets(self.Properties.RepairAnimation, repairAnimationOffsets)
    end
    if self.Properties.ItemQuantity:IsValid() then
      UiTextBus.Event.SetText(self.Properties.ItemQuantity, "")
    end
    self:SetQuantityEnabled(false)
  elseif layoutEnum == self.UIStyle.ITEM_LAYOUT_CIRCLE then
    isValid = true
    isDurabilityVisible = false
    imagePathRarityFrame = self.IMAGE_PATH_FRAME_RARITY_CIRCLE
    imagePathRarityBg = self.IMAGE_PATH_RARITY_CIRCLE
    imagePathHighlight = self.IMAGE_PATH_HIGHLIGHT_CIRCLE
    self.mWidth = self.UIStyle.ITEM_LAYOUT_CIRCLE_WIDTH
    self.mHeight = self.UIStyle.ITEM_LAYOUT_CIRCLE_HEIGHT
    self.mCurrentNewSprite = self.INDICATOR_PATH_NEW_CIRCLE
    if not self.showIconOnly and self.Properties.ItemQuantity:IsValid() then
      if self.infiniteAmmo and self.mItemData_itemType == self.ITEM_TYPE_AMMO then
        UiTextBus.Event.SetText(self.Properties.ItemQuantity, "\226\136\158")
      else
        UiTextBus.Event.SetText(self.Properties.ItemQuantity, self.mItemData_quantity or "")
      end
    end
  elseif layoutEnum == self.UIStyle.ITEM_LAYOUT_SQUARE then
    isValid = true
    isDurabilityVisible = false
    imagePathRarityFrame = self.IMAGE_PATH_FRAME_RARITY_SQUARE
    imagePathRarityBg = self.IMAGE_PATH_RARITY_SQUARE
    imagePathHighlight = self.IMAGE_PATH_HIGHLIGHT_SQUARE
    self.mWidth = self.mCurrentMode == self.MODE_TYPE_BANNER_REWARD and self.UIStyle.ITEM_LAYOUT_BANNER_SQUARE or self.UIStyle.ITEM_LAYOUT_SQUARE_WIDTH
    self.mHeight = self.mCurrentMode == self.MODE_TYPE_BANNER_REWARD and self.UIStyle.ITEM_LAYOUT_BANNER_SQUARE or self.UIStyle.ITEM_LAYOUT_SQUARE_HEIGHT
    self.mCurrentDamageSprite = self.INDICATOR_PATH_DAMAGED_RECTANGLE
    self.mCurrentNewSprite = self.INDICATOR_PATH_NEW_SQUARE
    isDurabilityVisible = self.mItemData_itemType == self.ITEM_TYPE_ARMOR or self.mItemData_itemType == self.ITEM_TYPE_CONSUMABLE or self.mItemData_itemType == self.ITEM_TYPE_WEAPON
    local quantityValue = ""
    if self.mItemData_quantity and self.mItemData_quantity <= 1 then
      self:SetQuantityEnabled(false)
    else
      quantityValue = tostring(self.mItemData_quantity or "")
    end
    if self.Properties.ItemQuantity:IsValid() then
      if self.infiniteAmmo and self.mItemData_itemType == self.ITEM_TYPE_AMMO then
        UiTextBus.Event.SetText(self.Properties.ItemQuantity, "\226\136\158")
      else
        UiTextBus.Event.SetText(self.Properties.ItemQuantity, quantityValue or "")
      end
    end
    if self.Properties.RepairAnimation:IsValid() then
      local repairAnimationOffsets = UiTransform2dBus.Event.GetOffsets(self.Properties.RepairAnimation)
      repairAnimationOffsets.right = 34
      repairAnimationOffsets.left = -34
      UiTransform2dBus.Event.SetOffsets(self.Properties.RepairAnimation, repairAnimationOffsets)
    end
  end
  if self.Properties.RarityEffect then
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityEffect, self.IMAGE_PATH_RARITYEFFECT_SQUARE)
    UiImageBus.Event.SetSpritePathname(self.Properties.RarityEffectFrame, self.IMAGE_PATH_SHEEN_SQUARE)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.RarityEffect, 180)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.RarityEffect, 180)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.RarityEffect, 30)
  end
  if self.Properties.ItemTier:IsValid() then
    UiTextBus.Event.SetText(self.Properties.ItemTier, GetRomanFromNumber(self.mItemData_tierNumber))
  end
  if isValid == true then
    self.mItemData_isValid = true
    self.mCurrentLayout = layoutEnum
    UiImageBus.Event.SetSpritePathnamePool(self.Properties.ItemIcon, imagePathIcon, DynamicBus.Globals.Broadcast.GetInventoryIconPoolId())
    if self.Properties.ItemHighlight:IsValid() then
      UiImageBus.Event.SetSpritePathname(self.Properties.ItemHighlight, imagePathHighlight)
    end
    UiTransform2dBus.Event.SetLocalWidth(self.entityId, self.mWidth)
    UiTransform2dBus.Event.SetLocalHeight(self.entityId, self.mHeight)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemRarityBg, self.mWidth - 1)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemRarityBg, self.mHeight)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.RarityEffectFrame, self.mWidth)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.RarityEffectFrame, self.mHeight)
    local padding = 6
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemIcon, self.mWidth - padding)
    UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemIcon, self.mHeight - padding)
    UiTransformBus.Event.SetScale(self.Properties.RepairAnimation, Vector2(1, 1))
    if self.Properties.ItemAnimatedIndicator:IsValid() and not self.Properties.RectangleItemSlotOverride then
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemAnimatedIndicator, self.mWidth)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemAnimatedIndicator, self.mHeight)
    end
    if self.mItemData_isContainer then
      if self.Properties.ItemAnimatedIndicator:IsValid() then
        UiImageBus.Event.SetColor(self.Properties.ItemAnimatedIndicator, self.UIStyle.COLOR_YELLOW)
      end
    elseif self.Properties.ItemAnimatedIndicator:IsValid() then
      UiImageBus.Event.SetColor(self.Properties.ItemAnimatedIndicator, self.UIStyle.COLOR_WHITE)
    end
    local hasGemSlot = self:HasGemSlot()
    if self.Properties.GemSlotContainer:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.GemSlotContainer, hasGemSlot)
    end
    if hasGemSlot then
      if self.Properties.GemSlotContainer:IsValid() then
        UiImageBus.Event.SetSpritePathname(self.Properties.GemSlotContainer, "lyshineui/images/tooltip/frame_gemsocket.png")
      end
      local hasGem = self.mItemData_gemPerkId ~= itemCommon.EMPTY_GEM_SLOT_PERK_ID
      if self.Properties.GemIcon:IsValid() then
        UiElementBus.Event.SetIsEnabled(self.Properties.GemIcon, hasGem)
        if hasGem then
          local gemIconPath = "lyshineui/images/" .. self.mItemData_gemIconPath .. ".dds"
          UiImageBus.Event.SetSpritePathname(self.Properties.GemIcon, gemIconPath)
        end
      end
      self:TransitionGemSlot(self.GEM_SLOT_CORNER)
    end
    if self.showIconOnly then
      local hasRarity = self.mItemData_itemDescriptor and self.mItemData_itemDescriptor:UsesRarity()
      if hasRarity then
        raritySuffix = tostring(self.mItemData_itemDescriptor:GetRarityLevel())
        self:SetRarityBgColor(raritySuffix, imagePathRarityBg, imagePathRarityFrame)
      else
        self:SetRarityBgColor(0, imagePathRarityBg, imagePathRarityFrame)
      end
      self:RefreshItemToProcureDataNode()
      return
    end
    if self.Properties.SalvageLockIcon:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.SalvageLockIcon, self:ShouldShowLockIcon(self.mCurrentMode) and self.mItemData_locked)
      self.ScriptedEntityTweener:Set(self.Properties.SalvageLockIcon, {y = -2})
    end
    if isDurabilityVisible == true then
      local isVisible = self.mItemData_maxDurability ~= nil and 0 < self.mItemData_maxDurability and (1 > self.mItemData_durabilityPercent or self.mItemData_itemType == self.ITEM_TYPE_CONSUMABLE)
      if self.Properties.ItemDurabilityHolder:IsValid() then
        if self.wasJustRepaired then
          UiElementBus.Event.SetIsEnabled(self.Properties.RepairAnimation, true)
          UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.RepairAnimation, 0)
          UiFlipbookAnimationBus.Event.Start(self.Properties.RepairAnimation)
          self.ScriptedEntityTweener:Play(self.Properties.ItemDurabilityFill, 0.4, {imgFill = 1, ease = "QuadOut"})
          self:SetRepairIndicatorVisible(true)
          do
            local animDuration = 0.4
            local delay = self.INDICATOR_DURATION_REPAIR - animDuration
            timingUtils:Delay(delay, self, function()
              self.ScriptedEntityTweener:Play(self.Properties.ItemDurabilityHolder, animDuration, {
                opacity = 0,
                ease = "QuadOut",
                onComplete = function()
                  UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
                  UiElementBus.Event.SetIsEnabled(self.Properties.RepairAnimation, false)
                  UiFlipbookAnimationBus.Event.Stop(self.Properties.RepairAnimation)
                  if self.Properties.SalvageLockIcon:IsValid() and self:ShouldShowLockIcon(self.mCurrentMode) and self.mItemData_locked then
                    self.ScriptedEntityTweener:Play(self.Properties.SalvageLockIcon, 0.2, {y = -5}, {y = -2, ease = "QuadOut"})
                  end
                end
              })
            end)
          end
        else
          self.ScriptedEntityTweener:Set(self.Properties.ItemDurabilityHolder, {opacity = 1})
          UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, isVisible)
        end
      end
      if isVisible then
        self:SetProgressPercent(self.mItemData_durabilityPercent)
        if self.mItemData_itemType == self.ITEM_TYPE_CONSUMABLE then
          if self.Properties.DurabilityDivider:IsValid() then
            UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityDivider, true)
            local durabilityDividerImagePath = "lyshineui/images/slices/itemlayout/itemdurabilitydividersegments" .. self.mItemData_maxDurability .. ".dds"
            UiImageBus.Event.SetSpritePathname(self.Properties.DurabilityDivider, durabilityDividerImagePath)
          end
        elseif self.Properties.DurabilityDivider:IsValid() then
          UiElementBus.Event.SetIsEnabled(self.Properties.DurabilityDivider, false)
        end
      end
      if self.Properties.SalvageLockIcon:IsValid() then
        local positionY = UiElementBus.Event.IsEnabled(self.Properties.ItemDurabilityHolder) and -5 or -2
        self.ScriptedEntityTweener:Set(self.Properties.SalvageLockIcon, {y = positionY})
      end
    elseif self.Properties.ItemDurabilityHolder:IsValid() then
      UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
    end
    self.wasJustRepaired = nil
    local hasRarity = self.mItemData_itemDescriptor and self.mItemData_itemDescriptor:UsesRarity()
    if hasRarity then
      raritySuffix = tostring(self.mItemData_itemDescriptor:GetRarityLevel())
      self:SetRarityBgColor(raritySuffix, imagePathRarityBg, imagePathRarityFrame)
    else
      self:SetRarityBgColor(0, imagePathRarityBg, imagePathRarityFrame)
    end
    if self.mCurrentDamageSprite ~= nil and self.mItemData_durabilityState ~= nil then
      self:SetDurabilityState(self.mItemData_durabilityState)
      UiTransform2dBus.Event.SetLocalWidth(self.Properties.ItemBroken, self.mHeight)
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemBroken, self.mHeight)
    end
    self:SetModeType(self.mCurrentMode)
    if self.mIsInInventory == true then
      self:SetIsItemNew()
    end
    if self.widthChangedCallback then
      self.widthChangedCallback(self.mWidth, self.mHeight)
    end
    if self.mItemData_isOutpostRushOnly then
      UiElementBus.Event.SetIsEnabled(self.Properties.ObjectiveIcon, true)
      UiImageBus.Event.SetSpritePathname(self.Properties.ObjectiveIcon, "LyShineUI/Images/Icons/OutpostRush/icon_outpostRush_map.dds")
      UiImageBus.Event.SetColor(self.Properties.ObjectiveIcon, self.UIStyle.COLOR_WHITE)
    else
      self:RefreshItemToProcureDataNode()
    end
    self:UpdateAnimatedIndicator()
    self.layout = layoutEnum
  end
end
function ItemLayout:SetOnWidthChangedCallback(callbackFunc)
  self.widthChangedCallback = callbackFunc
end
function ItemLayout:SetRarityBgColor(raritySuffix, imagePath, frameImgPath)
  local isValid = raritySuffix ~= nil
  if not isValid then
    Log("ItemLayout.lua: SetRarityBgColor() value - THIS RARITY VALUE IS NOT SUPPORTED: " .. tostring(value) .. "   ItemName: " .. tostring(self.mItemData_itemName))
  end
  if isValid then
    local fullImagePath = imagePath .. raritySuffix .. ".dds"
    local frameImagePath = frameImgPath .. raritySuffix .. ".dds"
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRarityBg, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemRarityBg, fullImagePath)
    if self.Properties.ItemFrame:IsValid() then
      UiImageBus.Event.SetSpritePathname(self.Properties.ItemFrame, frameImagePath)
    end
    local lightColorName = string.format("COLOR_RARITY_LEVEL_%s_LIGHT", raritySuffix)
    local brightColorName = string.format("COLOR_RARITY_LEVEL_%s_BRIGHT", raritySuffix)
    UiImageBus.Event.SetColor(self.Properties.RarityEffect, self.UIStyle[brightColorName])
    UiImageBus.Event.SetColor(self.Properties.RarityEffectFrame, self.UIStyle[lightColorName])
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRarityBg, false)
  end
end
function ItemLayout:SetModeType(value)
  self.mCurrentMode = value
  self.isInValidGemDropContainer = false
  if value == self.MODE_TYPE_EQUIPPED then
    self.isInValidGemDropContainer = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemFrame, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, self:ShouldShowItemTier(value))
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1.06, 1.06))
  elseif value == self.MODE_TYPE_CRAFTING then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRarityBg, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, self:ShouldShowItemTier(value))
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemQuantity, false)
  elseif value == self.MODE_TYPE_CRAFTING_RARITY then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRarityBg, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, self:ShouldShowItemTier(value))
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemQuantity, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemFrame, true)
    UiTextBus.Event.SetHorizontalTextAlignment(self.Properties.ItemQuantity, eUiHAlign_Center)
  elseif value == self.MODE_TYPE_CONTAINER then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1.06, 1.06))
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1.06, 1.06))
    self.isInValidGemDropContainer = true
    self.currentScale = 1.06
  elseif value == self.MODE_TYPE_TRADING_POST or value == self.MODE_TYPE_TRADING_POST_DETAILS then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemDurabilityHolder, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemRarityBg, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, self:ShouldShowItemTier(value))
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemQuantity, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemFrame, false)
    if value == self.MODE_TYPE_TRADING_POST then
      UiTransformBus.Event.SetScale(self.entityId, Vector2(0.6, 0.6))
    else
      UiTransformBus.Event.SetScale(self.entityId, Vector2(2.9, 2.9))
    end
  elseif value == self.MODE_TYPE_EQUIPMENT_WEAPON then
    self.isInValidGemDropContainer = true
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemFrame, false)
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1.06, 1.06))
  elseif value == self.MODE_TYPE_LOOTTICKER then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(0.85, 0.85))
  elseif value == self.MODE_TYPE_ITEM_PREVIEW then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(0.85, 0.85))
  elseif value == self.MODE_TYPE_INVENTORY then
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1.06, 1.06))
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1.06, 1.06))
    self.isInValidGemDropContainer = true
    self.currentScale = 1.06
  elseif value == self.MODE_TYPE_P2P_TRADING then
    UiElementBus.Event.SetIsEnabled(self.Properties.SalvageLockIcon, self:ShouldShowLockIcon(value))
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1, 1))
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1, 1))
    self.currentScale = 1.2
  else
    UiTransformBus.Event.SetScale(self.entityId, Vector2(1, 1))
    UiTransformBus.Event.SetScale(self.Properties.ItemTier, Vector2(1, 1))
    self.currentScale = 1
  end
  self:UpdateSpecialDropTargetStates()
  self:UpdateConsumableState()
end
function ItemLayout:OnDraggingGemSlotIdChanged(gemSlotId)
  if not self.slotNameForGemDrop or not self.mItemInstanceId then
    return
  end
  local duration = 0.015
  self.draggedGemSlotId = gemSlotId
  if not gemSlotId or gemSlotId == -1 then
    self.GemDropTarget:SetGemDropTargetIsValid(eItemClass_Gem, false)
    self:TransitionGemSlot(self.GEM_SLOT_CORNER, duration)
  else
    local containerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerId")
    local containerType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerType")
    local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
    local isContainer = containerType == eItemDragContext_Container
    if isContainer then
      local storageTransferType = GlobalStorageRequestBus.Event.GetCurrentGlobalStorageAllowTransactionType(playerEntityId)
      if storageTransferType ~= eGlobalStorageAllowTransactionType_AllowGiveAndTake then
        self.GemDropTarget:SetGemDropTargetIsValid(eItemClass_Gem, false)
        self:TransitionGemSlot(self.GEM_SLOT_CORNER, duration)
        self.draggedGemSlotId = -1
        return
      end
    end
    self.GemDropTarget:SetGemDropTargetEnabled(true)
    local isPaperdoll = self.mCurrentMode == self.MODE_TYPE_EQUIPPED or self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON
    local itemLocation = ItemLocation()
    itemLocation.containerSlotId = tonumber(self.slotNameForGemDrop)
    itemLocation.containerType = isPaperdoll and eItemContainerType_Paperdoll or eItemContainerType_Container
    itemLocation.itemInstanceId = self.mItemInstanceId
    local gemLocation = ItemLocation()
    gemLocation.containerSlotId = gemSlotId
    gemLocation.containerType = isContainer and eItemContainerType_GlobalStorage or eItemContainerType_Container
    local gemSlot = ContainerRequestBus.Event.GetSlot(containerEntityId, gemSlotId)
    if gemSlot:IsValid() then
      gemLocation.itemInstanceId = gemSlot:GetItemInstanceId()
    end
    if gemLocation.containerSlotId ~= self.INVALID_SLOT then
      local isValidGem = ItemRepairRequestBus.Event.IsValidGemForItem(playerEntityId, itemLocation, gemLocation)
      self.GemDropTarget:SetGemDropTargetIsValid(eItemClass_Gem, isValidGem)
      if isValidGem then
        self:TransitionGemSlot(self.GEM_SLOT_CENTER, duration)
      end
    end
  end
end
function ItemLayout:OnDraggingRepairKitSlotChanged(repairKitSlotId)
  self.draggedRepairKitSlotId = repairKitSlotId
  local highlightItem, isValidDrop
  if not repairKitSlotId or repairKitSlotId == -1 then
    highlightItem = false
    isValidDrop = false
  elseif self.mItemData_maxDurability > 0 then
    local repairKitTier = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.RepairKitTier")
    self.GemDropTarget:SetGemDropTargetEnabled(true)
    highlightItem = repairKitTier and repairKitTier >= self.mItemData_tierNumber and self.mItemData_durability < self.mItemData_maxDurability
    isValidDrop = true
  else
    highlightItem = false
    isValidDrop = false
  end
  self.GemDropTarget:SetGemDropTargetIsValid(eItemClass_RepairKit, isValidDrop)
  self.ScriptedEntityTweener:Play(self.Properties.ItemHighlight, 0.1, {
    opacity = highlightItem and 0.8 or 0,
    ease = "QuadIn"
  })
end
function ItemLayout:UpdateSpecialDropTargetStates()
  local isPaperdoll = self.mCurrentMode == self.MODE_TYPE_EQUIPPED or self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON
  local shouldEnable = (self.isShowing or isPaperdoll) and self.mItemInstanceId ~= nil
  if self.Properties.GemDropTarget:IsValid() then
    self.GemDropTarget:SetGemDropTargetEnabled(false)
    if shouldEnable and self.isInValidGemDropContainer and self:HasGemSlot() then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ItemDragging.GemSlotId", self.OnDraggingGemSlotIdChanged)
    else
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.ItemDragging.GemSlotId")
    end
    if shouldEnable then
      self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.ItemDragging.RepairKitSlotId", self.OnDraggingRepairKitSlotChanged)
    else
      self.dataLayer:UnregisterObserver(self, "Hud.LocalPlayer.ItemDragging.RepairKitTier")
    end
  end
end
function ItemLayout:OnRepairKitDropped()
  if self.draggedRepairKitSlotId == -1 then
    return
  end
  local containerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerId")
  local itemName = ItemDataManagerBus.Broadcast.GetDisplayName(self.mItemData_itemId)
  local repairKitInstanceId
  local repairKitSlot = ContainerRequestBus.Event.GetSlot(containerEntityId, self.draggedRepairKitSlotId)
  if repairKitSlot:IsValid() then
    repairKitInstanceId = repairKitSlot:GetItemInstanceId()
  end
  local repairKitDescriptor = ItemDescriptor()
  local itemContainerSlot = self:GetItemContainerSlot()
  if self.mItemInstanceId and repairKitInstanceId then
    local repairKitTier = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.RepairKitTier")
    if repairKitTier >= self.mItemData_tierNumber then
      local moreAppropriateRepairKitWarning = false
      if repairKitTier > self.mItemData_tierNumber then
        for i = self.mItemData_tierNumber, repairKitTier - 1 do
          repairKitDescriptor.itemId = Math.CreateCrc32("RepairKitT" .. tostring(i))
          local correctTierRepairKitCount = ContainerRequestBus.Event.GetItemCount(containerEntityId, repairKitDescriptor, false, false, false)
          if 0 < correctTierRepairKitCount then
            moreAppropriateRepairKitWarning = true
            break
          end
        end
      end
      local titleText = "@ui_repair_item"
      local messageText = moreAppropriateRepairKitWarning and "@ui_repair_better_kit_warning" or "@ui_repair_item_confirmation"
      PopupWrapper:RequestPopup(ePopupButtons_YesNo, titleText, messageText, "useRepairKit", self, function(self, result, eventId)
        if result == ePopupResult_Yes then
          local isPaperdoll = self.mCurrentMode == self.MODE_TYPE_EQUIPPED or self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON
          if isPaperdoll then
            LocalPlayerUIRequestsBus.Broadcast.PaperdollRepairItem(self.mSlotName, true)
          else
            LocalPlayerUIRequestsBus.Broadcast.RepairItem(self.mSlotName, true)
          end
        end
      end)
    else
      local notificationData = NotificationData()
      notificationData.type = "Minor"
      notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_repair_not_valid_kit", self.mItemData_tierNumber)
      UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
    end
  end
end
function ItemLayout:OnGemDropFailed()
  local notificationData = NotificationData()
  notificationData.type = "Minor"
  notificationData.text = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_replace_gem_not_valid")
  UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
end
function ItemLayout:OnGemDropped()
  if not self:HasGemSlot() or self.draggedGemSlotId == -1 then
    return
  end
  local containerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerId")
  local containerType = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.ItemDragging.ContainerType")
  local itemName = ItemDataManagerBus.Broadcast.GetDisplayName(self.mItemData_itemId)
  local gemName = ""
  local gemInstanceId
  local gemSlot = ContainerRequestBus.Event.GetSlot(containerEntityId, self.draggedGemSlotId)
  if gemSlot:IsValid() then
    gemInstanceId = gemSlot:GetItemInstanceId()
    local gemPerk = gemSlot:GetResourceGemPerkForItem(self.mItemData_itemId)
    gemName = ItemDataManagerBus.Broadcast.GetStaticPerkData(gemPerk).displayName
  end
  if self.mItemInstanceId and gemInstanceId then
    local hasGemInSlot = self.mItemData_gemPerkId ~= itemCommon.EMPTY_GEM_SLOT_PERK_ID
    local titleText = hasGemInSlot and "@ui_replace_gem" or "@ui_attach_gem"
    local messageText = hasGemInSlot and "@ui_replace_gem_confirmation_message" or "@ui_attach_gem_confirmation_message"
    self.droppedGemSlotId = self.draggedGemSlotId
    PopupWrapper:RequestPopup(ePopupButtons_YesNo, titleText, messageText, "attachGemToItem", self, function(self, result, eventId)
      if result == ePopupResult_Yes then
        local isPaperdoll = self.mCurrentMode == self.MODE_TYPE_EQUIPPED or self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON
        local itemLocation = ItemLocation()
        itemLocation.containerSlotId = tonumber(self.mSlotName)
        itemLocation.containerType = isPaperdoll and eItemContainerType_Paperdoll or eItemContainerType_Container
        itemLocation.itemInstanceId = self.mItemInstanceId
        local isInventory = containerType == eItemDragContext_Inventory
        local gemLocation = ItemLocation()
        gemLocation.containerType = isInventory and eItemContainerType_Container or eItemContainerType_GlobalStorage
        gemLocation.containerSlotId = self.droppedGemSlotId
        gemLocation.itemInstanceId = gemInstanceId
        local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
        ItemRepairRequestBus.Event.RequestSlotItemWithGem(playerEntityId, itemLocation, gemLocation)
        self.droppedGemSlotId = -1
        local message = GetLocalizedReplacementText("@ui_gem_added_notification", {gemPerkName = gemName, itemName = itemName})
        local notificationData = NotificationData()
        notificationData.type = "Minor"
        notificationData.text = message
        UiNotificationsBus.Broadcast.EnqueueNotification(notificationData)
      end
    end)
  end
end
function ItemLayout:DisableGemDropTarget()
  if self.Properties.GemDropTarget:IsValid() then
    self.GemDropTarget:SetGemDropTargetEnabled(false)
  end
end
function ItemLayout:GetCurrentScale()
  return self.currentScale
end
function ItemLayout:SetIndicatorsHidden()
  if self.Properties.ItemAnimatedIndicator:IsValid() then
    UiFlipbookAnimationBus.Event.Stop(self.Properties.ItemAnimatedIndicator)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemAnimatedIndicator, false)
  end
end
function ItemLayout:SetQuantityText(value)
  if self.Properties.ItemQuantity:IsValid() then
    if self.infiniteAmmo and self.mItemData_itemType == self.ITEM_TYPE_AMMO then
      UiTextBus.Event.SetText(self.Properties.ItemQuantity, "\226\136\158")
    else
      UiTextBus.Event.SetText(self.Properties.ItemQuantity, value or "")
    end
  end
end
function ItemLayout:SetItemIsShowing(isShowing)
  if self.isShowing == isShowing then
    return
  end
  self.isShowing = isShowing
  self:UpdateSpecialDropTargetStates()
  self:UpdateConsumableState()
  if not isShowing then
    self.damagedTimeline:Stop()
    self:SetIndicatorsHidden()
  else
    if self.mCurrentDamageSprite ~= nil and self.mItemData_durabilityState ~= nil then
      self:SetDurabilityState(self.mItemData_durabilityState)
    end
    if self.isNewIndicatorVisible then
      self:SetNewIndicatorVisible(self.isNewIndicatorVisible)
    end
  end
end
function ItemLayout:OnReturnedToCache()
  self.mItemInstanceId = nil
  self.slotNameForGemDrop = nil
  self:UpdateSpecialDropTargetStates()
  self:UpdateConsumableState()
end
function ItemLayout:SetIsInInventory(value)
  self.mIsInInventory = value
end
function ItemLayout:SetIsItemNew()
  local inventoryScriptEntity = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.InventoryScriptElement")
  if inventoryScriptEntity and inventoryScriptEntity:IsValid() then
    local inventoryTable = self.registrar:GetEntityTable(inventoryScriptEntity)
    local parentId = UiElementBus.Event.GetParent(self.entityId)
    local parentTable = self.registrar:GetEntityTable(parentId)
    parentTable:SetItemInstanceId(self.mItemInstanceId)
    inventoryTable:AddDraggableItem(parentTable)
  end
end
function ItemLayout:SetNewIndicatorVisible(isVisible, flashOverride)
  if not self.mIsInInventory and not flashOverride then
    self.isNewIndicatorVisible = false
  elseif self.mItemData_isContainer then
    self.isNewIndicatorVisible = true
  elseif isVisible ~= nil then
    self.isNewIndicatorVisible = isVisible
    if isVisible then
      if self.mItemData_isFromRewardChest then
        DynamicBus.BoxOpeningPopupNotifications.Connect(self.entityId, self)
      else
        timingUtils:Delay(self.INDICATOR_DURATION_NEW, self, function()
          self:SetNewIndicatorVisible(false)
        end)
      end
    end
  end
  self:UpdateAnimatedIndicator()
end
function ItemLayout:SetDamageIndicatorVisible(isVisible)
  self.isDamageIndicatorVisible = isVisible
  self:UpdateAnimatedIndicator()
end
function ItemLayout:SetRepairIndicatorVisible(isVisible)
  self.isRepairIndicatorVisible = isVisible
  if isVisible then
    timingUtils:Delay(self.INDICATOR_DURATION_REPAIR, self, function()
      self:SetRepairIndicatorVisible(false)
    end)
  end
  self:UpdateAnimatedIndicator()
end
function ItemLayout:UpdateAnimatedIndicator()
  if not self.Properties.ItemAnimatedIndicator then
    return
  end
  if self.isNewIndicatorVisible or self.isDamageIndicatorVisible or self.isRepairIndicatorVisible then
    local indicatorSpritePath = self.isDamageIndicatorVisible and self.mCurrentDamageSprite or self.mCurrentNewSprite
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemAnimatedIndicator, indicatorSpritePath)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemAnimatedIndicator, true)
    UiFlipbookAnimationBus.Event.Start(self.Properties.ItemAnimatedIndicator)
  else
    UiFlipbookAnimationBus.Event.Stop(self.Properties.ItemAnimatedIndicator)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemAnimatedIndicator, false)
  end
end
function ItemLayout:OnBoxOpeningPopupClosed()
  if self.isShowing then
    timingUtils:Delay(self.INDICATOR_DURATION_NEW, self, function()
      self:SetNewIndicatorVisible(false)
    end)
  end
  DynamicBus.BoxOpeningPopupNotifications.Disconnect(self.entityId, self)
end
function ItemLayout:OnItemMoved(flashOverride)
  self:SetNewIndicatorVisible(true, flashOverride)
end
function ItemLayout:SetProgressPercent(percent)
  if self.Properties.ItemDurabilityFill:IsValid() then
    self.ScriptedEntityTweener:Set(self.Properties.ItemDurabilityFill, {imgFill = percent})
  end
end
function ItemLayout:SetDurabilityState(damageState)
  if not self.mCurrentDamageSprite then
    return
  end
  local enableFlipbook = false
  local playFlipbook = false
  local playTimeline = false
  local enableBrokenImage = false
  if damageState ~= self.DURABILITY_STATE_NORMAL then
    enableFlipbook = true
    playTimeline = true
    if damageState == self.DURABILITY_STATE_BROKEN then
      playFlipbook = true
      enableBrokenImage = true
    end
  end
  self:SetDamageIndicatorVisible(enableFlipbook)
  if playTimeline then
    self.damagedTimeline:Play(0)
  else
    self.damagedTimeline:Stop()
    if self.Properties.ItemDurabilityHolder:IsValid() then
      UiImageBus.Event.SetColor(self.Properties.ItemDurabilityHolder, self.UIStyle.COLOR_GRAY_30)
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemBroken, enableBrokenImage)
end
function ItemLayout:SetQuantityEnabled(enable)
  if self.Properties.ItemQuantity:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemQuantity, enable)
  end
  if self.Properties.QuantityBg:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.QuantityBg, enable)
  end
end
function ItemLayout:SetDimVisible(isVisible)
  local animDuration = 0.3
  if isVisible then
    UiImageBus.Event.SetFillAmount(self.Properties.ItemDimmer, 1)
    self.ScriptedEntityTweener:Play(self.Properties.ItemDimmer, animDuration, {opacity = 0.65, ease = "QuadOut"})
  elseif not isVisible then
    self.ScriptedEntityTweener:Play(self.Properties.ItemDimmer, animDuration, {opacity = 0, ease = "QuadOut"})
  end
end
function ItemLayout:SetItemCooldown(isOnCooldown, remainingCooldown, totalCooldown)
  if isOnCooldown == self.isOnCooldown and not remainingCooldown then
    return
  end
  self.isOnCooldown = isOnCooldown
  if isOnCooldown then
    self:SetDimVisible(true)
    UiImageBus.Event.SetColor(self.Properties.ItemDimmer, self.UIStyle.COLOR_ABILITY_COOLDOWN)
    if remainingCooldown then
      local startFill = totalCooldown and totalCooldown ~= 0 and remainingCooldown / totalCooldown or 1
      if self.Properties.ItemCooldownText:IsValid() then
        self.ScriptedEntityTweener:Play(self.Properties.ItemCooldownHolder, 0.3, {opacity = 1, ease = "QuadOut"})
        self.ScriptedEntityTweener:Play(self.Properties.ItemDimmer, remainingCooldown, {imgFill = startFill}, {
          imgFill = 0,
          onUpdate = function(currentValue, currentProgressPercent)
            local timeRemaining = (1 - currentProgressPercent) * remainingCooldown
            if 3 < timeRemaining then
              UiTextBus.Event.SetText(self.Properties.ItemCooldownText, string.format("%d", timeRemaining))
            else
              UiTextBus.Event.SetText(self.Properties.ItemCooldownText, string.format("%.1f", timeRemaining))
            end
          end,
          onComplete = function()
            self:SetItemCooldown(false)
          end
        })
      else
        self.ScriptedEntityTweener:Play(self.Properties.ItemDimmer, remainingCooldown, {imgFill = startFill}, {
          imgFill = 0,
          onComplete = function()
            self:SetItemCooldown(false)
          end
        })
      end
    end
  else
    self:SetDimVisible(false)
    UiImageBus.Event.SetColor(self.Properties.ItemDimmer, self.UIStyle.COLOR_BLACK)
    if self.Properties.ItemCooldownHolder:IsValid() then
      self.ScriptedEntityTweener:Play(self.Properties.ItemCooldownHolder, 0.3, {opacity = 0, ease = "QuadOut"})
    end
    self:OnItemMoved()
  end
end
function ItemLayout:ClearItemCooldown()
  self.isOnCooldown = false
  self.ScriptedEntityTweener:Stop(self.Properties.ItemDimmer)
  self.ScriptedEntityTweener:Set(self.Properties.ItemDimmer, {opacity = 0})
  UiImageBus.Event.SetColor(self.Properties.ItemDimmer, self.UIStyle.COLOR_BLACK)
  UiImageBus.Event.SetFillAmount(self.Properties.ItemDimmer, 1)
  if self.Properties.ItemCooldownHolder:IsValid() then
    self.ScriptedEntityTweener:Stop(self.Properties.ItemCooldownHolder)
    self.ScriptedEntityTweener:Set(self.Properties.ItemCooldownHolder, {opacity = 0})
  end
end
function ItemLayout:IsOnCooldown()
  return self.isOnCooldown
end
function ItemLayout:TransitionGemSlot(location, duration)
  if not self.mItemData_gemPerkId then
    return
  end
  self.currentGemSlotLocation = location
  if self.Properties.GemSlotContainer:IsValid() then
    local duration = duration or 0
    local isCenter = location == self.GEM_SLOT_CENTER
    local scale = isCenter and self.GEM_SLOT_CENTER_SCALE or self.GEM_SLOT_CORNER_SCALE
    local iconPosX = isCenter and 0 or self.mWidth / 2 - self.gemSlotIconWidth * scale / 2 - self.GEM_SLOT_CORNER_MARGIN
    local iconPosY = isCenter and 0 or self.mHeight / 2 - self.gemSlotIconHeight * scale / 2 - self.GEM_SLOT_CORNER_MARGIN
    self.ScriptedEntityTweener:Play(self.Properties.GemSlotContainer, duration, {
      x = iconPosX,
      y = iconPosY,
      scaleX = scale,
      scaleY = scale,
      ease = "QuadOut"
    })
  end
end
function ItemLayout:GetItemInstanceId()
  return self.mItemInstanceId
end
function ItemLayout:GetSlotName()
  return self.mSlotName
end
function ItemLayout:IsEquippable()
end
function ItemLayout:SetPrice(value)
end
function ItemLayout:SetQuantity(value)
  self:SetQuantityText(tostring(value))
end
function ItemLayout:GetQuantity()
  return tonumber(UiTextBus.Event.GetText(self.Properties.ItemQuantity)) or self.mItemData_quantity
end
function ItemLayout:SetRequiredQuantity(value)
end
function ItemLayout:SetShouldCompare(shouldCompare)
  self.mShouldCompare = shouldCompare
end
function ItemLayout:SetSlotName(value)
  self.mSlotName = value
  self.slotNameForGemDrop = value
end
function ItemLayout:ClearItem()
end
function ItemLayout:ShowItem()
end
function ItemLayout:HideItem()
end
function ItemLayout:SetEntitlementIndex(index, callbackData)
  self.entitlementIndex = index + 1
  local itemSkinVector = {
    {
      uiImage = self.mIconPathRoot .. self.mItemData_itemType .. "/" .. self.mItemData_iconPath .. ".dds",
      type = ""
    }
  }
  if self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON then
    itemSkinVector = {
      {
        uiImage = self.mIconHiResPathRoot .. self.mItemData_iconPath .. ".dds",
        type = ""
      }
    }
  end
  local itemSkinEntries = ItemSkinDataManagerBus.Broadcast.GetItemSkinEntries(self.itemId)
  for itemSkinIndex = 1, #itemSkinEntries do
    local itemSkinEntry = itemSkinEntries[itemSkinIndex]
    local itemSkinData = ItemSkinData()
    if ItemSkinDataManagerBus.Broadcast.GetItemSkinDataFromId(itemSkinEntry, itemSkinData) then
      itemSkinKey = itemSkinData.key
    end
    local entitlementType = ""
    local itemSkinEntitlements = EntitlementRequestBus.Broadcast.GetEntitlementsForEntryIdOfRewardType(eRewardTypeItemSkin, itemSkinKey)
    if 0 < #itemSkinEntitlements then
      local itemSkinEntitlement = itemSkinEntitlements[1]
      local entitlementData = EntitlementRequestBus.Broadcast.GetEntitlementData(itemSkinEntitlement)
      entitlementType = entitlementData.entitlementInfo
    end
    local skinIcon = self.mIconPathRoot .. self.mItemData_itemType .. "/" .. itemSkinId .. ".dds"
    if self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON then
      skinIcon = self.mIconHiResPathRoot .. itemSkinId .. ".dds"
    end
    local skinStaticItemData = StaticItemDataManager:GetItem(Math.CreateCrc32(itemSkinId))
    if skinStaticItemData then
      skinIcon = self.mIconPathRoot .. self.mItemData_itemType .. "/" .. skinStaticItemData.iconPath .. ".dds"
      if self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON then
        skinIcon = self.mIconHiResPathRoot .. skinStaticItemData.iconPath .. ".dds"
      end
    end
    table.insert(itemSkinVector, {uiImage = skinIcon, type = entitlementType})
  end
  local entitlementData = itemSkinVector[self.entitlementIndex]
  if entitlementData and entitlementData.uiImage and entitlementData.uiImage ~= "" then
    UiImageBus.Event.SetSpritePathnamePool(self.Properties.ItemIcon, entitlementData.uiImage, DynamicBus.Globals.Broadcast.GetInventoryIconPoolId())
  end
  self:SetCallback(callbackData.caller, callbackData.func)
  local playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if self.entitlementIndex == 1 and ItemSkinningRequestBus.Event.GetItemSkinItemId(playerEntityId, self.itemId) == GetNilCrc() or self.entitlementIndex > 1 and ItemSkinningRequestBus.Event.IsItemSkinEnabled(playerEntityId, itemSkinEntries[self.entitlementIndex - 1]) then
    UiElementBus.Event.SetIsEnabled(self.Properties.IsEntitlementActiveIcon, true)
  end
end
function ItemLayout:GetEntitlementIndex()
  return self.entitlementIndex
end
function ItemLayout:SetGemPerkData()
  self.mItemData_gemPerkId = nil
  self.mItemData_gemIconPath = nil
  local numPerks = self.mItemData_itemDescriptor:GetPerkCount()
  for i = 0, numPerks - 1 do
    local perkId = self.mItemData_itemDescriptor:GetPerk(i)
    if perkId ~= 0 then
      local perkData = ItemDataManagerBus.Broadcast.GetStaticPerkData(perkId)
      if perkData:IsValid() and perkData.perkType == ePerkType_Gem then
        self.mItemData_gemPerkId = perkId
        self.mItemData_gemIconPath = perkData.iconPath
        return
      end
    end
  end
end
function ItemLayout:SetConsumableData()
  local cooldownDataPath
  if self.itemId then
    local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(self.itemId)
    if staticConsumableData:IsValid() then
      cooldownDataPath = string.format("%s.%s", self.COOLDOWN_BASE_DATA_PATH, tostring(staticConsumableData.cooldownId))
    end
  end
  local resetCooldown = cooldownDataPath ~= self.cooldownDataPath
  if resetCooldown then
    if self.cooldownDataPath then
      self.dataLayer:UnregisterObserver(self, string.format("%s.%s", self.cooldownDataPath, self.COOLDOWN_REMAINING_TIME_NODE))
    end
    self.cooldownDataPath = cooldownDataPath
  end
  self:UpdateConsumableState(resetCooldown)
end
function ItemLayout:UpdateConsumableState(resetCooldown)
  local isPaperdoll = self.mCurrentMode == self.MODE_TYPE_EQUIPPED or self.mCurrentMode == self.MODE_TYPE_EQUIPMENT_WEAPON
  local shouldEnable = (self.isShowing or isPaperdoll) and self.mItemInstanceId ~= nil and self.itemId ~= nil
  if not shouldEnable then
    if self.cooldownDataPath then
      self.dataLayer:UnregisterObserver(self, string.format("%s.%s", self.cooldownDataPath, self.COOLDOWN_REMAINING_TIME_NODE))
    end
    self:ClearItemCooldown()
    return
  end
  local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(self.itemId)
  if staticConsumableData:IsValid() then
    local rootEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.GDERootEntityId")
    if rootEntityId and CooldownTimersComponentBus.Event.IsConsumableOnCooldown(rootEntityId, staticConsumableData.cooldownId) then
      local remainingCooldownTime = CooldownTimersComponentBus.Event.GetConsumableCooldown(rootEntityId, staticConsumableData.cooldownId)
      local triggeringItemId = CooldownTimersComponentBus.Event.GetConsumableCooldownItemId(rootEntityId, staticConsumableData.cooldownId)
      local triggeringConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(triggeringItemId)
      self:SetItemCooldown(true, remainingCooldownTime, triggeringConsumableData.cooldownDuration)
    elseif resetCooldown then
      self:ClearItemCooldown()
    end
  end
  if self.cooldownDataPath then
    self.dataLayer:RegisterDataObserver(self, string.format("%s.%s", self.cooldownDataPath, self.COOLDOWN_REMAINING_TIME_NODE), function(self, timeRemaining)
      if not timeRemaining then
        return
      end
      local itemId = self.dataLayer:GetDataFromNode(string.format("%s.%s", self.cooldownDataPath, self.COOLDOWN_ITEM_ID_NODE))
      if itemId then
        local staticConsumableData = ItemDataManagerBus.Broadcast.GetConsumableData(itemId)
        self:SetItemCooldown(true, timeRemaining, staticConsumableData.cooldownDuration)
      end
    end)
  end
end
function ItemLayout:OnFilterChange(filter)
  if filter and filter.sortBy == filter.SORT_BY_WEIGHT then
    local itemWeight = GetFormattedNumber(self.mItemData_weight / 10, 1)
    local itemWeightIcon = "<img src=\"lyshineui/images/icons/misc/icon_weight\" xPadding=\"3\" scale=\"0.8\" yOffset=\"0\" />"
    UiTextBus.Event.SetText(self.Properties.ItemSortValueText, itemWeight .. itemWeightIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemSortValueText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, false)
  elseif filter and filter.sortBy == filter.SORT_BY_GEARSCORE then
    self.mItemData_gearScore = self.mItemData_itemDescriptor:GetGearScore()
    local itemGearScore = GetFormattedNumber(self.mItemData_gearScore)
    local itemGearScoreIcon = "<img src=\"lyshineui/images/icons/misc/icon_filter_gearscore\" xPadding=\"0\" scale=\"1.4\" yOffset=\"3\" />"
    UiTextBus.Event.SetText(self.Properties.ItemSortValueText, itemGearScore .. itemGearScoreIcon)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemSortValueText, self.mItemData_gearScore > 0)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemSortValueText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, self:ShouldShowItemTier())
  end
end
function ItemLayout:ShouldShowItemTier(value)
  local showItemTier = true
  if value == self.MODE_TYPE_CRAFTING or value == self.MODE_TYPE_CRAFTING_RARITY then
    showItemTier = false
  end
  return showItemTier
end
function ItemLayout:ShouldShowLockIcon(mode)
  if mode == self.MODE_TYPE_P2P_TRADING then
    return false
  end
  return true
end
function ItemLayout:OnShutdown()
  if self.ilsBusHandler then
    DynamicBus.ItemLayoutSlotProvider.Disconnect(self.itemEntity, self)
    self.ilsBusHandler = nil
  end
  if self.itemFilterNotificationhandler then
    DynamicBus.ItemFilterNotificationBus.Disconnect(self.itemEntity, self)
    self.itemFilterNotificationhandler = nil
  end
  if self.itemRepairDynamicBus then
    DynamicBus.ItemRepairDynamicBus.Disconnect(self.entityId, self)
    self.itemRepairDynamicBus = nil
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
function ItemLayout:OnItemRepaired(itemInstanceId)
  if itemInstanceId == self.mItemInstanceId then
    self.wasJustRepaired = true
  end
end
function ItemLayout:PlayRarityEffect(startPlay)
  if self.Properties.RarityEffect then
    if startPlay then
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect, true)
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffectFrame, true)
      UiFlipbookAnimationBus.Event.Start(self.Properties.RarityEffect)
      UiFlipbookAnimationBus.Event.Start(self.Properties.RarityEffectFrame)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffect, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityEffectFrame, false)
      UiFlipbookAnimationBus.Event.Stop(self.Properties.RarityEffect)
      UiFlipbookAnimationBus.Event.Stop(self.Properties.RarityEffectFrame)
    end
  end
end
return ItemLayout
