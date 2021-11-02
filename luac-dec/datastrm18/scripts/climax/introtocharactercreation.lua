local IntroToCharacterCreation = {
  Properties = {}
}
function IntroToCharacterCreation:OnActivate()
  self.systemHandler = CrySystemNotificationsBus.Connect(self)
  self.introHandler = IntroControllerComponentNotificationsBus.Connect(self, self.entityId)
  self.dataLayer = RequireScript("LyShineUI.UiDataLayer")
  self.prevMusicVol = self.dataLayer:GetDataFromNode("Hud.LocalPlayer.Options.Audio.MusicVolume")
end
function IntroToCharacterCreation:OnLevelLoadComplete(levelName)
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.g_uiEnableStoryCinematic") then
    BinkRequestBus.Broadcast.SetUseRenderTarget(true)
    BinkRequestBus.Broadcast.PlayFromSource("@assets@/LyShineUI/Videos/IntroCinematic.bk2", true)
  else
    CinematicRequestBus.Broadcast.PlaySequenceByName("EstabShip_Sequence")
  end
  self.cinematicHandler = CinematicEventBus.Connect(self)
end
function IntroToCharacterCreation:OnCinematicStateChanged(cinematicName, state)
  if state == eMovieEvent_Stopped then
    if cinematicName == "EstabShip_Sequence" then
      CinematicRequestBus.Broadcast.PlaySequenceByName("Character_Create_02_Sequence")
    elseif cinematicName == "Character_Create_02_Sequence" then
      CinematicRequestBus.Broadcast.PlaySequenceByName("Character_Create_01_Sequence")
      LyShineManagerBus.Broadcast.SetState(4065059436)
      IntroControllerComponentRequestBus.Broadcast.SetCanSkipCutscene(false)
    end
  end
end
function IntroToCharacterCreation:OnDeactivate()
  if self.systemHandler then
    self.systemHandler:Disconnect()
    self.systemHandler = nil
  end
  if self.cinematicHandler then
    self.cinematicHandler:Disconnect()
    self.cinematicHandler = nil
  end
  if self.introHandler then
    self.introHandler:Disconnect()
    self.introHandler = nil
  end
  self.dataLayer:UnregisterObservers(self)
end
function IntroToCharacterCreation:HideSkipIcon(playerRequestedSkip)
  if playerRequestedSkip then
    if BinkRequestBus.Broadcast.IsPlaying() then
      CinematicRequestBus.Broadcast.PlaySequenceByName("EstabShip_Sequence")
      BinkRequestBus.Broadcast.CloseVideoFile()
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_Shell", "Mx_Shell_FTUE")
      AudioUtilsBus.Broadcast.SetGlobalAudioSwitchState("Music_FTUE", "Mx_FTUE_Intro")
      AudioUtilsBus.Broadcast.SetGlobalAudioRtpc("Option_MX", self.prevMusicVol)
    end
    self.cinematicHandler:Disconnect()
    CinematicRequestBus.Broadcast.StopSequence("EstabShip_Sequence")
    CinematicRequestBus.Broadcast.StopSequence("Character_Create_02_Sequence")
    AudioUtilsBus.Broadcast.ExecuteGlobalAudioTrigger("Play_UI_FTUE_SkipEnd", true, EntityId())
    CinematicRequestBus.Broadcast.PlaySequenceByName("Character_Create_01_Sequence")
    LyShineManagerBus.Broadcast.SetState(4065059436)
    IntroControllerComponentRequestBus.Broadcast.SetCanSkipCutscene(false)
  end
end
return IntroToCharacterCreation
