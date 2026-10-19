-- Timer de foco (pomodoro): FocusMin de foco, BreakMin de pausa, contando sessoes (ate 4 bolinhas).
-- Expoe para a skin as variaveis FocusTime, FocusLabel, FocusPct, Running e Sessions.

function Initialize()
	phase = 'focus'
	running = false
	sessions = 0
	remaining = minutes() * 60
	last = ''
end

function minutes()
	if phase == 'focus' then return tonumber(SKIN:GetVariable('FocusMin')) or 25 end
	return tonumber(SKIN:GetVariable('BreakMin')) or 5
end

local function finish()
	local wav = (os.getenv('WINDIR') or 'C:\\Windows') .. '\\Media\\Alarm01.wav'
	SKIN:Bang('[Play "' .. wav .. '"]')
	if phase == 'focus' then
		sessions = sessions % 4 + 1
		phase = 'break'
	else
		phase = 'focus'
	end
	running = false
	remaining = minutes() * 60
end

function Toggle()
	running = not running
	if running then endAt = os.time() + remaining end
	Update()
end

function Reset()
	running = false
	phase = 'focus'
	remaining = minutes() * 60
	Update()
end

function Skip()
	running = false
	phase = (phase == 'focus') and 'break' or 'focus'
	remaining = minutes() * 60
	Update()
end

function Update()
	if running then
		remaining = endAt - os.time()
		if remaining <= 0 then finish() end
	end
	local total = minutes() * 60
	local key = phase .. remaining .. tostring(running) .. sessions .. total
	if key == last then return 0 end
	last = key
	local label = (phase == 'focus') and 'FOCO' or 'PAUSA'
	if not running and remaining == total then label = (phase == 'focus') and 'PRONTO PARA FOCAR' or 'HORA DA PAUSA' end
	SKIN:Bang('!SetVariable', 'FocusTime', string.format('%02d:%02d', math.floor(remaining / 60), remaining % 60))
	SKIN:Bang('!SetVariable', 'FocusLabel', label)
	SKIN:Bang('!SetVariable', 'FocusPct', string.format('%.4f', 1 - remaining / total))
	SKIN:Bang('!SetVariable', 'Running', running and 1 or 0)
	SKIN:Bang('!SetVariable', 'Sessions', sessions)
	SKIN:Bang('!SetVariable', 'IsBreak', phase == 'break' and 1 or 0)
	SKIN:Bang('!UpdateMeter', '*')
	SKIN:Bang('!Redraw')
	return 0
end
