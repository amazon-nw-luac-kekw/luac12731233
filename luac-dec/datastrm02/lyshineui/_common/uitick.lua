local timingUtils = RequireScript("LyShineUI._Common.TimingUtils")
local hoverIntentDetector = RequireScript("LyShineUI._Common.HoverIntentDetector")
UITick = {handler = nil}
function UITick:Activate()
  self.handler = TickBus.Connect(self)
  self.configHandler = ConfigSystemEventBus.Connect(self)
  self.crySystemEventHandler = CrySystemEventBus.Connect(self)
end
function UITick:OnTick(deltaTime, timePoint)
  if self.profiler then
    self.profiler:RadTmBegin("UI Lua Tick")
  end
  DynamicBus.UITickBus.Broadcast.OnTick(deltaTime, timePoint)
  timingUtils:OnTick(deltaTime, timePoint)
  hoverIntentDetector:OnTick(deltaTime, timePoint)
  if self.profiler then
    self.profiler:RadTmEnd("UI Lua Tick")
  end
end
function UITick:OnConfigChanged()
  if ConfigProviderEventBus.Broadcast.GetBool("UIFeatures.enable-automation") and not self.profiler then
    self.profiler = RequireScript("LyShineUI._Common.Profiler")
  end
end
function UITick:OnCrySystemPostViewSystemUpdate()
  DynamicBus.UITickBus.Broadcast.OnCrySystemPostViewSystemUpdate()
end
function UITick:Deactivate()
  self.handler:Disconnect()
  self.handler = nil
  self.configHandler:Disconnect()
  self.configHandler = nil
  self.crySystemEventHandler:Disconnect()
  self.crySystemEventHandler = nil
end
return UITick
