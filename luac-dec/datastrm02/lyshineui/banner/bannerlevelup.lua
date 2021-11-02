local BannerLevelUp = {
  Properties = {
    LevelUpCountLabel = {
      default = EntityId(),
      order = 1
    },
    LevelUpCount = {
      default = EntityId(),
      order = 2
    },
    LevelUpTextCenter = {
      default = EntityId(),
      order = 3
    },
    LevelUpTextCenterBg = {
      default = EntityId(),
      order = 4
    },
    LevelUpEffect = {
      default = EntityId(),
      order = 5
    },
    LevelUpRune2 = {
      default = EntityId(),
      order = 6
    },
    LevelUpBgIcon = {
      default = EntityId(),
      order = 7
    },
    LevelUpBgIconContainer = {
      default = EntityId(),
      order = 8
    },
    LevelUpHintContainer = {
      default = EntityId(),
      order = 8
    },
    LevelUpHint = {
      default = EntityId(),
      order = 10
    },
    LevelUpHintTitle = {
      default = EntityId(),
      order = 11
    },
    MilestoneHeader = {
      default = EntityId(),
      order = 12
    },
    UnlockedText = {
      default = EntityId(),
      order = 13
    },
    Milestones = {
      default = {
        EntityId()
      },
      order = 14
    },
    MilestoneHintContainer = {
      default = EntityId(),
      order = 15
    },
    MilestoneHint = {
      default = EntityId(),
      order = 15
    },
    MilestoneHintTitle = {
      default = EntityId(),
      order = 15
    },
    XPLevelUpContainer = {
      default = EntityId(),
      order = 16
    },
    TradeSkillContainer = {
      default = EntityId(),
      order = 17
    },
    MasteryContainer = {
      default = EntityId(),
      order = 18
    },
    ShapeXP = {
      default = EntityId(),
      order = 19
    },
    ShapeTradeskill = {
      default = EntityId(),
      order = 20
    },
    ShapeMastery = {
      default = EntityId(),
      order = 21
    },
    XPBgRune = {
      default = EntityId(),
      order = 22
    },
    TradeSkillBgRune = {
      default = EntityId(),
      order = 23
    },
    MasteryBgRune = {
      default = EntityId(),
      order = 24
    },
    TextOffset = {
      default = EntityId(),
      order = 25
    },
    ImageFill = {
      default = EntityId(),
      order = 26
    },
    ShowLine = {
      default = EntityId(),
      order = 27
    },
    LineGlow = {
      default = EntityId(),
      order = 28
    },
    XPLevelUpCount = {
      default = EntityId(),
      order = 29
    },
    XPLevel = {
      default = EntityId(),
      order = 30
    },
    NextMilestoneContainer = {
      default = EntityId(),
      order = 31
    },
    NextMilestoneText = {
      default = EntityId(),
      order = 31
    },
    TerritoryContainer = {
      default = EntityId(),
      order = 32
    },
    TerritoryShowLine = {
      default = EntityId(),
      order = 33
    },
    TerritoryLineGlow = {
      default = EntityId(),
      order = 34
    },
    TerritoryHeader = {
      default = EntityId(),
      order = 35
    },
    TerritoryText = {
      default = EntityId(),
      order = 36
    },
    MajorMilestoneContainer = {
      default = EntityId(),
      order = 37
    },
    MinorMilestoneContainer = {
      default = EntityId(),
      order = 38
    },
    PlusIcon = {
      default = EntityId(),
      order = 39
    },
    TerritoryHintContainer = {
      default = EntityId(),
      order = 40
    },
    TerritoryHint = {
      default = EntityId(),
      order = 41
    },
    TerritoryHintTitle = {
      default = EntityId(),
      order = 42
    },
    MilestoneOffset = {
      default = EntityId(),
      order = 43
    }
  },
  attributePoints = 0,
  tradeskillPoints = 0,
  shouldShowBgIcon = false,
  playAnimation = false,
  playedAnimation = false,
  callback = nil,
  IMAGEFILL_TRADESKILL = "lyshineui/images/banner/tradeskill_imageFill.dds",
  IMAGEFILL_MASTERY = "lyshineui/images/banner/mastery_imageFill.dds",
  hasTerritoryRecommendation = false
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(BannerLevelUp)
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function BannerLevelUp:OnInit()
  BaseElement.OnInit(self)
  self.dataLayer = dataLayer
  stopAnimatingProperties = {
    self.Properties.ShapeXP,
    self.Properties.ShapeMastery,
    self.Properties.ShapeTradeskill,
    self.Properties.LevelUpEffect
  }
  self:CacheAnimations()
  self.LevelUpHint:SetKeybindMapping("toggleSkillsComponent")
  self.MilestoneHint:SetKeybindMapping("bannerAccept")
  self.TerritoryHint:SetKeybindMapping("toggleMapComponent")
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Attributes.UnspentPoints", function(self, attributePoints)
    self.attributePoints = attributePoints or 0
    self:UpdatePointsText()
  end)
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Tradeskills.UnspentPoints", function(self, tradeskillPoints)
    self.tradeskillPoints = tradeskillPoints or 0
    self:UpdatePointsText()
  end)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  SetTextStyle(self.Properties.TerritoryHeader, self.UIStyle.FONT_STYLE_BANNER_TERRITORY_HEADER)
  SetTextStyle(self.Properties.TerritoryText, self.UIStyle.FONT_STYLE_BANNER_TERRITORY_TEXT)
