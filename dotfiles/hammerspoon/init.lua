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

function modalBind( mods, key, callback )
  table.insert( modalKeys, hs.hotkey.new( mods, key, callback ) )
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
  windowMode = 'move'
  for keyCount = 1, #modalKeys do
      modalKeys[ keyCount ]:enable()
  end
  hs.alert.show( "Window manager active", 999999 )
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
end

function windowDown()
  if (windowMode == 'extend') then
    stretch(0, 0, 0, 1)
  elseif (windowMode == 'shrink') then
    stretch(0, 1, 0, -1)
  elseif (windowMode == 'move') then
    stretch(0, 1, 0, 0)
  end
end

function windowUp()
  if (windowMode == 'extend') then
    stretch(0, -1, 0, 1)
  elseif (windowMode == 'shrink') then
    stretch(0, 0, 0, -1)
  elseif (windowMode == 'move') then
    stretch(0, -1, 0, 0)
  end
end

function windowLeft()
  if (windowMode == 'extend') then
    stretch(-1, 0, 1, 0)
  elseif (windowMode == 'shrink') then
    stretch(0, 0, -1, 0)
  elseif (windowMode == 'move') then
    stretch(-1, 0, 0, 0)
  end
end

function windowRight()
  if (windowMode == 'extend') then
    stretch(0, 0, 1, 0)
  elseif (windowMode == 'shrink') then
    stretch(1, 0, -1, 0)
  elseif (windowMode == 'move') then
    stretch(1, 0, 0, 0)
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

modalBind( modNone, 'j', function() windowDown() end )
--modalBind( modNone, 'j', function() stretch(0, 0, 0, 1) end )
--modalBind( modShift, 'j', function() stretch(0, 1, 0, -1) end )
--modalBind( modCmd, 'j', function() stretch(0, -1, 0, 0) end )

modalBind( modNone, 'k', function() windowUp() end )
--modalBind( modNone, 'k', function() stretch(0, -1, 0, 1) end )
--modalBind( modShift, 'k', function() stretch(0, 0, 0, -1) end )
--modalBind( modCmd, 'k', function() stretch(0, 1, 0, 0) end )

modalBind( modNone, 'h', function() windowLeft() end )
--modalBind( modNone, 'h', function() stretch(-1, 0, 1, 0) end )
--modalBind( modShift, 'h', function() stretch(0, 0, -1, 0) end )
--modalBind( modCmd, 'h', function() stretch(-1, 0, 0, 0) end )

modalBind( modNone, 'l', function() windowRight() end )
--modalBind( modNone, 'l', function() stretch(0, 0, 1, 0) end )
--modalBind( modShift, 'l', function() stretch(1, 0, -1, 0) end )
--modalBind( modCmd, 'l', function() stretch(1, 0, 0, 0) end )

modalBind( modNone, 'z', function() windowResize() end )
--modalBind( modNone, 'z', function() stretch(-1, -1, 1, 1) end )
modalBind( modShift, 'z', function() windowResize() end )
--modalBind( modShift, 'z', function() stretch(1, 1, -1, -1) end )

function stretch(x, y, w, h)
  local win = hs.window.focusedWindow()
  if (win == nil) then
    hs.alert.show("Can't rezise nothing..")
    do return end
  end
  
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
  win:setFrame(hs.geometry.new(target_x, target_y, target_w, target_h))
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

-- Renize and move windows. Same key twice throws to next display
--hs.hotkey.bind(move, "H", function() stretch(0,0,0.5,0.5) end)
--hs.hotkey.bind(move, "T", function() stretch(0,0.5,0.5,0.5) end)
--hs.hotkey.bind(move, "N", function() stretch(0.5,0.5,0.5,0.5) end)
--hs.hotkey.bind(move, "S", function() stretch(0.5,0,0.5,0.5) end)
--hs.hotkey.bind(move, "M", function() stretch(0,0,1,1) end)

function brightness(change)
  local current = hs.brightness.get()
  local target = current + change
  hs.brightness.set(target)
  hs.alert.show("Brightness: " .. target)
end

-- Control brightness
--hs.hotkey.bind(control, "N", function() brightness(-10) end)
--hs.hotkey.bind(control, "S", function() brightness(10) end)

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

-- Control volume
--hs.hotkey.bind(control, "H", function() volume(-10) end)
--hs.hotkey.bind(control, "T", function() volume(10) end)
--hs.hotkey.bind(control, "C", function() volume() end)


hs.alert.show("Config loaded")
