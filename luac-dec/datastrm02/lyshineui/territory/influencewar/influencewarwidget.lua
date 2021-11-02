local InfluenceWarWidget = {
  Properties = {
    Icons = {
      Defender = {
        default = EntityId()
      },
      Attacker1 = {
        default = EntityId()
      },
      Attacker2 = {
        default = EntityId()
      }
    },
    InfluenceBars = {
      Attacker1BG = {
        default = EntityId()
      },
      Attacker1Progress = {
        default = EntityId()
      },
      Attacker1PercentLeft = {
        default = EntityId()
      },
      Attacker1PercentRight = {
        default = EntityId()
      },
      Attacker1InfluenceDivider = {
        default = EntityId()
      },
      Attacker1ConflictText = {
        default = EntityId()
      },
      Attacker2BG = {
        default = EntityId()
      },
      Attacker2Progress = {
        default = EntityId()
      },
      Attacker2PercentLeft = {
        default = EntityId()
      },
      Attacker2PercentRight = {
        default = EntityId()
      },
      Attacker2InfluenceDivider = {
        default = EntityId()
      },
      Attacker2ConflictText = {
        default = EntityId()
      }
    },
    QuestionMark = {
      default = EntityId()
    },
    LocationText = {
      default = EntityId()
    },
    GovernedByText = {
      default = EntityId()
    },
    GovernedByIcon = {
      default = EntityId()
    },
    Attacker1Plus = {
      default = EntityId()
    },
    Attacker2Plus = {
      default = EntityId()
    },
    Defender1Plus = {
      default = EntityId()
    },
    Defender2Plus = {
      default = EntityId()
    },
    InfluenceBarsContainer = {
      default = EntityId()
    },
    Faction1ItemGenerationBar = {
      default = EntityId()
    },
    Faction1ItemGenerationBarPulseMask = {
      default = EntityId()
    },
    Faction1ItemGenerationBarPulse = {
      default = EntityId()
    },
    Faction2ItemGenerationBar = {
      default = EntityId()
    },
    Faction2ItemGenerationBarPulseMask = {
      default = EntityId()
    },
    Faction2ItemGenerationBarPulse = {
      default = EntityId()
    }
  },
  itemGenerationBarInitWidth = 352,
  itemGenerationBarPulseWidth = 35,
  barHeightNoConflict = 6,
  barHeightConflict = 30,
  otherAttackerOpacityConflict = 0.3
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(InfluenceWarWidget)
local factionCommon = RequireScript("LyShineUI._Common.FactionCommon")
function InfluenceWarWidget:OnInit()
  BaseElement.OnInit(self)
  self.influenceEnabled = ConfigProviderEventBus.Broadcast.GetBool("javelin.enable-territory-faction-influence")
  if self.Properties.Faction1ItemGenerationBarPulse:IsValid() then
    self.ScriptedEntityTweener:Set(self.Properties.Faction1ItemGenerationBarPulse, {opacity = 0})
    self.ScriptedEntityTweener:Set(self.Properties.Faction2ItemGenerationBarPulse, {opacity = 0})
  end
  if self.Properties.Icons.Defender:IsValid() and type(self.Icons.Defender) == "table" then
    self.Icons.Defender:SetForegroundVisibility(true)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, self.influenceEnabled)
end
function InfluenceWarWidget:OnShutdown()
end
function InfluenceWarWidget:SetIsEnabled(enabled)
  UiElementBus.Event.SetIsEnabled(self.entityId, enabled and self.influenceEnabled)
