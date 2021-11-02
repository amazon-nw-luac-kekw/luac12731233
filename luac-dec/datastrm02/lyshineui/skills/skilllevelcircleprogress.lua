local SkillLevelCircleProgress = {
  Properties = {
    LevelValue = {
      default = EntityId()
    },
    LevelLabel = {
      default = EntityId()
    },
    CircleProgress = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    ScaleContainer = {
      default = EntityId()
    }
  },
  maxProgressFill = 0.99
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkillLevelCircleProgress)
function SkillLevelCircleProgress:OnInit()
  BaseElement.OnInit(self)
  self.defaultSize = UiTransform2dBus.Event.GetLocalHeight(self.Properties.ScaleContainer)
  self.defaultTextSize = UiTextBus.Event.GetFontSize(self.Properties.LevelValue)
  UiImageBus.Event.SetColor(self.Properties.CircleProgress, self.UIStyle.COLOR_TRADESKILL)
end
function SkillLevelCircleProgress:SetLevel(currentLevel)
  UiTextBus.Event.SetText(self.Properties.LevelValue, currentLevel)
end
function SkillLevelCircleProgress:SetProgress(progressPercent, force)
  if force then
    self.ScriptedEntityTweener:Set(self.Properties.CircleProgress, {
      imgFill = progressPercent * self.maxProgressFill
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, 0.5, {imgFill = 0}, {
      imgFill = progressPercent * self.maxProgressFill
    })
  end
end
function SkillLevelCircleProgress:PlayCraftingProgress(duration, fromLevel, fromProgress, toLevel, toProgress, levelUpCallback, levelUpCallingTable)
  self:SetLevel(fromLevel)
  if fromLevel ~= toLevel then
    self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, duration / 2, {
      imgFill = fromProgress * self.maxProgressFill
    }, {
      imgFill = self.maxProgressFill,
      onComplete = function()
        self:SetLevel(toLevel)
        if levelUpCallback and levelUpCallingTable then
          if type(levelUpCallback) == "function" then
            levelUpCallback(levelUpCallingTable)
          else
            levelUpCallingTable[levelUpCallback](levelUpCallingTable)
          end
        end
        self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, duration / 2, {imgFill = 0}, {
          imgFill = toProgress * self.maxProgressFill
        })
      end
    })
  else
    self.ScriptedEntityTweener:Play(self.Properties.CircleProgress, duration, {
      imgFill = fromProgress * self.maxProgressFill
    }, {
      imgFill = toProgress * self.maxProgressFill
    })
  end
end
function SkillLevelCircleProgress:SetIcon(iconPath)
  if iconPath ~= nil then
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, iconPath)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.Icon, false)
  end
end
function SkillLevelCircleProgress:SetSize(size)
  local scale = size ~= nil and size / self.defaultSize or 1
  UiTransformBus.Event.SetScale(self.Properties.ScaleContainer, Vector2(scale, scale))
end
function SkillLevelCircleProgress:SetTextSize(textSize)
  local scale = textSize ~= nil and textSize / self.defaultTextSize or 1
  UiTransformBus.Event.SetScale(self.Properties.LevelValue, Vector2(scale, scale))
end
return SkillLevelCircleProgress
