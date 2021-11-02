local CACItem = {
  Properties = {
    FaceImage = {
      default = EntityId()
    },
    ItemImage = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACItem)
function CACItem:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiCACImageBus, self.entityId)
end
function CACItem:SetCACImage(baseImage, itemImage)
  if self.Properties.FaceImage:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.FaceImage, baseImage)
  end
  if self.Properties.ItemImage:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemImage, itemImage)
  end
end
return CACItem
