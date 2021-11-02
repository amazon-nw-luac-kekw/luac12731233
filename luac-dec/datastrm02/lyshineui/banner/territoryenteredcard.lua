local TerritoryEnteredCard = {
  Properties = {
    Phase1 = {
      default = EntityId()
    },
    Icon = {
      default = EntityId()
    },
    TierLabelText = {
      default = EntityId()
    },
    TitleText = {
      default = EntityId()
    },
    TitleBg = {
      default = EntityId()
    },
    TitleLabelText = {
      default = EntityId()
    },
    DescriptionContainer = {
      default = EntityId()
    },
    DescriptionText = {
      default = EntityId()
    },
    DescriptionBg = {
      default = EntityId()
    },
    ClaimedContainer = {
      default = EntityId()
    },
    ClaimedContainerOffset = {
      default = EntityId()
    },
    ClaimedContainerBg = {
      default = EntityId()
    },
    GuildCrest = {
      default = EntityId()
    },
    GuildNameText = {
      default = EntityId()
    },
    BottomContainer = {
      default = EntityId()
    },
    Phase2 = {
      default = EntityId()
    },
    StandingContainer = {
      default = EntityId()
    },
    StandingLabelText = {
      default = EntityId()
    },
    StandingLabelTextBg = {
      default = EntityId()
    },
    StandingRankText = {
      default = EntityId()
    },
    StandingNameText = {
      default = EntityId()
    },
    StandingNameTextBg = {
      default = EntityId()
    },
    TaxInfoContainer = {
      default = EntityId()
    },
    TaxInfos = {
      default = {
        EntityId()
      }
    },
    SequenceFogLoop = {
      default = EntityId()
    },
    FogStatic = {
      default = EntityId()
    },
    BgContainer = {
      default = EntityId()
    }
  },
  showBg = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(TerritoryEnteredCard)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function TerritoryEnteredCard:OnInit()
  BaseElement.OnInit(self)
end
function TerritoryEnteredCard:TransitionIn()
  self.ScriptedEntityTweener:Play(self.Properties.Phase1, 0.7, {opacity = 0}, {
    delay = 0.4,
    opacity = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Play(self.Properties.DescriptionContainer, 0.7, {opacity = 0}, {
    delay = 0.4,
    opacity = 1,
    ease = "QuadOut"
  })
  self.ScriptedEntityTweener:Set(self.Properties.Phase2, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.TitleLabelText, {opacity = 1})
  self.ScriptedEntityTweener:Set(self.Properties.BottomContainer, {opacity = 1})
  if self.showBg then
    UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, true)
    UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.SequenceFogLoop, 0)
    UiFlipbookAnimationBus.Event.Start(self.Properties.SequenceFogLoop)
    self.ScriptedEntityTweener:Set(self.Properties.FogStatic, {opacity = 0})
    self.ScriptedEntityTweener:PlayC(self.Properties.FogStatic, 0.3, tweenerCommon.opacityTo70, 0.4)
  end
  if self.hasSecondPhase then
    if self.isSettlement then
      self.ScriptedEntityTweener:Play(self.Properties.TitleLabelText, 0.5, {opacity = 1}, {
        delay = 3.8,
        opacity = 0,
        ease = "QuadOut"
      })
      self.ScriptedEntityTweener:Play(self.Properties.BottomContainer, 0.5, {opacity = 1}, {
        delay = 3.8,
        opacity = 0,
        ease = "QuadOut"
      })
    else
      self.ScriptedEntityTweener:Play(self.Properties.Phase1, 0.5, {opacity = 1}, {
        delay = 3.5,
        opacity = 0,
        ease = "QuadOut"
      })
    end
    self.ScriptedEntityTweener:Play(self.Properties.Phase2, 0.6, {opacity = 0}, {
      delay = 4.5,
      opacity = 1,
      ease = "QuadOut"
    })
  end
end
function TerritoryEnteredCard:TransitionOut()
  if self.showBg then
    self.ScriptedEntityTweener:PlayC(self.Properties.SequenceFogLoop, 1, tweenerCommon.fadeOutQuadOut, nil, function()
      UiFlipbookAnimationBus.Event.Stop(self.Properties.SequenceFogLoop)
      UiElementBus.Event.SetIsEnabled(self.Properties.SequenceFogLoop, false)
    end)
    self.ScriptedEntityTweener:PlayC(self.Properties.FogStatic, 0.3, tweenerCommon.fadeOutQuadOut)
  end
end
function TerritoryEnteredCard:UpdateRow(rowStyle, overrideData)
  UiElementBus.Event.SetIsEnabled(self.Properties.BgContainer, overrideData.showBg)
  self.showBg = overrideData.showBg
  UiTextBus.Event.SetTextWithFlags(self.Properties.TitleText, overrideData.title, eUiTextSet_SetLocalized)
  local titleTextSize = UiTextBus.Event.GetTextSize(self.Properties.TitleText).x
  local paddingX = 150
  local titleTextWidth = titleTextSize + paddingX
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.TitleBg, titleTextWidth)
  UiElementBus.Event.SetIsEnabled(self.Properties.Icon, overrideData.iconPath ~= nil)
  if overrideData.iconPath then
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon, overrideData.iconPath)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TitleLabelText, overrideData.titleLabel ~= nil)
  if overrideData.titleLabel then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TitleLabelText, overrideData.titleLabel, eUiTextSet_SetLocalized)
  end
  local isChurch = overrideData.eventId and overrideData.eventId == 2429410629
  local enableDescription = overrideData.description ~= nil and overrideData.guildName == nil and overrideData.isClaimable
  if isChurch then
    enableDescription = false
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.DescriptionContainer, enableDescription)
  if overrideData.description then
    UiTextBus.Event.SetTextWithFlags(self.Properties.DescriptionText, overrideData.description, eUiTextSet_SetLocalized)
    local descriptionTextSize = UiTextBus.Event.GetTextSize(self.Properties.GuildNameText).x
    local descriptionTextWidth = descriptionTextSize + paddingX
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.DescriptionBg, descriptionTextWidth)
  end
  local enableGuild = not isChurch and overrideData.guildName ~= nil
  UiElementBus.Event.SetIsEnabled(self.Properties.ClaimedContainer, enableGuild)
  if enableGuild then
    UiTextBus.Event.SetTextWithFlags(self.Properties.GuildNameText, overrideData.guildName, eUiTextSet_SetAsIs)
    self.GuildCrest:SetSmallIcon(overrideData.crestData)
    local guildNameTextSize = UiTextBus.Event.GetTextSize(self.Properties.GuildNameText).x
    local padding = 100
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.ClaimedContainerBg, guildNameTextSize + padding)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.StandingContainer, overrideData.standingLabel ~= nil)
  if overrideData.standingLabel then
    UiTextBus.Event.SetTextWithFlags(self.Properties.StandingLabelText, overrideData.standingLabel, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.StandingRankText, overrideData.rank, eUiTextSet_SetAsIs)
    UiTextBus.Event.SetTextWithFlags(self.Properties.StandingNameText, overrideData.rankName, eUiTextSet_SetLocalized)
    local labelTextSize = UiTextBus.Event.GetTextSize(self.Properties.StandingLabelText).x
    local nameTextSize = UiTextBus.Event.GetTextSize(self.Properties.StandingNameText).x
    local paddingX = 50
    local labelTextWidth = labelTextSize + paddingX
    local nameTextWidth = nameTextSize + paddingX
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.StandingLabelTextBg, labelTextWidth)
    UiTransform2dBus.Event.SetLocalWidth(self.Properties.StandingNameTextBg, nameTextWidth)
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TaxInfoContainer, overrideData.taxes ~= nil)
  if overrideData.taxes then
    for i = 1, #overrideData.taxes do
      local taxData = overrideData.taxes[i]
      local taxInfoEntityId = self.Properties.TaxInfos[i - 1]
      local taxInfoTable = self.registrar:GetEntityTable(taxInfoEntityId)
      if taxInfoTable then
        taxInfoTable:SetTaxInfo(taxData.label, taxData.value1, taxData.value2)
      end
    end
  end
  UiElementBus.Event.SetIsEnabled(self.Properties.TierLabelText, overrideData.tierLabel ~= nil)
  if overrideData.tierLabel then
    UiTextBus.Event.SetTextWithFlags(self.Properties.TierLabelText, overrideData.tierLabel, eUiTextSet_SetLocalized)
  end
  self.isSettlement = overrideData.isSettlement
  self.hasSecondPhase = overrideData.hasSecondPhase
  UiElementBus.Event.SetIsEnabled(self.Properties.Phase2, self.hasSecondPhase)
end
return TerritoryEnteredCard
