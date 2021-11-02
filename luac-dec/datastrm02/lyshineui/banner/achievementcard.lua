local AchievementCard = {
  Properties = {
    MainContainer = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    },
    SubjectText = {
      default = EntityId()
    },
    ScratchOutLine = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    PromptText = {
      default = EntityId()
    },
    PromptHint = {
      default = EntityId()
    },
    IconContainer = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    IconMask = {
      default = EntityId()
    },
    AdditionalTextLeft = {
      default = EntityId()
    },
    AdditionalTextRight = {
      default = EntityId()
    },
    AdditionalTextSeparator = {
      default = EntityId()
    },
    IconTextLeft = {
      default = EntityId()
    },
    IconTextRight = {
      default = EntityId()
    },
    DungeonLevel = {
      default = EntityId()
    },
    DifficultiesContainer = {
      default = EntityId()
    },
    DifficultiesBg = {
      default = EntityId()
    },
    DifficultyItems = {
      default = {
        EntityId()
      }
    },
    RewardsContainer = {
      default = EntityId()
    },
    RewardEntries = {
      default = {
        EntityId()
      }
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    Glow = {
      default = EntityId()
    },
    SequenceFire = {
      default = EntityId(),
      order = 1
    },
    LineGlow = {
      default = EntityId()
    },
    ConditionalBackdrop = {
      default = EntityId()
    }
  },
  darknessEvent = false,
  shouldPlayGlow = false,
  shouldShowPrompt = false,
  shouldShowIcon = false,
  shouldShowIconSequence = false,
  playedAnimation = false,
  hasRewards = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(AchievementCard)
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local ObjectiveDataHelper = RequireScript("LyShineUI.Objectives.ObjectiveDataHelper")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function AchievementCard:OnInit()
  BaseElement.OnInit(self)
  self.initialTitlePosY = UiTransformBus.Event.GetLocalPositionY(self.Properties.TitleText)
  self:CacheAnimations()
  SetTextStyle(self.Properties.PromptText, self.UIStyle.FONT_STYLE_ACHIEVEMENT_CARD_PROMPT)
end
function AchievementCard:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      textCharacterSpace = 700,
      opacity = 0,
      ease = "QuadOut"
    })
    self.anim.showLineIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 1,
      opacity = 1,
      ease = "QuadIn"
    })
    self.anim.lineGlowIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      ease = "QuadInOut"
    })
    self.anim.lineGlowOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      scaleX = 0.6,
      scaleY = 0,
      opacity = 0,
      imgColor = self.UIStyle.COLOR_YELLOW,
      ease = "QuadInOut"
    })
    self.anim.subjectTextScratch = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      textColor = self.UIStyle.COLOR_TAN_DARK,
      ease = "QuadInOut"
    })
    self.anim.scratchOutLineIn = self.ScriptedEntityTweener:CacheAnimation(0.2, {imgFill = 1, ease = "CubicOut"})
    self.anim.iconMaskOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {y = 180, ease = "QuadOut"})
    self.anim.difficultiesBgOut = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      scaleX = 0.5,
      ease = "QuadIn"
    })
  end