end
function BannerLevelUp:OnShutdown()
  self.dataLayer:UnregisterObservers(self)
  self.dataLayer = nil
end
function BannerLevelUp:CacheAnimations()
  if not self.anim then
    self.anim = {}
    self.anim.textCharacterSpaceTo300 = self.ScriptedEntityTweener:CacheAnimation(0.25, {textCharacterSpace = 300, ease = "QuadOut"})
    self.anim.textCharacterSpaceTo700 = self.ScriptedEntityTweener:CacheAnimation(0.25, {textCharacterSpace = 700, ease = "QuadOut"})
    self.anim.rune1Out = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      scaleX = 1.15,
      scaleY = 1.15,
      ease = "QuadOut"
    })
    self.anim.rune2Out = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      scaleX = 1.15,
      scaleY = 1.15,
      ease = "QuadOut"
    })
    self.anim.runeBaseOut = self.ScriptedEntityTweener:CacheAnimation(0.3, {
      scaleX = 1.15,
      scaleY = 1.15,
      ease = "QuadOut"
    })
    self.anim.backgroundRuneIn = self.ScriptedEntityTweener:CacheAnimation(0.5, {
      opacity = 1,
      scaleX = 1,
      scaleY = 1,
      delay = 0.25,
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
  end
end
function BannerLevelUp:UpdateRow(rowStyle, overrideData)
  if overrideData.level then
    UiTextBus.Event.SetText(self.Properties.LevelUpCount, overrideData.level)
    UiTextBus.Event.SetText(self.Properties.XPLevel, overrideData.level)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpHintTitle, "@ui_purchase_upgrades", eUiTextSet_SetLocalized)
  UiElementBus.Event.SetIsEnabled(self.Properties.MilestoneHintContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneContainer, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryHintContainer, false)
  if overrideData.weaponMastery then
    self.isWeaponMastery = true
    self.isTradeskill = false
    self.isXpLevelup = false
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenter, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenterBg, true)
    self.shouldShowBgIcon = true
    local hintTextSize = UiTextBus.Event.GetTextSize(self.Properties.LevelUpHintTitle).x
    local hintTextWidth = hintTextSize + 5
    UiLayoutCellBus.Event.SetMinWidth(self.Properties.LevelUpHintTitle, hintTextWidth)
    UiImageBus.Event.SetSpritePathname(self.Properties.LevelUpBgIcon, overrideData.iconPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpHintContainer, true)
    self.sound = self.audioHelper.Banner_WeaponMasteryLevelUp
    self.music = self.audioHelper.MusicState_WeaponMasteryLevelUp
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.MasteryContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpCount, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpCount, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpCountLabel, "@ui_mastery", eUiTextSet_SetLocalized)
    UiTransformBus.Event.SetLocalPositionY(self.Properties.LevelUpHintContainer, 250)
    UiImageBus.Event.SetSpritePathname(self.Properties.ImageFill, self.IMAGEFILL_MASTERY)
  elseif overrideData.tradeskill then
    self.isWeaponMastery = false
    self.isTradeskill = true
    self.isXpLevelup = false
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenter, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenterBg, true)
    self.shouldShowBgIcon = true
    UiImageBus.Event.SetSpritePathname(self.Properties.LevelUpBgIcon, overrideData.iconPath)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpHintContainer, false)
    self.sound = self.audioHelper.Banner_TradeskillLevelUp
    self.music = self.audioHelper.MusicState_TradeskillLevelUp
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.MasteryContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpCount, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpCount, false)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpCountLabel, "@ui_level", eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.ImageFill, self.IMAGEFILL_TRADESKILL)
  else
    self.isWeaponMastery = false
    self.isTradeskill = false
    self.isXpLevelup = true
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenter, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpTextCenterBg, false)
    self.shouldShowBgIcon = false
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpHintContainer, true)
    if overrideData.attributePoints or overrideData.tradeskillPoints then
      self.attributePoints = overrideData.attributePoints or 0
      self.tradeskillPoints = overrideData.tradeskillPoints or 0
      self:UpdatePointsText()
      local hintTextSize = UiTextBus.Event.GetTextSize(self.Properties.LevelUpHintTitle).x
      local hintTextWidth = hintTextSize + 5
      UiLayoutCellBus.Event.SetMinWidth(self.Properties.LevelUpHintTitle, hintTextWidth)
    end
    UiTextBus.Event.SetTextWithFlags(self.Properties.MilestoneHintTitle, "@ui_view_milestone_rewards", eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryHintTitle, "@ui_open_map", eUiTextSet_SetLocalized)
    local milestoneHintTextSize = UiTextBus.Event.GetTextSize(self.Properties.MilestoneHintTitle).x
    local milestoneHintTextWidth = milestoneHintTextSize + 5
    UiLayoutCellBus.Event.SetMinWidth(self.Properties.MilestoneHintTitle, milestoneHintTextWidth)
    local territoryHintTextSize = UiTextBus.Event.GetTextSize(self.Properties.TerritoryHintTitle).x
    local territoryHintTextWidth = territoryHintTextSize + 5
    UiLayoutCellBus.Event.SetMinWidth(self.Properties.TerritoryHintTitle, territoryHintTextWidth)
    self.sound = self.audioHelper.Banner_LevelUp
    self.music = self.audioHelper.MusicState_LevelUp
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpContainer, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.MasteryContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.TradeSkillContainer, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.XPLevelUpCount, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpCount, false)
  end
  if overrideData.displayName then
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpTextCenter, overrideData.displayName, eUiTextSet_SetLocalized)
  else
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpTextCenter, "@ui_level_increased", eUiTextSet_SetLocalized)
  end
  local textSize = UiTextBus.Event.GetTextSize(self.Properties.LevelUpTextCenter).x
  local textWidth = textSize + 100
  UiTransform2dBus.Event.SetLocalWidth(self.Properties.LevelUpTextCenterBg, textWidth)
  self.playAnimation = overrideData.play
  local milestoneHintPosY = 175
  if overrideData.milestoneData and 0 < #overrideData.milestoneData then
    self.isMilestone = true
    self.hasTerritoryRecommendation = false
    local hasMajorMilestone = false
    local hasMinorMilestone = false
    if not overrideData.displayName then
      UiTextBus.Event.SetTextWithFlags(self.Properties.LevelUpTextCenter, "@ui_milestone_reached", eUiTextSet_SetLocalized)
    end
    self.numberOfMinorMilestone = 0
    local minorMilestoneTextWidth = 0
    local majorMilestoneIconSize = 80
    local majorMilestoneTextSize = 125
    local majorMilestoneTextPosY = 84
    local majorMilestoneTextPosX = 0
    local minorMilestoneIconSize = 40
    local minorMilestoneTextSize = 500
    local minorMilestoneTextPosY = 0
    local minorMilestoneTextPosX = 50
    for i, data in pairs(overrideData.milestoneData) do
      if i - 1 > #self.Properties.Milestones then
        break
      end
      local milestoneType = data.type
      if milestoneType == eMilestoneType_TerritoryRecommendation then
        self.hasTerritoryRecommendation = true
        UiTextBus.Event.SetTextWithFlags(self.Properties.TerritoryText, data.name, eUiTextSet_SetLocalized)
        UiElementBus.Event.SetIsEnabled(self.Properties.Milestones[i - 1], false)
        UiLayoutCellBus.Event.SetTargetWidth(self.Properties.Milestones[i - 1], 0)
        UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Milestones[i - 1], 0)
      else
        UiTextBus.Event.SetTextWithFlags(self.Milestones[i - 1].Name, data.name, eUiTextSet_SetLocalized)
        UiImageBus.Event.SetSpritePathname(self.Milestones[i - 1].Icon, data.icon)
        UiElementBus.Event.SetIsEnabled(self.Properties.Milestones[i - 1], true)
        if milestoneType == eMilestoneType_Major then
          majorMilestoneIconSize = 80
          majorMilestoneTextSize = 125
          majorMilestoneTextPosY = 84
          majorMilestoneTextPosX = 0
          majorTargetWidth = 110
          majorTargetHeight = 40
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Icon, majorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalHeight(self.Milestones[i - 1].Icon, majorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Bg, majorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalHeight(self.Milestones[i - 1].Bg, majorMilestoneIconSize)
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Icon, UiAnchors(0.5, 0, 0.5, 0))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Icon, Vector2(0.5, 0))
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Bg, UiAnchors(0.5, 0, 0.5, 0))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Bg, Vector2(0.5, 0.5))
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Icon, {x = 0, y = 0})
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Bg, {
            x = 0,
            y = 40,
            scaleX = 1.2,
            scaleY = 1.2
          })
          UiLayoutCellBus.Event.SetTargetWidth(self.Properties.Milestones[i - 1], majorTargetWidth)
          UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Milestones[i - 1], majorTargetHeight)
          UiElementBus.Event.Reparent(self.Properties.Milestones[i - 1], self.Properties.MajorMilestoneContainer, EntityId())
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Name, UiAnchors(0.5, 0, 0.5, 0))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Name, Vector2(0.5, 0))
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Name, majorMilestoneTextSize)
          UiTextBus.Event.SetHorizontalTextAlignment(self.Milestones[i - 1].Name, eUiHAlign_Center)
          UiTextBus.Event.SetVerticalTextAlignment(self.Milestones[i - 1].Name, eUiVAlign_Top)
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Name, {x = majorMilestoneTextPosX, y = majorMilestoneTextPosY})
          hasMajorMilestone = true
        else
          minorMilestoneIconSize = 40
          minorMilestoneTextSize = 500
          minorMilestoneTextPosY = 0
          minorMilestoneTextPosX = 50
          minorTargetWidth = 0
          minorTargetHeight = 44
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Icon, minorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalHeight(self.Milestones[i - 1].Icon, minorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Bg, minorMilestoneIconSize)
          UiTransform2dBus.Event.SetLocalHeight(self.Milestones[i - 1].Bg, minorMilestoneIconSize)
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Icon, UiAnchors(0, 0, 0, 0))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Icon, Vector2(0, 0))
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Bg, UiAnchors(0, 0, 0, 0))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Bg, Vector2(0, 0))
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Icon, {x = 0, y = 0})
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Bg, {
            x = 0,
            y = 0,
            scaleX = 1,
            scaleY = 1
          })
          UiLayoutCellBus.Event.SetTargetWidth(self.Properties.Milestones[i - 1], minorTargetWidth)
          UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Milestones[i - 1], minorTargetHeight)
          UiElementBus.Event.Reparent(self.Properties.Milestones[i - 1], self.Properties.MinorMilestoneContainer, EntityId())
          UiTransform2dBus.Event.SetAnchorsScript(self.Milestones[i - 1].Name, UiAnchors(0, 0.5, 0, 0.5))
          UiTransformBus.Event.SetPivot(self.Milestones[i - 1].Name, Vector2(0, 0.5))
          UiTransform2dBus.Event.SetLocalWidth(self.Milestones[i - 1].Name, minorMilestoneTextSize)
          UiTextBus.Event.SetHorizontalTextAlignment(self.Milestones[i - 1].Name, eUiHAlign_Left)
          UiTextBus.Event.SetVerticalTextAlignment(self.Milestones[i - 1].Name, eUiVAlign_Center)
          self.ScriptedEntityTweener:Set(self.Milestones[i - 1].Name, {x = minorMilestoneTextPosX, y = minorMilestoneTextPosY})
          textWidth = UiTextBus.Event.GetTextSize(self.Milestones[i - 1].Name).x
          if minorMilestoneTextWidth < textWidth then
            minorMilestoneTextWidth = textWidth
          end
          hasMinorMilestone = true
          self.numberOfMinorMilestone = self.numberOfMinorMilestone + 1
        end
      end
    end
    for i = #overrideData.milestoneData, #self.Properties.Milestones do
      UiElementBus.Event.SetIsEnabled(self.Properties.Milestones[i], false)
      UiLayoutCellBus.Event.SetTargetWidth(self.Properties.Milestones[i], 0)
      UiLayoutCellBus.Event.SetTargetHeight(self.Properties.Milestones[i], 0)
    end
    local majorContainerPosX = -106
    local minorContainerPosX = 142
    local minorContainerWidth = minorMilestoneIconSize + minorMilestoneTextWidth + 10
    local majorContainerDefaultPosY = -10
    local majorContainerOffsetPosY = 10
    if hasMajorMilestone and hasMinorMilestone then
      local totalContainerWidth = minorContainerWidth + 74 + majorMilestoneIconSize
      majorContainerPosX = -106
      minorContainerPosX = 142
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MajorMilestoneContainer, majorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MinorMilestoneContainer, minorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MilestoneOffset, -totalContainerWidth / 2)
      UiElementBus.Event.SetIsEnabled(self.Properties.PlusIcon, true)
      local plusIconDefaultPosY = 10
      local plusIconOffsetPosY = 30
      if self.numberOfMinorMilestone > 2 then
        UiTransformBus.Event.SetLocalPositionY(self.Properties.MajorMilestoneContainer, majorContainerOffsetPosY)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PlusIcon, plusIconOffsetPosY)
        milestoneHintPosY = 272
      else
        UiTransformBus.Event.SetLocalPositionY(self.Properties.MajorMilestoneContainer, majorContainerDefaultPosY)
        UiTransformBus.Event.SetLocalPositionY(self.Properties.PlusIcon, plusIconDefaultPosY)
        milestoneHintPosY = 248
      end
    elseif not hasMajorMilestone and hasMinorMilestone then
      majorContainerPosX = -145
      minorContainerPosX = 0
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MajorMilestoneContainer, majorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MinorMilestoneContainer, minorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MilestoneOffset, -minorContainerWidth / 2)
      UiElementBus.Event.SetIsEnabled(self.Properties.PlusIcon, false)
      if self.numberOfMinorMilestone == 4 then
        milestoneHintPosY = 308
      elseif self.numberOfMinorMilestone == 3 then
        milestoneHintPosY = 270
      else
        milestoneHintPosY = 228
      end
    else
      majorContainerPosX = -145
      minorContainerPosX = 0
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MajorMilestoneContainer, majorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MinorMilestoneContainer, minorContainerPosX)
      UiTransformBus.Event.SetLocalPositionX(self.Properties.MilestoneOffset, 0)
      UiTransformBus.Event.SetLocalPositionY(self.Properties.MajorMilestoneContainer, majorContainerDefaultPosY)
      UiElementBus.Event.SetIsEnabled(self.Properties.PlusIcon, false)
      milestoneHintPosY = 264
    end
    if self.numberOfMinorMilestone == 4 then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MinorMilestoneContainer, 168)
    elseif self.numberOfMinorMilestone == 3 then
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MinorMilestoneContainer, 132)
    else
      UiTransform2dBus.Event.SetLocalHeight(self.Properties.MinorMilestoneContainer, 92)
    end
  else
    self.isMilestone = false
  end
  self.nextMilestone = overrideData.nextMilestone
  if self.nextMilestone then
    UiTextBus.Event.SetText(self.Properties.NextMilestoneText, tostring(self.nextMilestone))
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.MilestoneHintContainer, milestoneHintPosY)
  UiElementBus.Event.SetIsEnabled(self.entityId, self.playAnimation)