end
function InfluenceWarWidget:UpdateInfluenceBars(influenceData)
  if self.Properties.QuestionMark:IsValid() then
    self.QuestionMark:SetTooltip("@ui_territoryinfluencetooltip")
    self.QuestionMark:SetButtonStyle(self.QuestionMark.BUTTON_STYLE_QUESTION_MARK)
    self.QuestionMark:SetSize(18)
  end
  if not influenceData then
    return
  end
  local attacker = "Attacker1"
  for i = 1, #influenceData do
    local factionData = factionCommon.factionInfoTable[i]
    if factionData then
      if i == self.owningFaction then
        if self.Properties.Icons.Defender:IsValid() and type(self.Icons.Defender) == "table" then
          self.Icons.Defender:SetBackground("lyshineui/images/icons/misc/empty.dds", factionData.crestBgColor)
          self.Icons.Defender:SetForeground(factionData.crestFgSmall, factionData.crestBgColor)
          if self.Properties.Defender1Plus:IsValid() and self.Properties.Defender2Plus:IsValid() then
            UiImageBus.Event.SetColor(self.Properties.Defender1Plus, factionData.crestBgColor)
            UiImageBus.Event.SetColor(self.Properties.Defender2Plus, factionData.crestBgColor)
          end
        end
        UiImageBus.Event.SetColor(self.Properties.InfluenceBars.Attacker1BG, factionData.crestBgColor)
        UiImageBus.Event.SetColor(self.Properties.InfluenceBars.Attacker2BG, factionData.crestBgColor)
        if self.Properties.GovernedByText:IsValid() then
          UiTextBus.Event.SetTextWithFlags(self.Properties.GovernedByText, factionData.factionName, eUiTextSet_SetLocalized)
          UiTextBus.Event.SetColor(self.Properties.GovernedByText, factionData.crestBgColorLight)
        end
        if self.Properties.GovernedByIcon:IsValid() then
          UiImageBus.Event.SetSpritePathname(self.Properties.GovernedByIcon, factionData.crestFgSmall)
          UiImageBus.Event.SetColor(self.Properties.GovernedByIcon, factionData.crestBgColorLight)
        end
        if self.Properties.InfluenceBars.Attacker1PercentRight then
          UiTextBus.Event.SetColor(self.Properties.InfluenceBars.Attacker1PercentRight, factionData.chatColor)
        end
        if self.Properties.InfluenceBars.Attacker2PercentRight then
          UiTextBus.Event.SetColor(self.Properties.InfluenceBars.Attacker2PercentRight, factionData.chatColor)
        end
      else
        if attacker == "Attacker1" then
          self.attacker1Faction = i
        end
        if self.Properties.Icons[attacker]:IsValid() then
          UiImageBus.Event.SetSpritePathname(self.Properties.Icons[attacker], factionData.crestFgSmall)
          UiImageBus.Event.SetColor(self.Properties.Icons[attacker], factionData.crestBgColor)
        end
        UiImageBus.Event.SetFillAmount(self.Properties.InfluenceBars[attacker .. "Progress"], influenceData[i] / 100)
        local influencePercent = influenceData[i] / 100
        UiImageBus.Event.SetFillAmount(self.Properties.InfluenceBars[attacker .. "Progress"], influencePercent)
        UiImageBus.Event.SetSpritePathname(self.Properties.Icons[attacker], factionData.crestFgSmall)
        UiImageBus.Event.SetColor(self.Properties.InfluenceBars[attacker .. "Progress"], factionData.crestBgColor)
        UiImageBus.Event.SetColor(self.Properties[attacker .. "Plus"], factionData.crestBgColor)
        if self.Properties.InfluenceBars[attacker .. "InfluenceDivider"] then
          UiTransform2dBus.Event.SetAnchorsScript(self.Properties.InfluenceBars[attacker .. "InfluenceDivider"], UiAnchors(influencePercent, 0, influencePercent, 1))
        end
        if self.Properties.InfluenceBars[attacker .. "PercentLeft"]:IsValid() then
          local percentLeftEntity = self.Properties.InfluenceBars[attacker .. "PercentLeft"]
          local percentString = math.floor(influenceData[i]) .. "%"
          UiTextBus.Event.SetText(percentLeftEntity, percentString)
          UiTextBus.Event.SetColor(percentLeftEntity, factionData.chatColor)
        end
        if self.Properties.InfluenceBars[attacker .. "PercentRight"]:IsValid() then
          local percentRightEntity = self.Properties.InfluenceBars[attacker .. "PercentRight"]
          local percentString = math.ceil(100 - influenceData[i]) .. "%"
          UiTextBus.Event.SetText(percentRightEntity, percentString)
        end
        if self.Properties.InfluenceBars[attacker .. "ConflictText"]:IsValid() then
          local inConflict = influencePercent == 1
          UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceBars[attacker .. "ConflictText"], inConflict)
          UiTransform2dBus.Event.SetLocalHeight(self.Properties.InfluenceBars[attacker .. "BG"], inConflict and self.barHeightConflict or self.barHeightNoConflict)
          local otherAttacker = attacker == "Attacker1" and "Attacker2" or "Attacker1"
          UiFaderBus.Event.SetFadeValue(self.Properties.Icons[otherAttacker], inConflict and self.otherAttackerOpacityConflict or 1)
        end
        attacker = "Attacker2"
      end
    end
  end
