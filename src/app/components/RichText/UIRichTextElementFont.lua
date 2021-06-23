local UIRichTextElement = import(".UIRichTextElement")
local UIRichTextElementFont = class("UIRichTextElementFont", UIRichTextElement)

function UIRichTextElementFont.trySplitWords(sentence)
	local spilted = {}
	local byteCount = 0
	local currByte = 0
	local word = ""
	local isEndOfWord = false
	local placeSpace = false
	while string.len(sentence) > 0 do
		currByte = string.byte(sentence)
		if currByte ~= 32 then --正常的情况
			byteCount = UIRichTextElementFont.subStringGetByteCount(sentence, 1)
			word = word..string.sub(sentence, 1, byteCount)
		else --空格的情况
			placeSpace = true
			isEndOfWord = true
		end

		sentence = UIRichTextElementFont.subStringUTF8(sentence, 2)

		if isEndOfWord then
			table.insert(spilted, word)
			word = placeSpace and " " or ""

			isEndOfWord = false
			placeSpace = false
		end

		if string.len(sentence) == 0 then
			table.insert(spilted, word)
		end
	end
	return spilted
end

function UIRichTextElementFont.spiltString(str, reps)
    local ret = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(ret, w)
    end)
    return ret
end

function UIRichTextElementFont:onCreate()
	self:setDefaultValue("value",		"nullSet")
	self:setDefaultValue("fontPath",	"")
	self:setDefaultValue("fontSize",	"25")
	self:setDefaultValue("fontColor",	"255,255,255")
	self:setDefaultValue("underLine",	"false")
	self:setDefaultValue("outLine",		"false")
	self:setDefaultValue("outLineSize",	"3")
	self:setDefaultValue("outLineColor","255,255,255")
	UIRichTextElement.onCreate(self)
end

function UIRichTextElementFont:refresh()
	if self.context.value == "nullSet" then
		error("Execption Catched In function UIRichTextElement:initWithFont()! elementType Is font But NO string context !")
	end

	if not self.drawNode then 
		self.drawNode = cc.LabelTTF:create()--(self.context.value, self.context.fontPath)
		self.drawNode:setString(self.context.value)
		self.drawNode:setFontSize(tonumber(self.context.fontSize))
	end
	self.drawNode:addTo(self):setAnchorPoint(0, 0)
	local colors = self.spiltString(self.context.fontColor, ",")
	self.drawNode:setColor(cc.c3b(colors[1],colors[2],colors[3]))
	-- if self.context.underLine == "true" then self.drawNode:enableUnderline() end

	-- if self.context.outLine == "true" then
	-- 	local outLineColors = self.spiltString(self.context.outLineColor, ",")
	-- 	self.drawNode:enableOutline(cc.c4b(outLineColors[1],outLineColors[2],outLineColors[3], 255), self.context.outLineSize)
	-- end

	UIRichTextElement.refresh(self)
	return self
end

function UIRichTextElementFont:createNewFontForOutOfRangeLetters(maxWidth)

	local displayString = ""
	local tempSave = self.context.value
	self.drawNode:setString(UIRichTextElementFont.subStringUTF8(tempSave, 1, 1))
	if self.drawNode:getContentSize().width > maxWidth then assert(false, "\n[RichText] : MaxWidth Must Lager Than Single Letter!!!!!") end
	while self.drawNode:getContentSize().width < maxWidth do
		--一直填充直到无法装下为止
		displayString = displayString..UIRichTextElementFont.subStringUTF8(tempSave, 1, 1)
		tempSave = UIRichTextElementFont.subStringUTF8(tempSave, 2, self.subStringGetTotalIndex(tempSave))
		self.drawNode:setString(displayString)
	end

	--取出最后一个str装回去
	local totalSize = self.subStringGetTotalIndex(displayString)
	local lastLetter = self.subStringUTF8(displayString, totalSize, totalSize)
	tempSave = lastLetter..tempSave
	displayString = self.subStringUTF8(displayString, 1, self.subStringGetTotalIndex(displayString) - 1)

	self.context.value = displayString
	self.drawNode:setString(displayString)

	local newContext = self:copyContext(self.context)
	newContext.value = tempSave
	local newFontElement = UIRichTextElementFont:create(newContext)
	newFontElement:refresh()

	self:onTextChanged()
	return newFontElement
end

function UIRichTextElementFont:deleteLastLetter()
	local totalLen 	= UIRichTextElementFont.subStringGetTotalIndex(self.context.value)
	self.context.value = UIRichTextElementFont.subStringUTF8(self.context.value, 1, totalLen - 1)
	self.drawNode:setString(self.context.value)
	self:onTextChanged()
end

function UIRichTextElementFont:addNewLetter(newLetter)
	self.context.value = self.context.value..newLetter
	self.drawNode:setString(self.context.value)
	self:onTextChanged()
	return self:getPositionX() + self.drawNode:getContentSize().width
end

function UIRichTextElementFont:onTextChanged()
	if self.onTouchLayouter then self.onTouchLayouter:setContentSize(self.drawNode:getContentSize()) end
end

function UIRichTextElementFont:isSameContext(contextB)
	if string.byte(contextB.value) == 32 then return false end --空格则新建一个

	local isSame = true
	for k, v in pairs(self.context) do
		if type(v) ~= "function" and k ~= "value" then
			if type(v) == "table" and not self:compareTable(v, contextB[k]) then
				isSame = false
				break
			elseif contextB[k] ~= v then
				isSame = false
				break
			end
		end
	end

	return isSame
end



--截取中英混合的UTF8字符串，endIndex可缺省
function UIRichTextElementFont.subStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = UIRichTextElementFont.subStringGetTotalIndex(str) + startIndex + 1
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = UIRichTextElementFont.subStringGetTotalIndex(str) + endIndex + 1
    end

    if endIndex == nil then 
        return string.sub(str, UIRichTextElementFont.subStringGetTrueIndex(str, startIndex))
    else
        return string.sub(str, UIRichTextElementFont.subStringGetTrueIndex(str, startIndex), UIRichTextElementFont.subStringGetTrueIndex(str, endIndex + 1) - 1)
    end
end

--获取中英混合UTF8字符串的真实字符数量
function UIRichTextElementFont.subStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = UIRichTextElementFont.subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function UIRichTextElementFont.subStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = UIRichTextElementFont.subStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function UIRichTextElementFont.subStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

return UIRichTextElementFont