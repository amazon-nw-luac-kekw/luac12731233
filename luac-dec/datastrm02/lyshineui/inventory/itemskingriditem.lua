RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local ItemSkinGridItem = {
  Properties = {
    Name = {
      default = EntityId()
    },
    MaterialAffix = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Lock = {
      default = EntityId()
    },
    IsNewIndicator = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    }
  },
  selected = false,
  elementWidth = 150,
  elementHeight = 140
}
local EntitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local OmniDataHandler = RequireScript("LyShineUI._Common.OmniDataHandler")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(ItemSkinGridItem)
function ItemSkinGridItem:OnInit()
  BaseElement.OnInit(self)
end
function ItemSkinGridItem:OnShutdown()
  if self.timeline ~= nil then
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
function ItemSkinGridItem:GetElementWidth()
  return self.elementWidth
end
function ItemSkinGridItem:GetElementHeight(gridItemData)
  return self.elementHeight
end
function ItemSkinGridItem:GetHorizontalSpacing()
  return 15
end
function ItemSkinGridItem:SetGridItemData(gridItemData)
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if not gridItemData then
    return
  end
  self.gridItemData = gridItemData
  if self.gridItemData.isSelected then
    self.selected = true
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 1})
    UiImageBus.Event.SetColor(self.Properties.Hover, self.UIStyle.COLOR_TAN_LIGHT)
  else
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 0})
    UiImageBus.Event.SetColor(self.Properties.Hover, self.UIStyle.COLOR_WHITE)
    self.selected = false
  end
  local staticItemData = StaticItemDataManager:GetItem(gridItemData.displayItemId)
  if not staticItemData then
    return
  end
  if gridItemData.index == 0 then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Name, "@ui_none", eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.Name, staticItemData.displayName, eUiTextSet_SetLocalized)
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "lyShineui/images/icons/Items_HiRes/" .. staticItemData.icon .. ".dds")
  local descriptor = ItemDescriptor()
  descriptor.itemId = self.gridItemData.displayItemId
  self.tdi = StaticItemDataManager:GetTooltipDisplayInfo(descriptor, nil)
  self.tdi.gearScore = 0
  if self.gridItemData.isEnabled then
    UiElementBus.Event.SetIsEnabled(self.Properties.Lock, false)
  else
    local xPos = -2
    if self.gridItemData.availableProducts and 0 < #self.gridItemData.availableProducts then
      local isRewardFromTwitch = false
      local isRewardFromPrime = false
      local isRewardFromPreOrder = false
      local isRewardFromStore = false
      xPos = -2
      local iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      if isRewardFromTwitch then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_Twitch.dds"
      elseif isRewardFromPrime then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_TwitchPrime.dds"
      elseif isRewardFromPreOrder then
        iconTexture = "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds"
        xPos = 2
      elseif isRewardFromStore then
        iconTexture = "LyShineUI/Images/Entitlements/icon_purchasable.dds"
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.Lock, iconTexture)
    else
      UiImageBus.Event.SetSpritePathname(self.Properties.Lock, "LyShineUI/Images/Entitlements/icon_entitlement_locked.dds")
      xPos = 2
    end
    UiTransformBus.Event.SetLocalPositionX(self.Properties.Lock, xPos)
    UiElementBus.Event.SetIsEnabled(self.Properties.Lock, true)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.IsNewIndicator, gridItemData.isNew)
  if not self.Properties.IsNewIndicator:IsValid() and gridItemData.isNew then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Name, string.format("NEW! %s", staticItemData.displayName), eUiTextSet_SetLocalized)
  end
  self.tdi.tooltipLayout.RefinedAtText = ""
  self.tdi.tooltipLayout.DerivedFromText = ""
  self.tdi.usesRarity = false
  self.tdi.maxDurability = 0
  self.tdi.ignoreWeight = true
  self.tdi.ignoreRequirements = true
  self.tdi.rewardKey = gridItemData.rewardKey
  self.tdi.rewardType = eRewardTypeItemSkin
  self.tdi.isRewardOwned = self.gridItemData.isEnabled
end
function ItemSkinGridItem:CanBuy()
  return false