end
function InfluenceWarWidget:SetInfluenceWarData(territoryName, owningFaction, owningCrest, influenceData, disableMeters)
  if self.Properties.InfluenceBarsContainer:IsValid() then
    UiElementBus.Event.SetIsEnabled(self.Properties.InfluenceBarsContainer, not disableMeters)
  end
  if not self.influenceEnabled then
    return
  end
  self.owningFaction = owningFaction
  self.owningCrest = owningCrest
  if self.Properties.LocationText then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LocationText, territoryName, eUiTextSet_SetLocalized)
  end
  self:UpdateInfluenceBars(influenceData)
end
function InfluenceWarWidget:PlayInfluenceChangedAnimation(increasingForFaction)
  if increasingForFaction == self.owningFaction then
    self:SetFaction1PulseVisible(true, true)
    self:SetFaction2PulseVisible(true, true)
  elseif self.attacker1Faction == increasingForFaction then
    self:SetFaction1PulseVisible(true, false)
  else
    self:SetFaction2PulseVisible(true, false)
  end
end
function InfluenceWarWidget:SetFaction1PulseVisible(isVisible, moveLeft)
  if moveLeft then
    self.ScriptedEntityTweener:Set(self.Properties.Faction1ItemGenerationBar, {scaleX = -1})
  else
    self.ScriptedEntityTweener:Set(self.Properties.Faction1ItemGenerationBar, {scaleX = 1})
  end
  if isVisible then
    self.ScriptedEntityTweener:Stop(self.Faction1ItemGenerationBarPulse)
    self.ScriptedEntityTweener:Play(self.Faction1ItemGenerationBarPulse, 1, {
      x = -self.itemGenerationBarPulseWidth,
      opacity = 1
    }, {
      x = self.itemGenerationBarInitWidth + self.itemGenerationBarPulseWidth,
      opacity = 0,
      ease = "QuadIn",
      timesToPlay = 5
    })
  else
    self.ScriptedEntityTweener:Set(self.Faction1ItemGenerationBarPulse, {
      x = -self.itemGenerationBarPulseWidth
    })
  end
end
function InfluenceWarWidget:SetFaction2PulseVisible(isVisible, moveLeft)
  if moveLeft then
    self.ScriptedEntityTweener:Set(self.Properties.Faction2ItemGenerationBar, {scaleX = -1})
  else
    self.ScriptedEntityTweener:Set(self.Properties.Faction2ItemGenerationBar, {scaleX = 1})
  end
  if isVisible then
    self.ScriptedEntityTweener:Stop(self.Faction2ItemGenerationBarPulse)
    self.ScriptedEntityTweener:Play(self.Faction2ItemGenerationBarPulse, 1, {
      x = -self.itemGenerationBarPulseWidth,
      opacity = 1
    }, {
      x = self.itemGenerationBarInitWidth + self.itemGenerationBarPulseWidth,
      opacity = 0,
      ease = "QuadIn",
      timesToPlay = 5
    })
  else
    self.ScriptedEntityTweener:Set(self.Faction2ItemGenerationBarPulse, {
      x = -self.itemGenerationBarPulseWidth
    })
  end
end
return InfluenceWarWidget
