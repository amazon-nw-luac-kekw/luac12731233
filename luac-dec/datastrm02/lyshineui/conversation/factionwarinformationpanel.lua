local FactionWarInformationPanel = {
  Properties = {
    BGImage = {
      default = EntityId()
    },
    Title = {
      default = EntityId()
    },
    NextButton = {
      default = EntityId()
    },
    BackButton = {
      default = EntityId()
    },
    JoinFactionPanel = {
      default = EntityId()
    },
    ScreenScrim = {
      default = EntityId()
    },
    Headers = {
      default = {
        EntityId()
      }
    },
    ConfirmFactionButton = {
      default = EntityId()
    },
    FactionScreenListItemContainer = {
      default = EntityId()
    },
    HeaderDivider = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    FactionSelection1 = {
      default = EntityId()
    },
    FactionSelection2 = {
      default = EntityId()
    },
    FactionSelection3 = {
      default = EntityId()
    }
  },
  TUTORIAL_STEP_ABOUT_FACTIONS = 0,
  TUTORIAL_STEP_WAR = 1,
  TUTORIAL_STEP_INFLUENCE = 2,
  TUTORIAL_STEP_FLAGGING = 3,
  TUTORIAL_STEP_JOIN = 4
}
local BaseElement = RequireScript("LyShineUI._Common.BaseElement")
BaseElement:CreateNewElement(FactionWarInformationPanel)
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
function FactionWarInformationPanel:OnInit()
  BaseElement.OnInit(self)
  self.tutorials = {
    [self.TUTORIAL_STEP_ABOUT_FACTIONS] = {
      {
        title = "@owg_factionwarinfo_title_1",
        image = "lyShineUI/images/conversation/factions/BackgroundAboutFactions.dds"
      },
      {
        descTitle = "@owg_factionwarinfo_title_1_desc_1"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_1_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_1_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_1_bullet_3"
      },
      {
        descTitle = "@owg_factionwarinfo_title_1_desc_2"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_2_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_2_bullet_2"
      },
      {
        descTitle = "@owg_factionwarinfo_title_1_desc_3"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_3_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_1_desc_3_bullet_2"
      }
    },
    [self.TUTORIAL_STEP_WAR] = {
      {
        title = "@owg_factionwarinfo_title_2",
        image = "lyShineUI/images/conversation/factions/BackgroundFactionWar.dds"
      },
      {
        descTitle = "@owg_factionwarinfo_title_2_desc_1"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_1_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_1_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_1_bullet_3"
      },
      {
        descTitle = "@owg_factionwarinfo_title_2_desc_2"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_2_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_2_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_2_bullet_3"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_2_bullet_4"
      },
      {
        descTitle = "@owg_factionwarinfo_title_2_desc_3"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_3_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_3_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_3_bullet_3"
      },
      {
        desc = "@owg_factionwarinfo_title_2_desc_3_bullet_4"
      }
    },
    [self.TUTORIAL_STEP_INFLUENCE] = {
      {
        title = "@owg_factionwarinfo_title_3",
        image = "lyShineUI/images/conversation/factions/BackgroundTerritoryControl.dds"
      },
      {
        descTitle = "@owg_factionwarinfo_title_3_desc_1"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_1_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_1_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_1_bullet_3"
      },
      {
        descTitle = "@owg_factionwarinfo_title_3_desc_2"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_2_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_2_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_2_bullet_3"
      },
      {
        desc = "@owg_factionwarinfo_title_3_desc_2_bullet_4"
      }
    },
    [self.TUTORIAL_STEP_FLAGGING] = {
      {
        title = "@owg_factionwarinfo_title_4",
        image = "lyShineUI/images/conversation/factions/BackgroundPvpFlagging.dds"
      },
      {
        desc = "@owg_factionwarinfo_title_4_desc_1_bullet_1"
      },
      {
        desc = "@owg_factionwarinfo_title_4_desc_1_bullet_2"
      },
      {
        desc = "@owg_factionwarinfo_title_4_desc_1_bullet_3"
      }
    }
  }
  self.BackButton:SetText("@ui_back")
  self.BackButton:SetButtonStyle(self.BackButton.BUTTON_STYLE_DEFAULT)
  self.BackButton:SetCallback(self.PrevStep, self)
  self.backButtonWidth = self.BackButton:GetWidth()
  self.backButtonPositionNormal = UiTransformBus.Event.GetLocalPositionX(self.Properties.BackButton)
  self.NextButton:SetText("@ui_next")
  self.NextButton:SetButtonStyle(self.NextButton.BUTTON_STYLE_CTA)
  self.NextButton:SetCallback(self.NextStep, self)
  self.NextButtonPosition = UiTransformBus.Event.GetLocalPositionX(self.Properties.NextButton)
  self.backButtonPositionJoinStepX = math.abs(self.NextButtonPosition) + self.backButtonWidth
  self.ConfirmFactionButton:SetText("@ui_confirm")
  self.ConfirmFactionButton:SetButtonStyle(self.ConfirmFactionButton.BUTTON_STYLE_HERO)
  self.ConfirmFactionButton:SetCallback(self.NextStep, self)
  self.ConfirmFactionButton:SetEnabled(false)
  self:StopTutorial()
  self.ScriptedEntityTweener:Set(self.Properties.BGImage, {opacity = 0})
  self.ScriptedEntityTweener:Set(self.Properties.JoinFactionPanel, {opacity = 0})
  self.HeaderDivider:SetVisible(true)
