local OrderHistoryGridItem = {
  Properties = {
    Background = {
      default = EntityId(),
      order = 1
    },
    Name = {
      default = EntityId()
    },
    Type = {
      default = EntityId()
    },
    Date = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Amount = {
      default = EntityId()
    },
    CurrencyIcon = {
      default = EntityId()
    },
    Hover = {
      default = EntityId()
    },
    QuestionMark = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(OrderHistoryGridItem)
function OrderHistoryGridItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Name, self.UIStyle.FONT_STYLE_STORE_ITEM_TITLE_SMALL)
  SetTextStyle(self.Properties.Type, self.UIStyle.FONT_STYLE_STORE_REWARD_INFO)
  SetTextStyle(self.Properties.Amount, self.UIStyle.FONT_STYLE_STORE_DISCOUNT_TEXT)
  self.Background:SetListItemStyle(self.Background.LIST_ITEM_STYLE_ZEBRA)
  self.currencyIconWidth = UiTransform2dBus.Event.GetLocalWidth(self.Properties.CurrencyIcon)
  self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
  self.QuestionMark:SetSize(30)
end
function OrderHistoryGridItem:OnShutdown()
end
function OrderHistoryGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function OrderHistoryGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function OrderHistoryGridItem:GetHorizontalSpacing()
  return 21
end
function OrderHistoryGridItem:OnClicked()
  self.itemData.cb(self.itemData.cbContext, self)
end
function OrderHistoryGridItem:SetGridItemData(itemData)
  self.itemData = itemData
  UiElementBus.Event.SetIsEnabled(self.entityId, self.itemData ~= nil)
  if not itemData then
    return
  end
  self.itemData = itemData
  if itemData.isSelected then
    self.selected = true
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 1})
  else
    self.ScriptedEntityTweener:Set(self.Properties.Hover, {opacity = 0})
    self.selected = false
  end
  self:SetBgIndex(itemData.index)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, self.itemData.name, eUiTextSet_SetLocalized)
  if self.itemData.date then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Date, self.itemData.date, eUiTextSet_SetAsIs)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Date, self.itemData.date ~= nil)
  if self.itemData.amount then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Amount, self.itemData.amount, eUiTextSet_SetLocalized)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Amount, self.itemData.amount ~= nil)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, self.itemData.spritePath)
  if self.itemData.type == nil or self.itemData.type == "" then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Type, "@ui_type_none", eUiTextSet_SetLocalized)
    UiElementBus.Event.SetIsEnabled(self.Properties.Type, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, false)
  else
    if self.itemData.isBundle then
      UiTextBus.Event.SetTextWithFlags(self.Properties.Type, self.itemData.isExpanded and "@ui_collapse_bundle" or "@ui_expand_bundle", eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, false)
    else
      UiTextBus.Event.SetTextWithFlags(self.Properties.Type, self.itemData.type, eUiTextSet_SetLocalized)
      UiElementBus.Event.SetIsEnabled(self.Properties.QuestionMark, true)
      self.QuestionMark:SetTooltip(self.itemData.tooltip)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.Type, true)
  end
  if self.itemData.isBundleItem then
    self.isEnabled = false
  else
    self.isEnabled = true
  end
  if self.itemData.showMarksOfFortuneIcon then
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrencyIcon, self.currencyIconWidth)
  else
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.CurrencyIcon, 0)
  end
end
function OrderHistoryGridItem:OnFocus()
  if not self.isEnabled then
    return
  end
  self.audioHelper:PlaySound(self.audioHelper.OnHover_ItemDraggable)
  self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.2, {opacity = 1})
  if type(self.itemData.cbHoverBegin) == "function" and self.itemData.cbContext ~= nil then
    self.itemData.cbHoverBegin(self.itemData.cbContext, self.itemData)
  end
end
function OrderHistoryGridItem:OnUnfocus()
  DynamicBus.TooltipsRequestBus.Broadcast.HideTooltip()
  if not self.selected then
    if type(self.unfocusCallback) == "function" and self.unfocusCallbackTable ~= nil then
      self.unfocusCallback(self.unfocusCallbackTable, self)
    end
    self.ScriptedEntityTweener:Play(self.Properties.Hover, 0.1, {opacity = 0})
    if type(self.itemData.cbHoverEnd) == "function" and self.itemData.cbContext ~= nil then
      self.itemData.cbHoverEnd(self.itemData.cbContext, self.itemData)
    end
  end
  if self.timeline ~= nil then
    self.timeline:Stop()
  end
end
function OrderHistoryGridItem:OnPress()
  if self.itemData.productId and self.itemData.isBundle then
    DynamicBus.OrderHistoryPopup.Broadcast.SetProductExpanded(self.itemData.productId, not self.itemData.isExpanded)
  end
end
function OrderHistoryGridItem:SetBackgroundEnabled(enabled)
  UiElementBus.Event.SetIsEnabled(self.Properties.Background, enabled)
end
function OrderHistoryGridItem:SetBgIndex(index)
  self.Background:SetIndex(index)
  self.Background:SetZebraOpacity(0.5)
  self.Background:SetListItemStyle(self.Background.LIST_ITEM_STYLE_ZEBRA)
end
return OrderHistoryGridItem
