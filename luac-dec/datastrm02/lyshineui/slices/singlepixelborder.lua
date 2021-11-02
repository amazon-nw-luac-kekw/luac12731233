local SinglePixelBorder = {
  Properties = {
    TopBorder = {
      default = EntityId()
    },
    RightBorder = {
      default = EntityId()
    },
    BottomBorder = {
      default = EntityId()
    },
    LeftBorder = {
      default = EntityId()
    }
  },
  borderColor = false,
  borderSize = 1
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SinglePixelBorder)
function SinglePixelBorder:OnInit()
  BaseElement.OnInit(self)
  self.borderColor = self.UIStyle.COLOR_WHITE
end
function SinglePixelBorder:SetBorder(color, size)
  if color then
    self.borderColor = color
  end
  UiImageBus.Event.SetColor(self.Properties.TopBorder, self.borderColor)
  UiImageBus.Event.SetColor(self.Properties.RightBorder, self.borderColor)
  UiImageBus.Event.SetColor(self.Properties.BottomBorder, self.borderColor)
  UiImageBus.Event.SetColor(self.Properties.LeftBorder, self.borderColor)
  if size then
    self.borderSize = size
  end
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.TopBorder, self.borderSize)
  UiTransform2dBus.Event.SetLocalHeight(self.Properties.BottomBorder, self.borderSize)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LeftBorder, self.borderSize * 0.75)
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.RightBorder, self.borderSize * 0.75)
end
function SinglePixelBorder:ResetBorder()
  self.borderSize = 1
  self:SetBorder(self.UIStyle.COLOR_WHITE, self.borderSize)
end
return SinglePixelBorder
