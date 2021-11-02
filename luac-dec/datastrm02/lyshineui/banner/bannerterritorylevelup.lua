local BannerTerritoryLevelUp = {
  Properties = {
    LevelUpCountLabel = {
      default = EntityId(),
      order = 1
    },
    TitleText = {
      default = EntityId(),
      order = 2
    },
    LevelUpCount = {
      default = EntityId(),
      order = 3
    },
    LevelUpTextCenter = {
      default = EntityId(),
      order = 4
    },
    LevelUpTextCenterBg = {
      default = EntityId(),
      order = 5
    },
    LevelUpEffect = {
      default = EntityId(),
      order = 6
    },
    LevelUpRuneBase = {
      default = EntityId(),
      order = 7
    },
    LevelUpBgIconContainer = {
      default = EntityId(),
      order = 8
    },
    TextOffset = {
      default = EntityId(),
      order = 9
    },
    LevelUpHintContainer = {
      default = EntityId(),
      order = 10
    },
    LevelUpHint = {
      default = EntityId(),
      order = 11
    },
    LevelUpHintTitle = {
      default = EntityId(),
      order = 12
    },
    ShapeStanding = {
      default = EntityId(),
      order = 13
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(BannerTerritoryLevelUp)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function BannerTerritoryLevelUp:OnInit()
  BaseElement.OnInit(self)
  self:CacheAnimations()
  self.LevelUpHint:SetKeybindMapping("toggleMapComponent")
end
function BannerTerritoryLevelUp:OnShutdown()
end
function BannerTerritoryLevelUp:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 350, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 700, ease = "QuadOut"})
  end
end
function BannerTerritoryLevelUp:UpdateRow(rowStyle, overrideData)
  if overrideData.territoryName then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpTextCenter, overrideData.territoryName, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpCount, overrideData.level, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, overrideData.rankName, eUiTextSet_SetLocalized)
    local textSize = UiTextBus.Event.GetTextSize(self.Properties.LevelUpTextCenter).x
    local textWidth = textSize + 150
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.LevelUpTextCenterBg, textWidth)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpHintTitle, "@ui_open_map", eUiTextSet_SetLocalized)
  local hintTextSize = UiTextBus.Event.GetTextSize(self.Properties.LevelUpHintTitle).x
  local hintTextWidth = hintTextSize + 5
  UiLayoutCellBus.Event.SetMinWidth(self.Properties.LevelUpHintTitle, hintTextWidth)
  self.playAnimation = overrideData.play
  UiElementBus.Event.SetIsEnabled(self.entityId, self.playAnimation)
end
function BannerTerritoryLevelUp:TransitionIn()
  if self.playAnimation then
    self.audioHelper:PlaySound(self.audioHelper.Banner_Territory_LevelUp)
    self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.audioHelper.MusicState_Territory_LevelUp)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.LevelUpEffect, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.LevelUpEffect)
    local runeDuration = 0.25
    self.ScriptedEntityTweener:Play(self.Properties.LevelUpRuneBase, 0.3, {opacity = 0}, {
      opacity = 1,
      delay = runeDuration,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.LevelUpHintContainer, 0.7, {opacity = 0}, {
      opacity = 1,
      delay = 1.5,
      ease = "QuadOut"
    })
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ShapeStanding, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.ShapeStanding)
    self.ScriptedEntityTweener:Play(self.Properties.ShapeStanding, 1, {opacity = 1}, {
      opacity = 0,
      delay = 3,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Set(self.Properties.LevelUpRuneBase, {scaleX = 1, scaleY = 1})
    self.ScriptedEntityTweener:Play(self.Properties.LevelUpCount, 0.15, {opacity = 0}, {
      opacity = 1,
      delay = 0.3,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Play(self.Properties.LevelUpBgIconContainer, 0.5, {opacity = 0}, {
      opacity = 1,
      delay = 0.3,
      ease = "QuadOut"
    })
    self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {opacity = 1})
    self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpTextCenter, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadIn)
    self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpTextCenterBg, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadIn)
    local durationLetterSpacing = 2.8
    self.ScriptedEntityTweener:Set(self.Properties.LevelUpTextCenter, {textCharacterSpace = 100})
    self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpTextCenter, durationLetterSpacing, self.anim.textCharacterSpaceTo300, nil)
    self.playedAnimation = true
  end
end
function BannerTerritoryLevelUp:TransitionOut()
  if self.playedAnimation then
    local duration = 0.3
    self.ScriptedEntityTweener:PlayC(self.Properties.TextOffset, duration, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpBgIconContainer, duration, tweenerCommon.fadeOutQuadOut)
    self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpTextCenter, duration, self.anim.textCharacterSpaceTo700)
    self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpRuneBase, duration, tweenerCommon.fadeOutQuadOut, 0.5, function()
      UiFlipbookAnimationBus.Event.Stop(self.Properties.ShapeStanding)
      UiFlipbookAnimationBus.Event.Stop(self.Properties.LevelUpEffect)
      self.playedAnimation = false
    end)
  end
end
return BannerTerritoryLevelUp
