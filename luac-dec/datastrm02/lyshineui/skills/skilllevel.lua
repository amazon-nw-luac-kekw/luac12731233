local SkillLevel = {
  Properties = {
    Text = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    HoverIcon = {
      default = EntityId()
    }
  },
  levelStyles = {
    milestone = {
      acquired = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNodeMilestone_aquired.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(84, 78, 66, 1)
      },
      pending = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNodeMilestone_aquired.png",
        iconColor = ColorRgba(122, 199, 123, 1),
        textColor = ColorRgba(84, 78, 66, 1)
      },
      available = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNodeMilestone_available.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(158, 148, 126, 1)
      },
      unavailable = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNodeMilestone_unavailable.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(158, 148, 126, 1)
      }
    },
    normal = {
      acquired = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNode_aquired.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(84, 78, 66, 1)
      },
      pending = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNode_aquired.png",
        iconColor = ColorRgba(122, 199, 123, 1),
        textColor = ColorRgba(84, 78, 66, 1)
      },
      available = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNode_available.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(158, 148, 126, 1)
      },
      unavailable = {
        iconPath = "LyShineUI/Images/Skills/buttonSkillNode_unavailable.png",
        iconColor = ColorRgba(255, 255, 255, 1),
        textColor = ColorRgba(158, 148, 126, 1)
      }
    }
  },
  levelStates = {
    acquired = "acquired",
    pending = "pending",
    available = "available",
    unavailable = "unavailable"
  },
  levelType = "normal",
  levelState = "unavailable",
  rootDataPath = "Hud.LocalPlayer.Tradeskills",
  unspentPoints = 0,
  pendingValue = 0,
  spentValue = 0,
  lockedInSpent = 0,
  totalPending = 0,
  totalAvailable = 0
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(SkillLevel)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
function SkillLevel:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  self.hoverTimeline = {}
end
function SkillLevel:SetData(data)
  self.levelData = {}
  self.levelData.enum = data.enum
  self.levelData.itemIndex = data.itemIndex
  self.levelData.skillName = data.name
  self.levelData.skillDataPath = self.rootDataPath .. "." .. tostring(self.levelData.skillName)
  self.levelData.itemIndexDataPath = self.levelData.skillDataPath .. "." .. tostring(self.levelData.itemIndex)
  self:SetText(self.levelData.itemIndex)
  self:RegisterObservers()
end
function SkillLevel:SetUnspentPoints(data)
  if data ~= nil then
    self.unspentPoints = data
    self:UpdateLevel()
  end
end
function SkillLevel:SetPendingValue(data)
  if data ~= nil then
    self.pendingValue = data
    self:UpdateLevel()
  end
end
function SkillLevel:SetSpentValue(data)
  if data ~= nil then
    self.spentValue = data
    self:UpdateLevel()
  end
end
function SkillLevel:UpdateLevel()
  self.totalPending = self.spentValue + self.pendingValue
  self.totalAvailable = self.totalPending + self.unspentPoints
  if self.levelData.itemIndex <= self.spentValue then
    self:SetLevelState(self.levelStates.acquired)
  elseif self.levelData.itemIndex <= self.totalPending then
    self:SetLevelState(self.levelStates.pending)
  elseif self.levelData.itemIndex <= self.totalAvailable then
    self:SetLevelState(self.levelStates.available)
  else
    self:SetLevelState(self.levelStates.unavailable)
  end
end
function SkillLevel:SetIsMilestone(data)
  self.isMilestone = data == 1
  self.levelType = self.isMilestone and "milestone" or "normal"
  self:UpdateStyle()
end
function SkillLevel:SetTooltip(data)
  self.Icon:SetSimpleTooltip(data)
end
function SkillLevel:SetText(text)
  UiTextBus.Event.SetText(self.Text, tostring(text))
end
function SkillLevel:SetLevelState(newState)
  if newState == self.levelState then
    return
  end
  self.levelState = newState
  self:UpdateStyle()
end
function SkillLevel:UpdateStyle()
  local styleData = self.levelStyles[self.levelType][self.levelState]
  UiImageBus.Event.SetSpritePathname(self.Icon.entityId, styleData.iconPath)
  UiImageBus.Event.SetColor(self.Icon.entityId, styleData.iconColor)
  UiTextBus.Event.SetColor(self.Text, styleData.textColor)
end
function SkillLevel:OnSkillLevelUnfocus(entityId, actionName)
  self.Icon:OnTooltipSetterHoverEnd()
  if self.levelState == self.levelStates.pending or self.levelState == self.levelStates.available then
    self.hoverTimeline:Stop()
    self.ScriptedEntityTweener:TimelineDestroy(self.hoverTimeline)
  end
  self.ScriptedEntityTweener:Play(self.HoverIcon.entityId, 0.15, {opacity = 0, ease = "QuadIn"})
end
function SkillLevel:OnSkillLevelFocus()
  self.Icon:OnTooltipSetterHoverStart()
  if self.levelState == self.levelStates.pending or self.levelState == self.levelStates.available then
    self.hoverTimeline = self.ScriptedEntityTweener:TimelineCreate()
    self.hoverTimeline:Add(self.HoverIcon.entityId, self.UIStyle.DURATION_TIMELINE_FADE_OUT, {opacity = 0.6})
    self.hoverTimeline:Add(self.HoverIcon.entityId, self.UIStyle.DURATION_TIMELINE_FADE_IN, {opacity = 1})
    self.hoverTimeline:Add(self.HoverIcon.entityId, self.UIStyle.DURATION_TIMELINE_HOLD, {
      opacity = 1,
      onComplete = function()
        self.hoverTimeline:Play()
      end
    })
    self.ScriptedEntityTweener:Play(self.HoverIcon.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN, {opacity = 1, ease = "QuadOut"})
    self.ScriptedEntityTweener:Play(self.HoverIcon.entityId, self.UIStyle.DURATION_BUTTON_FADE_IN_HOLD, {
      opacity = 1,
      delay = self.UIStyle.DURATION_BUTTON_FADE_IN,
      onComplete = function()
        self.hoverTimeline:Play()
      end
    })
    self.audioHelper:PlaySound(self.audioHelper.OnHover)
  end
end
function SkillLevel:OnSkillLevelClick()
  if self.levelState == self.levelStates.pending then
    self:DecrementSkill()
    self.audioHelper:PlaySound(self.audioHelper.OnTradeSkillPress)
  elseif self.levelState == self.levelStates.available then
    self:IncrementSkill()
    self.audioHelper:PlaySound(self.audioHelper.OnTradeSkillPress)
  end
end
function SkillLevel:IncrementSkill()
end
function SkillLevel:DecrementSkill()
end
function SkillLevel:RegisterObservers()
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, data)
    self.playerEntityId = data
  end)
  if not self.levelData then
    return
  end
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.levelData.skillDataPath .. ".Spent", self.SetSpentValue)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.levelData.itemIndexDataPath .. ".IsMilestone", self.SetIsMilestone)
  self.dataLayer:RegisterAndExecuteDataObserver(self, self.levelData.itemIndexDataPath .. ".Tooltip", self.SetTooltip)
end
function SkillLevel:UnregisterObservers()
  self.dataLayer:UnregisterObservers()
end
function SkillLevel:OnShutdown()
  self:UnregisterObservers()
end
return SkillLevel
