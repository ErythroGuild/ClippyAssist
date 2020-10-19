local data = ClippyAssist.data

local animation_queue = {}
local animation_needs_init = true

---------------------------
-- Convenience Functions --
---------------------------

local function QueueAnimation(animation, callback)
	table.insert(animation_queue, {
		mode = "normal",
		["animation"] = animation,
		["callback"] = callback,
	})
	animation_needs_init = true
end

local function QueueAnimationLoop(animation, callback)
	table.insert(animation_queue, {
		mode = "loop",
		["animation"] = animation,
		["callback"] = callback,
	})
	animation_needs_init = true
end

-- Queue an animation with no callback.
local function SingleAnimation(animation)
	QueueAnimation(animation, function() end)
	table.insert(animation_queue, {
		mode = "loop",
		["animation"] = "RestPose",
		["callback"] = function() end,
	})
end

-- Queue an animation with no callback, *only* if no animations are
-- currently playing already.
local function IdleAnimation(animation)
	if #(animation_queue) == 1 and
		animation_queue[1].animation == "RestPose"
	then
		SingleAnimation(animation)
	end
end

-------------------------
-- Animation Functions --
-------------------------

-- Initialize the data structures AnimateTexCoords() requires to
-- properly calculate tex coords. Minimal work is performed here.
local function InitTexCoords(
	texture, animation,
	frameWidth, frameHeight,
	callback)

	animation_needs_init = false

	-- Actual texture path is set on first tex coord update
	-- (AnimateTexCoords()), not here (since proper tex coords
	-- haven't been calculated yet).
	texture.isSet = false

	texture.frame = 1
	texture.elapsed = 0

	texture.cols = floor(animation.tex_width / frameWidth)
	texture.rows = floor(animation.tex_height / frameHeight)

	-- Setting tex coords bases dimensions off of the parent's
	-- UV-coords, where max (width, height) is (1, 1).
	texture.w_col = frameWidth / animation.tex_width
	texture.h_row = frameHeight / animation.tex_height

	-- Using a callback to handle the "animation finished" event
	-- is the most flexible way to do this.
	texture.callback = callback
end

-- Moves local texture coordinates of a frame across a spritesheet
-- texture (stop-motion animation).
-- Intended to be called inside a tight OnUpdate() loop.
-- (Based off the code for Blizzard's LFG "eye" searching icon.)
local function AnimateTexCoords(texture, animation, elapsed)
	
	local elapsed_total = elapsed + texture.elapsed

	-- If next frame isn't due yet, account for the current update's
	-- elapsed time, then return without performing any work.
	if texture.isSet and
		elapsed_total <= animation.timing[texture.frame]
	then
		texture.elapsed = elapsed_total
		return
	end

	-- Increment current frame until we reach the one to display.
	-- Less efficient than Blizzard's method (which assumes a constant
	-- frame time), but allows for variable frame timing.
	while texture.frame <= animation.frames and
		elapsed_total > animation.timing[texture.frame]
	do
		elapsed_total = elapsed_total - animation.timing[texture.frame]
		texture.frame = texture.frame + 1
	end
	texture.elapsed = elapsed_total

	-- If we've gone past the end of the current animation, we can
	-- trigger our callback and then return (w/out doing work to figure
	-- out our new tex coords).
	if texture.frame > animation.frames then
		texture.callback()
		return
	end
	
	-- Calculate new local texture coordinates.
	-- `bottom` is calculated before `top` to make ceil() rounding not
	-- require an extra check.
	local left = ((texture.frame - 1) % texture.cols) * texture.w_col
	local right = left + texture.w_col
	local bottom = ceil(texture.frame / texture.cols) * texture.h_row
	local top = bottom - texture.h_row
	texture:SetTexCoord(left, right, top, bottom)

	-- This is only called once per animation, on the first frame.
	-- Subsequent OnUpdate() calls during the first frame will return
	-- early and skip executing this line.
	-- This call is delayed until after SetTexCoord() to prevent the
	-- frame from flashing entire unset textures.
	if not texture.isSet then
		texture:SetTexture(animation.path)
		texture.isSet = true
	end
end

----------------------
-- Main Frame Setup --
----------------------

-- Create and position addon frame.
local frame = CreateFrame("Frame", "ClippyFrame", UIParent)
frame:SetSize(124, 93)
frame:SetPoint("CENTER")
frame:SetFrameStrata("HIGH")

-- Create frame texture and set anchors.
local texture = frame:CreateTexture(nil, "OVERLAY")
frame.texture = texture
texture:SetAllPoints("ClippyFrame")
frame:Show()

-- Set mouse interaction properties of addon frame.
frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnMouseUp", function(self, button)
	IdleAnimation("Wave1")
end)
frame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
	IdleAnimation("Wave2")
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Set up syntactic sugar for handling all events.
ClippyFrame.events = {}
function ClippyFrame_OnEvent(self, event, ...)
	ClippyFrame.events[event](self, ...)
