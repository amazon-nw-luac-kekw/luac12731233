local TimeHelperFunctions = {
  secondsInMinute = 60,
  secondsInHour = 3600,
  secondsInDay = 86400,
  secondsInYear = 31536000,
  minutesInHour = 60,
  hoursInDay = 24
}
function TimeHelperFunctions:ConvertSecondsToDaysHoursMinutesSeconds(seconds)
  seconds = math.ceil(seconds)
  local days = math.floor(seconds / self.secondsInDay)
  seconds = seconds % self.secondsInDay
  local hours = math.floor(seconds / self.secondsInHour)
  seconds = seconds % self.secondsInHour
  local minutes = math.floor(seconds / self.secondsInMinute)
  seconds = seconds % self.secondsInMinute
  return days, hours, minutes, seconds
end
function TimeHelperFunctions:ConvertSecondsToHrsMinSecString(seconds, showDays, omitZeros, useSpacing)
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return omitZeros and "00" or "00:00:00"
  else
    local days, hours, mins, secs = self:ConvertSecondsToDaysHoursMinutesSeconds(seconds)
    showDays = showDays and 0 < days
    days = string.format("%02.f", days)
    hours = string.format("%02.f", showDays and hours or hours + days * 24)
    mins = string.format("%02.f", mins)
    secs = string.format("%02.f", secs)
    local spacing = ":"
    if useSpacing then
      spacing = " : "
    end
    if not omitZeros then
      local timeString = hours .. spacing .. mins .. spacing .. secs
      return showDays and days .. ":" .. timeString or timeString
    else
      local order = {
        days,
        hours,
        mins,
        secs
      }
      local outString = ""
      local hasFoundNonZero = false
      for i = showDays and 1 or 2, #order do
        if hasFoundNonZero or order[i] ~= "00" then
          if hasFoundNonZero then
            outString = outString .. spacing
          end
          outString = outString .. order[i]
          hasFoundNonZero = true
        end
      end
      return outString
    end
  end
end
function TimeHelperFunctions:ConvertToVerboseDurationString(durationSeconds, showZeroSeconds, skipSeconds)
  local days, hours, minutes, seconds = self:ConvertSecondsToDaysHoursMinutesSeconds(durationSeconds)
  local timeString = ""
  if days == 1 then
    timeString = timeString .. " " .. tostring(days) .. " @ui_day"
  elseif 0 < days then
    timeString = timeString .. " " .. tostring(days) .. " @ui_days"
  end
  if hours == 1 then
    timeString = timeString .. " " .. tostring(hours) .. " @ui_hour"
  elseif 0 < hours then
    timeString = timeString .. " " .. tostring(hours) .. " @ui_hours"
  end
  if minutes == 1 then
    timeString = timeString .. " " .. tostring(minutes) .. " @ui_minute"
  elseif 0 < minutes then
    timeString = timeString .. " " .. tostring(minutes) .. " @ui_minutes"
  end
  if not skipSeconds or durationSeconds < 60 then
    if seconds == 1 then
      timeString = timeString .. " " .. tostring(seconds) .. " @ui_second"
    elseif 0 < seconds or showZeroSeconds then
      timeString = timeString .. " " .. tostring(seconds) .. " @ui_seconds"
    end
  end
  if #timeString == 0 then
    timeString = " 0 @ui_seconds"
  end
  return string.sub(timeString, 2, -1)
