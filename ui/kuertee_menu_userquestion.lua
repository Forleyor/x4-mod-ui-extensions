local ffi = require ("ffi")
local C = ffi.C
local Lib = require ("extensions.sn_mod_support_apis.lua_interface").Library
local userQuestionMenu
local oldFuncs = {}
local newFuncs = {}
local isInited
local function init ()
	DebugError ("kuertee_menu_userquestion.init")
	if not isInited then
		isInited = true
		userQuestionMenu = Lib.Get_Egosoft_Menu ("UserQuestionMenu")
		-- oldFuncs.customOption = userQuestionMenu.customOption
		-- userQuestionMenu.customOption = newFuncs.customOption
		oldFuncs.createTable = userQuestionMenu.createTable
		userQuestionMenu.createTable = newFuncs.createTable
	end
end
-- function newFuncs.customOption (optionid, optionparameters)
-- 	local menu = userQuestionMenu

-- 	DebugError ("kuertee_menu_userquestion.newFuncs.createTable menu.conversationMenu " .. tostring (menu.conversationMenu))
-- 	DebugError ("kuertee_menu_userquestion.newFuncs.createTable menu.modeparam [7] " .. tostring (menu.modeparam [7]))
-- 	DebugError ("kuertee_menu_userquestion.newFuncs.createTable optionid " .. tostring (optionid))
-- 	if menu.modeparam [7] ~= nil and menu.conversationMenu then
-- 		-- has conversation next section parameter, assume opened with "open_conversation_menu"
-- 		-- local continueConversationFunc = function ()
-- 		-- 	UnsuspendConversation ()
-- 		-- 	ProceedFromMenu (menu.modeparam [7], optionid)
-- 		-- end
-- 		-- -- menu.onCloseElement ("close")
-- 		-- Helper.clearMenu (menu, continueConversationFunc)
-- 		Helper.closeMenuForSection (menu, menu.modeparam [7], optionid)
-- 	else
-- 		oldFuncs.customOption (optionid, optionparameters)
-- 	end
-- end
function newFuncs.createTable(frame, tableProperties)
	local menu = userQuestionMenu

	if menu.mode ~= "custom" then
		return oldFuncs.createTable (frame, tableProperties)
	end

	-- kuertee start: re-written custom user question
	local numCols = (menu.mode == "custom") and 5 or 6
	local ftable = frame:addTable(numCols, { tabOrder = 1, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y, defaultInteractiveObject = true })
	if menu.mode == "custom" then
		local leftwith = 0
		if menu.modeparam[3] ~= nil then
			leftwith = math.ceil(C.GetTextWidth(menu.modeparam[3][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		end
		local rightwidth = 0
		if menu.modeparam[4] ~= nil  then
			rightwidth = math.ceil(C.GetTextWidth(menu.modeparam[4][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		end
		local minbuttonwidth = 0.2 * tableProperties.width - Helper.borderSize
		local maxbuttonwidth = (tableProperties.width - 4 * Helper.borderSize - 3) / 2

		local buttonwidth = math.max(minbuttonwidth, math.min(maxbuttonwidth, math.max(leftwith, rightwidth) + 2 * Helper.standardTextOffsetx))
		ftable:setColWidth(2, buttonwidth, false)
		ftable:setColWidth(4, buttonwidth, false)
	end

	if menu.mode == "custom" then
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(numCols):createText(menu.modeparam[1] or "", Helper.headerRowCenteredProperties)

		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(numCols):createText(menu.modeparam[2] or "", { wordwrap = true })
	end

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(numCols):createText("")

	if menu.mode == "custom" then
		local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		if menu.modeparam[3] then
			row[2]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[3][2] or "", { halign = "center" })
			row[2].handlers.onClick = function () return menu.customOption(menu.modeparam[3][1], menu.modeparam[3]) end
		end
		if menu.modeparam[4] then
			row[4]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[4][2] or "", { halign = "center" })
			row[4].handlers.onClick = function () return menu.customOption(menu.modeparam[4][1], menu.modeparam[4]) end
		end

		if menu.modeparam[4] and menu.modeparam[6] == "right" then
			ftable:setSelectedCol(4)
		elseif menu.modeparam[3] and menu.modeparam[6] == "left" then
			ftable:setSelectedCol(2)
		elseif menu.modeparam [3] then
			ftable:setSelectedCol(2)
		end
	end

	return ftable
	-- kuertee end: re-written custom user question
end
init ()
