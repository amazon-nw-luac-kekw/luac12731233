local OutpostRushResource = {
  Properties = {
    Icon = {
      default = EntityId()
    },
    Value = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyshineUI._Common.BaseElement")
BaseElement:CreateNewElement(OutpostRushResource)
function OutpostRushResource:OnInit()
  BaseElement.OnInit(self)
end
function OutpostRushResource:SetItem(data)
  UiImageBus.Event.SetSpritePathname(self.Properties.Icon, "lyshineui/images/icons/items/" .. data.staticItemData.itemType .. "/" .. data.staticItemData.icon .. ".dds")
end
function OutpostRushResource:UpdateCount(value)
  UiTextBus.Event.SetText(self.Properties.Value, tostring(value))
end
return OutpostRushResource
