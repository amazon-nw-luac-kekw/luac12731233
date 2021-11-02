local TerritoryClaimedCard = {
  Properties = {
    ClaimedByText = {
      default = EntityId()
    },
    CrestIcon = {
      default = EntityId()
    },
    LineGlow = {
      default = EntityId()
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    ShowLine = {
      default = EntityId()
    },
    TextContainer = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    }
  }
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryClaimedCard)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TerritoryClaimedCard:CacheAnimations()
  if not self.anim then
    self.anim = {}
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
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.2, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.2, {
      opacity = 0,
      textCharacterSpace = 700,
      ease = "QuadOut"
    })
  end
end
function TerritoryClaimedCard:OnInit()
  BaseElement.OnInit(self)
  self:CacheAnimations()
  self.dataLayer:RegisterAndExecuteDataCallback(self, "Hud.LocalPlayer.Guild.Crest", function(self, crestData)
    if not crestData then
      return
    end
    self.CrestIcon:SetIcon(crestData)
  end)
end
function TerritoryClaimedCard:UpdateRow(rowStyle, overrideData)
  if overrideData.claimedByText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.ClaimedByText, overrideData.claimedByText, eUiTextSet_SetAsIs)
  end
  if overrideData.guildCrestData then
    self.CrestIcon:SetIcon(overrideData.guildCrestData)
  end
end
function TerritoryClaimedCard:TransitionIn()
  UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
  UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
  UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
  UiElementBus.Event.SetIsEnabled(self.Properties.LineGlow, true)
  self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
    scaleX = 0,
    scaleY = 0,
    opacity = 0,
    imgColor = self.UIStyle.COLOR_WHITE
  })
  self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.2)
  self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut, 0.4)
  self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {scaleX = 0, opacity = 0})
  self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn)
  self.ScriptedEntityTweener:Set(self.Properties.TitleText, {opacity = 0, textCharacterSpace = 100})
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 1, tweenerCommon.fadeInQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 2.8, self.anim.textCharacterSpaceTo300)
  self.playedAnimation = true
end
function TerritoryClaimedCard:TransitionOut()
  if self.playedAnimation then
    self.ScriptedEntityTweener:PlayC(self.Properties.TitleText, 0.3, self.anim.textCharacterSpaceTo700, nil, function()
      self.playedAnimation = false
    end)
  end
end
function TerritoryClaimedCard:AnimateOut()
  self.ScriptedEntityTweener:PlayC(self.Properties.TextContainer, 0.5, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, 1, tweenerCommon.fadeOutQuadOut, 0.5, function()
    UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.playedAnimation = false
  end)
end
return TerritoryClaimedCard