end
function BannerLevelUp:UpdatePointsText()
  local keys = vector_basic_string_char_char_traits_char()
  keys:push_back("attributePoints")
  keys:push_back("tradeskillPoints")
  keys:push_back("attributePointsText")
  keys:push_back("tradeskillPointsText")
  local values = vector_basic_string_char_char_traits_char()
  values:push_back(self.attributePoints)
  values:push_back(self.tradeskillPoints)
  values:push_back(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(self.attributePoints == 1 and "@ui_level_attribute_points_single" or "@ui_level_attribute_points_multiple", keys, values))
  values:push_back(LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacements(self.tradeskillPoints == 1 and "@ui_level_tradeskill_points_single" or "@ui_level_tradeskill_points_multiple", keys, values))
end
function BannerLevelUp:TransitionIn()
  self.ScriptedEntityTweener:Set(self.entityId, {opacity = 1})
  if self.playAnimation then
    do
      local topElementDuration = 0.3
      self.ScriptedEntityTweener:Set(self.Properties.TerritoryContainer, {opacity = 0})
      UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.LevelUpEffect, 0)
      UiFlipbookAnimationBus.Event.Start(self.Properties.LevelUpEffect)
      self.ScriptedEntityTweener:Set(self.Properties.TextOffset, {opacity = 1})
      self.ScriptedEntityTweener:Play(self.Properties.LevelUpHintContainer, 0.7, {opacity = 0}, {
        opacity = 1,
        delay = 1.5,
        ease = "QuadOut"
      })
      if self.LevelUpHint then
        self.LevelUpHint:SetHighlightVisible(true)
      end
      local shapeDisplayDuration = 3
      local shapeFadeoutDuration = 1
      local duration = 0.5
      if self.isMilestone or self.nextMilestone then
        shapeDisplayDuration = 2.8
        shapeFadeoutDuration = duration
      end
      if self.isXpLevelup then
        UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ShapeXP, 0)
        UiFlipbookAnimationBus.Event.Start(self.Properties.ShapeXP)
        self.ScriptedEntityTweener:Play(self.Properties.ShapeXP, 0.3, {scaleX = 1.2, scaleY = 1.2}, {
          scaleX = 1,
          scaleY = 1,
          delay = 0.2,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:Play(self.Properties.ShapeXP, 1, {opacity = 1}, {
          opacity = 0,
          delay = shapeDisplayDuration,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:PlayC(self.Properties.XPBgRune, 0.5, self.anim.backgroundRuneIn)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpRune2, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadOut)
        self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpRune2, 0.5, {scaleX = 0.25, scaleY = 0.25}, tweenerCommon.scaleTo1)
        self.ScriptedEntityTweener:Play(self.Properties.XPLevelUpCount, 0.25, {
          scaleX = 1.15,
          scaleY = 1.15,
          opacity = 0
        }, {
          scaleX = 1,
          scaleY = 1,
          opacity = 1,
          delay = 0.25,
          ease = "QuadOut"
        })
      elseif self.isTradeskill then
        UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ShapeTradeskill, 0)
        UiFlipbookAnimationBus.Event.Start(self.Properties.ShapeTradeskill)
        self.ScriptedEntityTweener:Play(self.Properties.ShapeTradeskill, shapeFadeoutDuration, {opacity = 1}, {
          opacity = 0,
          delay = shapeDisplayDuration,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:PlayC(self.Properties.TradeSkillBgRune, 0.5, self.anim.backgroundRuneIn)
        self.ScriptedEntityTweener:Play(self.Properties.LevelUpCount, 0.15, {opacity = 0}, {
          opacity = 1,
          delay = 0.4,
          ease = "QuadOut"
        })
      elseif self.isWeaponMastery then
        UiFlipbookAnimationBus.Event.SetCurrentFrame(self.Properties.ShapeMastery, 0)
        UiFlipbookAnimationBus.Event.Start(self.Properties.ShapeMastery)
        self.ScriptedEntityTweener:Play(self.Properties.ShapeMastery, 1, {opacity = 1}, {
          opacity = 0,
          delay = shapeDisplayDuration,
          ease = "QuadOut"
        })
        self.ScriptedEntityTweener:PlayC(self.Properties.MasteryBgRune, 0.5, self.anim.backgroundRuneIn)
        self.ScriptedEntityTweener:Play(self.Properties.LevelUpCount, 0.15, {opacity = 0}, {
          opacity = 1,
          delay = 0.4,
          ease = "QuadOut"
        })
      end
      self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpTextCenter, duration, {opacity = 0}, tweenerCommon.fadeInQuadIn)
      self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpTextCenterBg, duration, {opacity = 0}, tweenerCommon.fadeInQuadIn)
      local durationLetterSpacing = 2.8
      self.ScriptedEntityTweener:Set(self.Properties.LevelUpTextCenter, {textCharacterSpace = 100})
      self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpTextCenter, durationLetterSpacing, self.anim.textCharacterSpaceTo300, nil, function()
        if self.isMilestone or self.nextMilestone then
          self.ScriptedEntityTweener:Set(self.Properties.LineGlow, {
            scaleX = 0,
            scaleY = 0,
            opacity = 0,
            imgColor = self.UIStyle.COLOR_WHITE
          })
          self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 0.2, self.anim.lineGlowIn, 0.75)
          self.ScriptedEntityTweener:PlayC(self.Properties.LineGlow, 1.2, self.anim.lineGlowOut, 0.95)
          self.ScriptedEntityTweener:Set(self.Properties.ShowLine, {scaleX = 0, opacity = 0})
          self.ScriptedEntityTweener:PlayC(self.Properties.ShowLine, 0.15, self.anim.showLineIn, 0.8)
          self.ScriptedEntityTweener:PlayC(self.Properties.TextOffset, duration, tweenerCommon.fadeOutQuadOut)
          self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpRune2, duration, {opacity = 1}, tweenerCommon.opacityTo10)
          self.ScriptedEntityTweener:PlayFromC(self.Properties.XPBgRune, duration, {opacity = 0.6}, tweenerCommon.opacityTo20)
          self.ScriptedEntityTweener:PlayFromC(self.Properties.TradeSkillBgRune, duration, {opacity = 1}, tweenerCommon.opacityTo20)
          self.ScriptedEntityTweener:PlayFromC(self.Properties.MasteryBgRune, duration, {opacity = 0.6}, tweenerCommon.opacityTo20)
          self.ScriptedEntityTweener:PlayFromC(self.Properties.LevelUpBgIconContainer, duration, {opacity = 1}, tweenerCommon.fadeOutQuadOut)
          local enableUpdatedRewardMapping = self.dataLayer:GetDataFromNode("UIFeatures.enable-updated-reward-mapping")
          if self.isXpLevelup and enableUpdatedRewardMapping then
            UiElementBus.Event.SetIsEnabled(self.Properties.MilestoneHintContainer, true)
            self.ScriptedEntityTweener:PlayFromC(self.Properties.MilestoneHintContainer, duration, {opacity = 0}, tweenerCommon.fadeInQuadIn, 0.5)
            self.actionHandler = self:BusConnect(CryActionNotificationsBus, "bannerAccept")
            if self.MilestoneHint then
              self.MilestoneHint:SetHighlightVisible(true)
            end
          end
          self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpHintContainer, duration, tweenerCommon.fadeOutQuadOut, nil, function()
            if self.isMilestone then
              UiElementBus.Event.SetIsEnabled(self.Properties.MilestoneHeader, true)
              self.ScriptedEntityTweener:PlayFromC(self.Properties.MilestoneHeader, duration, {opacity = 0}, tweenerCommon.fadeInQuadIn, nil, function()
                if self.hasTerritoryRecommendation then
                  local durationMilestone = 4
                  self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneHeader, 0.5, tweenerCommon.fadeOutQuadOut, durationMilestone, function()
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryContainer, 0.5, tweenerCommon.fadeInQuadOut)
                    self.audioHelper:PlaySound(self.sound)
                    self.ScriptedEntityTweener:Set(self.Properties.TerritoryLineGlow, {
                      scaleX = 0,
                      scaleY = 0,
                      opacity = 0,
                      imgColor = self.UIStyle.COLOR_WHITE
                    })
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryLineGlow, 0.2, self.anim.lineGlowIn, 0)
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryLineGlow, 1.2, self.anim.lineGlowOut, 0.2)
                    self.ScriptedEntityTweener:Set(self.Properties.TerritoryShowLine, {scaleX = 0, opacity = 0})
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryShowLine, 0.15, self.anim.showLineIn)
                    self.ScriptedEntityTweener:Set(self.Properties.TerritoryText, {opacity = 0, textCharacterSpace = 100})
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryText, 1, tweenerCommon.fadeInQuadOut)
                    self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryText, 3.5, self.anim.textCharacterSpaceTo300)
                    UiElementBus.Event.SetIsEnabled(self.Properties.TerritoryHintContainer, true)
                    self.ScriptedEntityTweener:PlayFromC(self.Properties.TerritoryHintContainer, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadIn)
                    if self.TerritoryHint then
                      self.TerritoryHint:SetHighlightVisible(true)
                    end
                  end)
                  self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneHintContainer, 0.5, tweenerCommon.fadeOutQuadOut, durationMilestone)
                end
              end)
            end
            if self.nextMilestone then
              UiElementBus.Event.SetIsEnabled(self.Properties.NextMilestoneContainer, true)
              self.ScriptedEntityTweener:PlayFromC(self.Properties.NextMilestoneContainer, duration, {opacity = 0}, tweenerCommon.fadeInQuadIn)
            end
          end)
        end
      end)
      if self.shouldShowBgIcon then
        UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpBgIconContainer, true)
        self.ScriptedEntityTweener:Play(self.Properties.LevelUpBgIconContainer, 0.5, {opacity = 0}, {opacity = 1, delay = 0.3})
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.LevelUpBgIconContainer, false)
      end
      self.audioHelper:PlaySound(self.sound)
      self.audioHelper:SwitchMusicDB(self.audioHelper.MusicSwitch_Gameplay, self.music)
      self.playedAnimation = true
    end
  end
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    self.tickHandler = self:BusConnect(DynamicBus.UITickBus)
  end