end
function AchievementCard:UpdateRow(rowStyle, data)
  if data.darkness then
    UiElementBus.Event.SetIsEnabled(self.Properties.Glow, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFire, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, false)
    UiImageBus.Event.SetColor(self.Properties.Glow, self.UIStyle.COLOR_BANNER_GLOW_RED)
    UiTextBus.Event.SetColor(self.Properties.TitleText, self.UIStyle.COLOR_RED_LIGHT)
    self.darknessEvent = true
  end
  local bgColor = data.bgColor or self.UIStyle.COLOR_BLACK
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, data.title, eUiTextSet_SetLocalized)
  UiTextBus.Event.SetTextWithFlags(self.Properties.SubjectText, data.subject, eUiTextSet_SetLocalized)
  local hasAdditionalText = data.additionalTextData ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalTextLeft, hasAdditionalText)
  UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalTextRight, hasAdditionalText)
  UiElementBus.Event.SetIsEnabled(self.Properties.AdditionalTextSeparator, hasAdditionalText)
  if hasAdditionalText then
    local leftColor = data.additionalTextData.leftColor and data.additionalTextData.leftColor or self.UIStyle.COLOR_WHITE
    local rightColor = data.additionalTextData.rightColor and data.additionalTextData.rightColor or self.UIStyle.COLOR_WHITE
    local leftIconPath = data.additionalTextData.leftIconPath .. data.additionalTextData.leftText .. ".png"
    UiElementBus.Event.SetIsEnabled(self.Properties.IconTextLeft, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.IconTextLeft, leftIconPath)
    UiImageBus.Event.SetColor(self.Properties.IconTextLeft, leftColor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AdditionalTextLeft, data.additionalTextData.leftText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.AdditionalTextLeft, leftColor)
    UiTextBus.Event.SetTextWithFlags(self.Properties.AdditionalTextRight, data.additionalTextData.rightText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetColor(self.Properties.AdditionalTextRight, rightColor)
    if data.additionalTextData.rightText and data.additionalTextData.dungeonLevel then
      local initialRightTextPosX = UiTransformBus.Event.GetLocalPositionX(self.Properties.AdditionalTextRight)
      local rightIconOffset = 30
      UiTransformBus.Event.SetLocalPositionX(self.Properties.AdditionalTextRight, initialRightTextPosX + rightIconOffset)
      UiElementBus.Event.SetIsEnabled(self.Properties.IconTextRight, true)
      UiTextBus.Event.SetText(self.Properties.DungeonLevel, data.additionalTextData.dungeonLevel)
    else
      UiElementBus.Event.SetIsEnabled(self.Properties.IconTextRight, false)
    end
  end
  local titleOffset = hasAdditionalText and -25 or 0
  UiTransformBus.Event.SetLocalPositionY(self.Properties.TitleText, self.initialTitlePosY + titleOffset)
  local titleColor = data.titleColor or self.UIStyle.COLOR_WHITE
  UiTextBus.Event.SetColor(self.Properties.TitleText, titleColor)
  if data.prompt and data.promptAction then
    self.shouldShowPrompt = true
    UiTextBus.Event.SetTextWithFlags(self.Properties.PromptText, data.prompt, eUiTextSet_SetLocalized)
    if data.promptActionMap then
      self.PromptHint:SetActionMap(data.promptActionMap)
    end
    self.PromptHint:SetKeybindMapping(data.promptAction)
    if data.promptHighlight then
      self.PromptHint:SetHighlightVisible(data.promptHighlight)
    end
    if data.subject == "" then
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PromptText, 25)
    else
      UiTransformBus.Event.SetLocalPositionY(self.Properties.PromptText, 55)
    end
  else
    self.shouldShowPrompt = false
    UiTransformBus.Event.SetLocalPositionY(self.Properties.PromptText, 55)
  end
  if data.icon and data.icon ~= "" then
    self.shouldShowIcon = true
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, data.icon)
    local iconScale = data.iconScale or 1
    UiTransformBus.Event.SetScale(self.Properties.IconContainer, Vector2(iconScale, iconScale))
    if data.iconColor then
      UiImageBus.Event.SetColor(self.Properties.Icon, data.iconColor)
    end
  else
    self.shouldShowIcon = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DifficultiesContainer, false)
  if data.difficultyData and 0 < #data.difficultyData then
    local difficultyItemsShowing = 0
    local curX = 0
    local margin = 36
    local allMet = true
    for i = 0, #self.DifficultyItems do
      local difficultyItem = self.DifficultyItems[i]
      local difficultyItemData = data.difficultyData[i + 1]
      if difficultyItemData then
        UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyItems[i], true)
        UiTransformBus.Event.SetLocalPositionX(self.Properties.DifficultyItems[i], curX)
        if difficultyItemData.minGroupSize and 1 < difficultyItemData.minGroupSize then
          local memberCount = math.max(1, self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Group.MemberCount") or 1)
          difficultyItemData.isMet = memberCount >= difficultyItemData.minGroupSize
        end
        if difficultyItemData.minLevel and 0 < difficultyItemData.minLevel then
          local playerLevel = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Progression.Level")
          difficultyItemData.isMet = playerLevel >= difficultyItemData.minLevel
        end
        difficultyItem:SetText(difficultyItemData.text)
        difficultyItem:SetIsMet(difficultyItemData.isMet)
        difficultyItemsShowing = difficultyItemsShowing + 1
        curX = curX + margin + difficultyItem:GetWidth()
        if not difficultyItemData.isMet then
          allMet = false
        end
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.DifficultyItems[i], false)
      end
    end
    if not self.darknessEvent then
      UiImageBus.Event.SetColor(self.Properties.DifficultiesBg, allMet and self.UIStyle.COLOR_GRAY_60 or self.UIStyle.COLOR_RED_DARKER)
    end
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.DifficultiesContainer, curX - margin)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.DifficultiesContainer, -1 * (curX - margin) / 2)
    self.difficultiesToShow = difficultyItemsShowing
    self.shouldShowDifficulties = true
  else
    self.shouldShowDifficulties = false
  end
  self.hasRewards = data.rewards ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.RewardsContainer, self.hasRewards)
  if self.hasRewards then
    local numRewards = #data.rewards
    for i = 0, #self.RewardEntries do
      if numRewards >= i + 1 then
        local itemId = data.rewards[i + 1]
        local rewardEntry = self.RewardEntries[i]
        rewardEntry:SetDungeonRewardEntry(itemId, true)
        UiLayoutCellBus.Event.SetTargetWidth(self.Properties.RewardEntries[i], 64)
        UiElementBus.Event.SetIsEnabled(self.Properties.RewardEntries[i], true)
      else
        UiLayoutCellBus.Event.SetTargetWidth(self.Properties.RewardEntries[i], 0)
        UiElementBus.Event.SetIsEnabled(self.Properties.RewardEntries[i], false)
      end
    end
    local titleTextStyle = {fontSize = 32}
    local subjectTextStyle = {
      fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
      textCasing = self.UIStyle.TEXT_CASING_NORMAL,
      characterSpacing = 0
    }
    SetTextStyle(self.Properties.TitleText, titleTextStyle)
    SetTextStyle(self.Properties.SubjectText, subjectTextStyle)
  end
  self.shouldPlayGlow = data.shouldPlayGlow or self.hasRewards or false
  self.shouldPlayScratch = data.scratchOutSubject or false
  self.sound = data.sound or self.audioHelper.Banner_Achievement