end
function TimeHelperFunctions:ConvertToShorthandString(durationSeconds, alwaysShowSeconds, largestUnitOnly)
  local days, hours, minutes, seconds = self:ConvertSecondsToDaysHoursMinutesSeconds(durationSeconds)
  local timeString = ""
  if 0 < days then
    if timeString ~= "" then
      timeString = timeString .. " "
    end
    if largestUnitOnly and 12 < hours then
      days = days + 1
    end
    timeString = timeString .. tostring(days) .. "@ui_days_short"
    if largestUnitOnly then
      return timeString
    end
  end
  if 0 < hours then
    if timeString ~= "" then
      timeString = timeString .. " "
    end
    if largestUnitOnly and 30 < minutes then
      hours = hours + 1
    end
    timeString = timeString .. tostring(hours) .. "@ui_hours_short"
    if largestUnitOnly then
      return timeString
    end
  end
  if 0 < minutes then
    if timeString ~= "" then
      timeString = timeString .. " "
    end
    if largestUnitOnly and 30 < seconds then
      minutes = minutes + 1
    end
    timeString = timeString .. tostring(minutes) .. "@ui_minutes_short"
    if largestUnitOnly then
      return timeString
    end
  end
  if 0 < seconds or alwaysShowSeconds then
    if timeString ~= "" then
      timeString = timeString .. " "
    end
    if largestUnitOnly and seconds < 59 then
      seconds = seconds + 1
    end
    timeString = timeString .. tostring(seconds) .. "@ui_seconds_short"
    if largestUnitOnly then
      return timeString
    end
  end
  return timeString
end
function TimeHelperFunctions:ConvertToLargestTimeEstimate(durationSeconds, usePastTense, useShort)
  local days, hours, minutes, seconds = self:ConvertSecondsToDaysHoursMinutesSeconds(durationSeconds)
  if not self.largeTimeEstimateStrings then
    self.largeTimeEstimateStrings = {
      past = {
        year = "@ui_morethanoneyear",
        days = "@ui_daysago",
        day = "@ui_dayago",
        hours = "@ui_hoursago",
        hour = "@ui_hourago",
        minutes = "@ui_minutesago",
        minute = "@ui_minuteago"
      },
      present = {
        year = "@ui_morethanoneyear",
        days = "@ui_days_with_time",
        day = "@ui_day_with_time",
        hours = "@ui_hours_with_time",
        hour = "@ui_hour_with_time",
        minutes = "@ui_minutes_with_time",
        minute = "@ui_minute_with_time"
      },
      short = {
        year = "@ui_morethanoneyear_short",
        days = "@ui_days_with_time_short",
        day = "@ui_day_with_time_short",
        hours = "@ui_hours_with_time_short",
        hour = "@ui_hour_with_time_short",
        minutes = "@ui_minutes_with_time_short",
        minute = "@ui_minute_with_time_short"
      }
    }
  end
  local stringSetToUse
  if useShort then
    stringSetToUse = self.largeTimeEstimateStrings.short
  elseif usePastTense then
    stringSetToUse = self.largeTimeEstimateStrings.past
  else
    stringSetToUse = self.largeTimeEstimateStrings.present
  end
  local timeString
  if 365 < days then
    timeString = stringSetToUse.year
  elseif 1 < days then
    timeString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.days, days)
  elseif days == 1 then
    timeString = stringSetToUse.day
  elseif 1 < hours then
    timeString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.hours, hours)
  elseif hours == 1 then
    timeString = stringSetToUse.hour
  elseif 1 < minutes then
    timeString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.minutes, minutes)
  else
    timeString = stringSetToUse.minute
  end
  return timeString
end
function TimeHelperFunctions:ConvertToTwoLargestTimeEstimate(durationSeconds)
  local days, hours, minutes, seconds = self:ConvertSecondsToDaysHoursMinutesSeconds(durationSeconds)
  if not self.twoLargeTimeEstimateStrings then
    self.twoLargeTimeEstimateStrings = {
      year = "@ui_morethanoneyear",
      days = "@ui_days_with_time",
      day = "@ui_day_with_time",
      hours = "@ui_hours_with_time",
      hour = "@ui_hour_with_time",
      minutes = "@ui_minutes_with_time",
      minute = "@ui_minute_with_time",
      seconds = "@ui_secondsLeft"
    }
  end
  local stringSetToUse = self.twoLargeTimeEstimateStrings
  local timeString1, timeString2, timeString
  if 365 < days then
    timeString = stringSetToUse.year
  elseif 1 < days then
    timeString1 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.days, days)
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.hours, hours)
    if hours == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  elseif days == 1 then
    timeString1 = stringSetToUse.day
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.hours, hours)
    if hours == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  elseif 1 < hours then
    timeString1 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.hours, hours)
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.minutes, minutes)
    if minutes == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  elseif hours == 1 then
    timeString1 = stringSetToUse.hour
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.minutes, minutes)
    if minutes == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  elseif 1 < minutes then
    timeString1 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.minutes, minutes)
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.seconds, seconds)
    if seconds == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  elseif minutes == 1 then
    timeString1 = stringSetToUse.minute
    timeString2 = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.seconds, seconds)
    if seconds == 0 then
      timeString = timeString1
    else
      timeString = timeString1 .. " " .. timeString2
    end
  else
    timeString = LyShineScriptBindRequestBus.Broadcast.LocalizeTextWithReplacement(stringSetToUse.seconds, seconds)
  end
  return timeString
