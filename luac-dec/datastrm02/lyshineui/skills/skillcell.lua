local SkillCell = {
  Properties = {
    SkillName = {
      default = EntityId()
    },
    SkillLevelCircleProgress = {
      default = EntityId()
    },
    Highlight = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkillCell)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function SkillCell:OnInit()
  BaseElement.OnInit(self)
  self.SkillLevelCircleProgress:SetSize(122)
  self.SkillLevelCircleProgress:SetTextSize(72)
  self.ScriptedEntityTweener:Set(self.Properties.Frame, {
    imgColor = self.UIStyle.COLOR_TAN
  })
  self.ScriptedEntityTweener:Set(self.Properties.SkillName, {
    color = self.UIStyle.COLOR_GRAY_80
  })
end
function SkillCell:SetSkillInfo(currentLevel, progressPercent)
  self.SkillLevelCircleProgress:SetLevel(currentLevel)
  self.SkillLevelCircleProgress:SetProgress(progressPercent)
end
function SkillCell:SetTableInfo(tableName, tableIndex)
  self.tableName = tableName
  self.tableIndex = tableIndex
end
function SkillCell:SetText(text)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SkillName, text, eUiTextSet_SetLocalized)
end
function SkillCell:SetIcon(iconPath)
  self.SkillLevelCircleProgress:SetIcon(iconPath)
end
function SkillCell:SetCallback(cbTable, cbFunc)
  self.cbTable = cbTable
  self.cbFunc = cbFunc
end
function SkillCell:OnClick()
  if self.cbTable and self.cbFunc then
    self.cbFunc(self.cbTable, self.tableName, self.tableIndex)
  end
  self.audioHelper:PlaySound(self.audioHelper.OnTradeSkillPress)
end
function SkillCell:OnFocus()
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_IN
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, animTime, tweenerCommon.imgToWhite)
  self.ScriptedEntityTweener:PlayC(self.Properties.SkillName, animTime, tweenerCommon.textToWhite)
  if not self.highlightTimeline then
    self.highlightTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.highlightTimeline:Add(self.Properties.Highlight, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.highlightTimeline:Play()
      end
    })
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, true)
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, animTime, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.Highlight, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
    opacity = 1,
    delay = animTime,
    onComplete = function()
      self.highlightTimeline:Play()
    end
  })
  self.audioHelper:PlaySound(self.audioHelper.OnTradeSkillHover)
end
function SkillCell:OnUnfocus()
  local animTime = self.UIStyle.DURATION_BUTTON_FADE_OUT
  self.ScriptedEntityTweener:PlayC(self.Properties.Frame, animTime, tweenerCommon.imgToTan)
  self.ScriptedEntityTweener:PlayC(self.Properties.SkillName, animTime, tweenerCommon.textToGray80)
  self.highlightTimeline:Stop()
  self.ScriptedEntityTweener:PlayC(self.Properties.Highlight, animTime, tweenerCommon.fadeOutQuadOut, nil, function()
    UiElementBus.Event.SetIsEnabled(self.Properties.Highlight, false)
  end)
end
return SkillCell
