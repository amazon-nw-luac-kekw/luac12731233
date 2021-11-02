local JournalGridPage = {
  Properties = {
    PageNumber = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    },
    Background = {
      default = EntityId()
    },
    NewHighlight = {
      default = EntityId()
    },
    TooltipSetter = {
      default = EntityId()
    }
  },
  userData = nil,
  pressCallback = nil,
  pressTable = nil
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(JournalGridPage)
function JournalGridPage:OnInit()
  BaseElement.OnInit(self)
  local numberStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_REGULAR,
    fontSize = 21,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.Properties.PageNumber, numberStyle)
end
function JournalGridPage:SetUserData(userData)
  self.userData = userData
  self:SetPrimaryText(tostring(self.userData.data.order))
  self:UpdateLockedTooltip()
  self.isActive = false
  self:UpdateVisuals(0)
  self:SetIsNew(not self.userData.locked and self.userData.isNew)
end
function JournalGridPage:UpdateLockedTooltip()
  if self.userData.locked then
    self.TooltipSetter:SetSimpleTooltip("@journal_undiscovered")
  else
    self.TooltipSetter:SetSimpleTooltip(self.userData.title)
  end
end
function JournalGridPage:GetUserData(userData)
  return self.userData
end
function JournalGridPage:SetPrimaryText(title)
  UiTextBus.Event.SetTextWithFlags(self.PageNumber, title, eUiTextSet_SetLocalized)
end
function JournalGridPage:OnHoverStart()
  if self.userData.locked then
    return
  end
  self.isHovered = true
  self:UpdateVisuals(0.3)
  self.TooltipSetter:OnTooltipSetterHoverStart()
end
function JournalGridPage:OnHoverEnd()
  if self.userData.locked then
    return
  end
  self.isHovered = false
  self:UpdateVisuals(0.3)
  self.TooltipSetter:OnTooltipSetterHoverEnd()
end
function JournalGridPage:OnClick()
  if self.pressCallback ~= nil and self.pressTable ~= nil and type(self.pressCallback) == "function" then
    self.pressCallback(self.pressTable, self.pressArg)
  end
end
function JournalGridPage:SetCallback(command, table, arg)
  self.pressCallback = command
  self.pressTable = table
  self.pressArg = arg
end
function JournalGridPage:SetActive(isActive)
  self.isActive = isActive
  self:UpdateVisuals(0.15)
end
function JournalGridPage:SetIsNew(isNew)
  self:UpdateLockedTooltip()
  self.isNew = isNew
  self.ScriptedEntityTweener:Play(self.Properties.NewHighlight, 0.3, {
    opacity = self.isNew and 1 or 0
  })
end
function JournalGridPage:UpdateVisuals(animTime)
  animTime = animTime or 0
  local bgColor = self.UIStyle.COLOR_WHITE
  local bgOpacity = 0.1
  local frontColor = self.UIStyle.COLOR_GRAY_80
  if self.userData.locked then
    bgColor = self.UIStyle.COLOR_BLACK
    bgOpacity = 0.4
    frontColor = self.UIStyle.COLOR_TAN_DARK
  elseif self.isHovered or self.isActive then
    bgOpacity = 0.25
    frontColor = self.UIStyle.COLOR_WHITE
  end
  self.ScriptedEntityTweener:Play(self.Properties.Background, animTime, {
    imgColor = bgColor,
    opacity = bgOpacity,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.PageNumber, animTime, {textColor = frontColor, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Frame, animTime, {imgColor = frontColor, ease = "QuadOut"})
  local scale = self.isActive and 1.2 or 1
  self.ScriptedEntityTweener:Play(self.entityId, animTime, {
    scaleX = scale,
    scaleY = scale,
    ease = "QuadOut"
  })
end
return JournalGridPage
