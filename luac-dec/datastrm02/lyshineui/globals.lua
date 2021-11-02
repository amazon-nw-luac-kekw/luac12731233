g_cachedScripts = {}
require("LyShineUI._Common.Common")
local dataLayer = RequireScript("LyShineUI.UiDataLayer")
local UITick = require("LyShineUI._Common.UITick")
local territoryDataHandler = RequireScript("LyShineUI._Common.TerritoryDataHandler")
local tweenerCommon = RequireScript("LyShineUI._Common.ScriptedEntityTweenerCommon")
local hudSettingCommon = RequireScript("LyShineUI._Common.HudSettingCommon")
local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local cryActionCommon = RequireScript("LyShineUI._Common.CryActionCommon")
local entitlementsDataHandler = RequireScript("LyShineUI._Common.EntitlementsDataHandler")
local InputFilters = RequireScript("LyShineUI._Common.InputFilters")
local Logger = RequireScript("LyShineUI.Automation.Logger")
local loader = RequireScript("LyShineUI.uiLoader")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
local cinematicUtils = RequireScript("LyShineUI._Common.CinematicUtils")
local dataLayerGlobals = RequireScript("LyShineUI.DataLayerGlobals")
local StaticItemDataManager = RequireScript("LyShineUI._Common.StaticItemDataManager")
local tweener = RequireScript("Scripts.ScriptedEntityTweener.ScriptedEntityTweener")
local socialDataHandler = RequireScript("LyShineUI._Common.SocialDataHandler")
local contractsDataHandler = RequireScript("LyShineUI._Common.ContractsDataHandler")
local popupWrapper = RequireScript("LyShineUI.Popup.PopupRequestWrapper")
local Globals = {
  Properties = {},
  systemHandler = nil,
  configHandler = nil,
  locale = nil
}
function Globals:ResetGlobals()
  ScriptedEntityTweenerBus.Broadcast.Reset()
  tweener:Reset()
  g_entityTables = {}
  g_isDragging = false
  g_lastDropTime = WallClockTimePoint()
  g_slashCommands = {}
  g_watchedVariables = {}
  g_screenNameOverrides = {}
  g_Logger = require("Scripts._Common.Logger")
  g_timelineCounter = 0
  g_animationCallbackCounter = 0
  g_animationCallbacks = {}
  contractsDataHandler:Reset()
  socialDataHandler:Reset()
  popupWrapper:Reset()
  timingUtils:Reset()
  hoverIntentDetector:Reset()
  entitlementsDataHandler:Reset()
  territoryDataHandler:Reset()
  tweenerCommon:OnDeactivate()
  hudSettingCommon:Reset()
  cryActionCommon:OnDeactivate()
  InputFilters:Reset()
  loader:OnDeactivate()
  cinematicUtils:Reset()
  StaticItemDataManager:Reset()
end
function Globals:OnActivate()
  self:ResetGlobals()
  self.systemHandler = CrySystemNotificationsBus.Connect(self)
  dataLayer:Activate()
  dataLayerGlobals:Activate()
  UITick:Activate()
  self.lyShineScriptBind = LyShineScriptBindNotificationBus.Connect(self)
  self:EnableAutomation()
  local sizeOfIcon = 16384
  local maxIcons = 500
  self.inventoryIconPool = LyShineManagerBus.Broadcast.CreateSpriteCachePool(maxIcons * sizeOfIcon)
  DynamicBus.Globals.Connect(self.entityId, self)
  socialDataHandler:OnActivate()
  territoryDataHandler:OnActivate()
  entitlementsDataHandler:OnActivate()
  tweenerCommon:OnActivate()
  cryActionCommon:OnActivate()
  StaticItemDataManager:OnActivate()
  LyShineScriptBindRequestBus.Broadcast.AddLevelToUnloadCanvases("frontend")
  LyShineScriptBindRequestBus.Broadcast.AddLevelToUnloadCanvases("frontendv2")
  LyShineScriptBindRequestBus.Broadcast.AddLevelToUnloadCanvases("ftue")
  LyShineScriptBindRequestBus.Broadcast.AddLevelToUnloadCanvases("climax/climaxftue_02")
  LyShineScriptBindRequestBus.Broadcast.AddLevelToUnloadCanvases("climax_introscene")
  LoadScreenBus.Broadcast.RegisterLoadingScreen("LyShineUI/HUD/LoadingScreen.uicanvas")
  loader:OnActivate()
