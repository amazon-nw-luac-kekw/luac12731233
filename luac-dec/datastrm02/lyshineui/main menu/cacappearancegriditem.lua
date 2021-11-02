local CACAppearanceGridItem = {
  Properties = {
    ButtonFocus = {
      default = EntityId()
    },
    FaceImage = {
      default = EntityId()
    },
    ItemImage = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(CACAppearanceGridItem)
function CACAppearanceGridItem:OnInit()
  BaseElement.OnInit(self)
  self:BusConnect(UiCACImageBus, self.entityId)
end
function CACAppearanceGridItem:SetCACImage(baseImage, itemImage)
  if self.Properties.FaceImage:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.FaceImage, baseImage)
  end
  if self.Properties.ItemImage:IsValid() then
    UiImageBus.Event.SetSpritePathname(self.Properties.ItemImage, itemImage)
  end
end
function CACAppearanceGridItem:OnFocus()
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.ButtonFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ButtonFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnAppearenceGridHover)
end
function CACAppearanceGridItem:OnUnfocus()
  local isSelectedState = UiRadioButtonBus.Event.GetState(self.entityId)
  if isSelectedState == true then
    self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8})
  else
    self:OnUnselected()
  end
end
function CACAppearanceGridItem:OnSelected(suppressSound)
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0.8, ease = "QuadIn"})
  if suppressSound ~= true then
    self.audioHelper:PlaySound(self.audioHelper.FrontEnd_OnAppearenceGridPress)
  end
end
function CACAppearanceGridItem:OnUnselected()
  self.ScriptedEntityTweener:Play(self.ButtonFocus, 0.15, {opacity = 0, ease = "QuadIn"})
end
function CACAppearanceGridItem:OnShutdown()
  if self.timeline ~= nil then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
  end
end
return CACAppearanceGridItem
