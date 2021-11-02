local WoodyGridItem = {
  Properties = {
    Name = {
      default = EntityId()
    },
    Type = {
      default = EntityId()
    },
    Value = {
      default = EntityId()
    }
  },
  colors = {
    ColorRgba(66, 66, 66, 1),
    ColorRgba(77, 77, 77, 1),
    ColorRgba(66, 88, 66, 1),
    ColorRgba(77, 99, 77, 1)
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(WoodyGridItem)
function WoodyGridItem:OnInit()
  BaseElement.OnInit(self)
end
function WoodyGridItem:OnShutdown()
end
function WoodyGridItem:GetElementWidth()
  return UiLayoutCellBus.Event.GetTargetWidth(self.entityId)
end
function WoodyGridItem:GetElementHeight()
  return UiLayoutCellBus.Event.GetTargetHeight(self.entityId)
end
function WoodyGridItem:GetHorizontalSpacing()
  return 0
end
function WoodyGridItem:OnClicked()
  self.itemData.cb(self.itemData.context, self)
end
function WoodyGridItem:SetGridItemData(itemData)
  if not itemData then
    return
  end
  local colorIdx = itemData.index % 2 + 1
  if itemData.expandable then
    colorIdx = colorIdx + 2
  end
  UiImageBus.Event.SetColor(self.entityId, self.colors[colorIdx])
  self.itemData = itemData
  UiTextBus.Event.SetTextWithFlags(self.Properties.Name, itemData.name, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Type, itemData.varType, eUiTextSet_SetAsIs)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Value, itemData.value, eUiTextSet_SetAsIs)
end
return WoodyGridItem
