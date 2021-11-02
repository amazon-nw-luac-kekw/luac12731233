local WarTutorialPopup = {
  Properties = {
    PopupBackgroundTutorial = {
      default = EntityId()
    },
    MasterContainer = {
      default = EntityId()
    },
    CloseButton = {
      default = EntityId()
    },
    Header = {
      default = EntityId()
    },
    Divider = {
      default = EntityId()
    },
    BackgroundImage = {
      default = EntityId()
    },
    Icon1 = {
      default = EntityId()
    },
    Icon2 = {
      default = EntityId()
    },
    Icon3 = {
      default = EntityId()
    },
    Icon4 = {
      default = EntityId()
    },
    Title1 = {
      default = EntityId()
    },
    Title2 = {
      default = EntityId()
    },
    Title3 = {
      default = EntityId()
    },
    Title4 = {
      default = EntityId()
    },
    Desc1 = {
      default = EntityId()
    },
    Desc2 = {
      default = EntityId()
    },
    Desc3 = {
      default = EntityId()
    },
    Desc4 = {
      default = EntityId()
    },
    LevelRequirement = {
      default = EntityId()
    },
    Frame = {
      default = EntityId()
    }
  },
  isShowing = false
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(WarTutorialPopup)
local GameModeCommon = RequireScript("LyShineUI._Common.GameModeCommon")
function WarTutorialPopup:OnInit()
  BaseScreen.OnInit(self)
  self.GameModeData = {
    [GameModeCommon.GAMEMODE_WAR] = {
      mainBg = "lyshineui/images/raid/warTutorial_imageWar.dds",
      headerText = "@ui_how_war_works",
      icon1 = "lyshineui/images/raid/warTutorial_image1.dds",
      icon2 = "lyshineui/images/raid/warTutorial_image2.dds",
      icon3 = "lyshineui/images/raid/warTutorial_image3.dds",
      icon4 = "lyshineui/images/raid/warTutorial_image4.dds",
      iconTitle1 = "@ui_war_tutorial_title_1",
      iconTitle2 = "@ui_war_tutorial_title_2",
      iconTitle3 = "@ui_war_tutorial_title_3",
      iconTitle4 = "@ui_war_tutorial_title_4",
      iconDesc1 = "@ui_war_tutorial_desc_1",
      iconDesc2 = "@ui_war_tutorial_desc_2",
      iconDesc3 = "@ui_war_tutorial_desc_3",
      iconDesc4 = "@ui_war_tutorial_desc_4"
    },
    [GameModeCommon.GAMEMODE_INVASION] = {
      mainBg = "lyshineui/images/raid/warTutorial_imageInvasion.dds",
      headerText = "@ui_how_invasion_works",
      icon1 = "lyshineui/images/raid/warTutorial_image1_invasion.dds",
      icon2 = "lyshineui/images/raid/warTutorial_image2.dds",
      icon3 = "lyshineui/images/raid/warTutorial_image3.dds",
      icon4 = "lyshineui/images/raid/warTutorial_image4.dds",
      iconTitle1 = "@ui_war_tutorial_title_1_invasion",
      iconTitle2 = "@ui_war_tutorial_title_2",
      iconTitle3 = "@ui_war_tutorial_title_3",
      iconTitle4 = "@ui_war_tutorial_title_4",
      iconDesc1 = "@ui_war_tutorial_desc_1_invasion",
      iconDesc2 = "@ui_war_tutorial_desc_2_invasion",
      iconDesc3 = "@ui_war_tutorial_desc_3",
      iconDesc4 = "@ui_war_tutorial_desc_4"
    },
    [GameModeCommon.GAMEMODE_OUTPOST_RUSH] = {
      mainBg = "lyshineui/images/raid/orTutorialImage.dds",
      headerText = "@ui_outpost_rush_tutorial_how_it_works",
      icon1 = "lyshineui/images/raid/orTutorialIcon1.dds",
      icon2 = "lyshineui/images/raid/orTutorialIcon2.dds",
      icon3 = "lyshineui/images/raid/orTutorialIcon3.dds",
      icon4 = "lyshineui/images/raid/orTutorialIcon4.dds",
      iconTitle1 = "@ui_outpost_rush_tutorial_title1",
      iconTitle2 = "@ui_outpost_rush_tutorial_title2",
      iconTitle3 = "@ui_outpost_rush_tutorial_title3",
      iconTitle4 = "@ui_outpost_rush_tutorial_title4",
      iconDesc1 = "@ui_outpost_rush_tutorial_desc1",
      iconDesc2 = "@ui_outpost_rush_tutorial_desc2",
      iconDesc3 = "@ui_outpost_rush_tutorial_desc3",
      iconDesc4 = "@ui_outpost_rush_tutorial_desc4"
    }
  }
  self.dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.HudComponent.PlayerEntityId", function(self, playerEntityId)
    self.playerEntityId = playerEntityId
  end)
  self.dataLayer:RegisterOpenEvent("WarTutorialPopup", self.canvasId)
  DynamicBus.WarTutorialPopup.Connect(self.entityId, self)
  self:SetVisualElements()
