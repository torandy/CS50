-- Use classic tool to build an object of square
Object = require("libs.classic")
require("square")
local Sound = require("sound")

gameboard = {}
gameboard.button = {}

function gameboard:load()
	love.graphics.setFont(love.graphics.newFont(25))
	Sound:init(1, "sounds/phaseJump1.ogg", "static")
	Sound:init(2, "sounds/phaseJump2.ogg", "static")
	Sound:init(3, "sounds/phaseJump3.ogg", "static")
	Sound:init(4, "sounds/phaseJump4.ogg", "static")

	-- Load all 4 squares using a class of square object (name, value, r, g, b, x, y)
	sq1 = Square("green", 1, 0, 1, 0, 150, 150, "one")
	sq2 = Square("red", 2, 1, 0, 0, 0, 150, "two")
	sq3 = Square("yellow", 3, 1, 1, 0, 150, 0, "three")
	sq4 = Square("blue", 4, 0, 0, 1, 0, 0, "four")
	self.buttons = {
		{ sq1 },
		{ sq2 },
		{ sq3 },
		{ sq4 },
	}
	restartButton = { x = love.graphics.getWidth() / 2, y = love.graphics.getHeight() / 2, w = 150, h = 30 }

	self.roundCounter = 1
	self.totalNoOfRounds = 0
	self.lastPlayedRound = 0
	self.currentRound = 1
	self.activeMessage = ""
	self.playAgain = false

	-- controls current gameplay status
	self.playerTurn = false
	self.playerWin = false
	self.playerLose = false
	self.score = 0
	self.playerSequence = {}

	-- controls status of currently lit/unlit buttons
	self.activeLit = false
	self.activeBoxNumber = 0
	self.activeLitSpeed = 0
	self.timer = 0
end

function gameboard:update(dt)
	-- If not player's turn, and game is active (neither win nor lose), playback pattern
	if self.playerTurn == false and self.playerWin == false and self.playerLose == false then
		self.timer = self.timer + dt
		if self.timer > 0.75 then
			self.totalNoOfRounds = title.inputValue
			if self.lastPlayedRound < self.roundCounter then
				self:buttonLit(title.levelRounds[self.roundCounter], self.buttons)
				self.lastPlayedRound = self.lastPlayedRound + 1
				--self.roundCounter = 1
				self.timer = 0
			elseif self.lastPlayedRound > self.roundCounter then
				self:buttonLit(title.levelRounds[self.roundCounter], self.buttons)
				self.roundCounter = self.roundCounter + 1
				self.timer = 0
			elseif self.lastPlayedRound == self.roundCounter and self.lastPlayedRound < self.currentRound then
				self:buttonLit(title.levelRounds[self.roundCounter], self.buttons)
				self.roundCounter = self.roundCounter + 1
				self.timer = 0
			else
				self.playerTurn = true
				self.timer = 0
			end
		end
	end

	if self.playerWin == false and self.playerLose == false then
		self.activeMessage = "Current Round: " .. self.currentRound
	end

	-- Since default button status is unlit, if it's lit, we want to turn it off after LitSpeed
	if self.activeLit == true then
		self.timer = self.timer + dt
		if self.timer >= self.activeLitSpeed then
			self:buttonUnlit(self.activeBoxNumber, self.buttons)
			self.timer = 0
		end
	end
end

function gameboard:draw()
	-- Create the gameboard
	sq1:draw()
	sq2:draw()
	sq3:draw()
	sq4:draw()

	-- Active messages (Current Round, WIN or LOSE)
	love.graphics.setColor(0, 1, 0)
	love.graphics.printf(self.activeMessage, 0, 0, love.graphics.getWidth(), "center")

	-- Create the Score counter
	love.graphics.setColor(1, 1, 1)
	love.graphics.printf(
		"Score: " .. gameboard.score,
		0,
		love.graphics.getHeight() - 100,
		love.graphics.getWidth(),
		"center"
	)

	-- Display who's turn
	if self.playerWin == false and self.playerLose == false then
		if self.playerTurn == true then
			love.graphics.printf("Current turn: Player", 0, 100, love.graphics.getWidth(), "center")
		else
			love.graphics.printf("Current turn: Simon (Computer)", 0, 100, love.graphics.getWidth(), "center")
		end
	end

	-- Restart button
	if self.playAgain == true then
		love.graphics.setColor(0.8, 0.8, 0.8)
		love.graphics.rectangle(
			"fill",
			restartButton.x - (restartButton.w / 2),
			restartButton.y + (restartButton.y * 0.8),
			restartButton.w,
			restartButton.h,
			10,
			10,
			4
		)
		love.graphics.setColor(0, 0, 0)
		love.graphics.printf("Replay", 0, restartButton.y + (restartButton.y * 0.8), love.graphics.getWidth(), "center")
	end