end
function Globals:GetInventoryIconPoolId()
  return self.inventoryIconPool
end
function Globals:SetLocale(localeName)
  self.locale = localeName
end
function Globals:GetLocale()
  return self.locale
end
function Globals:EnableAutomation()
  if not self.automation then
    local enableAutomation = ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-automation")
    if enableAutomation then
      local automation = RequireScript("LyShineUI.Automation.Automation")
      self.automationHandler = UiAutomationNotificationBus.Connect(self)
      self.automation = automation
      self.automation:Init(self.entityId)
      self.configHandler:Disconnect()
      self.configHandler = nil
    else
      self.configHandler = ConfigSystemEventBus.Connect(self)
    end
  end
end
function Globals:OnConfigChanged()
  self:EnableAutomation()
end
function Globals:OnEditorGameStart()
  loader:StartLoading()
end
function Globals:OnEditorGameStop()
  timingUtils:Reset()
  hoverIntentDetector:Reset()
  LyShineManagerBus.Broadcast.DeregisterAllScreens()
  LyShineDataLayerBus.Broadcast.Reset()
end
function Globals:LoadLevel()
  dataLayer:RegisterAndExecuteDataObserver(self, "Hud.LocalPlayer.Options.Localization.Language", self.SetLocale)
  hudSettingCommon:OnActivate()
  InputFilters:OnActivate()
  InputFilters:OnActivate()
  if FtueSystemRequestBus.Broadcast.IsFtue() then
    self.tutorialSystem = require("LyShineUI.Tutorial.TutorialSystem")
    self.tutorialSystem:OnInit()
    self.tutorialSystem:LoadTutorial("Inventory")
    self.tutorialSystem:LoadTutorial("MasteryTree")
  end
  if not LyShineScriptBindRequestBus.Broadcast.IsEditor() then
    loader:StartLoading(self.levelNameCrc, self.prevLevelCrc)
  end
end
function Globals:OnPlayerConnected()
  if GameRequestsBus.Broadcast.IsFastLoadEnabled() then
    self:LoadLevel()
    DynamicBus.playerSpawningBus.Broadcast.onPlayerSpawned(true)
  end
end
function Globals:OnLevelLoad(levelNameCrc)
  self.prevLevelCrc = self.levelNameCrc
  self.levelNameCrc = levelNameCrc
  if GameRequestsBus.Broadcast.IsFastLoadEnabled() then
    return
  end
  self:LoadLevel()
end
function Globals:OnLevelLoadComplete(levelNameCrc)
end
function Globals:OnLevelUnload(levelNameCrc)
  loader:StopLoading()
  local audioHelper = RequireScript("LyShineUI.AudioEvents")
  audioHelper:SetTicking(false)
  if self.tutorialSystem then
    self.tutorialSystem:OnShutdown()
    self.tutorialSystem = nil
  end
  if LyShineScriptBindRequestBus.Broadcast.ReleasedCanvases() then
    LyShineManagerBus.Broadcast.DeregisterAllScreens()
    self:ResetGlobals()
    LyShineDataLayerBus.Broadcast.Reset()
  end
end
function Globals:OnLevelUnloadComplete(levelNameCrc)
end
function Globals:SetupUIAutomation(valueList)
  taskName = valueList[1]
  paramsTable = {}
  for i = 2, #valueList, 2 do
    paramsTable[valueList[i]] = valueList[i + 1]
  end
  if self.automation then
    self.automation:SetupAutomation(taskName, paramsTable)
  end
end
function Globals:BeginUIAutomation()
  if self.automation then
    self.automation:BeginAutomation()
  end
end
function Globals:ResetUIAutomation()
  if self.automation then
    self.automation:ResetAutomation()
  end
end
function Globals:OnDeactivate()
  self:ResetGlobals()
  dataLayer:Deactivate()
  UITick:Deactivate()
  DynamicBus.Globals.Disconnect(self.entityId, self)
  if self.configHandler then
    self.configHandler:Disconnect()
    self.configHandler = nil
  end
  if self.automationHandler then
    self.automationHandler:Disconnect()
    self.automationHandler = nil
  end
  if self.systemHandler then
    self.systemHandler:Disconnect()
    self.systemHandler = nil
  end
  if self.lyShineScriptBind then
    self.lyShineScriptBind:Disconnect()
    self.lyShineScriptBind = nil
  end
end
return Globals
