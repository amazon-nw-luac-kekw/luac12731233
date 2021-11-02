local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local OWGuildShopConfirmPopup = {
  Properties = {
    ItemName = {
      default = EntityId()
    },
    ItemDescription = {
      default = EntityId()
    },
    MaterialAffixBG = {
      default = EntityId()
    },
    ItemIconBG = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    TotalInfluence = {
      default = EntityId()
    },
    TotalGold = {
      default = EntityId()
    },
    RemainingInfluence = {
      default = EntityId()
    },
    RemainingGold = {
      default = EntityId()
    },
    TotalAzoth = {
      default = EntityId()
    },
    RemainingAzoth = {
      default = EntityId()
    },
    QuantitySlider = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    ConfirmButton = {
      default = EntityId()
    },
    UnitPrice = {
      default = EntityId()
    },
    UnitInfluence = {
      default = EntityId()
    },
    UnitAzoth = {
      default = EntityId()
    },
    UnitAzothIcon = {
      default = EntityId()
    },
    TotalAzothIcon = {
      default = EntityId()
    },
    RemainingAzothIcon = {
      default = EntityId()
    },
    GuildCurrencyIcon1 = {
      default = EntityId()
    },
    GuildCurrencyIcon2 = {
      default = EntityId()
    },
    GuildCurrencyIcon3 = {
      default = EntityId()
    },
    GoldIcon1 = {
      default = EntityId()
    },
    GoldIcon2 = {
      default = EntityId()
    },
    GoldIcon3 = {
      default = EntityId()
    },
    PopupBackground = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    PopupShadow = {
      default = EntityId()
    },
    BGOverlay = {
      default = EntityId()
    },
    CurrentValueTextInput = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShopConfirmPopup)
function OWGuildShopConfirmPopup:OnInit()
  BaseElement.OnInit(self)
  self.canvasId = UiElementBus.Event.GetCanvas(self.entityId)
  self.CloseButton:SetCallback(self.OnClose, self)
  self.ConfirmButton:SetCallback(self.OnConfirmButton, self)
  self.QuantitySlider:SetCallback(self.OnQuantityChange, self)
  self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
  DynamicBus.OWGDynamicRequestBus.Connect(self.entityId, self)
  UiImageBus.Event.SetSpritePathname(self.Properties.PopupShadow, "LyShineUI/Images/Contracts/contracts_popupShadow.dds")
  UiImageBus.Event.SetSpritePathname(self.Properties.BGOverlay, "LyShineUI/Images/Contracts/contracts_popupGradient.dds")
  UiImageBus.Event.SetSpritePathname(self.Properties.CurrentValueTextInput, "LyShineUI/Images/slices/slider/sliderNumberBg.dds")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.InventoryEntityId", function(self, inventoryId)
    self.inventoryId = inventoryId
  end)
end
function OWGuildShopConfirmPopup:OnShutdown()
  DynamicBus.OWGDynamicRequestBus.Disconnect(self.entityId, self)
end
function OWGuildShopConfirmPopup:ConfirmPurchase(shopItemData, wallet, callback, context, useAlternateCost, costIconPath)
  self.callback = callback
  self.context = context
  self.shopItemData = shopItemData
  self.wallet = wallet
  self.quantity = 1
  local staticItemData = StaticItemDataManager:GetItem(self.shopItemData.itemDescriptor.itemId)
  local displayName = staticItemData.displayName
  if 1 < self.shopItemData.itemDescriptor.quantity then
    displayName = displayName .. " " .. GetLocalizedReplacementText("@ui_quantitywithx", {
      quantity = self.shopItemData.itemDescriptor.quantity
    })
  end
  local raritySuffix = tostring(self.shopItemData.itemDescriptor:GetRarityLevel())
  local materialBGPath = "lyshineui/images/crafting/crafting_itemraritybgLarge" .. raritySuffix .. ".dds"
  UiImageBus.Event.SetSpritePathname(self.Properties.MaterialAffixBG, materialBGPath)
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, "lyShineui/images/icons/Items_HiRes/" .. staticItemData.icon .. ".dds")
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemName, displayName, eUiTextSet_SetLocalized)
  local description = LyShineScriptBindRequestBus.Broadcast.LocalizeWithDataSheetData(staticItemData.description)
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemDescription, description, eUiTextSet_SetLocalized)
  if useAlternateCost then
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon1, costIconPath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon2, costIconPath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon3, costIconPath)
  else
    local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
    local currencyImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon1, currencyImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon2, currencyImagePath)
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon3, currencyImagePath)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon1, not useAlternateCost)
  UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon2, not useAlternateCost)
  UiElementBus.Event.SetIsEnabled(self.Properties.GoldIcon3, not useAlternateCost)
  UiElementBus.Event.SetIsEnabled(self.Properties.UnitPrice, not useAlternateCost)
  self:SetupQuantity()
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
end
function OWGuildShopConfirmPopup:SetupQuantity()
  local max = GetMaxNum()
  if self.shopItemData.coin > 0 then
    local coinAmt = math.floor(self.wallet.coin / self.shopItemData.coin)
    max = math.min(max, coinAmt)
  end
  if 0 < self.shopItemData.influence then
    local influenceAmount = math.floor(self.wallet.influence / self.shopItemData.influence)
    max = math.min(max, influenceAmount)
  end
  if self.shopItemData.azothPrice and 0 < self.shopItemData.azothPrice then
    local azothAmount = math.floor(self.wallet.azoth / self.shopItemData.azothPrice)
    max = math.min(max, azothAmount)
  end
  if self.shopItemData.itemPrice and 0 < self.shopItemData.itemPrice then
    local itemAmount = math.floor(self.wallet.influence / self.shopItemData.itemPrice)
    max = math.min(max, itemAmount)
  end
  if max == 0 then
    self.QuantitySlider:SetSliderMaxValue(1)
  else
    self.QuantitySlider:SetSliderMaxValue(max)
  end
  self.QuantitySlider:HideCrownIcons()
  self.QuantitySlider:SetSliderValue(1)
  self:OnQuantityChange()