end
function AchievementCard:TransitionIn()
  local currentState = LyShineManagerBus.Broadcast.GetCurrentState()
  if currentState == 2609973752 or currentState == 640726528 then
    self.ScriptedEntityTweener:Set(self.Properties.ConditionalBackdrop, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.ConditionalBackdrop, 0.2, tweenerCommon.fadeInQuadIn, 0.4)
  else
    self.ScriptedEntityTweener:Set(self.Properties.ConditionalBackdrop, {opacity = 0})
  end
  UiFaderBus.Event.SetFadeValue(self.Properties.MainContainer, 1)
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  if self.darknessEvent then
    self.ScriptedEntityTweener:Set(self.Properties.SequenceFire, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1
    })
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFire, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFire)
    self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 1, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.Glow, 2.5, tweenerCommon.fadeOutQuadOut, 3)
    self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFire, 1, tweenerCommon.fadeOutLinear, 0.5)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, self.shouldPlayGlow)
    if self.shouldPlayGlow then
      self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
        scaleX = 0,
        scaleY = 0,
        opacity = 0.6,
        imgColor = self.UIStyle.COLOR_WHITE
      })
      self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.15)
      self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut, 0.35)
    end
  end
  self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {scaleX = 0, opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn, 0.2)
  self.ScriptedEntityTweener:Set(self.Properties.TitleText, {opacity = 0, textCharacterSpace = 100})
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 2.5, self.anim.textCharacterSpaceTo300)
  self.ScriptedEntityTweener:Set(self.Properties.SubjectText, {opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.SubjectText, 1.4, tweenerCommon.fadeInQuadOut, 0.8)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScratchOutLine, self.shouldPlayScratch)
  if self.shouldPlayScratch then
    local basicDelay = 3
    self.ScriptedEntityTweener:PlayC(self.Properties.SubjectText, 1, self.anim.subjectTextScratch, basicDelay)
    self.ScriptedEntityTweener:Set(self.Properties.ScratchOutLine, {imgFill = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.ScratchOutLine, 0.6, self.anim.scratchOutLineIn, basicDelay + 0.4)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, self.shouldShowIcon)
  if self.shouldShowIcon then
    self.ScriptedEntityTweener:Set(self.Properties.IconMask, {y = 180})
    self.ScriptedEntityTweener:PlayC(self.Properties.IconMask, 1.75, tweenerCommon.yTo0, 0.5)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.PromptText, self.shouldShowPrompt)
  if self.shouldShowPrompt then
    self.ScriptedEntityTweener:Set(self.Properties.PromptText, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptText, 1, tweenerCommon.fadeInQuadIn, 0.5)
  end
  if self.shouldShowDifficulties then
    local difficultiesDelay = 1
    TimingUtils:Delay(difficultiesDelay, self, function()
      UiElementBus.Event.SetIsEnabled(self.Properties.DifficultiesContainer, true)
      self.ScriptedEntityTweener:Set(self.Properties.DifficultiesBg, {scaleX = 0, opacity = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.4, tweenerCommon.scaleXTo1)
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.2, tweenerCommon.fadeInQuadOut)
      self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, 0.2, tweenerCommon.opacityTo60, 0.2)
      local firstDifficultyDelay = 0.2
      local difficultyStagger = 0.45
      for i = 0, self.difficultiesToShow - 1 do
        self.DifficultyItems[i]:AnimateIn(firstDifficultyDelay + i * difficultyStagger)
      end
    end)
  end
  if self.hasRewards then
    local delay = 0.1
    for i = 0, #self.RewardEntries do
      self.ScriptedEntityTweener:Set(self.Properties.RewardEntries[i], {opacity = 0})
      self.ScriptedEntityTweener:PlayC(self.Properties.RewardEntries[i], 0.5, tweenerCommon.fadeInQuadIn, delay * i + 0.75)
    end
  end
  self.audioHelper:PlaySound(self.sound)
  self.playedAnimation = true
end
function AchievementCard:TransitionOut()
  if self.playedAnimation then
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.3, self.anim.textCharacterSpaceTo700, nil, function()
      self.playedAnimation = false
    end)
  end
end
function AchievementCard:AnimateOut()
  local duration = 0.3
  if self.shouldShowIcon then
    self.ScriptedEntityTweener:PlayC(self.Properties.IconMask, duration, self.anim.iconMaskOut)
  end
  if self.shouldShowPrompt then
    self.ScriptedEntityTweener:PlayC(self.Properties.PromptText, duration, tweenerCommon.fadeOutQuadOut)
  end
  if self.shouldShowDifficulties then
    self.ScriptedEntityTweener:PlayC(self.Properties.DifficultiesBg, duration, self.anim.difficultiesBgOut)
    for i = 0, self.difficultiesToShow - 1 do
      self.DifficultyItems[i]:AnimateOut()
    end
  end
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.SubjectText, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, 1, tweenerCommon.fadeOutQuadOut, 0.5, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, false)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.playedAnimation = false
  end)
end
return AchievementCard