end
frame:SetScript("OnEvent", ClippyFrame_OnEvent)

-- Set up animation update logic.
frame:SetScript("OnUpdate", function(self, elapsed)
	if #(animation_queue) == 0 then
		return
	end

	if animation_needs_init then
		InitTexCoords(
			frame.texture,
			data[animation_queue[1].animation],
			124, 93,
			function()
				animation_queue[1].callback()
				animation_needs_init = true
				if #(animation_queue) > 1 or
					animation_queue[1].mode == "normal"
				then
					table.remove(animation_queue, 1)
				end
				if #(animation_queue) == 0 then
					frame.texture:SetTexture(nil)
				end
			end)
	end
	
	AnimateTexCoords(
		frame.texture,
		data[animation_queue[1].animation],
		elapsed)

	end)

------------
-- Events --
------------

-- Idle: 10% GetArtsy, 10% Print, 20% GetAttention, 60% Look{direction}
local function AnimateIdle()
	local delay = math.random(20, 30)
	C_Timer.After(delay, function()
		local chance = math.random()
		if chance < 0.10 then
			IdleAnimation("GetArtsy")
		elseif chance < 0.20 then
			IdleAnimation("Print")
		elseif chance < 0.40 then
			IdleAnimation("GetAttention")
		else
			chance = math.random(1, 8)
			if     chance == 1 then IdleAnimation("LookUp")
			elseif chance == 2 then IdleAnimation("LookUpRight")
			elseif chance == 3 then IdleAnimation("LookRight")
			elseif chance == 4 then IdleAnimation("LookDownRight")
			elseif chance == 5 then IdleAnimation("LookDown")
			elseif chance == 6 then IdleAnimation("LookDownLeft")
			elseif chance == 7 then IdleAnimation("LookLeft")
			elseif chance == 8 then IdleAnimation("LookUpLeft")
			end
		end
		AnimateIdle()
	end)
end

-- Alert
frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("ROLE_POLL_BEGIN")
function frame.events:CHAT_MSG_RAID_WARNING(...) SingleAnimation("Alert") end
function frame.events:READY_CHECK(...)		SingleAnimation("Alert") end
function frame.events:ROLE_POLL_BEGIN(...)	SingleAnimation("Alert") end
-- paragon chest complete
-- received zone quest (legion/bfa assaults)

-- CheckingSomething
-- encounter journal open
-- reading TRP/MRP

-- Congratulate
frame:RegisterEvent("BOSS_KILL")
frame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("ISLAND_COMPLETED")
frame:RegisterEvent("WARFRONT_COMPLETED")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_UNGHOST")
frame:RegisterEvent("PLAYER_ALIVE")
frame:RegisterEvent("DUEL_FINISHED")
frame:RegisterEvent("NEW_MOUNT_ADDED")
frame:RegisterEvent("NEW_PET_ADDED")
frame:RegisterEvent("NEW_TOY_ADDED")
frame:RegisterEvent("BARBER_SHOP_APPEARANCE_APPLIED")
function frame.events:BOSS_KILL(...)			SingleAnimation("Congratulate") end
function frame.events:CHALLENGE_MODE_COMPLETED() SingleAnimation("Congratulate") end
function frame.events:QUEST_TURNED_IN(...)		SingleAnimation("Congratulate") end
function frame.events:ISLAND_COMPLETED(...)		SingleAnimation("Congratulate") end
function frame.events:WARFRONT_COMPLETED(...)	SingleAnimation("Congratulate") end
function frame.events:ACHIEVEMENT_EARNED(...)	SingleAnimation("Congratulate") end
function frame.events:PLAYER_LEVEL_UP(...)		SingleAnimation("Congratulate") end
function frame.events:PLAYER_UNGHOST()			SingleAnimation("Congratulate") end
function frame.events:PLAYER_ALIVE()
	if (not UnitIsDeadOrGhost("player")) then SingleAnimation("Congratulate") end
end
function frame.events:DUEL_FINISHED()			SingleAnimation("Congratulate") end
function frame.events:NEW_MOUNT_ADDED(...)		SingleAnimation("Congratulate") end
function frame.events:NEW_PET_ADDED(...)		SingleAnimation("Congratulate") end
function frame.events:NEW_TOY_ADDED(...)		SingleAnimation("Congratulate") end
function frame.events:BARBER_SHOP_APPEARANCE_APPLIED() SingleAnimation("Congratulate") end
-- rare elite killed
-- received AH mail
-- reached reputation level
-- crafting complete
-- new appearance set
-- all battlepets healed

-- EmptyTrash
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("ENCOUNTER_END")
frame:RegisterEvent("DELETE_ITEM_CONFIRM")
function frame.events:PLAYER_DEAD()				SingleAnimation("EmptyTrash") end
function frame.events:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
	if success == 0 then SingleAnimation("EmptyTrash") end
