local TutorialKeyBindingLine = {
  Properties = {
    Text = {
      default = EntityId()
    },
    KeyBindingsList = {
      default = EntityId()
    },
    KeyBindingFlash = {
      default = EntityId()
    }
  },
  isAnimating = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TutorialKeyBindingLine)
function TutorialKeyBindingLine:OnInit()
  BaseElement.OnInit(self)
  self.keyBindingList = self.registrar:GetEntityTable(self.Properties.KeyBindingsList)
  local textStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_SEMIBOLD,
    fontSize = 30,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.Text, textStyle)
end
function TutorialKeyBindingLine:SetLine(msgText, keyBindings)
  UiTextBus.Event.SetTextWithFlags(self.Properties.Text, msgText, eUiTextSet_SetLocalized)
  self.keyBindingList:SetupBindings(keyBindings)
end
function TutorialKeyBindingLine:SetFlashVisible(value)
  self.ScriptedEntityTweener:Stop(self.KeyBindingFlash)
  if value then
    local startingAlpha = self.isAnimating and 0.1 or 0
    local duration = self.isAnimating and 0.01 or 0.08
    self.isAnimating = true
    self.ScriptedEntityTweener:Play(self.KeyBindingFlash, duration, {opacity = startingAlpha}, {
      opacity = 0.6,
      ease = "QuadOut",
      delay = 0.12,
      onComplete = function()
        self:SetFlashVisible(false)
      end
    })
  else
    self.isAnimating = false
    self.ScriptedEntityTweener:Play(self.KeyBindingFlash, 0.05, {opacity = 0, ease = "QuadIn"})
  end
end
function TutorialKeyBindingLine:Clear()
  UiTextBus.Event.SetText(self.Properties.Text, "")
  self.keyBindingList:ClearKeyBindingEntities()
end
return TutorialKeyBindingLine
