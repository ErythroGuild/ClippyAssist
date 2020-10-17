local data = ClippyAssist.data

local animation_queue = {"RestPose"}

-----------------------
-- Utility Functions --
-----------------------

local function QueueAnimation(animation)
	table.insert(animation_queue, animation)
	table.insert(animation_queue, "RestPose")
end

local function AnimateTexCoordsSingle(texture,
	texturePath,
	textureWidth, textureHeight,
	frameWidth, frameHeight,
	numFrames, elapsed, throttle)
	if ( not texture.frame ) then
		-- initialize everything
		texture.frame = 1;
		texture.throttle = throttle;
		texture.numColumns = floor(textureWidth/frameWidth);
		texture.numRows = floor(textureHeight/frameHeight);
		texture.columnWidth = frameWidth/textureWidth;
		texture.rowHeight = frameHeight/textureHeight;
		texture.isFinished = false;
	end
	local frame = texture.frame;
	if ( not texture.throttle or texture.throttle > throttle ) then
		local framesToAdvance = floor(texture.throttle / throttle);
		while ( frame + framesToAdvance > numFrames ) do
			frame = frame - numFrames;
		end
		frame = frame + framesToAdvance;
		texture.throttle = 0;
		local left = mod(frame-1, texture.numColumns)*texture.columnWidth;
		local right = left + texture.columnWidth;
		local bottom = ceil(frame/texture.numColumns)*texture.rowHeight;
		local top = bottom - texture.rowHeight;
		texture:SetTexCoord(left, right, top, bottom);
		if texture.frame == 1 then
			texture:SetTexture(texturePath)
		end

		texture.frame = frame;
		if frame == numFrames then
			texture.isFinished = true
		end
	else
		texture.throttle = texture.throttle + elapsed;
	end
end

----------------------
-- Main Frame Setup --
----------------------

local frame = CreateFrame("Frame", "ClippyFrame", UIParent)
frame:SetSize(124, 93)
frame:SetPoint("CENTER")
frame:SetFrameStrata("HIGH")

ClippyFrame.events = {}
function ClippyFrame_OnEvent(self, event, ...)
	ClippyFrame.events[event](self, ...)
end
frame:SetScript("OnEvent", ClippyFrame_OnEvent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_STOPPED_MOVING")
frame:RegisterEvent("PLAYER_ENTER_COMBAT")
frame:RegisterEvent("PLAYER_LEAVE_COMBAT")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_STARTED_MOVING")

local texture = frame:CreateTexture(nil, "OVERLAY")
frame.texture = texture
texture:SetAllPoints("ClippyFrame")
frame:SetScript("OnUpdate", function(self, elapsed)
	local animation = animation_queue[1]
	local frame_duration
	if texture.frame then
		frame_duration = data[animation].timing[texture.frame]
	else
		frame_duration = data[animation].timing[1]
	end

	AnimateTexCoordsSingle(self.texture,
		data[animation].path,
		data[animation].tex_width, 
		data[animation].tex_height,
		124, 93,
		data[animation].frames,
		elapsed,
		frame_duration)

	if texture.isFinished then
		texture.isFinished = false
		if #(animation_queue) > 1 then
			table.remove(animation_queue, 1)
			animation = animation_queue[1]
			texture.frame = nil
		end
	end
end)

frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

--------------------
-- Event Handlers --
--------------------

function ClippyFrame.events:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	C_Timer.After(5.0, function()
		QueueAnimation("Greeting2")
		ClippyFrame.texture.frame = nil
		ClippyFrame:Show()
	end)
end

function ClippyFrame.events:PLAYER_STOPPED_MOVING()
	local chance = math.random()
	if chance < 0.15 then
		QueueAnimation("GetAttention")
	end
end

function ClippyFrame.events:PLAYER_ENTER_COMBAT()
	local chance = math.random()
	if chance < 0.60 then
		QueueAnimation("LookDown")
	end
end

function ClippyFrame.events:PLAYER_LEAVE_COMBAT()
	local chance = math.random()
	if chance < 0.20 then
		QueueAnimation("Congratulate")
	end
end

function ClippyFrame.events:PLAYER_DEAD()
	QueueAnimation("EmptyTrash")
end

function ClippyFrame.events:PLAYER_STARTED_MOVING()
	local chance = math.random()
	if chance < 0.05 then
		QueueAnimation("GetArtsy")
	end
end

--------------------
-- Slash Commands --
--------------------
SLASH_CLIPPY1 = "/clippy"
function SlashCmdList.CLIPPY(msg, editBox)
	QueueAnimation(msg)	-- no error checking!
end
