local PurchasePopupGridItem = {
  Properties = {
    ListItemBg = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    Type = {
      default = EntityId()
    },
    Description = {
      default = EntityId()
    },
    ReceivedFrom = {
      default = EntityId()
    },
    NewItemText = {
      default = EntityId()
    }
  }
}
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(PurchasePopupGridItem)
function PurchasePopupGridItem:OnInit()
  BaseElement.OnInit(self)
  SetTextStyle(self.Properties.Type, self.UIStyle.FONT_STYLE_LIST_ITEM)
  SetTextStyle(self.Properties.Description, self.UIStyle.FONT_STYLE_LIST_ITEM)
  SetTextStyle(self.Properties.ReceivedFrom, self.UIStyle.FONT_STYLE_LIST_ITEM)
  SetTextStyle(self.Properties.NewItemText, self.UIStyle.FONT_STYLE_NEW_PURCHASE_INDICATOR)
end
function PurchasePopupGridItem:OnShutdown()
end
function PurchasePopupGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function PurchasePopupGridItem:SetBackground(path)
  UiImageBus.Event.SetSpritePathname(self.entityId, path)
end
function PurchasePopupGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function PurchasePopupGridItem:GetHorizontalSpacing()
  return 0
end
function PurchasePopupGridItem:SetGridItemData(itemData)
  if not itemData then
    return
  end
  self.ListItemBg:SetIndex(itemData.index)
  self.ListItemBg:SetListItemStyle(self.ListItemBg.LIST_ITEM_STYLE_ZEBRA)
  self.ListItemBg:SetFocusGlowEnabled(false)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, itemData.displayInfo.spritePath)
  UiImageBus.Event.SetColor(self.Properties.Icon, itemData.displayInfo.spriteColor)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Type, itemData.displayInfo.typeString, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Description, itemData.displayInfo.itemDescription, eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.NewItemText, itemData.isNew)
  if self.Properties.ReceivedFrom:IsValid() then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ReceivedFrom, itemData.grantedBy, eUiTextSet_SetAsIs)
  end
end
return PurchasePopupGridItem
