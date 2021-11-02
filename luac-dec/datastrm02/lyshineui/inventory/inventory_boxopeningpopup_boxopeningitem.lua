local Inventory_BoxOpeningPopup_BoxOpeningItem = {
  Properties = {
    Container = {
      default = EntityId()
    },
    ItemIconBg = {
      default = EntityId()
    },
    RarityBackground = {
      default = EntityId()
    },
    RarityRune = {
      default = EntityId()
    },
    ItemTier = {
      default = EntityId()
    },
    ItemBg = {
      default = EntityId()
    },
    ItemIcon = {
      default = EntityId()
    },
    BackingGlow = {
      default = EntityId()
    },
    TextContainer = {
      default = EntityId()
    },
    RarityText = {
      default = EntityId()
    },
    RarityTextGlow = {
      default = EntityId()
    },
    ItemNameText = {
      default = EntityId()
    },
    CategoryText = {
      default = EntityId()
    },
    SecondaryText = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    GearScoreLabelText = {
      default = EntityId()
    },
    GearScoreText = {
      default = EntityId()
    },
    QuantityText = {
      default = EntityId()
    },
    RaritySequences = {
      default = EntityId()
    },
    Rarity0 = {
      default = EntityId()
    },
    Rarity1 = {
      default = EntityId()
    },
    Rarity2 = {
      default = EntityId()
    },
    Rarity3 = {
      default = EntityId()
    },
    Rarity4 = {
      default = EntityId()
    },
    FakeGlow = {
      default = EntityId()
    }
  },
  currencyName = "@ui_currency",
  currencyIconPath = "LyShineUI/Images/Icons/Items_HiRes/Crowns_T0.dds",
  azothName = "@ui_azoth_currency",
  azothIconPath = "LyShineUI/Images/Icons/Items_HiRes/AzureT1.dds"
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(Inventory_BoxOpeningPopup_BoxOpeningItem)
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local itemCommon = RequireScript("LyShineUI._Common.ItemCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function Inventory_BoxOpeningPopup_BoxOpeningItem:OnInit()
  BaseElement.OnInit(self)
  self:CacheAnimations()
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:OnShutdown()
  timingUtils:StopDelay(self)
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.burstIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadIn"
    })
    self.anim.burstOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      scaleX = 0,
      scaleY = 0,
      ease = "QuadOut"
    })
  end
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:ShowBoxOpeningItem(data)
  self.itemTable = nil
  if data.itemSlot then
    self.itemTable = StaticItemDataManager:GetTooltipDisplayInfo(data.itemSlot:GetItemDescriptor())
  end
  local nameText
  if self.itemTable then
    nameText = self.itemTable.displayName
  else
    nameText = data.isAzoth and self.azothName or self.currencyName
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.ItemNameText, nameText, eUiTextSet_SetLocalized)
  local itemNameTextHeight = UiTextBus.Event.GetTextHeight(self.Properties.ItemNameText)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.ItemNameText, itemNameTextHeight)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.SecondaryText, itemNameTextHeight + 25)
  local iconPath
  if data.itemSlot then
    iconPath = "LyShineUI/Images/Icons/Items_HiRes/" .. data.itemSlot:GetIconPath() .. ".dds"
  else
    iconPath = data.isAzoth and self.azothIconPath or self.currencyIconPath
  end
  UiImageBus.Event.SetSpritePathname(self.Properties.ItemIcon, iconPath)
  local isGold = not self.itemTable and not data.isAzoth
  if isGold then
    self.ScriptedEntityTweener:Set(self.Properties.ItemIcon, {scaleX = 0.5, scaleY = 0.5})
  else
    self.ScriptedEntityTweener:Set(self.Properties.ItemIcon, {scaleX = 1, scaleY = 1})
  end
  local nameTextColor = self.UIStyle.COLOR_WHITE
  local rarityColor = self.UIStyle.COLOR_RARITY_LEVEL_0
  UiElementBus.Event.SetIsEnabled(self.Properties.RarityText, self.itemTable and self.itemTable.usesRarity)
  local raritylevel = -1
  if self.itemTable and self.itemTable.usesRarity then
    raritylevel = self.itemTable.rarityLevel
    local raritySuffix = tostring(raritylevel)
    local displayName = "@RarityLevel" .. raritySuffix .. "_DisplayName"
    UiTextBus.Event.SetTextWithFlags(self.Properties.RarityText, displayName, eUiTextSet_SetLocalized)
    local rarityTextWidth = UiTextBus.Event.GetTextWidth(self.Properties.RarityText)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.RarityTextGlow, rarityTextWidth + 80)
    local basecolor = self.UIStyle[string.format("COLOR_RARITY_LEVEL_%s", raritySuffix)]
    local bgcolor = self.UIStyle[string.format("COLOR_RARITY_LEVEL_%s_BG", raritySuffix)]
    local lightcolor = self.UIStyle[string.format("COLOR_RARITY_LEVEL_%s_LIGHT", raritySuffix)]
    nameTextColor = lightcolor
    rarityColor = basecolor
    local backgroundImagePath = "LyShineUI/images/crafting/crafting_itemRarityBgLarge" .. raritySuffix .. ".dds"
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemBg, backgroundImagePath)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemBg, "LyShineUI/images/crafting/crafting_itemRarityBgLarge0.dds")
  end
  if self.itemTable and self.itemTable.tier then
    UiElementBus.Event.SetIsEnabled(self.Properties.ItemTier, true)
    UiTextBus.Event.SetText(self.Properties.ItemTier, GetRomanFromNumber(self.itemTable.tier))
  end
  UiTextBus.Event.SetColor(self.Properties.ItemNameText, nameTextColor)
  UiTextBus.Event.SetColor(self.Properties.RarityText, rarityColor)
  UiImageBus.Event.SetColor(self.Properties.RarityTextGlow, nameTextColor)
  UiImageBus.Event.SetColor(self.Properties.BackingGlow, rarityColor)
  local className
  local amount = -1
  if data.itemSlot then
    className = itemCommon:GetItemClassNameForSlot(data.itemSlot)
  end
  if className then
    UiElementBus.Event.SetIsEnabled(self.Properties.CategoryText, className ~= nil)
    UiTextBus.Event.SetTextWithFlags(self.Properties.CategoryText, className, eUiTextSet_SetLocalized)
  end
  local hasGearScore = self.itemTable and type(self.itemTable.gearScore) == "number" and self.itemTable.gearScore > 0
  UiElementBus.Event.SetIsEnabled(self.Properties.QuantityText, not hasGearScore)
  UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreLabelText, hasGearScore)
  if hasGearScore then
    UiTextBus.Event.SetTextWithFlags(self.Properties.GearScoreText, tostring(self.itemTable.gearScore), eUiTextSet_SetAsIs)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityTextGlow, true)
  else
    amount = (data.itemSlot or data.isAzoth) and data.quantity or GetLocalizedCurrency(data.quantity)
    local quantityText = GetLocalizedReplacementText("@ui_quantity_with_amount", {amount = amount})
    UiTextBus.Event.SetTextWithFlags(self.Properties.QuantityText, quantityText, eUiTextSet_SetAsIs)
  end
  local showdivider = hasGearScore
  UiElementBus.Event.SetIsEnabled(self.Properties.Divider, showdivider)
  UiElementBus.Event.SetIsEnabled(self.Properties.GearScoreLabelText, hasGearScore)
  UiElementBus.Event.SetIsEnabled(self.Properties.QuantityText, not hasGearScore)
  UiTransformBus.Event.SetLocalPosition(self.entityId, data.pos)
  UiTransformBus.Event.SetScale(self.entityId, Vector2(data.scale, data.scale))
  self:HideBoxOpeningItem()
  timingUtils:Delay(data.delay, self, function()
    self:SetVisibility(true, data, raritylevel, hasGearScore)
  end)
  return raritylevel
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:SetVisibility(isVisible, data, raritylevel, hasGearScore)
  if self.isVisible == isVisible then
    return
  end
  self.isVisible = isVisible
  UiElementBus.Event.SetIsEnabled(self.entityId, isVisible)
  self.ScriptedEntityTweener:Set(self.Properties.Container, {opacity = 0, x = 0})
  self.ScriptedEntityTweener:Set(self.Properties.FakeGlow, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TextContainer, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.ItemIcon, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.RarityBackground, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.BackingGlow, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.Divider, {opacity = 0, scaleX = 0})
  if raritylevel ~= nil and 1 <= raritylevel then
    local effectName = string.format("Rarity%s", raritylevel)
    local itemSound = string.format("BoxOpeningItem_%s", effectName)
    UiElementBus.Event.SetIsEnabled(self.Properties.RarityText, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.CategoryText, false)
    UiElementBus.Event.SetIsEnabled(self.Properties[effectName], true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties[effectName], 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties[effectName])
    self.audioHelper:PlaySound(self.audioHelper[itemSound])
    if 2 < raritylevel then
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityBackground, true)
      self.ScriptedEntityTweener:Play(self.Properties.RarityRune, 180, {rotation = 0}, {timesToPlay = -1, rotation = -359})
      self.ScriptedEntityTweener:PlayC(self.Properties.RarityBackground, 1, tweenerCommon.fadeInQuadOut, 1.25)
    end
  elseif raritylevel ~= nil and raritylevel < 1 then
    if hasGearScore then
      UiElementBus.Event.SetIsEnabled(self.Properties.CategoryText, false)
      UiElementBus.Event.SetIsEnabled(self.Properties.RarityText, true)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Rarity0, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.Rarity0, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.Rarity0)
    self.audioHelper:PlaySound(self.audioHelper.BoxOpeningItem_Rarity0)
  end
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ItemIconBg, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.ItemIconBg)
  self.ScriptedEntityTweener:PlayC(self.Properties.Container, 0.3, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.FakeGlow, 0.4, self.anim.burstIn, nil, function()
    self.ScriptedEntityTweener:Play(self.Properties.FakeGlow, 0.35, {opacity = 0, ease = "linear"})
  end)
  self.ScriptedEntityTweener:PlayC(self.Properties.ItemIcon, 0.25, tweenerCommon.fadeInQuadOut, 0.25)
  self.ScriptedEntityTweener:PlayC(self.Properties.TextContainer, 0.25, tweenerCommon.fadeInQuadOut, 0.3)
  self.ScriptedEntityTweener:PlayC(self.Properties.BackingGlow, 0.75, tweenerCommon.fadeInQuadOut, nil, function()
    self.ScriptedEntityTweener:Play(self.Properties.BackingGlow, 2.5, {opacity = 0, ease = "linear"})
  end)
  self.ScriptedEntityTweener:Play(self.Properties.Divider, 0.75, {scaleX = 0, opacity = 0}, {
    scaleX = 1,
    opacity = 1,
    ease = "QuadInOut"
  })
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:HideBoxOpeningItem()
  timingUtils:StopDelay(self)
  self:SetVisibility(false)
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:OnFocus()
  if self.itemTable then
    DynamicBus.TooltipsRequestBus.Broadcast.ShowTooltip(self.itemTable, self)
  end
end
function Inventory_BoxOpeningPopup_BoxOpeningItem:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
end
return Inventory_BoxOpeningPopup_BoxOpeningItem
