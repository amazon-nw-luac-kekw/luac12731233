local LoadingScreen = {
  Properties = {
    TipRotationTime = {
      default = 5,
      description = "Time before next tip is shown (seconds)"
    },
    BackgroundImage = {
      default = EntityId()
    },
    BasicScreen = {
      Container = {
        default = EntityId()
      },
      LoadingRune1 = {
        default = EntityId()
      },
      LoadingRune2 = {
        default = EntityId()
      }
    },
    TipsScreen = {
      Container = {
        default = EntityId()
      },
      LoadingRune1 = {
        default = EntityId()
      },
      LoadingRune2 = {
        default = EntityId()
      },
      LoadingRune3 = {
        default = EntityId()
      },
      LoadingText = {
        default = EntityId()
      }
    }
  },
  currentTipShownTime = 0,
  currentlyShowingTip = 0
}
local BaseScreen = RequireScript("LyShineUI._Common.BaseScreen")
BaseScreen:CreateNewScreen(LoadingScreen)
function LoadingScreen:OnInit()
  BaseScreen.OnInit(self)
  self:BusConnect(LoadScreenNotificationBus, self.entityId)
  math.randomseed(os.time())
  math.random()
  math.random()
  math.random()
  self:SetVisualElements()
  self.loadingTips = {
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic01.dds",
      text = "@loadingScreen_ingame_scenic01"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic02.dds",
      text = "@loadingScreen_ingame_scenic02"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic03.dds",
      text = "@loadingScreen_ingame_scenic03"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic04.dds",
      text = "@loadingScreen_ingame_scenic04"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic05.dds",
      text = "@loadingScreen_ingame_scenic05"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic06.dds",
      text = "@loadingScreen_ingame_scenic06"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic07.dds",
      text = "@loadingScreen_ingame_scenic07"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic08.dds",
      text = "@loadingScreen_ingame_scenic08"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic09.dds",
      text = "@loadingScreen_ingame_scenic09"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic10.dds",
      text = "@loadingScreen_ingame_scenic10"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic11.dds",
      text = "@loadingScreen_ingame_scenic11"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic12.dds",
      text = "@loadingScreen_ingame_scenic12"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic13.dds",
      text = "@loadingScreen_ingame_scenic13"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic14.dds",
      text = "@loadingScreen_ingame_scenic14"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic15.dds",
      text = "@loadingScreen_ingame_scenic15"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageScenic16.dds",
      text = "@loadingScreen_ingame_scenic16"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned01.dds",
      text = "@loadingScreen_ingame_damned01"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned02.dds",
      text = "@loadingScreen_ingame_damned02"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned03.dds",
      text = "@loadingScreen_ingame_damned03"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned04.dds",
      text = "@loadingScreen_ingame_damned04"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned05.dds",
      text = "@loadingScreen_ingame_damned05"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned06.dds",
      text = "@loadingScreen_ingame_damned06"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned07.dds",
      text = "@loadingScreen_ingame_damned07"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned08.dds",
      text = "@loadingScreen_ingame_damned08"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned09.dds",
      text = "@loadingScreen_ingame_damned09"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageDamned10.dds",
      text = "@loadingScreen_ingame_damned10"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient01.dds",
      text = "@loadingScreen_ingame_ancient01"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient02.dds",
      text = "@loadingScreen_ingame_ancient02"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient03.dds",
      text = "@loadingScreen_ingame_ancient03"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient04.dds",
      text = "@loadingScreen_ingame_ancient04"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient05.dds",
      text = "@loadingScreen_ingame_ancient05"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient06.dds",
      text = "@loadingScreen_ingame_ancient06"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient07.dds",
      text = "@loadingScreen_ingame_ancient07"
    },
    {
      image = "LyShineUI/Images/LoadingScreen/LoadingImages/loadingImageAncient08.dds",
      text = "@loadingScreen_ingame_ancient08"
    }
  }
end
function LoadingScreen:SetLoadingScreenType(screenType)
  self.screenType = screenType
