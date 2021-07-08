local UIViewBase 				= import("..UIViewBase")
local UIRichText 				= class("UIRichText", UIViewBase)
local utf8 						= import("app.components.utf8")
local UIRichTextElement 		= import(".UIRichTextElement")
local UIRichTextElementFont 	= import(".UIRichTextElementFont")
local UIRichTextElementSprite 	= import(".UIRichTextElementSprite")
local XMLReader 				= import(".LuaXML")


--[[
	UIRichText控件:

	控件描述:
		1. 这是一个可以在文本中插入图片, 点击事件, 添加不同文本特效的控件

	此控件由以下部分组成:
		1. (UIViewBase)			UIRichText 							--控件主体
			1. (layout) 		Line * n 	 						--行填充
				1. (UIViewBase)	UIRichTextElement * n 				--子节点
					1.	(LabelTTF/Sprite) drawNode					--子节点的显示节点
					2.	(layout) touchLayouter 						--点击事件触发器

	类关系视图:
		1. UIRichText -> 继承自 UIViewBase
			包含
		2. UIRichTextElementFont 	--|
									  |-> 继承自 UIRichTextElement -> 继承自 UIViewBase
		3. UIRichTextElementSprite 	--|

	功能实现:
		1. 全局:
			1. 设置每行最大行高
				=>	这个参数将会影响到精灵类型子节点, 如果一个精灵类型子节点的最大高度超过了所给值，
					那么这个精灵将会按照最大宽度 / 精灵实际宽度进行等比缩小

			2. 设置所有行最大行宽
				=>	这个参数决定了最大的行宽度，如果一个长文本超出了最大行宽度，他将会被按规则切分，
					并且填充到下一行

			3. 设置每行之间的间距
				=>	咕~~(╯﹏╰)b  就是间距

			4. 设置文本的对齐方式/也可以说是精灵子节点的对齐方式
				=>	上中下对齐方式, 没有左右

		2. 子节点
			1. context类型:
				  完整名				  短名				例
				["value"] 			= "t",  		----t='测试文本'
				["fontColor"]		= "c",			----c='FFFFFF'
				["fontPath"]		= "p",			----p='fonts/xxx.ttf'
				["fontSize"]		= "s",			----s='25'
				["underLine"]		= "ul",			----ul='true'
				["outLine"]			= "ol",			----ol='true'
				["outLineColor"]	= "olc",		----olc='FFFFFF'
				["outLineSize"]		= "ols",		----ols='3'
				["imgPath"]			= "ip",			----ip="res/xxx/xxx/x.png"
				["func"]			= "func",		----func='onTouchedElmenetType'
				["param"]			= "param"		----param={1,2,3,4}
													----param=function() return 'nonono' end
													----param='123123'
				

				t/value 		--文本类型的文本
				fontColor 		--文本类型的文字颜色
				fontPath 		--文本类型的字体路径
				fontSize 		--文本类型的字体大小
				underline 		--文本类型是否开启下划线
				outLine 		--文本类型是否开启描边
				outlineColor 	--文本类型的描边颜色
				outlineSize  	--文本类型的描边尺寸
				imgPath 	 	--图片类型的图片路径


				func 			--所有类型的点击事件响应方法名
				param 			--所有类型的点击事件响应方法传入参数

				以上传参
					当value/t不为 nil 时，将视为这个element为label类型, --不管后面的ip有没有跟参数
					当value/t为 nil 时， 将视为这个element为img类型， --不管img是否有参数

				img类型参数只需要传入ip[imagePath] 就可以
				label类型参数 t[value] 为必传参数 其他为可选(除func和param外 均有默认值)

				如果是使用luaString的方式构造, 则除param外其他字段都需为字符串类型， 否则将会出现类似下面的错误:

					Execption Catched In UIViewBase:checkDefaultValues(defaultValueTable) !
					Type Check Failed On Default Context Value [fontSize] : Rquire Type Is [string]
					But Input Type is [number] !

				需要注意的是  如果是纯string方法构造 则构造方法默认会认为除param之外的值都是字符串 所以无需添加''来标识字符串字段
							如果是以LuaString方法构造 则需遵循lua语法标准.

				
				string类型传参:
					以|为每个子节点的分隔符，并以@为每个子节点内的context元素的分隔符
						例 t=123 @ func=abc @ param = {1, 2, 3, 4} | ....
				注意:
					如果是String类型传参 参数为table的话 第一个字符必须为'{' 否则将会当成普通文本处理



	构造传参
		1. 参数名详见onCreate方法内的	DefaultValue
			参数意义详见全局功能实现相关


	解析相关
		1. UIRichText提供3种解析方式：
			1. Lua解析: 			generateFromLuaString	--已完成
								generateFromLuaTable	--直接从contextsTable中生成
			2. string解析:		generateFromString 		--已完成
			3. XML解析:			generateFromXMLData		--暂无回调传参

	序列化相关:
		1. UIRichText提供2种序列化方法:
			1. Lua序列化			serializeToLuaData	--已完成
			2. XML序列化			serializeToXMLData	--回调还没做
			3. 没有序列化为text的接口

	解析与序列化
		1. 解析和序列化并不是一一对应的关系
			所以可以用lua解析 用xml序列化
			也可以用xml解析 用lua序列化
			或者用string解析 用lua序列化
			目前比较完善的是lua序列化和lua解析 所以推荐使用Lua


	流程说明
		Step1:
			UIRichText把传进来的string / luafile / luastring / xml 解析为一个contexts的集合(table)
		Step2:
			由contexts创建subElmenets
		Step3:
			创建完了

		所以以后如果需要添加Json的解析  
		就只需要做解析这一步 
		然后把context交给UIRichText

		再做一下序列化就可以了


	Sample:
		String创建: --onTouch无法传入table参数

			local text = "ip=res/Default/1.jpg @ func=??? @ param=??????? |t=你真是代码界的一股清流 @ s=30 @ c=FFFFFF @ ul = true @ ol = true @ ols = 2 @ olc=FF0000 |t=__用来测试的文本..... @ c=FF00FF|t=__用来测试的文本.....@ c=FF00FF | ip=res/Default/1.jpg"
			local rich = UIRichText:create({
					maxLineHeight = 80,
					maxLineWidth  = 700,
					VGAP = 10,
					VALIGN = "center",
				})
			rich["???"] = handler(self, self.testFunction)
			rich:generateFromString(text):addTo(self):move(display.left, display.top)


		LuaString创建: --可以传入table类型参数

			text = "{{t='withFunc withFunc withFunc withFunc withFunc withFunc ', s='25',c = 'FFFFFF', func='!!!', param={1,2,3,4}}, {t = '一串', s='35', c='FF0000'}, {ip='res/Default/Slider_Back.png', func='aaa', param={222,222,222}}}"
			rich = UIRichText:create({
				maxLineHeight = 80,
				maxLineWidth  = 300,
				VGAP = 10,
				VALIGN = "center",
			})
			rich["!!!"] = handler(self, self.testFunction)
			rich['aaa'] = handler(self, self.testImgCallBack)
			rich:generateFromLuaString(text):addTo(self):move(display.left, display.top - 200)


		XML创建:
			local xmlData = ''
			if cc.FileUtils:getInstance():isFileExist("res/test.xml") then
				xmlData = cc.FileUtils:getInstance():getStringFromFile("res/test.xml")
				local RichText = UIRichText:create({maxLineWidth 	= 600,
												maxLineHeight 	= 150,
												VGAP 			= 10,
												VALIGN			= "center"
												})

				if not xmlData then reportExecption end
				RichText:generateFromXMLData(xmlData)
				RichText:addTo(self):setPositionX(50):setPositionY(display.top)
			end


	其他需要注意的事项:
		1. 文本类型子节点中的文本最好不要加入特殊字符 有一些特殊字符有可能会导致无法被解析出来(已经处理一部分
		2. 通常文本对齐/切割方案是
			1. 换行符 char = 10 为新增一行
			2. 空格	char = 32  为单词标识
			3. 任意视觉效果变更(例: 下划线，颜色，大小)和加入图片类型子节点视为 开始一段新单词
			4. 中文英文处理方式一致,
]]

function UIRichText:onCreate()
	self._lines = {}
	self._standingPosX = 0
	UIViewBase.onCreate(self)
end

function UIRichText:generateFromLuaTable(contexts)
	for k, v in pairs(contexts) do
		v.elementType = v.t and "label" or "img"
		for idx, value in pairs(v) do
			v[UIRichTextElement.toLongIdx(idx)] = value
		end
		if v.fontColor and string.len(v.fontColor) == 6 then v.fontColor = self.stringToRGB(v.fontColor) end
		if v.outLineColor and string.len(v.outLineColor) == 6 then v.outLineColor = self.stringToRGB(v.outLineColor) end
	end
	-- local createdElements = self:createElementsByContexts(contexts, true)
	-- self:alignElements(nil, createdElements)
	-- self:alignLines()
	return self
end

function UIRichText:generateFromLuaString(luaStr)
	local contexts = loadstring("return "..luaStr)()
	if not contexts then error("\nCatched Execption While Decoding LuaStr In function UIRichText:generateFromLuaString(luaStr)! Please Check Syntax Is All Currect.") end
	return self:generateFromLuaTable(contexts)
end

function UIRichText:generateFromString(str)
	local contexts = self:decodeContextsFromString(str)
	self:generateNodesFromContexts(contexts)
	-- local createdElements = self:createElementsByContexts(contexts, true)
	-- self:alignElements(nil, createdElements)
	-- self:alignLines()
	return self
end

function UIRichText:generateFromXMLData(str)
	self.context.xmlData = data and data or ""
	local reader = XMLReader:create()
	local decoded = reader:ParseXmlText(str)
	local children = decoded.___children
	if #children <= 0 then 
		release_print("XML decode With A None-Child XML Data !")
		return
	end
	local contexts = self:decodeContextsFromXMLData(children)
	-- local elements = self:createElementsByContexts(contexts, true)
	-- self:alignElements(nil, elements)
	-- self:alignLines()
end
---------Decoding--------

function UIRichText.stringToRGB(str)
	local ret = ""
	ret = tostring(tonumber( string.sub(str, 1, 2) ,16) )..","
	ret = ret..tostring(tonumber( string.sub(str, 3, 4),16) )..","
	ret = ret..tostring(tonumber( string.sub(str, 5, 6),16) )
	return ret
end

function UIRichText._rgbToString(char)
	local str = string.format("%#x", char)
	return string.sub(str, 3, string.len(str))
end

function UIRichText.rgbToString(charcharchar)
	local ret = ""
	local ss = string.split(charcharchar, ",")
	for k, v in pairs(ss) do
		ret = ret..UIRichText._rgbToString(v)
	end

	return ret
end

function UIRichText:decodeContextsFromXMLData(children)
	local contexts = {}
	for k, v in pairs(children) do
		local context = {}
		context.elementType 	= v:getType()
		context.name			= v.name
		context.value			= v:value()
		if context.elementType == "label" then
			context.fontSize		= v.fontSize
			context.fontPath		= v.fontPath
			context.fontSize		= v.fontSize
			context.fontPath		= v.fontPath
			context.underLine		= v.underLine
			context.outLine			= v.outLine
			context.fontColor		= v.fontColor
			context.outLineColor	= v.outLineColor
			context.outLineSize		= v.outLineSize
		elseif context.elementType == "img" then
			context.img				= v.img
			context.imgPath			= v.imgPath
		end

		table.insert(contexts, context)
	end
	return contexts
end

function UIRichText:decodeContextsFromString(str)
	local spilted = string.split(str, "|")
	local elements = {}
	for k, v in pairs(spilted) do
		local attrs = string.split(v, "@")
		local elementAttrs = {}
		for _, valueInfo in pairs(attrs) do
			local singleValue = string.split(valueInfo, "=")
			elementAttrs[string.gsub(singleValue[1], "^%s*(.-)%s*$", "%1")] = string.gsub(singleValue[2], "^%s*(.-)%s*$", "%1")
		end
		table.insert(elements, elementAttrs)
	end

	for idx, element in pairs(elements) do
		element.elementType = element.t and "label" or "img"
		for idx, value in pairs(element) do
			element[UIRichTextElement.toLongIdx(idx)] = value
		end
		if element.param and string.sub(element.param, 1, 1) == "{" then
			element.param = loadstring("return "..element.param)()
		end
		if element.fontColor then element.fontColor = self.stringToRGB(element.fontColor) end
		if element.outLineColor then element.outLineColor = self.stringToRGB(element.outLineColor) end
	end
	return elements
end

------CreateElements-------
function UIRichText:createElementsByContexts(contexts, splitWords)

	---这一部分是切割换行符\n
	local newContextQueue = {}
	while #contexts > 0 do
		local context = table.remove(contexts, 1)
		if context.elementType == "label" then
			local words = string.split(context.value, "\n")
			if #words > 1 then
				while #words > 0 do
					local cpContext = self:copyContext(context)
					cpContext.value = table.remove(words, 1)
					cpContext.t = cpContext.value
					table.insert(newContextQueue, cpContext)
					if #words > 0 then table.insert(newContextQueue, {value = "\n", elementType = "label", t = "\n"}) end
				end
			else
				table.insert(newContextQueue, context)
			end
		else
			table.insert(newContextQueue, context)
		end
	end
	--把塞入换行符的队列赋值给contexts
	contexts = newContextQueue

	--真正的创建
	local elementArray = {}
	for _, context in pairs(contexts) do
		local element = nil
		if context.elementType == "label" then
			if context.value ~= nil then
				if splitWords then
					local splited = UIRichTextElementFont.trySplitWords(context.value) --这边是以空格为分割 逐个比对
					for k, v in pairs(splited) do
						local newContext = self:copyContext(context)
						newContext.value = v
						if newContext.t then newContext.t = newContext.value end
						element = UIRichTextElementFont:create(newContext)
						element:refresh()
						table.insert(elementArray, element)
					end
				else
					element = UIRichTextElementFont:create(context)
					element:refresh()
					table.insert(elementArray, element)
				end
			end
		elseif context.elementType == "img" then
			element = UIRichTextElementSprite:create(context)
			element:refresh()
			element:fixSize(self.context.maxLineWidth, self.context.maxLineHeight) --以高度为上限 如果超过固定行最大高度 或者固定行宽度 则等比缩小
			table.insert(elementArray, element)
		end
	end

	for k, v in pairs(elementArray) do 	--添加触摸回调
		if v.context.func then
			v.context.onTouched = handler(self, self.onTouchedElement)
		end
	end
	return elementArray
end

-----NetWorkking-----
function UIRichText:serializeToXMLData()
	local data = "<body>"

	for k, v in pairs(self._lines) do
		for _, c in pairs(v._elements) do
			if c.context.elementType == "label" and string.len(c.context.value) ~= 0 then
				data = data..c:serialize()
			elseif c.context.elementType == "img" then
				data = data..c:serialize()
			end
		end
	end
	data = data.."</body>"
	return data
end

function UIRichText:serializeToLuaData()
	local data = "{"

	for k, v in pairs(self._lines) do
		for _, c in pairs(v._elements) do
			data = data..c:serializeToLuaData()..","
		end
	end
	data = data.."}"

	return data
end

----Sortting----
-- 100 300
local function moveStringToLeft(left, right)
	left = left..utf8.sub(right, 1, 1)
	right = utf8.sub(right, 2)
	return left, right
end

local function moveStringToRight(left, right)
	local pos = utf8.len(left)
	right = utf8.sub(left, pos, pos)..right
	left = utf8.sub(left, 1, pos - 1)
	return left, right
end

function UIRichText:trySplitFontElement(fnt, context)
	local newContext 		= table.clone(context)
	local maxLineWidth 		= tonumber(self.context.maxLineWidth)
	local GAP 				= tonumber(self.context.VGAP)
	GAP = (self._standingPosX == 0 and GAP or 0)
	local currWidth 		= fnt:getDrawSize().width
	local percent 			= math.min((maxLineWidth - self._standingPosX - GAP) / currWidth, 1)
	if percent < 1 then
		local fontCount 		= math.ceil(percent * utf8.len(context.value))
		local left 				= utf8.sub(context.value, 1, fontCount)
		local right 			= utf8.sub(context.value, fontCount + 1)
		while true do
			if self._standingPosX + GAP + fnt:setString(left):getDrawSize().width <= maxLineWidth then
				left, right = moveStringToLeft(left, right)
			else
				-- 超出边界
				left, right = moveStringToRight(left, right)
				break
			end
		end
		while self._standingPosX + GAP + fnt:setString(left):getDrawSize().width > maxLineWidth do
			left, right = moveStringToRight(left, right)
		end
		context.value 		= left
		newContext.value 	= right
		context.t 			= left
		newContext.t 		= right
	end
	return newContext
end

function UIRichText:generateNodesFromContexts(contexts)
	if #contexts == 0 then return end
	self:addNewLine()
	local maxLineHeight 	= tonumber(self.context.maxLineHeight)
	local GAP 				= tonumber(self.context.VGAP)
	local currLineHeight 	= maxLineHeight
	local ind = 0
	while #contexts > 0 do
		ind = ind + 1
		if ind > 10 then break end
		local context = table.remove(contexts, 1)
		local newContext = self:createNodeToLine(context)
		if newContext then table.insert(contexts, 1, newContext) end
	end
	self:alignLines()
end

function UIRichText:alignLines()
	local GAP = self.context.HGAP
	--垂直方向对齐
	local lastLine = nil
	for k, v in pairs(self._lines) do
		local maxHeight = 0
		dump(v._elements)
		for _, ele in pairs(v._elements) do
			maxHeight = ele:getDrawSize().height > maxHeight and ele:getDrawSize().height or maxHeight
		end
		v:setContentSize(v:getContentSize().width, maxHeight)
		if lastLine then
			v:setPositionY(lastLine:getPositionY() - lastLine:getContentSize().height - tonumber(self.context.VGAP))
		end
		-- self:debugDraw(v, cc.c4f(k % 2 == 0 and 1 or 0, k % 2 == 0 and 1 or 0, 1, 0.2))

		--重新排列文本
		for _, c in pairs(v._elements) do
			if c.context.elementType == "label" then
				if self.context.VALIGN == "top" then
					c:setPositionY(maxHeight - c.drawNode:getContentSize().height)
				elseif self.context.VALIGN == "center" then
					c:setPositionY(v:getContentSize().height / 2 - c.drawNode:getContentSize().height / 2)
				elseif self.context.VALIGN == "buttom" then
					c:setPositionY(0)
				end
			end
		end
		lastLine = v
	end

	local totalHeight = 0
	for k, v in pairs(self._lines) do
		totalHeight = totalHeight + v:getContentSize().height
	end
	for k, v in pairs(self._lines) do
		v:setPositionY(totalHeight)
		totalHeight = totalHeight - v:getContentSize().height - GAP
	end

	self:setContentSize( self.context.maxLineWidth, totalHeight )
end

function UIRichText:getCurrentLine()
	return self._lines[#self._lines]
end

function UIRichText:getPreLine()
	return self._lines[#self._lines - 1]
end

function UIRichText:addNewLine()
	local lineLayouter = ccui.Layout:create()
									:addTo(self)
									:setAnchorPoint(0, 1)
									:setContentSize(self.context.maxLineWidth, 0)

	lineLayouter._elements = {}
	self._standingPosX = 0
	table.insert(self._lines, lineLayouter)
end

function UIRichText:hasEnoughSpaceFor(node)
	local currWidth = node:getDrawSize().width
	local GAP = (self._standingPosX == 0 and self.context.VGAP or 0)
	return self._standingPosX + currWidth + GAP <= self.context.maxLineWidth
end

function UIRichText:createNodeToLine(context)
	local element = nil
	local GAP = self._standingPosX == 0 and self.context.VGAP or 0
	if context.elementType == "label" then
		element = UIRichTextElementFont:create(context)
	elseif context.elementType == "img" then
		element = UIRichTextElementSprite:create(context)
	else
		assert(false, "Unknow context type for richtext element : "..tostring(context.elementType))
	end

	local spaceEnough = self:hasEnoughSpaceFor(element)

	if not spaceEnough then
		if context.elementType == "label" then
			local newContext = self:trySplitFontElement(element, context)
			element:addTo(self:getCurrentLine())
				   :move(self._standingPosX + GAP, 0)
			table.insert(self:getCurrentLine()._elements, element)
			self:addNewLine()
			return newContext
		end
		self:addNewLine()
	end
	element:addTo(self:getCurrentLine())
		   :move(self._standingPosX + GAP, 0)
	self._standingPosX = self._standingPosX + element:getDrawSize().width + GAP
	table.insert(self:getCurrentLine()._elements, element)
	return nil
end

----Events----

function UIRichText:onTouchedElement(func, param)
	--?????????????????????
	if self[func] then self[func](param) end
	--!!!!!!!!!!!!!!!!!!!!!
end

-- function UIRichText:onDeleteFromEditBox()
-- 	if #self._lines <= 0 then return end
-- 	local lastLine = self._lines[#self._lines]
-- 	if #lastLine._elements <= 0 then return end
-- 	local lastElement = lastLine._elements[#lastLine._elements]

-- 	local needDeleteElement = false
-- 	if lastElement.context.elementType == "label" then
-- 		if string.len(lastElement.context.value) > 0 then
-- 			lastElement:deleteLastLetter()
-- 		end

-- 		if string.len(lastElement.context.value) == 0 then
-- 			needDeleteElement = true
-- 		end
-- 	else
-- 		needDeleteElement = true
-- 	end
-- 	if needDeleteElement then 
-- 		table.remove(lastLine._elements, #lastLine._elements):removeFromParent() 
-- 		--这边还需要检查line的情况

-- 		if #lastLine._elements == 0 then
-- 			release_print(#self._lines)
-- 			table.remove(self._lines, #self._lines):removeFromParent()
-- 		end
-- 	end
-- end

-- function UIRichText:onInputFromEditBox(line, filed, context, onUpdateFocusElement)
-- 	--判断是否需要另起一行
-- 	if context.elementType == "label" then
-- 		if string.len(context.value) == 1 and string.byte(context.value) == 32 then
-- 			self.spaceCount = self.spaceCount + 1
-- 			return
-- 		end

-- 		while self.spaceCount ~= 0 do
-- 			self.spaceCount = self.spaceCount - 1
-- 			context.value = " "..context.value
-- 		end
-- 	end

-- 	local starttingRefresh = false
-- 	local recoveryElements = {}
-- 	local element = nil

-- 	for k, v in pairs(self._lines) do
-- 		if v == line then
-- 			starttingRefresh = true
-- 		end

-- 		if starttingRefresh then
-- 			while #v._elements ~= 0 do
-- 				local childElement = v._elements[#v._elements]
-- 				childElement:retain()
-- 				childElement:removeFromParent()
-- 				table.insert(recoveryElements, table.remove(v._elements, #v._elements))
-- 			end
-- 		end
-- 	end

-- 	local focusedElement = nil
-- 	--找到filed的index 插入到后面
-- 	local insertPos = 0
-- 	for k, v in pairs(recoveryElements) do
-- 		if v == filed then
-- 			insertPos = k
-- 			break
-- 		end
-- 	end

-- 	--还需要判断是否需要新建一个Label
-- 	if context.elementType == "label" then
-- 		local needAddNewElement = true

-- 		if filed and filed.context.elementType == "label" and filed:isSameContext(context) then
-- 			--在尾部添加的情况
-- 			local pos = filed:addNewLetter(context.value)
-- 			--这边要判断是否该元素的尾部超出了范围
-- 			--如果超出了范围 则退回 并且新建一个element
-- 			if pos <= self.context.maxLineWidth then
-- 				needAddNewElement = false
-- 			end
-- 			focusedElement = filed
-- 		end
-- 		if needAddNewElement == true then 
-- 			--添加新的Element逻辑
-- 			local splited = UIRichTextElementFont.trySplitWords(context.value)
-- 			for k, v in pairs(splited) do
-- 				local newContext = self:copyContext(context)
-- 				newContext.value = v
-- 				element = UIRichTextElementFont:create(newContext)
-- 				element:refresh()
-- 				--找到filed的index 插入到后面
-- 				table.insert(recoveryElements, insertPos + k, element)
-- 				focusedElement = element
-- 			end
-- 		end
-- 	elseif context.elementType == "img" then
-- 		element 				= UIRichTextElementSprite:create(context)
-- 		element:refresh()
-- 		element:fixSize(self.context.maxLineWidth, self.context.maxLineHeight)
-- 		table.insert(recoveryElements, insertPos + 1, element)
-- 		focusedElement = element
-- 	end
-- 		--移除当前编辑line之后的line  包括当前编辑的line
-- 		while self._lines[#self._lines] ~= line do
-- 			table.remove(self._lines, #self._lines):removeFromParent()
-- 		end
-- 	if #recoveryElements > 0 then
-- 		recoveryElements = self:alignElements(line, recoveryElements)
-- 	end
-- 	self:alignLines()
-- 	for k, v in pairs(recoveryElements) do
-- 		if v.__needRelease then v:release() v.__needRelease = false end
-- 	end
-- 	onUpdateFocusElement(focusedElement)
-- end

return UIRichText