end
function TimeHelperFunctions:GetLocalizedTime(utcTimeInSeconds, showSeconds, appendTimeZone, useSoftReturn, useRawUtc)
  local format = "%r"
  if not showSeconds then
    local locale = DynamicBus.Globals.Broadcast.GetLocale()
    if locale == "en-US" then
      format = "%I:%M %p"
    else
      format = "%H:%M"
    end
  end
  local prependFormat = useRawUtc and "!" or ""
  local time = os.date(prependFormat .. format, utcTimeInSeconds)
  if appendTimeZone then
    if useSoftReturn then
      time = string.format([[
%s
%s]], time, os.date("%Z"))
    else
      time = string.format("%s %s", time, os.date("%Z"))
    end
  end
  return time
end
function TimeHelperFunctions:GetServerDateTable(utcTimeInSeconds)
  local regionData = PlayerDataManagerBus.Broadcast.GetRegionData()
  local serverDate = os.date("!*t", utcTimeInSeconds)
  local isDst = false
  if regionData.observesDst then
    isDst = self:IsServerTimeInDST(regionData.dstRuleId, serverDate.day, serverDate.month, serverDate.wday - 1, serverDate.hour)
  end
  local serverUtcOffset = regionData.utcOffset
  if isDst then
    serverUtcOffset = serverUtcOffset + 1
  end
  local offsetServerUtc = utcTimeInSeconds + serverUtcOffset * self.secondsInHour
  return os.date("!*t", offsetServerUtc)
end
function TimeHelperFunctions:GetLocalizedAbbrevDate(utcTimeInSeconds)
  local dateTable = self:GetServerDateTable(utcTimeInSeconds)
  local dayName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_abbrev_dayofweek_" .. tostring(dateTable.wday))
  local monthName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_abbrev_month_" .. tostring(dateTable.month))
  local dateString = GetLocalizedReplacementText("@ui_date_format", {
    dayOfWeek = dayName,
    month = monthName,
    date = tostring(dateTable.day)
  })
  return dateString
end
function TimeHelperFunctions:GetLocalizedLongDate(utcTimeInSeconds)
  local dateTable = self:GetServerDateTable(utcTimeInSeconds)
  local dayName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_long_dayofweek_" .. tostring(dateTable.wday))
  local monthName = LyShineScriptBindRequestBus.Broadcast.LocalizeText("@ui_long_month_" .. tostring(dateTable.month))
  local dateString = GetLocalizedReplacementText("@ui_long_date_format", {
    dayOfWeek = dayName,
    month = monthName,
    date = tostring(dateTable.day)
  })
  return dateString
end
function TimeHelperFunctions:GetLocalizedDate(utcTimeInSeconds)
  return os.date("%x", utcTimeInSeconds)
end
function TimeHelperFunctions:GetLocalTimeZoneName()
  local format = GetLocalizedReplacementText("@ui_timezone_format", {
    timezone = os.date("%Z")
  })
  return format
end
function TimeHelperFunctions:GetServerAbbreviatedTimeZoneName(localTimeUtcOffset, isDst)
  local prefix = "@ui_server_utc_"
  if isDst then
    prefix = prefix .. "dst_"
  end
  return LyShineScriptBindRequestBus.Broadcast.LocalizeText(prefix .. tostring(localTimeUtcOffset))