end
function LoadingScreen:OnCanvasEnabledChanged(isEnabled)
  if isEnabled ~= self.isEnabled then
    if self.tickBusHandler ~= nil then
      self:BusDisconnect(self.tickBusHandler)
      self.tickBusHandler = nil
    end
    local isTipScreen = self.screenType == eLoadingScreenIds_LEVEL1 or self.screenType == eLoadingScreenIds_DEATH
    if isEnabled then
      UiElementBus.Event.SetIsEnabled(self.Properties.TipsScreen.Container, isTipScreen)
      UiElementBus.Event.SetIsEnabled(self.Properties.BasicScreen.Container, not isTipScreen)
      if isTipScreen then
        if not self.tickBusHandler then
          self.tickBusHandler = TickBus.Connect(self)
        end
        self:ShowNextTip()
        self.ScriptedEntityTweener:Play(self.Properties.TipsScreen.LoadingRune2, 50, {rotation = 0}, {timesToPlay = -1, rotation = 359})
        self.ScriptedEntityTweener:Play(self.Properties.TipsScreen.LoadingRune3, 50, {rotation = 0}, {timesToPlay = -1, rotation = -359})
        self.audioHelper:onUIStateChanged(self.audioHelper.UIState_LoadingScreen)
      else
        UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundImage, "LyShineUI/Images/LoadingScreen/LoadingImages/mainbg2.dds")
        self.ScriptedEntityTweener:Play(self.Properties.BasicScreen.LoadingRune1, 50, {rotation = 0}, {timesToPlay = -1, rotation = 359})
        self.ScriptedEntityTweener:Play(self.Properties.BasicScreen.LoadingRune2, 50, {rotation = 0}, {timesToPlay = -1, rotation = -359})
      end
    else
      if isTipScreen then
        if self.tickBusHandler ~= nil then
          self:BusDisconnect(self.tickBusHandler)
          self.tickBusHandler = nil
        end
        if self.screenType == eLoadingScreenIds_LEVEL1 then
          self.audioHelper:PlaySound(self.audioHelper.StopMenuMusic)
        end
        UiElementBus.Event.SetIsEnabled(self.Properties.TipsScreen.Container, false)
      else
        UiElementBus.Event.SetIsEnabled(self.Properties.BasicScreen.Container, false)
      end
      UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundImage, "lyshineui/images/icons/misc/empty.dds")
      self.ScriptedEntityTweener:Stop(self.Properties.TipsScreen.LoadingRune2)
      self.ScriptedEntityTweener:Stop(self.Properties.TipsScreen.LoadingRune3)
      self.ScriptedEntityTweener:Stop(self.Properties.BasicScreen.LoadingRune1)
      self.ScriptedEntityTweener:Stop(self.Properties.BasicScreen.LoadingRune2)
      local currentLevelName = LoadScreenBus.Broadcast.GetCurrentLevelName()
      if isTipScreen or currentLevelName == "newworld_vitaeeterna" then
        self:PlayerSpawned()
      end
    end
    self.isEnabled = isEnabled
  end
end
function LoadingScreen:SetVisualElements()
  local loadingTextStyle = {
    fontFamily = self.UIStyle.FONT_FAMILY_PICA,
    fontSize = 56,
    fontColor = self.UIStyle.COLOR_GRAY_80
  }
  SetTextStyle(self.TipsScreen.LoadingText, loadingTextStyle)
  UiElementBus.Event.SetIsEnabled(self.Properties.BasicScreen.Container, false)
end
function LoadingScreen:PlayerSpawned()
  self.playerEntityId = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.HudComponent.PlayerEntityId")
  if self.playerEntityId then
    GameRequestsBus.Broadcast.ClearFirstRun()
    DynamicBus.playerSpawningBus.Broadcast.onPlayerSpawned(true)
    LyShineDataLayerBus.Broadcast.SetData("Hud.LocalPlayer.Vitals.ShowRespawnEffects", false)
  end
end
function LoadingScreen:OnShutdown()
  BaseScreen.OnShutdown(self)
  if self.tickBusHandler ~= nil then
    self:BusDisconnect(self.tickBusHandler)
    self.tickBusHandler = nil
  end
  self.ScriptedEntityTweener:Stop(self.Properties.TipsScreen.LoadingRune2)
  self.ScriptedEntityTweener:Stop(self.Properties.TipsScreen.LoadingRune3)
  self.ScriptedEntityTweener:Stop(self.Properties.BasicScreen.LoadingRune1)
  self.ScriptedEntityTweener:Stop(self.Properties.BasicScreen.LoadingRune2)
end
function LoadingScreen:OnTick(elapsed, timePoint)
  self.currentTipShownTime = self.currentTipShownTime + elapsed
  if self.currentTipShownTime > self.Properties.TipRotationTime then
    self.currentTipShownTime = 0
    self:ShowNextTip()
  end
end
function LoadingScreen:ShowNextTip()
  local nextTipToShow = math.random(1, #self.loadingTips)
  while nextTipToShow == self.currentlyShowingTip and 1 < #self.loadingTips do
    nextTipToShow = math.random(1, #self.loadingTips)
  end
  self.currentlyShowingTip = nextTipToShow
  local tipData = self.loadingTips[self.currentlyShowingTip]
  if tipData.Image == "" then
    UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundImage, false)
  else
    UiElementBus.Event.SetIsEnabled(self.Properties.BackgroundImage, true)
    UiImageBus.Event.SetSpritePathname(self.Properties.BackgroundImage, tipData.image)
  end
  UiTextBus.Event.SetTextWithFlags(self.Properties.TipsScreen.LoadingText, tipData.text, eUiTextSet_SetLocalized)
end
return LoadingScreen
