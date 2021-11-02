local IngredientRowModifierV4 = {
  Properties = {
    ItemFocus = {
      default = EntityId()
    },
    Tooltip = {
      default = EntityId()
    },
    DisabledDarken = {
      default = EntityId()
    }
  },
  pressCallback = nil,
  pressTable = nil,
  isEnabled = true
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(IngredientRowModifierV4)
function IngredientRowModifierV4:OnInit()
  BaseElement.OnInit(self)
end
function IngredientRowModifierV4:SetCallback(command, table)
  self.pressCallback = command
  self.pressTable = table
end
function IngredientRowModifierV4:SetTooltip(value)
  self.Tooltip:SetSimpleTooltip(value)
end
function IngredientRowModifierV4:OnFocus()
  if self.timeline == nil then
    self.timeline = self.ScriptedEntityTweener:TimelineCreate()
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.45})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.timeline:Add(self.Properties.ItemFocus, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.timeline:Play()
      end
    })
  end
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
    onComplete = function()
      self.timeline:Play()
    end
  })
  self.Tooltip:OnTooltipSetterHoverStart()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Material_Hover)
end
function IngredientRowModifierV4:OnUnfocus()
  self.ScriptedEntityTweener:Play(self.Properties.ItemFocus, 0.3, {opacity = 0, ease = "QuadOut"})
  self.Tooltip:OnTooltipSetterHoverEnd()
end
function IngredientRowModifierV4:OnPress()
  if not self.isEnabled then
    return
  end
  if type(self.pressCallback) == "function" and self.pressTable ~= nil then
    self.pressCallback(self.pressTable)
  end
  self.Tooltip:OnTooltipSetterHoverEnd()
  self.audioHelper:PlaySound(self.audioHelper.Crafting_Item_Select)
end
function IngredientRowModifierV4:SetEnabled(isEnable)
  self.isEnabled = isEnable
  if self.isEnabled then
    self.ScriptedEntityTweener:Play(self.Properties.DisabledDarken, 0.3, {opacity = 0, ease = "QuadOut"})
  else
    self.ScriptedEntityTweener:Play(self.Properties.DisabledDarken, 0.3, {opacity = 0.6, ease = "QuadOut"})
  end
end
function IngredientRowModifierV4:OnShutdown()
  if self.timeline then
    self.timeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.timeline)
    self.timeline = nil
  end
end
return IngredientRowModifierV4
