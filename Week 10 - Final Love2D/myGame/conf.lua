-- This file helps show the console as well as setup some global settings

function love.conf(t)
	t.title = "Simon" -- The title of the window the game is in (string)
	t.version = "11.4" -- The LÖVE version this game was made for (string)
	t.console = false -- Attach a console (boolean, Windows only)
	t.window.width = 800 -- The window width (number)
	t.window.height = 600 -- The window height (number)
end
