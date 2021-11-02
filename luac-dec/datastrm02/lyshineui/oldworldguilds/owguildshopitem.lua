RequireScript("LyShineUI.FlyoutMenu.FlyoutMenuHelper")
local ItemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local FactionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local OWGuildShopItem = {
  Properties = {
    HeaderContainer = {
      default = EntityId()
    },
    ItemContainer = {
      default = EntityId()
    },
    RankLockContainer = {
      default = EntityId()
    },
    HeaderText = {
      default = EntityId()
    },
    Name = {
      default = EntityId()
    },
    MaterialAffix = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Influence = {
      default = EntityId()
    },
    Gold = {
      default = EntityId()
    },
    AzothPrice = {
      default = EntityId()
    },
    Lock = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    Button = {
      default = EntityId()
    },
    GuildCurrencyIcon = {
      default = EntityId()
    }
  },
  battleTokenIconPath = "lyshineui/images/HUD/WarHUD/icon_BattleTokens.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OWGuildShopItem)
function OWGuildShopItem:OnInit()
  BaseElement.OnInit(self)
  DynamicBus.OWGDynamicRequestBus.Connect(self.entityId, self)
  self.factionInfoTable = FactionCommon.factionInfoTable
end
function OWGuildShopItem:OnShutdown()
  DynamicBus.OWGDynamicRequestBus.Disconnect(self.entityId, self)
end
function OWGuildShopItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function OWGuildShopItem:GetElementHeight(gridItemData)
  if gridItemData then
    if gridItemData.rowType.name == "shopItem" then
      return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
    elseif gridItemData.rowType.name == "header" then
      return UiTransform2dBus.Event.GetLocalHeight(self.Properties.HeaderContainer)
    elseif gridItemData.rankData.isLocked then
      return UiTransform2dBus.Event.GetLocalHeight(self.Properties.RankLockContainer)
    else
      return 0
    end
  end
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function OWGuildShopItem:GetHorizontalSpacing()
  return 11
end
function OWGuildShopItem:SetGridItemData(gridItemData)
  self.shopItemData = nil
  self.rowType = nil
  UiElementBus.Event.SetIsEnabled(self.entityId, gridItemData ~= nil)
  if not gridItemData then
    return
  end
  self.rowType = gridItemData.rowType
  self.isSiegeArmory = gridItemData.isSiegeArmory
  self.isOutpostRush = gridItemData.isOutpostRush
  UiElementBus.Event.SetIsEnabled(self.Properties.HeaderContainer, self.rowType.name == "header")
  UiElementBus.Event.SetIsEnabled(self.Properties.ItemContainer, self.rowType.name == "shopItem")
  UiElementBus.Event.SetIsEnabled(self.Properties.Button, self.rowType.name == "shopItem")
  UiElementBus.Event.SetIsEnabled(self.Properties.RankLockContainer, self.rowType.name == "rankLock")
  if self.rowType.name == "header" then
    self.shopItemData = nil
    local rankData = gridItemData.rankData
    local name = ""
    if self.isSiegeArmory then
      name = "@owg_battletoken_header"
    elseif self.isOutpostRush then
      name = "@ui_outpost_rush_title"
    else
      local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
      name = self.factionInfoTable[faction].rankNames[rankData.rank + 1]
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.HeaderText, name, eUiTextSet_SetLocalized)
    self.gridItemData = gridItemData
    if not self.isSiegeArmory and not self.isOutpostRush and gridItemData.onShowCallback then
      gridItemData.onShowCallback.cbFunction(gridItemData.onShowCallback.cbSelf, rankData.rank)
    end
    self.RankLockContainer:SetRankInfo(nil)
  elseif self.rowType.name == "rankLock" then
    self.shopItemData = nil
    local rankData = gridItemData.rankData
    self.RankLockContainer:SetRankInfo(gridItemData.rankData)
  else
    self.shopItemData = gridItemData.itemData
    self.RankLockContainer:SetRankInfo(nil)
    local staticItemData = StaticItemDataManager:GetItem(self.shopItemData.itemDescriptor.itemId)
    local displayName = staticItemData.displayName
    if 1 < self.shopItemData.itemDescriptor.quantity then
      displayName = displayName .. " " .. GetLocalizedReplacementText("@ui_quantitywithx", {
        quantity = self.shopItemData.itemDescriptor.quantity
      })
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.Name, displayName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetText(self.Properties.Influence, GetLocalizedNumber(self.shopItemData.influence))
    UiTextBus.Event.SetText(self.Properties.Gold, GetLocalizedCurrency(self.shopItemData.coin))
    UiTextBus.Event.SetText(self.Properties.AzothPrice, self.shopItemData.azothPrice)
    local hasAzothCost = self.shopItemData.azothPrice and tonumber(self.shopItemData.azothPrice) ~= 0
    UiElementBus.Event.SetIsEnabled(self.Properties.AzothPrice, hasAzothCost)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "lyShineui/images/icons/Items_HiRes/" .. staticItemData.icon .. ".dds")
    local raritySuffix = tostring(self.shopItemData.itemDescriptor:GetRarityLevel())
    local materialBGPath = ItemCommon.IMAGE_PATH_RARITY_RECTANGLE .. raritySuffix .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.MaterialAffix, materialBGPath)
    self:OnWalletChange(DynamicBus.OWGuildShop.Broadcast.GetWallet())
    local currencyImagePath
    self.useItemForInfluence = false
    if self.isSiegeArmory then
      UiElementBus.Event.SetIsEnabled(self.Properties.Gold, false)
      currencyImagePath = self.battleTokenIconPath
    elseif self.isOutpostRush then
      self.useItemForInfluence = true
      UiElementBus.Event.SetIsEnabled(self.Properties.Gold, false)
      local itemPriceData = StaticItemDataManager:GetItem(self.shopItemData.itemPriceId)
      UiTextBus.Event.SetText(self.Properties.Influence, GetLocalizedNumber(self.shopItemData.itemPrice))
      currencyImagePath = "lyshineui/images/icons/items/" .. itemPriceData.itemType .. "/" .. itemPriceData.icon .. ".dds"
    else
      local faction = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Faction")
      currencyImagePath = "lyshineui/images/icons/objectives/reward_factiontokens" .. tostring(faction) .. ".dds"
      UiElementBus.Event.SetIsEnabled(self.Properties.Gold, true)
    end
    UiImageBus.Event.SetSpritePathname(self.Properties.GuildCurrencyIcon, currencyImagePath)
  end
