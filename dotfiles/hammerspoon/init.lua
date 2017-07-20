hs.window.animationDuration = 0
local vw = hs.inspect.inspect
local configFileWatcher = nil

ctrl_table = {
    sends_escape = true,
    last_mods = {}
}

control_key_timer = hs.timer.delayed.new(0.2, function()
    ctrl_table["send_escape"] = false
end
)

last_mods = {}

control_handler = function(evt)
  local new_mods = evt:getFlags()
  if last_mods["ctrl"] == new_mods["ctrl"] then
      return false
  end
  if not last_mods["ctrl"] then
    last_mods = new_mods
    ctrl_table["send_escape"] = true
    control_key_timer:start()
  else
    -- log.i("contrtol released")
    -- log.i(ctrl_table["send_escape"])
    if ctrl_table["send_escape"] then
      -- log.i("send escape key...")
      hs.eventtap.keyStroke({}, "ESCAPE")
    end
    last_mods = new_mods
    control_key_timer:stop()
  end
  return false
end

control_tap = hs.eventtap.new({12}, control_handler)

control_tap:start()


local modNone  = {}
local mAlt     = {"⌥"}
local modCmd   = {"⌘"}
local modShift = {"⇧"}
local modHyper = {"⌘", "⌃", "⇧"}
local hyper = {"⌘", "⌥"}

-- init grid
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0
hs.grid.GRIDWIDTH = 7
hs.grid.GRIDHEIGHT = 5

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
    hs.grid.resizeWindowTaller().pushWindowDown()
  elseif (windowMode == 'shrink') then
    hs.grid.resizeWindowShorter().pushWindowDown()
  elseif (windowMode == 'move') then
    hs.grid.pushWindowDown()
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowSouth()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenSouth()
  elseif (windowMode == 'normal') then
    hs.eventtap.keyStroke({}, 'down')
  end
end

function windowUp()
  if (windowMode == 'extend') then
    hs.grid.resizeWindowTaller().pushWindowUp()
  elseif (windowMode == 'shrink') then
    hs.grid.resizeWindowShorter().pushWindowUp()
  elseif (windowMode == 'move') then
    hs.grid.pushWindowUp()
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowNorth()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenNorth()
  elseif (windowMode == 'normal') then
    hs.eventtap.keyStroke({}, 'up')
  end
end

function windowLeft()
  if (windowMode == 'extend') then
    hs.grid.resizeWindowWider().pushWindowLeft()
  elseif (windowMode == 'shrink') then
    hs.grid.resizeWindowThinner().pushWindowLeft()
  elseif (windowMode == 'move') then
    hs.grid.pushWindowLeft()
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowWest()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenWest()
  elseif (windowMode == 'normal') then
    hs.eventtap.keyStroke({}, 'left')
  end
end

function windowRight()
  if (windowMode == 'extend') then
    hs.grid.resizeWindowWider().pushWindowRight()
  elseif (windowMode == 'shrink') then
    hs.grid.resizeWindowThinner().pushWindowRight()
  elseif (windowMode == 'move') then
    hs.grid.pushWindowRight()
  elseif (windowMode == 'window') then
    focusedWin():moveOneScreenEast()
  elseif (windowMode == 'focus') then
    focusedWin():focusWindowEast()
  elseif (windowMode == 'throw') then
    focusedWin():moveOneScreenEast()
  elseif (windowMode == 'normal') then
    hs.eventtap.keyStroke({}, 'right')
  end
end

function windowResize()
  if (windowMode == 'extend') then
    hs.grid.maximizeWindow()
  elseif (windowMode == 'shrink') then
    hs.grid.hide()
  end
end

hs.hotkey.bind( modHyper, 'h', function() toggelModal() end )
modalBind( modNone, 'escape', function() disableModal() end )
modalBind( modNone, 'return', function() disableModal() end )

modalBind( modNone, 'm', function() toggleMode('move') end )
modalBind( modNone, 'e', function() toggleMode('extend') end )
modalBind( modNone, 's', function() toggleMode('shrink') end )
modalBind( modNone, 'f', function() toggleMode('focus') end )
modalBind( modNone, 't', function() toggleMode('throw') end )
modalBind( modNone, 'n', function() toggleMode('normal') end )
modalBind( modNone, 'c', function() disableModal(); hs.caffeinate.startScreensaver() end )

modalBind( modNone, 'j', function() windowDown() end )
modalBind( modNone, 'k', function() windowUp() end )
modalBind( modNone, 'h', function() windowLeft() end )
modalBind( modNone, 'l', function() windowRight() end )
modalBind( modNone, 'z', function() windowResize() end )
modalBind( modShift, 'z', function() windowResize() end )

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