end
function ItemSkinGridItem:BuyShopItem()
end
function ItemSkinGridItem:OnFocus()
  if self.gridItemData.displayItemId then
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    if flyoutMenu:IsLocked() then
      return
    end
    local flyoutVisible = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Flyout.IsVisible")
    if flyoutVisible and flyoutMenu.invokingEntityId == self.entityId then
      return
    end
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
    local itemTable = self.tdi
    local rewardDisplayInfo = EntitlementsDataHandler:GetEntitlementDisplayInfo(eRewardTypeItemSkin, self.gridItemData.itemSkinEntry)
    local productType = rewardDisplayInfo.typeString
    local grantInfo = EntitlementsDataHandler:GetGrantorForRewardTypeAndKey(eRewardTypeItemSkin, self.gridItemData.itemSkinEntry)
    itemTable.productType = productType
    itemTable.sourceType = grantInfo.grantor and grantInfo.grantor.sourceType
    local rows = {}
    table.insert(rows, {
      slicePath = "LyShineUI/Tooltip/DynamicTooltip",
      itemTable = itemTable,
      itemId = self.gridItemData.displayItemId,
      isInPaperdoll = false,
      inventoryTable = nil,
      slotIndex = nil,
      availableProducts = self.gridItemData.availableProducts,
      rewardType = eRewardTypeItemSkin,
      rewardKey = self.gridItemData.itemSkinEntry,
      dynamicInfoText = self.gridItemData.isEnabled and "@ui_click_to_choose_this_skin" or "@ui_itemskin_tooltip_not_entitled",
      dynamicInfoColor = self.gridItemData.isEnabled and self.UIStyle.COLOR_YELLOW or self.UIStyle.COLOR_RED,
      disclaimerText = self.gridItemData.availableProducts and "@ui_mtx_disclaimer" or nil,
      draggableItem = nil
    })
    if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
      flyoutMenu:SetOpenLocation(self.entityId)
      flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
      flyoutMenu:EnableFlyoutDelay(true, 0.2)
      flyoutMenu:SetFadeInTime(0.2)
      flyoutMenu:SetRowData(rows)
      flyoutMenu:DockToCursor(10)
    end
    if not self.timeline then
      self.timeline = self.ScriptedEntityTweener:TimelineCreate()
      self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.3})
      self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 0.7})
      self.timeline:Add(self.Properties.Hover, self.UIStyle.DURATION_TIMELINE_HOLD, {
        opacity = 0.7,
        onComplete = function()
          self.timeline:Play()
        end
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.Hover, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 0.7, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.Properties.Hover, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 0.7,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ItemDraggable)
  if type(self.gridItemData.cbHoverBegin) == "function" and self.gridItemData.cbContext ~= nil then
    self.gridItemData.cbHoverBegin(self.gridItemData.cbContext, self.gridItemData)
  end
end
function ItemSkinGridItem:OnFlyoutMenuClosed()
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  flyoutMenu:Unlock()
end
function ItemSkinGridItem:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if not self.selected then
    if type(self.unfocusCallback) == "function" and self.unfocusCallbackTable ~= nil then
      self.unfocusCallback(self.unfocusCallbackTable, self)
    end
    UiImageBus.Event.SetColor(self.Properties.Hover, self.UIStyle.COLOR_WHITE)
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
    if type(self.gridItemData.cbHoverEnd) == "function" and self.gridItemData.cbContext ~= nil then
      self.gridItemData.cbHoverEnd(self.gridItemData.cbContext, self.gridItemData)
    end
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
  end
end
function ItemSkinGridItem:OnPress()
  if self.gridItemData.isEnabled then
    self.gridItemData.cb(self.gridItemData.cbContext, self.gridItemData.index, self.gridItemData)
    self.selected = true
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.15, {opacity = 1})
    UiImageBus.Event.SetColor(self.Properties.Hover, self.UIStyle.COLOR_TAN_LIGHT)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  else
    local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
    flyoutMenu:SetSourceHoverOnly(false)
    flyoutMenu:Lock()
  end
end
return ItemSkinGridItem
