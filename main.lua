-- luacheck: globals audio display easing graphics lfs media native network Runtime system timer transition

package.path = "./src/?.lua;" .. package.path
local composer = require "composer"

-- hide the status bar
display.setStatusBar (display.HiddenStatusBar)
-- load menu screen
composer.gotoScene "seq.menu"
