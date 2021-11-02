local CaptionedImage = {
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
BaseElement:CreateNewElement(CaptionedImage)
function CaptionedImage:OnInit()
  BaseElement.OnInit(self)
end
function CaptionedImage:Setup(text, image)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, text, eUiTextSet_SetLocalized)
  UiImageBus.Event.SetSpritePathname(self.Properties.Image, image)
end
return CaptionedImage
