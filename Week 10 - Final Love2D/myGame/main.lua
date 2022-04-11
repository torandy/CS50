-- Main game: Simon with multi levels
--[[
    Alt + L to run the code
    Extensions used in VSCode: Lua | Lua Debug | Love2D Support | Love2D Snippets | Path Autocomplete | vscode-lua | 
    vscode-lua-format | Auto Close Tag | Auto Rename Tag | Duplicate Action | image preview | StyLua (linting)
	Screen width: 800px
-- ]]

require("title")
require("gameboard")
require("sound")

function love.load()
	title:load()
	gameboard:load()
end

-- dt: Delta time equalizes the speed for all computers
function love.update(dt)
	title:update(dt)
	if title.validRounds == true then
		gameboard:update(dt)
	end
end

function love.draw()
	title:draw()
	if title.validRounds == true then
		gameboard:draw()
	end
end

function love.mousepressed(x, y, button)
	if title.validRounds == true then
		gameboard:mousepressed(x, y, button)
	end
end