end
function OWGuildShopItem:CanBuy()
  if self.shopItemData then
    return DynamicBus.OWGuildShop.Broadcast.CanBuyItem(self.shopItemData)
  end
  return false
end
function OWGuildShopItem:BuyShopItem()
  DynamicBus.OWGuildShop.Broadcast.OnItemBuyButton(self)
end
function OWGuildShopItem:OnFocus()
  if self.shopItemData and self.shopItemData.itemDescriptor then
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
      itemTable = StaticItemDataManager:GetTooltipDisplayInfo(self.shopItemData.itemDescriptor, nil),
      itemId = self.shopItemData.itemDescriptor.itemId,
      owgAvailableItem = self.shopItemData,
      isInPaperdoll = false,
      inventoryTable = nil,
      shopTable = self,
      slotIndex = nil,
      draggableItem = nil,
      allowExternalCompare = true
    })
    if LocalPlayerUIRequestsBus.Broadcast.IsFlyoutMenuEnabled() then
      flyoutMenu:SetOpenLocation(self.Properties.ItemContainer)
      flyoutMenu:SetClosedCallback(self, self.OnFlyoutMenuClosed)
      flyoutMenu:EnableFlyoutDelay(true, 0.5)
      flyoutMenu:SetFadeInTime(0.4)
      flyoutMenu:SetRowData(rows)
    end
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.15, {opacity = 1})
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ItemDraggable)
  if type(self.focusCallback) == "function" and self.focusCallbackTable ~= nil then
    self.focusCallback(self.focusCallbackTable, self)
  end
end
function OWGuildShopItem:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if type(self.unfocusCallback) == "function" and self.unfocusCallbackTable ~= nil then
    self.unfocusCallback(self.unfocusCallbackTable, self)
  end
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
end
function OWGuildShopItem:OnPress()
  local rankIsLocked = DynamicBus.OWGuildShop.Broadcast.IsRankLocked(self.shopItemData.rank)
  if rankIsLocked then
    return
  end
  local flyoutMenu = GetFlyoutMenu(self.dataLayer, self.registrar)
  LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Flyout.IsVisible", false)
  flyoutMenu:OnFlyoutClose()
  DynamicBus.OWGuildShop.Broadcast.OnItemBuyButton(self)
end
function OWGuildShopItem:OnWalletChange(wallet)
  if not self.shopItemData or not wallet then
    return
  end
  local rankIsLocked = DynamicBus.OWGuildShop.Broadcast.IsRankLocked(self.shopItemData.rank)
  UiElementBus.Event.SetIsEnabled(self.Properties.Lock, rankIsLocked)
  self.ScriptedEntityTweener:Set(self.Properties.ItemContainer, {
    opacity = rankIsLocked and 0.55 or 1
  })
  if wallet.coin >= self.shopItemData.coin or rankIsLocked then
    UiTextBus.Event.SetColor(self.Properties.Gold, self.UIStyle.COLOR_GRAY_80)
  else
    UiTextBus.Event.SetColor(self.Properties.Gold, self.UIStyle.COLOR_RED_LIGHT)
  end
  local hasInfluence = false
  if self.useItemForInfluence then
    hasInfluence = wallet.influence >= self.shopItemData.itemPrice
  else
    hasInfluence = wallet.influence >= self.shopItemData.influence
  end
  if hasInfluence or rankIsLocked then
    UiTextBus.Event.SetColor(self.Properties.Influence, self.UIStyle.COLOR_GRAY_80)
  else
    UiTextBus.Event.SetColor(self.Properties.Influence, self.UIStyle.COLOR_RED_LIGHT)
  end
  if wallet.azoth >= self.shopItemData.azothPrice or rankIsLocked then
    UiTextBus.Event.SetColor(self.Properties.AzothPrice, self.UIStyle.COLOR_GRAY_80)
  else
    UiTextBus.Event.SetColor(self.Properties.AzothPrice, self.UIStyle.COLOR_RED_LIGHT)
  end
end
return OWGuildShopItem
