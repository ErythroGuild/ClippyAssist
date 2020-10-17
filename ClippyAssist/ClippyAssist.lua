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

local texture = frame:CreateTexture(nil, "OVERLAY")
frame.texture = texture
texture:SetAllPoints("ClippyFrame")

frame:EnableMouse(true)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnMouseUp", function(self, button)
	QueueAnimation("Wave1")
end)
frame:SetScript("OnDragStart", function(self, button)
	self:StartMoving()
	QueueAnimation("Wave2")
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

ClippyFrame.events = {}
function ClippyFrame_OnEvent(self, event, ...)
	ClippyFrame.events[event](self, ...)
end
frame:SetScript("OnEvent", ClippyFrame_OnEvent)

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

-- Events

-- Idle: 10% GetArtsy, 10% Print, 20% GetAttention, 60% Look{direction}
local function AnimateIdle()
	local delay = math.random(20, 45)
	C_Timer.After(delay, function()
		local chance = math.random()
		if chance < 0.10 then
			QueueAnimation("GetArtsy")
		elseif chance < 0.20 then
			QueueAnimation("Print")
		elseif chance < 0.40 then
			QueueAnimation("GetAttention")
		else
			chance = math.random(1, 8)
			if     chance == 1 then QueueAnimation("LookUp")
			elseif chance == 2 then QueueAnimation("LookUpRight")
			elseif chance == 3 then QueueAnimation("LookRight")
			elseif chance == 4 then QueueAnimation("LookDownRight")
			elseif chance == 5 then QueueAnimation("LookDown")
			elseif chance == 6 then QueueAnimation("LookDownLeft")
			elseif chance == 7 then QueueAnimation("LookLeft")
			elseif chance == 8 then QueueAnimation("LookUpLeft")
			end
		end
		AnimateIdle()
	end)
end

-- Alert
frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
frame:RegisterEvent("READY_CHECK")
frame:RegisterEvent("ROLE_POLL_BEGIN")
function frame.events:CHAT_MSG_RAID_WARNING(...) QueueAnimation("Alert") end
function frame.events:READY_CHECK(...)		QueueAnimation("Alert") end
function frame.events:ROLE_POLL_BEGIN(...)	QueueAnimation("Alert") end
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
function frame.events:BOSS_KILL(...)			QueueAnimation("Congratulate") end
function frame.events:CHALLENGE_MODE_COMPLETED() QueueAnimation("Congratulate") end
function frame.events:QUEST_TURNED_IN(...)		QueueAnimation("Congratulate") end
function frame.events:ISLAND_COMPLETED(...)		QueueAnimation("Congratulate") end
function frame.events:WARFRONT_COMPLETED(...)	QueueAnimation("Congratulate") end
function frame.events:ACHIEVEMENT_EARNED(...)	QueueAnimation("Congratulate") end
function frame.events:PLAYER_LEVEL_UP(...)		QueueAnimation("Congratulate") end
function frame.events:PLAYER_UNGHOST()			QueueAnimation("Congratulate") end
function frame.events:PLAYER_ALIVE()
	if (not UnitIsDeadOrGhost("player")) then QueueAnimation("Congratulate") end
end
function frame.events:DUEL_FINISHED()			QueueAnimation("Congratulate") end
function frame.events:NEW_MOUNT_ADDED(...)		QueueAnimation("Congratulate") end
function frame.events:NEW_PET_ADDED(...)		QueueAnimation("Congratulate") end
function frame.events:NEW_TOY_ADDED(...)		QueueAnimation("Congratulate") end
function frame.events:BARBER_SHOP_APPEARANCE_APPLIED() QueueAnimation("Congratulate") end
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
function frame.events:PLAYER_DEAD()				QueueAnimation("EmptyTrash") end
function frame.events:ENCOUNTER_END(encounterID, encounterName, difficultyID, groupSize, success)
	if success == 0 then QueueAnimation("EmptyTrash") end
end
function frame.events:DELETE_ITEM_CONFIRM(...)	QueueAnimation("EmptyTrash") end
-- key failed
-- duel lost

-- Explain
-- weakaura speech bubble (while idle)

-- GetAttention
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
function frame.events:PLAYER_FLAGS_CHANGED(unitTarget)
	if unitTarget == "player" and UnitIsAFK("player") then QueueAnimation("GetAttention") end
end
-- afk logout starts

-- GoodBye
-- casting hearth
-- casting teleport

-- Greeting
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
function frame.events:PLAYER_ENTERING_WORLD(...)
	C_Timer.After(5.0, function()
		if (math.random() < 0.40) then
			QueueAnimation("Greeting1")
		else
			QueueAnimation("Greeting2")
		end
		frame.texture.frame = nil
		frame:Show()
		AnimateIdle()
	end)
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
function frame.events:MAIL_SEND_SUCCESS()	QueueAnimation("SendMail") end
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
		QueueAnimation("Alert")
		QueueAnimation("GetAttention")
		local x_mid = GetScreenWidth() / 2
		local y_mid = GetScreenHeight() / 2
		local x_frame, y_frame = frame:GetCenter()
		x_frame = x_frame - x_mid
		y_frame = y_frame - y_mid
		local theta = atan2(y_frame, x_frame)
		if     theta >  -22.5 and theta <=   22.5 then QueueAnimation("GestureRight2");		QueueAnimation("LookRight")
		elseif theta >   22.5 and theta <=   67.5 then QueueAnimation("GestureDownRight2");	QueueAnimation("LookDownRight")
		elseif theta >   67.5 and theta <=  112.5 then QueueAnimation("GestureDown2");		QueueAnimation("LookDown")
		elseif theta >  112.5 and theta <=  157.5 then QueueAnimation("GestureDownLeft2");	QueueAnimation("LookDownLeft")
		elseif theta >  157.5 and theta <= -157.5 then QueueAnimation("GestureLeft2");		QueueAnimation("LookLeft")
		elseif theta > -157.5 and theta <= -112.5 then QueueAnimation("GestureUpLeft2");	QueueAnimation("LookUpLeft")
		elseif theta > -112.5 and theta <=  -67.5 then QueueAnimation("GestureUp2");		QueueAnimation("LookUp")
		elseif theta >  -67.5 and theta <=  -22.5 then QueueAnimation("GestureUpRight2");	QueueAnimation("LookUpRight")
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
		frame:Hide()
	elseif msg == "-show" then
		frame:Show()
	elseif msg == "-reset" or msg == "-r" then
		frame:ClearAllPoints()
		frame:SetPoint("CENTER")
	elseif msg == "-list" or msg == "-l" then
	else
		if data.msg == nil then
			print("Couldn't find that animation.")
			print("Use \"/clippy -list\" to list available animations.")
			print("Use \"/clippy -help\" to view all commands.")
		else
			QueueAnimation(msg)
		end
	end
end