end
function OWGuildShopConfirmPopup:OnQuantityChange()
  self.quantity = math.floor(self.QuantitySlider:GetSliderValue())
  local totalInfluence = self.shopItemData.influence * self.quantity
  if self.shopItemData.itemPrice > 0 then
    totalInfluence = self.shopItemData.itemPrice * self.quantity
  end
  local remainingInfluence = self.wallet.influence - totalInfluence
  local totalCoin = self.shopItemData.coin * self.quantity
  local remainingCoin = self.wallet.coin - totalCoin
  local totalAzoth = self.shopItemData.azothPrice * self.quantity
  local remainingAzoth = self.wallet.azoth - totalAzoth
  UiTextBus.Event.SetText(self.Properties.TotalInfluence, GetFormattedNumber(totalInfluence))
  UiTextBus.Event.SetText(self.Properties.TotalGold, GetLocalizedCurrency(totalCoin))
  if 0 < totalAzoth then
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalAzoth, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.UnitAzoth, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingAzoth, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalAzothIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.UnitAzothIcon, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingAzothIcon, true)
    UiTextBus.Event.SetText(self.Properties.TotalAzoth, GetFormattedNumber(totalAzoth))
    UiTextBus.Event.SetText(self.Properties.UnitAzoth, GetFormattedNumber(self.shopItemData.azothPrice))
    UiTextBus.Event.SetText(self.Properties.RemainingAzoth, GetFormattedNumber(remainingAzoth))
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalAzoth, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.UnitAzoth, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingAzoth, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TotalAzothIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.UnitAzothIcon, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.RemainingAzothIcon, false)
  end
  UiTextBus.Event.SetText(self.Properties.RemainingInfluence, GetFormattedNumber(remainingInfluence))
  UiTextBus.Event.SetText(self.Properties.RemainingGold, GetLocalizedCurrency(remainingCoin))
  UiTextBus.Event.SetText(self.Properties.UnitPrice, GetLocalizedCurrency(self.shopItemData.coin))
  if self.shopItemData.itemPrice > 0 then
    UiTextBus.Event.SetText(self.Properties.UnitInfluence, GetFormattedNumber(self.shopItemData.itemPrice))
  else
    UiTextBus.Event.SetText(self.Properties.UnitInfluence, GetFormattedNumber(self.shopItemData.influence))
  end
  local canBuy = totalInfluence <= self.wallet.influence and totalCoin <= self.wallet.coin
  local canBuyMoreOfThisItem = true
  if StaticItemDataManager:IsUniqueItem(self.shopItemData.itemDescriptor.itemId) then
    local uniqueItemCount = ContainerRequestBus.Event.GetItemCount(self.inventoryId, self.shopItemData.itemDescriptor, false, true, false)
    if 1 <= uniqueItemCount or self.quantity > 1 then
      canBuyMoreOfThisItem = false
    end
  end
  if self.quantity >= 1 and canBuy and canBuyMoreOfThisItem then
    self.ConfirmButton:SetEnabled(true)
    self.ConfirmButton:SetButtonStyle(self.ConfirmButton.BUTTON_STYLE_CTA)
    self.ConfirmButton:SetText("@ui_buynow")
  else
    self.ConfirmButton:SetEnabled(false)
    if not canBuyMoreOfThisItem then
      self.ConfirmButton:SetText("@ui_contract_failure_already_has_item")
    elseif self.quantity < 1 then
      self.ConfirmButton:SetText("@ui_contract_failure_no_quantity_selected")
    else
      self.ConfirmButton:SetText("@ui_postordererror_buy_notenoughmoney_button")
    end
  end
end
function OWGuildShopConfirmPopup:OnWalletChange(wallet)
  if not UiElementBus.Event.IsEnabled(self.entityId) then
    return
  end
  self.wallet = wallet
  self:SetupQuantity()
end
function OWGuildShopConfirmPopup:IsOpen()
  return UiElementBus.Event.IsEnabled(self.entityId)
end
function OWGuildShopConfirmPopup:OnClose()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.entityId, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackground, false)
      self.IsClosing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackground, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
end
function OWGuildShopConfirmPopup:OnConfirmButton()
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  self.callback(self.context, self.shopItemData, self.quantity)
end
return OWGuildShopConfirmPopup