end
function BannerLevelUp:OnTick(elapsed, timepoint)
  if LyShineManagerBus.Broadcast.GetCurrentState() == 3576764016 then
    self:AnimateOut(self.callback)
  end
end
function BannerLevelUp:TransitionOut(callback)
  if self.playedAnimation then
    self.playedAnimation = false
    if FtueSystemRequestBus.Broadcast.IsFtue() and LyShineManagerBus.Broadcast.GetCurrentState() ~= 3576764016 then
      self.callback = callback
      return
    end
    self:AnimateOut(callback)
  end
end
function BannerLevelUp:AnimateOut(callback)
  local duration = 1
  self.ScriptedEntityTweener:PlayC(self.entityId, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TextOffset, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneHeader, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpHintContainer, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.MilestoneHintContainer, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.NextMilestoneContainer, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.TerritoryContainer, duration, tweenerCommon.fadeOutQuadOut)
  self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpTextCenter, 0.5, self.anim.textCharacterSpaceTo700)
  self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpRune2, duration, tweenerCommon.fadeOutQuadOut, nil, callback)
  self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpRune2, duration, self.anim.rune2Out, nil, function()
    for i, property in ipairs(stopAnimatingProperties) do
      UiFlipbookAnimationBus.Event.Stop(property)
    end
    UiElementBus.Event.SetIsEnabled(self.entityId, false)
    self.playedAnimation = false
  end)
  if self.LevelUpHint then
    self.LevelUpHint:SetHighlightScale(1.8, 0.2)
  end
  if self.MilestoneHint then
    self.MilestoneHint:SetHighlightScale(1.8, 0.2)
  end
  if self.TerritoryHint then
    self.TerritoryHint:SetHighlightScale(1.8, 0.2)
  end
  if self.shouldShowBgIcon then
    self.ScriptedEntityTweener:PlayC(self.Properties.LevelUpBgIconContainer, 0.3, tweenerCommon.fadeOutQuadOut)
  end
  self:BusDisconnect(self.actionHandler)
  self.actionHandler = nil
  if self.tickHandler then
    self:BusDisconnect(self.tickHandler)
    self.tickHandler = nil
  end
end
function BannerLevelUp:OnCryAction(actionName)
  if actionName == "bannerAccept" then
    DynamicBus.GloryBarBus.Broadcast.ShowMilestoneWindow()
  end
end
return BannerLevelUp
