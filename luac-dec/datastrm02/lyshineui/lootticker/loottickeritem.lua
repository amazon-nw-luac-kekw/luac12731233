local LootTickerItem = {
  Properties = {
    ContainerElement = {
      default = EntityId()
    },
    ItemNameText = {
      default = EntityId()
    },
    ItemQuantityText = {
      default = EntityId()
    },
    ItemLayout = {
      default = EntityId()
    },
    ItemLayoutPositioner = {
      default = EntityId()
    },
    LineFadeAnimation = {
      default = EntityId()
    },
    ItemLegibility = {
      default = EntityId()
    },
    Hash = {
      default = EntityId()
    },
    DummyTweener = {
      default = EntityId(),
      description = "Dummy entity to allow number tween operation"
    }
  },
  initLineWidth = 570,
  initTextWidth = 250,
  isShowing = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(LootTickerItem)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
function LootTickerItem:OnInit()
  BaseElement.OnInit(self)
  function self:hideDelayFunc()
    self:Hide()
  end
  self.initTextWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ItemNameText)
  self.ItemLayout:SetShowIconOnly(true)
  self.ItemLayout:SetModeType(self.ItemLayout.MODE_TYPE_LOOTTICKER)
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemLayout, true)
end
function LootTickerItem:OnShutdown()
end
function LootTickerItem:SetDisplayData(itemDesc, quantity, inventoryQuantity, onEndCallbackInfo, playRarityEffect, index, data)
  local isInventoryQuantityNumber = type(inventoryQuantity) == "number"
  self.ItemLayout:SetItemByDescriptor(itemDesc)
  self.ItemLayout:SetQuantityText(isInventoryQuantityNumber and tostring(inventoryQuantity - quantity) or inventoryQuantity)
  UiElementBus.Event.SetIsEnabled(self.ItemLayout.Properties.ItemQuantity, true)
  self.audioHelper:PlaySound(self.audioHelper.LootTickerItems_OnReceived)
  if playRarityEffect then
    self.ItemLayout:PlayRarityEffect(true)
  end
  local itemType = self.ItemLayout.mItemData_staticItem.itemType
  local localizedText = ""
  if itemType == "Weapon" then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemLayoutPositioner, 42)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemLegibility, "lyshineui/images/lootticker/lootticker_itemBg_square.dds")
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemNameText, 0)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Hash, 90)
  elseif itemType == "Consumable" or itemType == "Ammo" then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemLayoutPositioner, 42)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemLegibility, "lyshineui/images/lootticker/lootticker_itemBg_square.dds")
    localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_lootTickerAddedItem", quantity)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemNameText, 12)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Hash, 90)
  elseif itemType == "Armor" then
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemLayoutPositioner, 42)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemLegibility, "lyshineui/images/lootticker/lootticker_itemBg_square.dds")
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemNameText, 0)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Hash, 90)
  else
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemLayoutPositioner, 42)
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemLegibility, "lyshineui/images/lootticker/lootticker_itemBg_circle.dds")
    localizedText = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@ui_lootTickerAddedItem", quantity)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.ItemNameText, 12)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.Hash, 90)
  end
  local hasStacks = self.ItemLayout.mItemData_staticItem.maxStackSize > 1
  UiTextBus.Event.SetText(self.ItemQuantityText, hasStacks and localizedText or "")
  if isInventoryQuantityNumber then
    self.ScriptedEntityTweener:Play(self.Properties.DummyTweener, 0.5, {
      opacity = inventoryQuantity - quantity
    }, {
      delay = 0.5,
      opacity = inventoryQuantity,
      ease = "CubicOut",
      onUpdate = function(currentValue, currentProgressPercent)
        local displayValue = math.floor(currentValue + 0.5)
        self.ItemLayout:SetQuantityText(tostring(displayValue))
      end
    })
  end
  if index == nil then
    index = 0
  end
  local showDelay = 0.1 * index
  self.ScriptedEntityTweener:Play(self.entityId, 0.1, {opacity = 0}, {
    opacity = 1,
    ease = "QuadOut",
    delay = showDelay
  })
  self.ScriptedEntityTweener:Play(self.Properties.Hash, 0.01, {opacity = 0}, {opacity = 1, delay = showDelay})
  self.ScriptedEntityTweener:Play(self.Properties.Hash, 0.3, {opacity = 1}, {
    opacity = 0,
    delay = showDelay + 0.05
  })
  self.ScriptedEntityTweener:Play(self.Properties.ItemQuantityText, 0.25, {opacity = 0, x = -10}, {
    opacity = 1,
    x = 0,
    ease = "QuadOut",
    delay = showDelay + 0.05
  })
  local fadeInTime = 0.1
  self.ScriptedEntityTweener:PlayC(self.Properties.ContainerElement, fadeInTime, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.ItemLayout, fadeInTime, tweenerCommon.fadeInQuadOut)
  self.ItemLayout:OnItemMoved()
  local itemName = self.ItemLayout.mItemData_itemDescriptor:GetDisplayName()
  if data and data.size and data.weight and 0 < data.size and 0 < data.weight then
    itemName = itemName .. string.format("  %0.2flb  %0.2fin", data.weight, data.size)
  end
  UiTextBus.Event.SetTextWithFlags(self.ItemNameText, itemName, eUiTextSet_SetLocalized)
  local raritySuffix = tostring(self.ItemLayout.mItemData_itemDescriptor:GetRarityLevel())
  local colorName = string.format("COLOR_RARITY_LEVEL_%s_BRIGHT", raritySuffix)
  UiTextBus.Event.SetColor(self.Properties.ItemNameText, self.UIStyle[colorName])
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.isShowing = true
  self:ExecuteOnHideCallback()
  self.onEndCallbackInfo = onEndCallbackInfo
  self:ResetDelay()
end
function LootTickerItem:HideTotalIfDescMatch(descriptor)
  if descriptor:MatchesDescriptor(self.ItemLayout.mItemData_itemDescriptor) then
    self.ScriptedEntityTweener:Stop(self.Properties.DummyTweener)
    UiElementBus.Event.SetIsEnabled(self.ItemLayout.Properties.ItemQuantity, false)
  end
end
function LootTickerItem:ResetDelay()
  timingUtils:StopDelay(self)
  timingUtils:Delay(4, self, self.hideDelayFunc)
end
function LootTickerItem:SetTextWidth(width)
  local widthToUse = self.initTextWidth
  if width then
    widthToUse = width
  end
  self.ScriptedEntityTweener:Set(self.Properties.ItemNameText, {w = widthToUse})
end
function LootTickerItem:Hide()
  self.ScriptedEntityTweener:PlayC(self.Properties.ItemLayout, 0.25, tweenerCommon.lootTickerItemHide)
  self.ScriptedEntityTweener:Play(self.Properties.LineFadeAnimation, 0.25, {
    opacity = 0,
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      self.ItemLayout:PlayRarityEffect(false)
      self.isShowing = false
      self:ExecuteOnHideCallback()
    end,
    onUpdate = function(currentValue, currentProgressPercent)
      if 0.4 <= currentProgressPercent then
        self:ExecuteOnHideCallback()
      end
    end
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.ContainerElement, 0.25, tweenerCommon.lootTickerItemContainerHide)
end
function LootTickerItem:ExecuteOnHideCallback()
  if self.onEndCallbackInfo then
    self.onEndCallbackInfo.func(self.onEndCallbackInfo.caller)
    self.onEndCallbackInfo = nil
  end
end
return LootTickerItem
