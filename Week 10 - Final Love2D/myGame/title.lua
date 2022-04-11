-- Each level adds 3 pattern types, this randomly sets an array of elements based on level and # of rounds.
title = { validRounds = false, levelRounds = {}, inputValue = 0 }

function title:load()
	self.minRounds = 1
	self.maxRounds = 9
	self.inputRoundsText = "Enter the # of rounds you wish to play ("
		.. self.minRounds
		.. "-"
		.. self.maxRounds
		.. "): "
	self.errorStringText = "Please only enter an integer (between " .. self.minRounds .. "-" .. self.maxRounds .. "): "
	self.errorIntegerText = "Integer outside range (between " .. self.minRounds .. "-" .. self.maxRounds .. "): "
	self.inputCounter = 0

	self.level = 0
end

function title:update(dt)
	--self:checkInput()
end

-- Input message for # of rounds
function title:draw()
	if title.validRounds == false then
		love.graphics.setColor(0, 1, 1)
		love.graphics.printf(
			"Welcome to Simon\n The goal of this game is to repeat the sequence after me.",
			0,
			0,
			love.graphics.getWidth(),
			"center"
		)

		love.graphics.setColor(1, 1, 1)
		love.graphics.printf(
			title.inputRoundsText,
			0,
			love.graphics.getHeight() / 2,
			love.graphics.getWidth(),
			"center"
		)

		love.graphics.printf(
			"Esc: Quit game\nLeft Mouse Click: Select box",
			0,
			love.graphics.getHeight() - 100,
			love.graphics.getWidth(),
			"left"
		)
	end
end

-- Validation of inputed rounds
function title:checkInput() end

-- Each level has 4 unique objects, the higher the level, the more objects added
function title:setRounds(level, rounds)
	totalNumberOfPatterns = 4
	for i = 1, rounds do
		math.randomseed(os.time())
		title.levelRounds[i] = love.math.random(1, totalNumberOfPatterns * level)
		--print("levelRounds: " .. title.levelRounds[i])
	end
end

function love.textinput(text)
	-- Check if number
	local input = tonumber(text)
	if input == nil then
		title.inputRoundsText = title.errorStringText
	else
		-- Check if # of rounds is within allowed range
		title.inputCounter = title.inputCounter + 1
		if title.inputCounter == 1 then
			if input >= title.minRounds and input <= title.maxRounds then
				title.inputRoundsText = title.inputRoundsText .. text
				title.inputValue = input
			else
				title.inputRoundsText = title.errorIntegerText
				title.inputCounter = 0
			end
		end
	end
end

-- exit and enter conditions
function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	if love.keyboard.isDown("return", "kpenter") then
		if title.inputValue >= title.minRounds and title.inputValue <= title.maxRounds then
			title.validRounds = true
			title:setRounds(1, title.inputValue)
		end
	end
end
