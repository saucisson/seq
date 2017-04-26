-- luacheck: globals audio display easing graphics lfs media native network Runtime system timer transition

local Composer = require "composer"
local Widget   = require "widget"

local scene = Composer.newScene ()

function scene.create ()
  -- Background:
  local background = display.newImageRect ("img/background.jpg", display.actualContentWidth, display.actualContentHeight)
  background.anchorX = 0
  background.anchorY = 0
  background.x = 0 + display.screenOriginX
  background.y = 0 + display.screenOriginY
  scene.view:insert (background)
  -- Titile:
  local title = display.newImageRect ("img/logo.png", 264, 42)
  title.x = display.contentCenterX
  title.y = 100
  scene.view:insert (title)
  -- Play button:
  local play = Widget.newButton {
    label       = "Play",
    labelColor = { default = {255}, over = {128} },
    default    = "img/button.png",
    over       = "img/button-over.png",
    width       = 154,
    height     = 40,
    onRelease  = function ()
      Composer.gotoScene ("seq.game", "fade", 500)
      return true
    end
  }
  play.x = display.contentCenterX
  play.y = display.contentHeight - 125
  scene.view:insert (play)
end

function scene.show (_, event)
  if event.phase == "will" then
    -- Called when the scene is still off screen and is about to move on screen
  elseif event.phase == "did" then
    -- Called when the scene is now on screen
  end
end

function scene.hide (_, event)
  if event.phase == "will" then
    -- Called when the scene is on screen and is about to move off screen
  elseif event.phase == "did" then
    -- Called when the scene is now off screen
  end
end

function scene.destroy ()
  for _, element in pairs (scene.view) do
    element:removeSelf ()
  end
end

-- Listeners:
scene:addEventListener ("create" , scene)
scene:addEventListener ("show"   , scene)
scene:addEventListener ("hide"   , scene)
scene:addEventListener ("destroy", scene)

return scene