end
function frame.events:DELETE_ITEM_CONFIRM(...)	SingleAnimation("EmptyTrash") end
-- key failed
-- duel lost

-- Explain
-- weakaura speech bubble (while idle)

-- GetAttention
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
function frame.events:PLAYER_FLAGS_CHANGED(unitTarget)
	if unitTarget == "player" and UnitIsAFK("player") then SingleAnimation("GetAttention") end
end
-- afk logout starts

-- GoodBye
-- casting hearth
-- casting teleport

-- Greeting
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame.events:PLAYER_ENTERING_WORLD(isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		C_Timer.After(5.0, function()
			if (math.random() < 0.40) then
				SingleAnimation("Greeting1")
			else
				SingleAnimation("Greeting2")
			end
			AnimateIdle()
		end)
	end
end

-- Hide
-- cast invisibility
-- cast stealth

-- Print
-- export weakaura

-- Processing
-- viewing LFG applicants

-- Searching
-- viewing LFG groups

-- SendMail
frame:RegisterEvent("MAIL_SEND_SUCCESS")
function frame.events:MAIL_SEND_SUCCESS()	SingleAnimation("SendMail") end
-- trade complete

-- Show
-- exit invisibility
-- exit stealth
-- cancel logout

-- Aggro drop (e.g. fade, feign death)
-- 1. Hide
-- 2. Show

-- Pull timer
frame:RegisterEvent("START_TIMER")
function frame.events:START_TIMER(timerType, timeRemaining, totalTime)
	if timerType == 3 then
		SingleAnimation("Alert")
		SingleAnimation("GetAttention")
		local x_mid = GetScreenWidth() / 2
		local y_mid = GetScreenHeight() / 2
		local x_frame, y_frame = frame:GetCenter()
		x_frame = x_frame - x_mid
		y_frame = y_frame - y_mid
		local theta = atan2(y_frame, x_frame)
		if     theta >  -45 and theta <=   45 then SingleAnimation("GestureRight2")
		elseif theta >   45 and theta <=  135 then SingleAnimation("GestureDown2")
		elseif theta >  135 or  theta <= -135 then SingleAnimation("GestureLeft2")
		elseif theta > -135 and theta <=  -45 then SingleAnimation("GestureUp2")
		end
		if     theta >  -22.5 and theta <=   22.5 then SingleAnimation("LookRight")
		elseif theta >   22.5 and theta <=   67.5 then SingleAnimation("LookDownRight")
		elseif theta >   67.5 and theta <=  112.5 then SingleAnimation("LookDown")
		elseif theta >  112.5 and theta <=  157.5 then SingleAnimation("LookDownLeft")
		elseif theta >  157.5 and theta <= -157.5 then SingleAnimation("LookLeft")
		elseif theta > -157.5 and theta <= -112.5 then SingleAnimation("LookUpLeft")
		elseif theta > -112.5 and theta <=  -67.5 then SingleAnimation("LookUp")
		elseif theta >  -67.5 and theta <=  -22.5 then SingleAnimation("LookUpRight")
		end
	end
end

-- Log out (timer)
-- 1. Wave1
-- 2. Save
-- 3. Print
-- 4. GoodBye

--------------------
-- Slash Commands --
--------------------
SLASH_CLIPPY1 = "/clippy"
function SlashCmdList.CLIPPY(msg, editBox)
	if msg == "" then
		msg = "-help"
	end
	if msg == "-help" or msg == "-h" or msg == "-?" then
		print("You are currently using Clippy Assist v" ..
			GetAddOnMetadata("ClippyAssist", "Version") .. ".")
		print("It looks like you're trying to use Clippy Assist. " .. 
			"Would you like some help with that?")
		print("  -help: Shows this text.")
		print("  -hide: Temporarily hide Clippy. :c")
		print("  -show: Show Clippy again. :D")
		print("  -reset: Resets Clippy's position.")
		print("  -list: Lists all available animations.")
		print("  everything else: Attempts to play that animation.")
	elseif msg == "-hide" then
		frame:Hide()	-- Note: also prevents frame:OnUpdate() from firing!
	elseif msg == "-show" then
		frame:Show()
	elseif msg == "-reset" or msg == "-r" then
		frame:ClearAllPoints()
		frame:SetPoint("CENTER")
	elseif msg == "-list" or msg == "-l" then
		print("Clippy's available animations:")
		local display = {}
		for i,_ in pairs(data) do
			table.insert(display, i)
		end
		table.sort(display)
		for _,name in ipairs(display) do
			print("  " .. name)
		end
	else
		if data.msg == nil then
			print("Couldn't find that animation.")
			print("Use \"/clippy -list\" to list available animations.")
			print("Use \"/clippy -help\" to view all commands.")
		else
			SingleAnimation(msg)
		end
	end
end