end
function WarTutorialPopup:SetVisualElements()
  local titleStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 26,
    fontColor = self.UIStyle.COLOR_TAN_LIGHT
  }
  local descStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_NIMBUS_MEDIUM,
    fontSize = self.UIStyle.FONT_SIZE_BODY_NEW,
    fontColor = self.UIStyle.COLOR_TAN_LIGHT
  }
  SetTextStyle(self.Properties.Header, self.UIStyle.FONT_STYLE_HEADER_TAN)
  SetTextStyle(self.Properties.Title1, titleStyle)
  SetTextStyle(self.Properties.Title2, titleStyle)
  SetTextStyle(self.Properties.Title3, titleStyle)
  SetTextStyle(self.Properties.Title4, titleStyle)
  SetTextStyle(self.Properties.Desc1, descStyle)
  SetTextStyle(self.Properties.Desc2, descStyle)
  SetTextStyle(self.Properties.Desc3, descStyle)
  SetTextStyle(self.Properties.Desc4, descStyle)
  self.CloseButton:SetCallback(self.HideWarTutorialPopup, self)
  self.CloseButton:SetButtonStyle(self.CloseButton.BUTTON_STYLE_REGULAR)
end
function WarTutorialPopup:ShowWarTutorialPopup(gameMode)
  if self.isShowing then
    return
  end
  local gameModeData = self.GameModeData[gameMode]
  if gameModeData then
    UiTextBus.Event.SetTextWithFlags(self.Properties.Header, gameModeData.headerText, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title1, gameModeData.iconTitle1, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title2, gameModeData.iconTitle2, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title3, gameModeData.iconTitle3, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Title4, gameModeData.iconTitle4, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Desc1, gameModeData.iconDesc1, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Desc2, gameModeData.iconDesc2, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Desc3, gameModeData.iconDesc3, eUiTextSet_SetLocalized)
    UiTextBus.Event.SetTextWithFlags(self.Properties.Desc4, gameModeData.iconDesc4, eUiTextSet_SetLocalized)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon1, gameModeData.icon1)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon2, gameModeData.icon2)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon3, gameModeData.icon3)
    UiImageBus.Event.SetSpritePathname(self.Properties.Icon4, gameModeData.icon4)
    UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundImage, gameModeData.mainBg)
  end
  local headerOffsetPosY = 34
  local dividerOffsetPosY = 112
  if gameMode == GameModeCommon.GAMEMODE_INVASION then
    headerOffsetPosY = 18
    dividerOffsetPosY = 136
    local minLevel = ConfigProviderEventBus.Broadcast.GetInt("javelin.social.invasion-min-level") + 1
    local levelText = GetLocalizedReplacementText("@ui_tutorial_level_requirement", {level = minLevel})
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelRequirement, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelRequirement, levelText, eUiTextSet_SetLocalized)
  elseif gameMode == GameModeCommon.GAMEMODE_OUTPOST_RUSH then
    headerOffsetPosY = 18
    dividerOffsetPosY = 136
    local gameModeData = GameModeParticipantComponentRequestBus.Event.GetGameModeStaticData(self.playerEntityId, GameModeCommon.GAMEMODE_OUTPOST_RUSH)
    local minLevel = gameModeData.requiredLevel
    local levelText = GetLocalizedReplacementText("@ui_outpost_rush_tutorial_level_requirement", {level = minLevel})
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelRequirement, true)
    UiTextBus.Event.SetTextWithFlags(self.Properties.LevelRequirement, levelText, eUiTextSet_SetLocalized)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.LevelRequirement, false)
  end
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Header, headerOffsetPosY)
  UiTransformBus.Event.SetLocalPositionY(self.Properties.Divider, dividerOffsetPosY)
  self.dataLayer:SetScreenEnabled("WarTutorialPopup", true)
  self.isShowing = true
end
function WarTutorialPopup:HideWarTutorialPopup()
  if not self.isShowing then
    return
  end
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {
    opacity = 0,
    y = -10,
    ease = "QuadOut",
    onComplete = function()
      UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackgroundTutorial, false)
      self.dataLayer:SetScreenEnabled("WarTutorialPopup", false)
      self.isShowing = false
    end
  })
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackgroundTutorial, 0.3, {opacity = 1}, {opacity = 0, ease = "QuadOut"})
  self.audioHelper:PlaySound(self.audioHelper.Raid_Popup_Hide)
end
function WarTutorialPopup:OnTransitionIn(fromState, fromLevel, toState, toLevel)
  UiElementBus.Event.SetIsEnabled(self.Properties.PopupBackgroundTutorial, true)
  self.ScriptedEntityTweener:Play(self.Properties.PopupBackgroundTutorial, 0.5, {opacity = 0}, {opacity = 1, ease = "QuadOut"})
  self.ScriptedEntityTweener:Play(self.Properties.MasterContainer, 0.3, {opacity = 0, y = -10}, {
    opacity = 1,
    y = 0,
    ease = "QuadOut",
    delay = 0.2
  })
  self.audioHelper:PlaySound(self.audioHelper.Raid_Popup_Show)
end
function WarTutorialPopup:OnShutdown()
  BaseScreen.OnShutdown(self)
  DynamicBus.WarTutorialPopup.Disconnect(self.entityId, self)
  self.isShowing = false
end
return WarTutorialPopup
