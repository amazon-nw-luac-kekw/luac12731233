local FlyoutRow_FactionReputationBarRankIcon = {
  Properties = {
    ContentContainer = {
      default = EntityId()
    },
    RankName = {
      default = EntityId()
    },
    RankCostLabel = {
      default = EntityId()
    },
    RankIcon = {
      default = EntityId()
    },
    NewShopItemsLabel = {
      default = EntityId()
    }
  }
}
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_FactionReputationBarRankIcon)
function FlyoutRow_FactionReputationBarRankIcon:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.RankName, self.UIStyle.FONT_STYLE_PRIMARY_TITLE)
  SetTextStyle(self.Properties.RankCostLabel, self.UIStyle.FONT_STYLE_BODY_NEW)
  SetTextStyle(self.Properties.NewShopItemsLabel, self.UIStyle.FONT_STYLE_BODY_NEW)
end
function FlyoutRow_FactionReputationBarRankIcon:SetData(data)
  if not data then
    Log("[FlyoutRow_FactionReputationBarRankIcon] Error: invalid data passed to SetData")
    return
  end
  local containerHeight = 74
  UiTextBus.Event.SetTextWithFlags(self.Properties.RankName, data.rankName, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetColor(self.Properties.RankName, data.rankNameColor)
  UiImageBus.Event.SetSpritePathname(self.Properties.RankIcon, data.rankIcon)
  UiImageBus.Event.SetColor(self.Properties.RankIcon, data.rankIconColor)
  UiTextBus.Event.SetText(self.Properties.RankCostLabel, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_guildreputation_name", GetFormattedNumber(data.reputationCost)))
  if data.reputationCost and data.reputationCost > 0 then
    UiElementBus.Event.SetIsEnabled(self.Properties.NewShopItemsLabel, true)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.NewShopItemsLabel, self.UIStyle.FONT_STYLE_BODY_NEW.fontSize)
    containerHeight = containerHeight + self.UIStyle.FONT_STYLE_BODY_NEW.fontSize + 12
    UiTextBus.Event.SetText(self.Properties.NewShopItemsLabel, LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement("@owg_newshopitems", GetFormattedNumber(data.numShopItems)))
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.NewShopItemsLabel, false)
    UiLayoutCellBus.Event.SetTargetHeight(self.Properties.NewShopItemsLabel, 0)
  end
  local containerWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.ContentContainer)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, containerHeight)
  UiLayoutCellBus.Event.SetTargetWidth(self.entityId, containerWidth)
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, containerHeight)
  UiTransform2dBus.Event.SetLocalWidth(self.entityId, containerWidth)
end
return FlyoutRow_FactionReputationBarRankIcon