end
function FactionWarInformationPanel:StartTutorial(cancelCallback, cancelCallbackTable)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScreenScrim, true)
  self.ScriptedEntityTweener:PlayFromC(self.Properties.ScreenScrim, 0.5, {opacity = 0}, tweenerCommon.fadeInQuadOut)
  self.callback = cancelCallback
  self.callingTable = cancelCallbackTable
  self:SetupPanel(self.TUTORIAL_STEP_ABOUT_FACTIONS)
end
function FactionWarInformationPanel:PrevStep()
  self.FactionSelection1:ClearSelected()
  self.FactionSelection2:ClearSelected()
  self.FactionSelection3:ClearSelected()
  self:EnableConfirmButton(false)
  if self.tutorialStep == self.TUTORIAL_STEP_ABOUT_FACTIONS then
    self.callback(self.callingTable)
  else
    self.ScriptedEntityTweener:PlayC(self.Properties.BGImage, 0.1, tweenerCommon.fadeOutQuadOut, nil, function()
      self:SetupPanel(self.tutorialStep - 1)
    end)
  end
end
function FactionWarInformationPanel:NextStep()
  self.ScriptedEntityTweener:PlayC(self.Properties.BGImage, 0.1, tweenerCommon.fadeOutQuadOut, nil, function()
    if self.tutorialStep < self.TUTORIAL_STEP_JOIN then
      self:SetupPanel(self.tutorialStep + 1)
    end
  end)
end
function FactionWarInformationPanel:EnableConfirmButton(value)
  if value then
    self.ConfirmFactionButton:SetEnabled(true)
    self.ConfirmFactionButton:SetCallback(self.popupCallback, self.popupCallbackCallingTable)
  else
    self.ConfirmFactionButton:SetEnabled(false)
  end
end
function FactionWarInformationPanel:OnConfirmButton(callback, callingTable)
  self.popupCallback = callback
  self.popupCallbackCallingTable = callingTable
end
function FactionWarInformationPanel:SetupPanel(index)
  self.tutorialStep = index
  if self.tutorialStep < self.TUTORIAL_STEP_JOIN then
    self.Divider:SetVisible(true)
    local currentTutorial = self.tutorials[self.tutorialStep]
    UiImageBus.Event.SetSpritePathname(self.Properties.BGImage, currentTutorial[1].image)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title, currentTutorial[1].title, eUiTextSet_SetLocalized)
    local tutorialSize = #currentTutorial
    local numLines = tutorialSize - 1
    UiDynamicLayoutBus.Event.SetNumChildElements(self.Properties.FactionScreenListItemContainer, numLines)
    local childElements = UiElementBus.Event.GetChildren(self.Properties.FactionScreenListItemContainer)
    for i = 2, tutorialSize do
      local childEntity = UiElementBus.Event.GetChild(self.FactionScreenListItemContainer, i - 2)
      local childTable = self.registrar:GetEntityTable(childEntity)
      local tutorialData = currentTutorial[i]
      local targetHeight = 0
      if tutorialData.descTitle then
        local title = tutorialData.descTitle
        childTable:SetTitle(title)
        local textHeight = childTable:GetTextHeight()
        local spacer = 30
        targetHeight = textHeight + spacer
      elseif tutorialData.desc then
        local bullet = tutorialData.desc
        childTable:SetBulletPoint(bullet)
        local textHeight = childTable:GetTextHeight()
        local spacer = 5
        targetHeight = textHeight + spacer
      end
      UiLayoutCellBus.Event.SetTargetHeight(childTable.entityId, targetHeight)
    end
    UiElementBus.Event.SetIsEnabled(self.Properties.JoinFactionPanel, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmFactionButton, false)
    self.ConfirmFactionButton:StartStopImageSequence(false)
    self.ScriptedEntityTweener:Set(self.Properties.JoinFactionPanel, {opacity = 0})
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.BackButton, UiAnchors(1, 1, 1, 1))
    UiTransformBus.Event.SetLocalPositionX(self.Properties.BackButton, self.backButtonPositionNormal)
    UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.BGImage, true)
  else
    self.Divider:SetVisible(false)
    UiElementBus.Event.SetIsEnabled(self.Properties.JoinFactionPanel, true)
    UiElementBus.Event.SetIsEnabled(self.Properties.ConfirmFactionButton, true)
    self.ConfirmFactionButton:StartStopImageSequence(true)
    self.ScriptedEntityTweener:PlayC(self.Properties.JoinFactionPanel, 0.5, tweenerCommon.fadeInQuadOut, 0.1)
    UiTransform2dBus.Event.SetAnchorsScript(self.Properties.BackButton, UiAnchors(0, 1, 0, 1))
    UiTransformBus.Event.SetLocalPositionX(self.Properties.BackButton, self.backButtonPositionJoinStepX)
    UiElementBus.Event.SetIsEnabled(self.Properties.NextButton, false)
    UiElementBus.Event.SetIsEnabled(self.Properties.BGImage, false)
  end
  UiElementBus.Event.SetIsEnabled(self.entityId, true)
  self.ScriptedEntityTweener:PlayC(self.Properties.BGImage, 0.5, tweenerCommon.fadeInQuadOut)
  for i = 0, #self.Properties.Headers do
    self.Headers[i]:SetHighlight(i == self.tutorialStep)
  end
end
function FactionWarInformationPanel:StopTutorial()
  UiElementBus.Event.SetIsEnabled(self.Properties.BGImage, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.JoinFactionPanel, false)
  UiElementBus.Event.SetIsEnabled(self.entityId, false)
  UiElementBus.Event.SetIsEnabled(self.Properties.ScreenScrim, false)
  self.ScriptedEntityTweener:Set(self.Properties.BGImage, {opacity = 0})
  UiImageBus.Event.SetSpritePathname(self.Properties.BGImage, "lyshineui/images/icons/misc/empty.png")
end
return FactionWarInformationPanel
