local TownStructureChangedBanner = {
  Properties = {
    Phase1 = {
      default = EntityId()
    },
    Phase2 = {
      default = EntityId()
    },
    BenefitsText = {
      default = EntityId()
    },
    Benefit1 = {
      default = EntityId()
    },
    Benefit1Image = {
      default = EntityId()
    },
    Benefit1Text = {
      default = EntityId()
    },
    Benefit2 = {
      default = EntityId()
    },
    Benefit2Image = {
      default = EntityId()
    },
    Benefit2Text = {
      default = EntityId()
    },
    Benefit3 = {
      default = EntityId()
    },
    Benefit3Image = {
      default = EntityId()
    },
    Benefit3Text = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    SecondaryTextContainer = {
      default = EntityId()
    },
    SubjectText = {
      default = EntityId()
    },
    ProjectName = {
      default = EntityId()
    },
    SeparatorLine = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    },
    LineGlow = {
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
    }
  },
  benefitElements = {}
}
local TimingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TownStructureChangedBanner)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TownStructureChangedBanner:OnInit()
  BaseElement.OnInit(self)
  self.benefitElements = {
    {
      parentElement = self.Properties.Benefit1,
      textElement = self.Properties.Benefit1Text,
      imageElement = self.Properties.Benefit1Image
    },
    {
      parentElement = self.Properties.Benefit2,
      textElement = self.Properties.Benefit2Text,
      imageElement = self.Properties.Benefit2Image
    },
    {
      parentElement = self.Properties.Benefit3,
      textElement = self.Properties.Benefit3Text,
      imageElement = self.Properties.Benefit3Image
    }
  }
  self:CacheAnimations()
end
function TownStructureChangedBanner:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.25, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.25, {textCharacterSpace = 700, ease = "QuadOut"})
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
  end
end
function TownStructureChangedBanner:StopFogLoop()
  UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, false)
end
function TownStructureChangedBanner:TransitionIn()
  if self.playAnimation then
    UiElementBus.Event.SetIsEnabled(self.Properties.Phase1, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.Phase2, false)
    if self.showPhase2 then
      UiElementBus.Event.SetIsEnabled(self.Properties.Phase2, true)
      self.ScriptedEntityTweener:Play(self.Properties.Phase1, 0.1, {opacity = 1}, {
        delay = 4.5,
        opacity = 0,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.Phase2, 0.1, {opacity = 0}, {
        delay = 4.6,
        opacity = 1,
        ease = "QuadOut"
      })
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
    local lineFlashOpacity = 1
    UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, true)
    self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
      scaleX = 0,
      scaleY = 0,
      opacity = 0.6,
      imgColor = self.UIStyle.COLOR_WHITE
    })
    self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.15)
    self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut, 0.35)
    self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn)
    self.ScriptedEntityTweener:Set(self.Properties.TitleText, {opacity = 0, textCharacterSpace = 100})
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 1, tweenerCommon.fadeInQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 5, self.anim.textCharacterSpaceTo300)
    self.ScriptedEntityTweener:PlayC(self.Properties.SecondaryTextContainer, 0.5, tweenerCommon.fadeInQuadOut, 0.5)
    UiElementBus.Event.SetIsEnabled(self.Properties.IconContainer, true)
    self.ScriptedEntityTweener:Play(self.Properties.IconMask, 1.6, {y = 145}, {y = 0, delay = 0.4})
    self.audioHelper:PlaySound(self.audioHelper.Banner_TownProjectComplete)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_Town_Project_Completed)
    self.playedAnimation = true
  end
end
function TownStructureChangedBanner:TransitionOut()
  if self.playedAnimation then
    self.playedAnimation = false
    TimingUtils:Delay(1, self, self.StopFogLoop)
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.3, self.anim.textCharacterSpaceTo700, nil)
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.3, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.SecondaryTextContainer, 0.5, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:Play(self.Properties.IconMask, 0.5, {y = 145, ease = "QuadIn"})
  end
end
function TownStructureChangedBanner:UpdateRow(rowStyle, overrideData)
  if overrideData.territoryName then
    UiTextBus.Event.SetTextWithFlags(self.Properties.SubjectText, overrideData.territoryName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.ProjectName, overrideData.title, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, overrideData.imagePath)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, overrideData.projectStatus, eUiTextSet_SetLocalized)
    local padding = 15
    local territoryTextSize = UiTextBus.Event.GetTextWidth(self.Properties.SubjectText)
    local projectTextSize = UiTextBus.Event.GetTextWidth(self.Properties.ProjectName)
    local secondaryTextWidth = territoryTextSize + projectTextSize + padding * 2
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.SecondaryTextContainer, secondaryTextWidth)
    UiTransformBus.Event.SetLocalPositionX(self.Properties.SeparatorLine, territoryTextSize + padding)
    for k, benefitInfo in ipairs(overrideData.benefits) do
      if benefitInfo.text then
        UiElementBus.Event.SetIsEnabled(self.benefitElements[k].parentElement, true)
        UiTextBus.Event.SetTextWithFlags(self.benefitElements[k].textElement, benefitInfo.text, eUiTextSet_SetLocalized)
        UiImageBus.Event.SetSpritePathname(self.benefitElements[k].imageElement, benefitInfo.imagePath)
      else
        UiElementBus.Event.SetIsEnabled(self.benefitElements[k].parentElement, false)
      end
    end
    self.showPhase2 = #overrideData.benefits > 0
  end
  self.playAnimation = overrideData.play
  UiElementBus.Event.SetIsEnabled(self.entityId, self.playAnimation)
end
return TownStructureChangedBanner
