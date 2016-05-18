hs.window.animationDuration = 0
local vw = hs.inspect.inspect
local configFileWatcher = nil

local modNone  = {}
local mAlt     = {"⌥"}
local modCmd   = {"⌘"}
local modShift = {"⇧"}
local modHyper = {"⌘", "⌃", "⇧"}

function reloadConfig()
  configFileWatcher:stop()
  configFileWatcher = nil
  hs.reload()
end

configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

local modalKeys = {}
local modalActive = false
local windowMode = ""

function modalBind( mods, key, callback )
  table.insert( modalKeys, hs.hotkey.new( mods, key, callback ) )
end

function toggleMode(targetMode)
  if (targetMode == windowMode) then
    windowMode = 'move'
  else
    windowMode = targetMode
  end
  hs.alert.closeAll()
  hs.alert.show( "Window manager: " .. windowMode, 999999 )
end

function disableModal()
  modalActive = false
  for keyCount = 1, #modalKeys do
    modalKeys[ keyCount ]:disable()
  end
  hs.alert.closeAll()
end

function enableModal()
  modalActive = true
  toggleMode('move')
  for keyCount = 1, #modalKeys do
      modalKeys[ keyCount ]:enable()
  end
end

function toggelModal()
  if( modalActive ) then
    disableModal()
  else
    enableModal()
  end
end

function toggleMode(targetMode)
  if (targetMode == windowMode) then
    windowMode = 'move'
  else
    windowMode = targetMode
  end
  hs.alert.closeAll()
  hs.alert.show( "Window Manager: " .. windowMode, 999999 )
end

function focusedWin()
  local win = hs.window.frontmostWindow()
  if (win == nil) then
    hs.alert.show("Can't find a focused window")
    return
  else
    return win
  end
end

function windowDown()
  if (windowMode == 'extend') then
    stretch(0, 0, 0, 1)
  elseif (windowMode == 'shrink') then
    stretch(0, 1, 0, -1)
  elseif (windowMode == 'move') then
    stretch(0, 1, 0, 0)
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowSouth()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenSouth()
  end
end

function windowUp()
  if (windowMode == 'extend') then
    stretch(0, -1, 0, 1)
  elseif (windowMode == 'shrink') then
    stretch(0, 0, 0, -1)
  elseif (windowMode == 'move') then
    stretch(0, -1, 0, 0)
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowNorth()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenNorth()
  end
end

function windowLeft()
  if (windowMode == 'extend') then
    stretch(-1, 0, 1, 0)
  elseif (windowMode == 'shrink') then
    stretch(0, 0, -1, 0)
  elseif (windowMode == 'move') then
    stretch(-1, 0, 0, 0)
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowWest()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenWest()
  end
end

function windowRight()
  if (windowMode == 'extend') then
    stretch(0, 0, 1, 0)
  elseif (windowMode == 'shrink') then
    stretch(1, 0, -1, 0)
  elseif (windowMode == 'move') then
    stretch(1, 0, 0, 0)
  elseif (windowMode == 'window') then
    focusedWin():moveOneScreenEast()
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowEast()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenEast()
  end
end

function windowResize()
  if (windowMode == 'extend') then
    stretch(-1, -1, 1, 1)
  elseif (windowMode == 'shrink') then
    stretch(1, 1, -1, -1)
  end
end

hs.hotkey.bind( modHyper, 'h', function() toggelModal() end )
modalBind( modNone, 'escape', function() disableModal() end )
modalBind( modNone, 'return', function() disableModal() end )

modalBind( modNone, 'm', function() toggleMode('move') end )
modalBind( modNone, 'e', function() toggleMode('extend') end )
modalBind( modNone, 's', function() toggleMode('shrink') end )
modalBind( modNone, 'p', function() toggleMode('focus') end )
modalBind( modNone, 't', function() toggleMode('throw') end )

modalBind( modNone, 'j', function() windowDown() end )
modalBind( modNone, 'k', function() windowUp() end )
modalBind( modNone, 'h', function() windowLeft() end )
modalBind( modNone, 'l', function() windowRight() end )
modalBind( modNone, 'z', function() windowResize() end )
modalBind( modShift, 'z', function() windowResize() end )

function fuzzyWindowEquals(one, two)
  if (math.floor(one.x) ~= math.floor(two.x)) then
    return false
  elseif (math.floor(one.y) ~= math.floor(two.y)) then
    return false
  elseif(math.floor(one.w/10) ~= math.floor(two.w/10)) then
    return false
  elseif(math.floor(one.h/10) ~= math.floor(two.h/10)) then
    return false
  else
    return true
  end
end

function stretch(x, y, w, h)
  local win = focusedWin()
  local screen = win:screen()
  local screenRect = screen:frame()
  local windowRect = win:frame()
  local wSteps = math.floor(screenRect.w / 10)
  local hSteps = math.floor(screenRect.h / 10)

  local windowsize = win:frame()
  local target_x = math.max(math.floor(windowRect.x + (x * wSteps)), 0)
  local target_y = math.max(math.floor(windowRect.y + (y * hSteps)), 0)
  local target_w = math.min(math.floor(windowRect.w + (w * wSteps)), screenRect.w)
  local target_h = math.min(math.floor(windowRect.h + (h * hSteps)), screenRect.h)
  local target = hs.geometry.new(target_x, target_y, target_w, target_h)
  win:setFrame(target)
end

function throw()
  if (#hs.screen.allScreens() > 1) then
    local current = hs.screen.mainScreen()
    local win = hs.window.focusedWindow()
    if (win ~= nil) then
      local target = win:screen():next()
      win:moveToScreen(target)
    end
  end
end

function brightness(change)
  local current = hs.brightness.get()
  local target = current + change
  hs.brightness.set(target)
  hs.alert.show("Brightness: " .. target)
end

function volume(change)
  local systemsound = hs.audiodevice.current().device
  local current = systemsound:volume()

  if(change == nil) then
    local muted = systemsound:muted()
    systemsound:setMuted(not muted)
    if (muted) then
      hs.alert.show("Volume: " .. current)
    else
      hs.alert.show("Muted")
    end
  else
    local target = current + change
    systemsound:setVolume(target)
    hs.alert.show("Volume: " .. target)
  end
end


hs.alert.show("Config loaded")