end
function TimeHelperFunctions:GetLocalizedDateTime(utcTimeInSeconds, abbreviated)
  local dateTimeString = GetLocalizedReplacementText("@ui_date_time_format", {
    date = abbreviated and self:GetLocalizedAbbrevDate(utcTimeInSeconds) or self:GetLocalizedLongDate(utcTimeInSeconds),
    time = self:GetLocalizedTime(utcTimeInSeconds)
  })
  return dateTimeString
end
function TimeHelperFunctions:ServerNow()
  local serverTime = LocalPlayerComponentRequestBus.Broadcast.GetCurrentSyncedWallClockTime()
  if serverTime then
    return serverTime
  else
    return WallClockTimePoint:Now()
  end
end
function TimeHelperFunctions:ServerSecondsSinceEpoch()
  return self:ServerNow():GetTimeSinceEpoc():ToSeconds()
end
function TimeHelperFunctions:GetUtcStartOfDay()
  local now = self:ServerSecondsSinceEpoch()
  return now - now % self.secondsInDay
end
function TimeHelperFunctions:IsServerTimeInDST(dstRule, day, month, dow, hour)
  if dstRule == 2806025604 then
    if month < 3 or 11 < month then
      return false
    end
    if 3 < month and month < 11 then
      return true
    end
    local previousSunday = day - dow
    if month == 3 then
      local inDstDay = 8 <= previousSunday
      if inDstDay and dow == 0 and 8 <= day and day <= 14 then
        return 2 <= hour
      else
        return inDstDay
      end
    end
    if dow == 0 and 1 <= day and day <= 7 then
      return hour < 2
    else
      return previousSunday <= 0
    end
  elseif dstRule == 3411872625 then
    if 4 < month and month < 10 then
      return false
    end
    if 10 < month or month < 4 then
      return true
    end
    local previousSunday = day - dow
    if month == 10 then
      local inDstDay = 1 <= previousSunday
      if inDstDay and dow == 0 and 1 <= day and day <= 7 then
        return 2 <= hour
      else
        return inDstDay
      end
    end
    if dow == 0 and 1 <= day and day <= 7 then
      return hour < 2
    else
      return false
    end
  else
    if month < 3 or 10 < month then
      return false
    end
    if 3 < month and month < 10 then
      return true
    end
    local previousSunday = day - dow
    if month == 3 then
      local inDstDay = 25 <= previousSunday
      if inDstDay and dow == 0 then
        return 2 <= hour
      else
        return inDstDay
      end
    end
    if month == 10 then
      if 25 <= previousSunday and dow == 0 then
        return hour < 2
      else
        return previousSunday < 25
      end
    end
    return false
  end
end
function TimeHelperFunctions:GetCurrentServerTime()
  local serverUtc = self:ServerSecondsSinceEpoch()
  return self:GetLocalizedServerTime(serverUtc)
end
function TimeHelperFunctions:GetLocalizedServerTime(serverUtc, displayTimeZone)
  local regionData = PlayerDataManagerBus.Broadcast.GetRegionData()
  local serverDate = os.date("!*t", serverUtc)
  local isDst = false
  if regionData.observesDst then
    isDst = self:IsServerTimeInDST(regionData.dstRuleId, serverDate.day, serverDate.month, serverDate.wday - 1, serverDate.hour)
  end
  local serverUtcOffset = regionData.utcOffset
  if isDst then
    serverUtcOffset = serverUtcOffset + 1
  end
  local offsetServerUtc = serverUtc + serverUtcOffset * self.secondsInHour
  if displayTimeZone == nil then
    displayTimeZone = true
  end
  local timeText = self:GetLocalizedTime(offsetServerUtc, false, false, false, true)
  if displayTimeZone then
    timeText = self:GetLocalizedTime(offsetServerUtc, false, false, false, true) .. "  (" .. self:GetServerAbbreviatedTimeZoneName(regionData.utcOffset, isDst) .. ")"
  end
  return timeText
end
return TimeHelperFunctions
