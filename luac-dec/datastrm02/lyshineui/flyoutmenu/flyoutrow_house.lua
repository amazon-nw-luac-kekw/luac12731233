local FlyoutRow_House = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Image = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FlyoutRow_House)
function FlyoutRow_House:OnInit()
  BaseElement.OnInit(self)
  self.initialHeight = UiTransform2dBus.Event.GetLocalHeight(self.entityId)
end
function FlyoutRow_House:SetData(data)
  if not data or not data.text then
    Log("[FlyoutRow_House] Error: invalid data passed to SetData")
    return
  end
  local locFlag = eUiTextSet_SetLocalized
  if data.skipLocalization then
    locFlag = eUiTextSet_SetAsIs
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, data.text, locFlag)
  if data.image then
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, data.image)
  else
    UiImageBus.Event.SetSpritePathname(self.Properties.Image, "lyshineui/images/map/tooltipImages/mapTooltip_house_default.dds")
  end
  local height = data.height or self.initialHeight
  UiTransform2dBus.Event.SetLocalHeight(self.entityId, height)
  UiLayoutCellBus.Event.SetTargetHeight(self.entityId, height)
end
return FlyoutRow_House
