local StructureNavWheelItem = {
  Properties = {
    icon = {
      default = EntityId()
    },
    text = {
      default = EntityId()
    },
    bg = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(StructureNavWheelItem)
function StructureNavWheelItem:OnSelected()
  UiElementBus.Event.SetIsEnabled(self.bg, true)
  UiTextBus.Event.SetColor(self.text, self.UIStyle.COLOR_YELLOW)
  self.audioHelper:PlaySound(self.audioHelper.OnBuildModeScrollTier)
end
function StructureNavWheelItem:OnUnselected()
  UiElementBus.Event.SetIsEnabled(self.bg, false)
  UiTextBus.Event.SetColor(self.text, self.UIStyle.COLOR_WHITE)
end
function StructureNavWheelItem:SetData(data, radioGroupEntityId)
  self.data = data
  local blueprintImage = ItemDataManagerBus.Broadcast.GetIconPath(Math.CreateCrc32(data.resultItemId))
  UiImageBus.Event.SetSpritePathname(self.icon, "LyShineUI/Images/Icons/Items/Blueprint/" .. blueprintImage .. ".png")
  UiTextBus.Event.SetTextWithFlags(self.text, data.name, eUiTextSet_SetLocalized)
  UiRadioButtonGroupBus.Event.AddRadioButton(radioGroupEntityId, self.entityId)
end
return StructureNavWheelItem