end

-- Mouse click function
function gameboard:mousepressed(x, y, button)
	if button == 1 and self.playerTurn == true and self.playAgain == false then
		mouse = {
			x = x,
			y = y,
		}
		self:checkInsideBox(mouse, self.buttons)
	end
	if button == 1 and self.playerTurn == false and self.playAgain == true then
		if
			x > restartButton.x - (restartButton.w / 2)
			and x < restartButton.x - (restartButton.w / 2) + restartButton.w
			and y > restartButton.y + (restartButton.y * 0.8)
			and y < restartButton.y + (restartButton.y * 0.8) + restartButton.h
		then
			love.event.quit("restart")
		end
	end
end

-- Check if click is inside game box
function gameboard:checkInsideBox(mouse, boxes)
	-- mouse will represent mouse pointer
	local a_left = mouse.x
	local a_top = mouse.y

	-- for each click, check if it's within each of the boxs
	for i, eachButton in ipairs(boxes) do
		local b_left = eachButton[1].properties.x
		local b_right = eachButton[1].properties.x + eachButton[1].properties.w
		local b_top = eachButton[1].properties.y
		local b_bottom = eachButton[1].properties.y + eachButton[1].properties.h
		if
			-- if mouse x axis is greater than left game box
			a_left > b_left
			-- and mouse x axis less than right game box
			and a_left < b_right
			-- and mouse y axis is greater top game box
			and a_top > b_top
			-- and mouse y axis is less than bottom game box
			and a_top < b_bottom
		then
			-- Box found, add the box # to the sequence
			self:buttonLit(eachButton[1].properties.value, boxes)
			-- add the clicked button to the sequence and check if it matches pattern
			table.insert(self.playerSequence, eachButton[1].properties.value)
			self:compareSequences(self.playerSequence, title.levelRounds)
			return
		end
	end
end

-- Compare game sequences
function gameboard:compareSequences(playerSequence, gameSequence)
	local playerSequenceLength = #playerSequence
	if playerSequenceLength == self.currentRound then
		for i = 1, playerSequenceLength do
			if playerSequence[i] ~= gameSequence[i] then
				self:lose()
				self.playerSequence = {}
				return
			end
		end
		if self.lastPlayedRound == playerSequenceLength then
			self.score = self.score + (self.currentRound * 10)

			-- Check if you have played all rounds
			if self.currentRound == self.totalNoOfRounds then
				self:win()
			else
				self.currentRound = self.currentRound + 1
				self.playerTurn = false
				self.playerSequence = {}
				self.roundCounter = 1
				self.timer = 0
			end
		end
	end
end

-- Light up the box
function gameboard:buttonLit(boxNumber, boxes)
	for i, eachButton in ipairs(boxes) do
		if boxNumber == eachButton[1].properties.value then
			eachButton[1].properties.o = eachButton[1].buttonLitOpacity
			Sound:play(eachButton[1].properties.value)
			self.activeLit = true
			self.activeBoxNumber = boxNumber
			self.activeLitSpeed = eachButton[1].buttonLitSpeed
		end
	end
end

-- Dim the box
function gameboard:buttonUnlit(boxNumber, boxes)
	for i, eachButton in ipairs(boxes) do
		if boxNumber == eachButton[1].properties.value then
			eachButton[1].properties.o = eachButton[1].buttonUnlitOpacity
			self.activeLit = false
			self.activeBoxNumber = 0
			self.activeLitSpeed = 0
		end
	end
end

-- Win function
function gameboard:win()
	self.activeMessage = "You WIN with a score of: " .. self.score
	self.playerWin = true
	self.playerTurn = false
	self.playAgain = true
end

-- Lose function
function gameboard:lose()
	self.activeMessage = "Game Over, your score was: " .. self.score
	self.playerLose = true
	self.playerTurn = false
	self.playAgain = true
end
