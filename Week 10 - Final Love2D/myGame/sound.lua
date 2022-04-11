local sound = { active = {}, source = {} }

function sound:init(id, source, soundType)
	self.source[id] = love.audio.newSource(source, soundType)
end

function sound:play(id)
	sound.source[id]:play()
end

return sound
