--[[ Creation time 15:18 2022-08-26 UTC+3 ]]
--[[ Written by ProBaturay ]]
--[[ Description
string library limitations update: 
    string calculation limit is 1073741824 therefore created a custom function
    if exceeds 2147483648, returns 0 (library)
]]

--!strict

type NorS = string | number
type _table = typeof({})

type metatable = typeof(setmetatable({}, {}))

type metastringTable = {
	__add : (metatable, metatable) -> (),
	__sub : (metatable, metatable) -> (),
	__mul : (metatable, metatable) -> (),
	__div : (metatable, metatable) -> (),
}

type tableReturnType<NS> = {
	[any] : NS
}

export type StringsForMathModule = {
	SetMetastring : (StringsForMathModule, NorS) -> (metatable), 
	NumberToString : (StringsForMathModule, {[any] : number} | number) -> (...any),
	StringToNumber : (StringsForMathModule, {[any] : string} | string) -> (...any),
	ToDecimalFraction : (StringsForMathModule, NorS) -> (string),
	ToENotation : (StringsForMathModule, string, boolean?) -> (string?),
	Add : (StringsForMathModule, ...any) -> string?,
	Subtract : (StringsForMathModule, ...any) -> (string?),
	Multiply : (StringsForMathModule, ...any) -> (string?),
	Divide : (StringsForMathModule, ...any) -> (string?),
	CheckEquality : (StringsForMathModule, NorS, NorS) -> (string?),
	ExpandDecimal : (StringsForMathModule, string, number?) -> (string?),
	ToInteger : (StringsForMathModule, NorS) -> string?,
	abs : (StringsForMathModule, NorS) -> string,
	IsENotation : (StringsForMathModule, string) -> boolean?,
	ToThePower : (StringsForMathModule, NorS, NorS) -> string?,
	Root : (StringsForMathModule, NorS, NorS, NorS) -> string?
}

local stringsForMathModule : StringsForMathModule = {} :: never

local EPSILON_FOR_BISECTION = "0.0000000000000000000001"

local additionTable : {[string] : string} = {
	["00"] = "0",
	["01"] = "1",
	["10"] = "1",
	["02"] = "2",
	["11"] = "2",
	["20"] = "2",
	["03"] = "3",
	["12"] = "3",
	["21"] = "3",
	["30"] = "3",
	["04"] = "4",
	["13"] = "4",
	["22"] = "4",
	["31"] = "4",
	["40"] = "4",
	["05"] = "5",
	["14"] = "5",
	["23"] = "5",
	["32"] = "5",
	["41"] = "5",
	["50"] = "5",
	["06"] = "6",
	["15"] = "6",
	["24"] = "6",
	["33"] = "6",
	["42"] = "6",
	["51"] = "6",
	["60"] = "6",
	["07"] = "7",
	["16"] = "7",
	["25"] = "7",
	["34"] = "7",
	["43"] = "7",
	["52"] = "7",
	["61"] = "7",
	["70"] = "7",
	["08"] = "8",
	["17"] = "8",
	["26"] = "8",
	["35"] = "8",
	["44"] = "8",
	["53"] = "8",
	["62"] = "8",
	["71"] = "8",
	["80"] = "8",
	["09"] = "9",
	["18"] = "9",
	["27"] = "9",
	["36"] = "9",
	["45"] = "9",
	["54"] = "9",
	["63"] = "9",
	["72"] = "9",
	["81"] = "9",
	["90"] = "9",
	["19"] = "10",
	["28"] = "10",
	["37"] = "10",
	["46"] = "10",
	["55"] = "10",
	["64"] = "10",
	["73"] = "10",
	["82"] = "10",
	["91"] = "10",
	["29"] = "11",
	["38"] = "11",
	["47"] = "11",
	["56"] = "11",
	["65"] = "11",
	["74"] = "11",
	["83"] = "11",
	["92"] = "11",
	["39"] = "12",
	["48"] = "12",
	["57"] = "12",
	["66"] = "12",
	["75"] = "12",
	["84"] = "12",
	["93"] = "12",
	["49"] = "13",
	["58"] = "13",
	["67"] = "13",
	["76"] = "13",
	["85"] = "13",
	["94"] = "13",
	["59"] = "14",
	["68"] = "14",
	["77"] = "14",
	["86"] = "14",
	["95"] = "14",
	["69"] = "15",
	["78"] = "15",
	["87"] = "15",
	["96"] = "15",
	["79"] = "16",
	["88"] = "16",
	["97"] = "16",
	["89"] = "17",
	["98"] = "17",
	["99"] = "18"
}

local multiplicationTable : {[string] : string} = {
	["00"] = "0",
	["01"] = "0",
	["10"] = "0",
	["02"] = "0",
	["11"] = "1",
	["20"] = "0",
	["03"] = "0",
	["12"] = "2",
	["21"] = "2",
	["30"] = "0",
	["04"] = "0",
	["13"] = "3",
	["22"] = "4",
	["31"] = "3",
	["40"] = "0",
	["05"] = "0",
	["14"] = "4",
	["23"] = "6",
	["32"] = "6",
	["41"] = "4",
	["50"] = "0",
	["06"] = "0",
	["15"] = "5",
	["24"] = "8",
	["33"] = "9",
	["42"] = "8",
	["51"] = "5",
	["60"] = "0",
	["07"] = "0",
	["16"] = "6",
	["25"] = "10",
	["34"] = "12",
	["43"] = "12",
	["52"] = "10",
	["61"] = "6",
	["70"] = "0",
	["08"] = "0",
	["17"] = "7",
	["26"] = "12",
	["35"] = "15",
	["44"] = "16",
	["53"] = "15",
	["62"] = "12",
	["71"] = "7",
	["80"] = "0",
	["09"] = "0",
	["18"] = "8",
	["27"] = "14",
	["36"] = "18",
	["45"] = "20",
	["54"] = "20",
	["63"] = "18",
	["72"] = "14",
	["81"] = "8",
	["90"] = "0",
	["19"] = "9",
	["28"] = "16",
	["37"] = "21",
	["46"] = "24",
	["55"] = "25",
	["64"] = "24",
	["73"] = "21",
	["82"] = "16",
	["91"] = "9",
	["29"] = "18",
	["38"] = "24",
	["47"] = "28",
	["56"] = "30",
	["65"] = "30",
	["74"] = "28",
	["83"] = "24",
	["92"] = "18",
	["39"] = "27",
	["48"] = "32",
	["57"] = "35",
	["66"] = "36",
	["75"] = "35",
	["84"] = "32",
	["93"] = "27",
	["49"] = "36",
	["58"] = "40",
	["67"] = "42",
	["76"] = "42",
	["85"] = "40",
	["94"] = "36",
	["59"] = "45",
	["68"] = "48",
	["77"] = "49",
	["86"] = "48",
	["95"] = "45",
	["69"] = "54",
	["78"] = "56",
	["87"] = "56",
	["96"] = "54",
	["79"] = "63",
	["88"] = "64",
	["97"] = "63",
	["89"] = "72",
	["98"] = "72",
	["99"] = "81"
}

local superscripts = {
	[1] = "⁰",
	[2] = "¹",
	[3] = "²",
	[4] = "³",
	[5] = "⁴",
	[6] = "⁵",
	[7] = "⁶",
	[8] = "⁷",
	[9] = "⁸",
	[10] = "⁹",
	[11] = "⁻",
	[12] = "⁺"
}

--| Utils

--local function reversedipairs(tab)
--	local newTab = {}
	
--	for i = #tab, -1, 1 do
--		newTab[(#tab - i) + 1] = tab[i]
--	end
	
--	return newTab
--end

local function string_rep(str : string, num : number) : string
	local str_rep : string, n : number = "", 0

	repeat
		str_rep ..= str
		n += 1
	until n == num

	return str_rep
end

local function table_reverse<a>(tab : {a}) : {a}
	local reversed = {}
	
	for i = table.getn(tab), 1, -1 do
		reversed[table.getn(reversed) + 1] = tab[i]
	end
	
	return reversed
end

local function interchangeVariables<typ>(a : typ, b : typ)
	return b, a	
end

--| Script utils

local function wwarn(message : string) : ()
	if getmetatable(stringsForMathModule :: never).printWarnings then
		warn(message)
	end
end

local function iterateSuperscripts(str : string) : boolean
	for i, superscript in pairs(superscripts) do
		if string.find(str, superscript) then
			return true
		end
	end
	
	return false
end

local function passWholeAndDecimals(tab) : ({}, {}, number, number, string, string, string, string, string)
	local notation1 : string, notation2 : string = "", ""
	local notationType : string = ""
	
	local notations = {
		[1] = notation1,
		[2] = notation2
	}
	
	local wholeNumbers = {}
	local decimals = {}
	local wholeStr : string, decimalStr : string = "", ""

	local wholeWithMostDigits : number = 0
	local decimalWithMostDigits : number = 0
	
	for i, str in pairs(tab) do		
		if string.find(str, "e") then
			notations[i] = string.sub(str, string.find(str, "e") :: number)
			notationType = "E"
		elseif iterateSuperscripts(str) then
			notations[i] = string.sub(str, (string.find(str, "x") :: number) + 1)
			notationType = "E"
		end
	end
	
	for i, str in pairs(tab) do		
		str = string.gsub(str, "%s+", "")

		local fraction : string = ""
		
		fraction = stringsForMathModule:ToDecimalFraction(str)

		local try_integer = stringsForMathModule:ToInteger(fraction)
		
		if try_integer then
			fraction = try_integer
		end
		
		local findDot : number = string.find(fraction, "%.", 1, false) :: number

		wholeNumbers[#wholeNumbers + 1] = {}

		local currentWhole = wholeNumbers[#wholeNumbers]
		local wholeDigits = 0

		local wholeMatched, rewrite : string = nil, ""

		if findDot then
			wholeMatched = string.gmatch(string.sub(fraction, 1, findDot - 1), "%d")
		else
			wholeMatched = string.gmatch(fraction, "%d")
		end

		for number in wholeMatched do
			rewrite = number .. rewrite
		end

		for number in string.gmatch(rewrite, ".") do
			currentWhole[#currentWhole + 1] = number
			wholeDigits += 1
		end

		if wholeDigits > wholeWithMostDigits then
			wholeWithMostDigits = wholeDigits
		end

		if findDot then
			local decimalMatched = string.gmatch(string.sub(fraction, findDot + 1, -1), "%d")			

			decimals[#decimals + 1] = {}

			local currentDec = decimals[#decimals]
			local decDigits = 0

			for number in decimalMatched do
				currentDec[#currentDec + 1] = number
				decDigits += 1
			end

			if decDigits > decimalWithMostDigits then
				decimalWithMostDigits = decDigits
			end	
		end
	end
	
	if notation1 ~= notation2 then
		
	end
		
	return wholeNumbers, decimals, wholeWithMostDigits, decimalWithMostDigits, wholeStr, decimalStr, notationType, notations[1], notations[2]
end

--local function appendZerosToDecimal(passedStr : string, first : number, last : number) : string
--	local firstZeros = string_rep("0", first)
--end

local function removeZerosFromDecimal(passedStr : string) : string
	local dBeg, dEnd = false, false

	repeat
		local find0End = string.find(passedStr :: string, "0", string.len(passedStr))
		local find0Beginning = string.find(passedStr :: string, "0", 1)

		if find0End and string.find(passedStr :: string, "%.") and (not string.find(passedStr :: string, "%.0", string.len(passedStr) - 1) and not stringsForMathModule:IsENotation(passedStr)) then
			passedStr = string.sub(passedStr :: string, 1, string.len(passedStr :: string) - 1)
		else
			dEnd = true
		end

		if find0Beginning and (not (string.find(string.sub(passedStr, 1, 2), "0%.", 1)) and not (string.find(string.sub(passedStr, 1, 1), "[^0]", 1))) then
			passedStr = string.sub(passedStr :: string, 2, string.len(passedStr :: string))
		else
			dBeg = true
		end
	until dBeg and dEnd

	if not string.find(passedStr, "%.") then
		passedStr ..= ".0"

		if passedStr == ".0" then
			passedStr = "0.0"
		end
	end

	return passedStr
end

local function determineNumericalOperations(tabToClone : {[number] : string}, operation : string)
	local cloneTab = table.clone(tabToClone)

	local operations = {
		["Addition"] = function(tab)
			if stringsForMathModule:CheckEquality(tab[1], "0") == "Less" then
				if stringsForMathModule:CheckEquality(tab[2], "0") == "Less" then
					return "Addition", "-"
				else
					local result = stringsForMathModule:CheckEquality(stringsForMathModule:abs(tab[1]), tab[2])
					if result == "Greater" then
						return "Subtraction", "-"
					elseif result == "Less" then
						return "Subtraction", "+"
					else
						return "Subtraction", "+"
					end
				end
			else
				if stringsForMathModule:CheckEquality(tab[2], "0") == "Less" then
					local result = stringsForMathModule:CheckEquality(tab[1], stringsForMathModule:abs(tab[2]))

					if result == "Greater" then
						return "Subtraction", "+"
					elseif result == "Less" then
						return "Subtraction", "-"
					else
						return "Subtraction", "+"
					end
				else
					return "Addition", "+"
				end
			end
		end,

		["Subtraction"] = function(tab)
			if stringsForMathModule:CheckEquality(tab[1], "0") == "Less" then
				if stringsForMathModule:CheckEquality(tab[2], "0") == "Less" then
					local result = stringsForMathModule:CheckEquality(stringsForMathModule:abs(tab[1]), stringsForMathModule:abs(tab[2]))

					if result == "Greater" then
						return "Subtraction", "-"
					elseif result == "Less" then
						return "Subtraction", "+"
					else
						return "Subtraction", "+"
					end
				else
					return "Addition", "-"
				end
			else
				if stringsForMathModule:CheckEquality(tab[2], "0") == "Less" then
					return "Addition", "+"
				else
					local result = stringsForMathModule:CheckEquality(tab[1], tab[2])

					if result == "Greater" then
						return "Subtraction", "+"
					elseif result == "Less" then
						return "Subtraction", "-"
					else
						return "Subtraction", "+"
					end
				end
			end
		end,

		["Multiplication"] = function(tab)
			if string.find(tab[1], "%-") then
				if string.find(tab[2], "%-") then
					return "Multiplication", "+"
				else
					return "Multiplication", "-"
				end
			else
				if string.find(tab[2], "%-") then
					return "Multiplication", "-"
				else
					return "Multiplication", "+"
				end
			end
		end,

		["Division"] = function(tab)
			if string.find(tab[1], "%-") then
				if string.find(tab[2], "%-") then
					return "Division", "+"
				else
					return "Division", "-"
				end
			else
				if string.find(tab[2], "%-") then
					return "Division", "-"
				else
					return "Division", "+"
				end
			end
		end
	}

	if not operations[operation] then
		return wwarn(debug.traceback("Please report this to ProBaturay:\nNo operation found named '" .. operation .. "'"))
	end

	return operations[operation](cloneTab)
end

local function transformToTable(...) : {[any] : string}?
	local packed = if typeof(...) == "table" then ... elseif ... then {...} else nil

	if not packed then
		return wwarn("No value found.")
	end

	for i, v in pairs(packed) do
		if typeof(v) ~= "string" and typeof(v) ~= "number" then
			return wwarn("Some of the values are not compatible. Please format the parameter meeting the conditions if the parameter is\n    a table : {[any] : number | string}\n    a number : number,\n    a string : string")
		end
	end

	return packed
end

local function essentialize(...) : {}?
	local tab = transformToTable(...)

	if not tab then
		return wwarn("Please make sure the parameter was passed correctly. Function: StringsForMathModule.Add")
	elseif table.getn(tab) == 1 then		
		return wwarn("At least two numbers required.")	
	else
		return tab
	end
end

-- Metatable

local metaProperties : metastringTable = {
	__add = function(t1, t2)		
		return stringsForMathModule:Add(t1[1], t2[1])
	end,
	__sub = function(t1, t2)		
		return stringsForMathModule:Subtract(t1[1], t2[1])
	end,
	__mul = function(t1, t2)		
		return stringsForMathModule:Multiply(t1[1], t2[1])
	end,
	__div = function(t1, t2)		
		return stringsForMathModule:Divide(t1[1], t2[1])
	end,
}

function add(tab : {[any] : string}) : string
	local operation : string, sign : string = "", ""

	local lastSum : string = tab[1]
	--local dot1 : number, dot2 : number = 0, 0
	
	local function loop(sub : {[number] : string})
		local additionTable = {}
		
		operation, sign = determineNumericalOperations(sub, "Addition")
				
		--dot1 = string.find(sub[1], "%.") or 0
		--dot2 = string.find(sub[2], "%.") or 0

		--if dot1 < dot2 then
		--	sub = table_reverse(sub)

		--	dot1, dot2 = interchangeVariables(dot1, dot2)
		--end
		
		if operation ~= "Addition" then
			sub[1] = string.gsub(sub[1], "%-", "")
			sub[2] = string.gsub(sub[2], "%-", "")

			if sign == "-" then
				if stringsForMathModule:CheckEquality(sub[1], sub[2]) == "Greater" then
					sub = table_reverse(sub)
				end
			else
				if stringsForMathModule:CheckEquality(sub[1], sub[2]) == "Less" then
					sub = table_reverse(sub)
				end
			end
			
			return subtract(sub)
 		end
		
		local wholeNumbers, decimals, wholeWithMostDigits, decimalWithMostDigits, wholeStr, decimalStr, notationType, notation1, notation2 = passWholeAndDecimals(sub)
		
		--for i1 : number, tab in pairs(wholeNumbers) do
		--	--coroutine.wrap(function()
		--		for i2 : number, value : number in ipairs(tab) do
		--			if not additionTable[i2] then
		--				additionTable[i2] = {}
		--			end
					
		--			if i1 ~= table.getn(wholeNumbers) then
		--				table.insert(additionTable[i2], value)
		--			else
		--				print(dot2, dot1, additionTable, i2)
		--				table.insert(additionTable[i2 + (dot1 - dot2)], value)						
		--			end
		--		end
		--	--end)()
		--end
		
		--print(additionTable)
		--additionTable = table_reverse(additionTable)
		--print(additionTable)

		--for i, tab in ipairs(additionTable) do
		--	--coroutine.wrap(function()
		--		local totalNumber : number = 0
			
		--		for i, num in ipairs(tab) do
		--			totalNumber += num
		--		end
				
		--		additionTable[i] = totalNumber :: never
		--	--end)()
		--end
		
		--local remaining = 0
		
		--for i, num : number in ipairs(additionTable :: {}) do
		--	if i ~= table.getn(additionTable) then
		--		local total = tostring(num + remaining)
		--		wholeStr = string.sub(total, string.len(total)) .. wholeStr
				
		--		if string.len(tostring(num)) >= 2 then
		--			remaining = tonumber(string.sub(tostring(num), 1, string.len(tostring(num)) - 1)) :: number
		--		end
		--	else
		--		wholeStr = tostring(remaining + num) .. wholeStr
		--	end
		--end
		
		local wholeSum : number, wholeRemaining : number = 0, 0
		local decimalSum : number, decimalRemaining : number = 0, 0
		
		if decimalWithMostDigits > 0 then
			for iteration = decimalWithMostDigits, 1, -1 do
				decimalSum = decimalRemaining
				
				for i, setOfDigits : {[number] : string} in pairs(decimals) do
					decimalSum += tonumber(setOfDigits[iteration]) or 0
				end
				
				if string.len(tostring(decimalSum)) == 1 then
					decimalRemaining = 0
				else						
					decimalRemaining = (decimalSum - tonumber(string.sub(tostring(decimalSum), string.len(tostring(decimalSum)), -1)) :: number) / 10
				end
				
				decimalStr = string.sub(tostring(decimalSum), string.len(tostring(decimalSum)), -1) .. decimalStr
			end
		end
		
		wholeRemaining = decimalRemaining
		
		if wholeWithMostDigits > 0 then
			for iteration = 1, wholeWithMostDigits, 1 do
				wholeSum = wholeRemaining
				for i, setOfDigits : {[number] : string} in pairs(wholeNumbers) do
					wholeSum += tonumber(setOfDigits[iteration]) or 0
				end
						
				if string.len(tostring(wholeSum)) == 1 then
					wholeRemaining = 0
				else
					wholeRemaining = (wholeSum - tonumber(string.sub(tostring(wholeSum), string.len(tostring(wholeSum)), -1)) :: number) / 10
				end
			
				if iteration == wholeWithMostDigits then
					wholeStr = wholeSum .. wholeStr
				else
					wholeStr = string.sub(tostring(wholeSum), string.len(tostring(wholeSum)), -1) .. wholeStr
				end
			end
		end
		
		--if dot2 > 0 then
		--	wholeStr = string.sub(wholeStr, 1, (dot2 + (string.len(sub[2]) - string.len(wholeStr))) + 1) .. "." .. string.sub(wholeStr, (dot2 + (string.len(sub[2]) - string.len(wholeStr))) + 2)
		--end
		
		if sign == "-" then
			wholeStr = "-" .. wholeStr
		end
		
		--return if string.len(decimalStr) ~= 0 then wholeStr .. "." .. decimalStr else wholeStr
		return wholeStr
	end
	
	local n : number = 2
	
	repeat
		lastSum = loop({lastSum, tab[n]})
		n += 1
	until n == #tab + 1
	
	return if sign == "-" and (not string.find(lastSum, "%-")) then sign .. lastSum else lastSum
end

function subtract(tab : {[any] : string}) : string
	local operation, sign

	local lastDifference : string = tab[1]
	
	local function loop(sub : {[number] : string})		
		operation, sign = determineNumericalOperations(sub, "Subtraction")
				
		if (string.find(sub[1], "%-") or string.find(sub[2], "%-")) and operation == "Addition" then
			sub[1] = string.gsub(sub[1], "%-", "")
			sub[2] = string.gsub(sub[2], "%-", "")
		end
		
		if operation ~= "Subtraction" then
			if stringsForMathModule:CheckEquality(stringsForMathModule:abs(sub[1]), stringsForMathModule:abs(sub[2])) == "Less" then
				sub = table_reverse(sub)
			end
			
			return if sign == "-" then "-" .. add(sub) else add(sub)
		else
			if not (string.find(sub[1], "%-") and string.find(sub[2], "%-")) then
				if stringsForMathModule:CheckEquality(sub[1], sub[2]) == "Less" then
					sub = table_reverse(sub)
				end
			else
				sub[1] = string.gsub(sub[1], "%-", "")
				sub[2] = string.gsub(sub[2], "%-", "")

				if stringsForMathModule:CheckEquality(sub[1], sub[2]) == "Less" then
					sub = table_reverse(sub)
				end
			end
		end
		
		local wholeNumbers, decimals, wholeWithMostDigits, decimalWithMostDigits, wholeStr, decimalStr = passWholeAndDecimals(sub)
		
		for i, v in pairs(wholeNumbers) do
			if #v ~= wholeWithMostDigits then
				repeat
					v[#v + 1] = "0"
				until #v == wholeWithMostDigits
			end
		end
		
		for i, v in pairs(decimals) do
			if #v ~= decimalWithMostDigits then
				repeat
					v[#v + 1] = "0"
				until #v == decimalWithMostDigits
			end
		end
		
		local wholeDifference : number, wholeLoan : number = 0, 0
		local decimalDifference : number, decimalLoan : number = 0, 0
		
		if decimalWithMostDigits > 0 then
			for iteration = decimalWithMostDigits, 1, -1 do
				decimalDifference = -decimalLoan

				for i, setOfDigits : {[number] : string} in pairs(decimals) do
					decimalDifference = if i == 1 then (tonumber(setOfDigits[iteration]) :: number) + decimalDifference or 0 else (decimalDifference + 10) - (tonumber(setOfDigits[iteration]) :: number)
				end
				
				if string.len(tostring(decimalDifference)) ~= 2 then
					decimalLoan = 1
				else
					decimalLoan = 0
				end
				
				decimalStr = string.sub(tostring(decimalDifference), string.len(tostring(decimalDifference)), -1) .. decimalStr
			end
		end
		
		wholeLoan = decimalLoan

		if wholeWithMostDigits > 0 then
			for iteration = 1, wholeWithMostDigits, 1 do
				wholeDifference = -wholeLoan
				
				for i, setOfDigits : {[number] : string} in pairs(wholeNumbers) do
					wholeDifference = if i == 1 then (tonumber(setOfDigits[iteration]) :: number) + wholeDifference or 0 else (wholeDifference + 10) - (tonumber(setOfDigits[iteration]) :: number)
				end

				if string.len(tostring(wholeDifference)) ~= 2 then
					wholeLoan = 1
				else
					wholeLoan = 0
				end
				
				wholeStr = string.sub(tostring(wholeDifference), string.len(tostring(wholeDifference)), -1) .. wholeStr
			end
		end

		if string.find(tostring(wholeDifference), "%-") then
			wholeStr = "-" .. wholeStr
		end
		
		if wholeStr == "" then
			wholeStr = "0"
		end
		
		if sign == "-" and not string.find(wholeStr, "%-") then 
			wholeStr = sign .. wholeStr
		end
		
		return if string.len(decimalStr) ~= 0 then wholeStr .. "." .. decimalStr else wholeStr
	end
	
	local n : number = 2
	
	repeat
		lastDifference = loop({lastDifference, tab[n]}) :: string
		n += 1
	until n == #tab + 1
		
	return lastDifference
end

function multiply(tab : {[any] : string}) : string
	local operation : string, sign : string = "", ""

	local lastProduct : string = tab[1]
	
	local function loop(sub : {[number] : string}) : string
		local multiplicationTab = {}

		operation, sign = determineNumericalOperations(sub, "Multiplication")
		
		local float = 0
		
		for i, str in pairs(sub) do
			if string.find(str, "%.") then
				float += string.len(string.sub(str, (string.find(str, "%.") :: number) + 1))
			end
		end

		sub[1] = string.gsub(sub[1], "%.", "")
		sub[2] = string.gsub(sub[2], "%.", "")

		local wholeNumbers : {}, decimals : {}, wholeWithMostDigits : number, decimalWithMostDigits : number, wholeStr : string, decimalStr : string = passWholeAndDecimals(sub)
		
		local slide = 1
		
		local remaining = "0"
		
		for first_i : number, multiplicandDigit : string in pairs(wholeNumbers[2]) do
			for last_i : number, multiplierDigit : string in pairs(wholeNumbers[1]) do
				if not multiplicationTab[slide] then
					multiplicationTab[slide] = {}
				end
				
				local digitsToAdd = {remaining}
				
				if multiplicandDigit ~= "0" then
					for i = 1, tonumber(multiplicandDigit) :: number do -- No precision lost
						table.insert(digitsToAdd, i, multiplierDigit)
					end
					
					if #digitsToAdd ~= 1 then
						local sum = "0"
						
						--[[sum = stringsForMathModule:ToInteger(add(digitsToAdd)) :: string --[[ 
						Deprecated
						Reason: add function slowed down the speed of the addition, instead, applied a multiplication table of digits
						]]
						
						local mul = multiplierDigit .. multiplicandDigit
						local overall = multiplicationTable[mul]
												
						if string.len(overall) > 1 then
							local added = additionTable[remaining .. string.sub(overall, string.len(overall))]
							if string.len(added) > 1 then
								overall = additionTable[string.sub(overall, 1, string.len(overall) - 1) .. "1"] .. string.sub(added, string.len(added))
							else
								overall = string.sub(overall, 1, string.len(overall) - 1) .. added
							end
						else
							overall = additionTable[remaining .. overall]
						end
						
						sum = stringsForMathModule:ToInteger(overall) :: string

						if string.len(sum) >= 2 and last_i ~= wholeNumbers[1] then
							remaining = string.sub(sum, 1, string.len(sum) - 1)
						else
							remaining = "0"
						end
						
						if last_i ~= #wholeNumbers[1] then
							table.insert(multiplicationTab[slide], string.sub(sum, string.len(sum)))
						else
							if string.len(sum) >= 2 then
								sum = string.reverse(sum)
								
								for i in string.gmatch(sum, ".") do
									if not multiplicationTab[slide] then
										multiplicationTab[slide] = {}
									end
									
									table.insert(multiplicationTab[slide], i)
									
									slide += 1
								end
							else
								table.insert(multiplicationTab[slide], sum)
							end
						end
					else
						table.insert(multiplicationTab[slide], multiplierDigit)
					end
				end
				
				slide += 1
			end
			
			remaining = "0"
			slide = first_i + 1
		end
		
		for i : number, v : {[number] : string} in ipairs(multiplicationTab) do			
			table.insert(v, tostring(remaining))
			local sum = v[1]

			if #v > 1 then
				--[[ Bad practice:
				
				--local added = v[1]
				--table.remove(v, 1)
				
				--local function loopConsecutively(a : string, b : string) : string
				--	local extra = "0"
					
				--	if string.len(a) > 1 then
				--		extra = string.sub(a, 1, string.len(a) - 1)
				--	end
					
				--	local added = additionTable[string.sub(a, string.len(a)) .. b]
				--	print(added)
				--	if string.len(added) > 1 then
				--		return additionTable[extra .. string.sub(added, 1, string.len(added) - 1)] .. string.sub(added, string.len(added))
				--	else
				--		return extra .. added
				--	end
				--end
				
				--print(added)
				--for i, str : string in pairs(v) do
				--	added = loopConsecutively(added, str)
				--end
				
				]]
				
				local added = add(v)

				sum = stringsForMathModule:ToInteger(added) :: string
				
				if string.len(sum) >= 2 then
					remaining = string.sub(sum, 1, string.len(sum) - 1)
				else
					remaining = "0"
				end
				
				sum = string.sub(sum, string.len(sum))
			end
			
			wholeStr = sum .. wholeStr
		end
		
		if float > 0 then
			local first : string, last : string
			
			if string.len(wholeStr) > float then
				first = string.sub(wholeStr, 1, (string.len(wholeStr) - float))
				last = string.sub(wholeStr, string.len(wholeStr) - float + 1)
				wholeStr = first .. "." .. last
			else
				local zeros = (float - string.len(wholeStr)) + 1
				local rep = string_rep("0", zeros)
				wholeStr = rep .. wholeStr
				
				first = string.sub(wholeStr, 1, 1)
				last = string.sub(wholeStr, 2)
				wholeStr = first .. "." .. last
				wholeStr = removeZerosFromDecimal(wholeStr)
			end
		end

		return wholeStr
	end

	local n : number = 2
	
	repeat
		lastProduct = loop({sign .. lastProduct, tab[n]}) :: string
		n += 1
	until n == #tab + 1
	
	return if sign == "-" and (not string.find(lastProduct, "%-")) then sign .. lastProduct else lastProduct
end

function divide(tab : {[any] : string}) : string
	local operation : string, sign : string = "", ""

	local lastQuotient : string = tab[1]

	local function loop(sub : {[number] : string}) : string
		local divisionTab = {}

		operation, sign = determineNumericalOperations(sub, "Multiplication")

		local float = 0

		for i, str in pairs(sub) do
			if string.find(str, "%.") then
				float += string.len(string.sub(str, (string.find(str, "%.") :: number) + 1))
			end
		end

		sub[1] = string.gsub(sub[1], "%.", "")
		sub[2] = string.gsub(sub[2], "%.", "")

		local wholeNumbers : {}, decimals : {}, wholeWithMostDigits : number, decimalWithMostDigits : number, wholeStr : string, decimalStr : string = passWholeAndDecimals(sub)

		local slide = 1

		local remaining = "0"

		for first_i : number, multiplicandDigit : string in pairs(wholeNumbers[2]) do
			for last_i : number, multiplierDigit : string in pairs(wholeNumbers[1]) do
				if not divisionTab[slide] then
					divisionTab[slide] = {}
				end

				local digitsToAdd = {remaining}

				if multiplicandDigit ~= "0" then
					for i = 1, tonumber(multiplicandDigit) :: number do -- No precision lost
						table.insert(digitsToAdd, i, multiplierDigit)
					end

					if #digitsToAdd ~= 1 then
						local sum = "0"

						--[[sum = stringsForMathModule:ToInteger(add(digitsToAdd)) :: string --[[ 
						Deprecated
						Reason: add function slowed down the speed of the addition, instead, applied a multiplication table of digits
						]]

						local mul = multiplierDigit .. multiplicandDigit
						local overall = multiplicationTable[mul]

						if string.len(overall) > 1 then
							local added = additionTable[remaining .. string.sub(overall, string.len(overall))]
							if string.len(added) > 1 then
								overall = additionTable[string.sub(overall, 1, string.len(overall) - 1) .. "1"] .. string.sub(added, string.len(added))
							else
								overall = string.sub(overall, 1, string.len(overall) - 1) .. added
							end
						else
							overall = additionTable[remaining .. overall]
						end

						sum = stringsForMathModule:ToInteger(overall) :: string

						if string.len(sum) >= 2 and last_i ~= wholeNumbers[1] then
							remaining = string.sub(sum, 1, string.len(sum) - 1)
						else
							remaining = "0"
						end

						if last_i ~= #wholeNumbers[1] then
							table.insert(divisionTab[slide], string.sub(sum, string.len(sum)))
						else
							if string.len(sum) >= 2 then
								sum = string.reverse(sum)

								for i in string.gmatch(sum, ".") do
									if not divisionTab[slide] then
										divisionTab[slide] = {}
									end

									table.insert(divisionTab[slide], i)

									slide += 1
								end
							else
								table.insert(divisionTab[slide], sum)
							end
						end
					else
						table.insert(divisionTab[slide], multiplierDigit)
					end
				end

				slide += 1
			end

			remaining = "0"
			slide = first_i + 1
		end

		print(divisionTab)

		for i : number, v : {[number] : string} in ipairs(divisionTab) do			
			table.insert(v, tostring(remaining))
			local sum = v[1]

			if #v > 1 then
				--[[ Bad practice:
				
				--local added = v[1]
				--table.remove(v, 1)
				
				--local function loopConsecutively(a : string, b : string) : string
				--	local extra = "0"
					
				--	if string.len(a) > 1 then
				--		extra = string.sub(a, 1, string.len(a) - 1)
				--	end
					
				--	local added = additionTable[string.sub(a, string.len(a)) .. b]
				--	print(added)
				--	if string.len(added) > 1 then
				--		return additionTable[extra .. string.sub(added, 1, string.len(added) - 1)] .. string.sub(added, string.len(added))
				--	else
				--		return extra .. added
				--	end
				--end
				
				--print(added)
				--for i, str : string in pairs(v) do
				--	added = loopConsecutively(added, str)
				--end
				
				]]

				local added = add(v)

				sum = stringsForMathModule:ToInteger(added) :: string

				if string.len(sum) >= 2 then
					remaining = string.sub(sum, 1, string.len(sum) - 1)
				else
					remaining = "0"
				end

				sum = string.sub(sum, string.len(sum))
			end

			wholeStr = sum .. wholeStr
		end

		if float > 0 then
			local first : string, last : string

			if string.len(wholeStr) > float then
				first = string.sub(wholeStr, 1, (string.len(wholeStr) - float))
				last = string.sub(wholeStr, string.len(wholeStr) - float + 1)
				wholeStr = first .. "." .. last
			else
				local zeros = (float - string.len(wholeStr)) + 1
				local rep = string_rep("0", zeros)
				wholeStr = rep .. wholeStr

				first = string.sub(wholeStr, 1, 1)
				last = string.sub(wholeStr, 2)
				wholeStr = first .. "." .. last
				wholeStr = removeZerosFromDecimal(wholeStr)
			end
		end

		return wholeStr
	end

	local n : number = 2

	repeat
		lastQuotient = loop({sign .. lastQuotient, tab[n]}) :: string
		n += 1
	until n == #tab + 1

	return if sign == "-" and (not string.find(lastQuotient, "%-")) then sign .. lastQuotient else lastQuotient
end

function stringsForMathModule:abs(numberToAbsolute : NorS) : string
	local decimal = stringsForMathModule:ToDecimalFraction(numberToAbsolute)
	
	return if string.find(decimal, "%-") then string.gsub(decimal, "%-", "") else decimal
end

function stringsForMathModule:NumberToString(...) : (string | {[any] : string} | nil)
	wwarn("Number(s) might have lost precision while being converted to string.")

	if typeof(...) == "table" then
		local tab : tableReturnType<string> = ...
		
		for i, v in pairs(tab) do
			tab[i] = tostring(v) :: string
		end
		
		return tab
	elseif typeof(...) == "number" then
		return tostring(...) :: string
	elseif typeof(...) == "string" then
		return ...
	else	
		return nil :: nil
	end
end

function stringsForMathModule:StringToNumber(...)
	wwarn("Number(s) might have lost precision while being converted to string.")

	if typeof(...) == "table" then
		local tab : tableReturnType<number> = ...

		for i, v in pairs(tab) do
			tab[i] = tonumber(v) :: number
		end

		return tab
	elseif typeof(...) == "string" then
		return tonumber(...)
	elseif typeof(...) == "number" then
		return tonumber(...)
	else
		return nil
	end
end

function stringsForMathModule:ToDecimalFraction(targetToConvert : NorS) : string
	if not targetToConvert then
		wwarn("No number passed.\n\n" .. debug.traceback())
	elseif targetToConvert == "" then
		return "0.0"
	end
	
	if stringsForMathModule:IsENotation(targetToConvert :: string) and string.find(targetToConvert :: string, "%.") ~= 2 then
		targetToConvert = stringsForMathModule:ToENotation(targetToConvert :: string) :: string
	end
	
	local str : string = targetToConvert :: string

	if typeof(targetToConvert) == "number" and (targetToConvert > 2^53 or targetToConvert < -2^53) then
		str = string.format("%f", targetToConvert) :: string; wwarn("Number(s) might have lost precision while being converted to string.")
	end
	
	local sign = string.match(string.sub(str :: string, 1, 1), "%-", 1)
	
	str = if sign then string.gsub(str :: string, "%-", "", 1) else str

	local findDot = string.find(str :: string, "%.")
		
	if findDot then
		str = removeZerosFromDecimal(str :: string)
	end
	
	local findExponentialNotation = string.find(str :: string, "e") or string.find(str :: string, "E")

	if findExponentialNotation then
		local fullNotation : string
		
		fullNotation = string.match(str :: string, "[[%d+%.%-%+]?%.*[%d+]*[e?E?]]?[%-%+]*%d+")
			
		if not fullNotation then
			wwarn("The number with the 'E' notation is malformed. Will try to figure out the number manually.")
		end
			
		if string.sub(fullNotation, 1, 1) == "e" then
			wwarn("The number with the 'E' notation is malformed. Will try to figure out the number manually.")
		elseif string.sub(fullNotation, 1, 2) == ".e" then
			wwarn("The number with the 'E' notation is malformed. Will try to figure out the number manually.")
		end

		local s, e = pcall(function()
			local newStr : string = str :: string
			local sign = string.find(string.sub(newStr, 1, 1), "%-", 1)
			local dot = string.find(newStr, "%.")
			local exponent : string = string.match(newStr, ".+", findExponentialNotation + 1)
			local exp : number = tonumber(exponent) :: number
			
			if exp < 0 then
				local str_rep = ""
				str_rep = string_rep("0", tonumber(stringsForMathModule:abs(exp)) :: number)
				
				newStr ..= str_rep
				
				newStr = str_rep .. string.match(string.gsub(newStr, "%.", ""), "%d+", 1)
				newStr = string.sub(newStr, 1, 1) .. "." .. string.sub(newStr, 2)
			elseif exp > 0 then
				if dot then			
					local numbersAfterDot = string.sub(newStr, dot + 1, (string.find(newStr, "[e?E?]") :: number) - 1)

					newStr = string.gsub(newStr, "[e?E?][%-%+]*%d+", "")
					
					local str_rep = ""
					str_rep = string_rep("0", exp)
					
					newStr ..= str_rep
					
					local dotPosition : number = string.find(newStr, "%.") :: number
					local gsub = string.gsub(newStr, "%.", "")
					
					newStr = string.sub(gsub, 1, (dotPosition - 1) + exp) .. "." .. string.sub(gsub, dotPosition + exp)
				else
					local str_rep = ""
					str_rep = string_rep("0", exp)

					
					newStr = string.sub(newStr, 1, (string.find(newStr, "[e?E?]") :: number) - 1) .. str_rep
					newStr ..= ".0"
				end
			else
				newStr = string.gsub(newStr, "e[%-?%+?]%d+", "")
			end
			
			str = if sign then "-" .. newStr else newStr
		end)	
	end
	
	if string.find(string.sub(str :: string, 1, 1), "%+") then
		str = string.sub(str :: string, 2)
	end
	
	if string.sub(str :: string, string.len(str :: string) - 1, string.len(str :: string)) ~= ".0" then
		str = removeZerosFromDecimal(str :: string)
	end
	
	return if sign then "-" .. str :: string else str :: string
end

function stringsForMathModule:ToENotation(eNoted : string, uppercase : boolean?) : string
	if typeof(eNoted) == "number" then
		eNoted = string.format("%f", eNoted) :: string
	end
	
	local letter : string = if uppercase then "E" else "e"
	local sign : string = string.match(string.sub(eNoted, 1, 1), "%-", 1) or ""
	
	eNoted = string.gsub(eNoted, "%-", "")

	local findDot : number = string.find(eNoted, "%.", 1) :: number
		
	local firstDigitExceptZero : number = string.find(eNoted, "[^0%D]", 1) :: number
	local baseTen : string? = string.match(eNoted, "%p?%d+", string.find(eNoted, "e") :: number)
	
	local floated : string 
	
	if not findDot and baseTen then
		floated = tostring(string.len(string.match(eNoted, "%d+", 1)))
	else
		floated = subtract({tostring(findDot), tostring(firstDigitExceptZero)}) :: string
	end
	
	if stringsForMathModule:IsENotation(eNoted) then
		eNoted = string.gsub(eNoted, "%.", "")
		
		if stringsForMathModule:CheckEquality(floated, 0) == "Less" then
			local base : string = stringsForMathModule:ToInteger(add({baseTen :: string, floated}) :: string) :: string

			eNoted = string.sub(eNoted, 1, firstDigitExceptZero - 1) .. "." .. string.sub(eNoted, firstDigitExceptZero, (string.find(eNoted, "[e?E?]") :: number) - 1) .. letter .. (if stringsForMathModule:CheckEquality(stringsForMathModule:abs(base), base) == "Equal" then "+" .. base else (if base ~= "0" then base else "+" .. base))
			eNoted = string.match(eNoted, "[^0]+.+", 1)
		else
			local wholePart : string = string.sub(eNoted, 1, 1)

			local decimalPart : string = string.sub(eNoted, 2, (string.find(eNoted, "[e?E?]") :: number) - 1)
			
			local float = add({floated, "-1"})
			local base : string = stringsForMathModule:ToInteger(add({baseTen :: string, float}) :: string) :: string

			eNoted = wholePart .. "." .. decimalPart .. letter .. (if stringsForMathModule:CheckEquality(stringsForMathModule:abs(base), base) == "Equal" then "+" .. base else (if base ~= "0" then base else "+" .. base))
		end
	else
		if findDot then
			eNoted = string.gsub(eNoted, "%.", "")
			eNoted = string.sub(eNoted, 1, 1) .. "." .. string.sub(eNoted, 2) .. letter .. "+" .. findDot - 1
		else
			local fraction = string.sub(eNoted, 2)
			
			if not fraction then
				eNoted = string.sub(eNoted, 1, 1) .. letter .. "+0"
			else
				eNoted = string.sub(eNoted, 1, 1) .. "." .. fraction .. letter .. "+" .. string.len(fraction)
			end
		end
	end
	
	if string.find(string.sub(eNoted, 1, 1), "%+", 1) then 
		eNoted = string.gsub(eNoted, "%+", "", 1)
	end
	
	if string.find(string.sub(eNoted, 2, (string.find(eNoted, "e") :: number) - 1), "0+", 1) then 
		eNoted = string.gsub(eNoted, "0+", "", 1)
	end

	return sign .. eNoted
end

function stringsForMathModule:CheckEquality(a : NorS, b : NorS, customReturns : {[number] : any}?) : string?
	local returns = {
		[1] = "Equal",
		[2] = "Greater",
		[3] = "Less",
	}
	
	if customReturns then
		customReturns = returns
	end
	
	local aDecimal : string = stringsForMathModule:ToDecimalFraction(a)
	local bDecimal : string = stringsForMathModule:ToDecimalFraction(b)
	
	local tab = {aDecimal, bDecimal}
	
	type DecimalProperties = {
		["WholeDigits"] : {[number] : number},
		["FractionDigits"] : {[number] : number},
		["Sign"] : {[number] : string}
	}
	
	local properties : DecimalProperties = {
		["WholeDigits"] = {},
		["FractionDigits"] = {},
		["Sign"] = {}
	}
	
	local leastDecimal = if string.find(aDecimal, "%.") then string.len(string.sub(aDecimal, (string.find(aDecimal, "%.") :: number) + 1)) else 0

	for i, decimal in pairs(tab) do
		properties["WholeDigits"][i] = string.len(string.sub(decimal, 1, string.find(decimal, "%.") :: number))
		properties["FractionDigits"][i] = if string.find(decimal, "%.") then string.len(string.sub(decimal, (string.find(decimal, "%.") :: number) + 1)) else 0
		properties["Sign"][i] = if string.find(decimal, "-") then "-" else "+"
		
		if properties["FractionDigits"][i] < leastDecimal then
			leastDecimal = properties["FractionDigits"][i]
		end
	end
	
	if properties["Sign"][1] == "-" then
		if properties["Sign"][2] == "-" then
			if properties["WholeDigits"][1] == properties["WholeDigits"][2] then
				for i = 1, string.len(string.sub(aDecimal, 1, ((string.find(aDecimal, "%.") :: number) or 0) - 1)) do
					if tonumber(string.sub(aDecimal, i, i)) == tonumber(string.sub(bDecimal, i, i)) then
						continue
					elseif tonumber(string.sub(aDecimal, i, i)) :: number > tonumber(string.sub(bDecimal, i, i)) :: number then
						return returns[3]
					else
						return returns[2]
					end
				end
				
				for i = 1, leastDecimal do
					if tonumber(string.sub(aDecimal, (string.find(aDecimal, "%.") :: number) + i, (string.find(aDecimal, "%.") :: number) + i)) == tonumber(string.sub(bDecimal, (string.find(bDecimal, "%.") :: number) + i, (string.find(bDecimal, "%.") :: number) + i)) then
						continue
					elseif (tonumber(string.sub(aDecimal, (string.find(aDecimal, "%.") :: number) + i, (string.find(aDecimal, "%.") :: number) + i)) :: number) > (tonumber(string.sub(bDecimal, (string.find(bDecimal, "%.") :: number) + i, (string.find(bDecimal, "%.") :: number) + i)) :: number) then
						return returns[3]
					else
						return returns[2]
					end
				end
				
				if properties["FractionDigits"][1] == properties["FractionDigits"][2] then
					return returns[1]
				elseif properties["FractionDigits"][1] < properties["FractionDigits"][2] then	
					return returns[3]
				else
					return returns[2]
				end
			elseif properties["WholeDigits"][1] < properties["WholeDigits"][2] then		
				return returns[2]
			else
				return returns[3]
			end
		else
			return returns[3]
		end
	else
		if properties["Sign"][2] == "-" then
			return returns[2]
		else
			if properties["WholeDigits"][1] == properties["WholeDigits"][2] then
				for i = 1, string.len(string.sub(aDecimal, 1, ((string.find(aDecimal, "%.") :: number) or 0) - 1)) do
					if tonumber(string.sub(aDecimal, i, i)) == tonumber(string.sub(bDecimal, i, i)) then
						continue
					elseif tonumber(string.sub(aDecimal, i, i)) :: number > tonumber(string.sub(bDecimal, i, i)) :: number then
						return returns[2]
					else
						return returns[3]
					end
				end

				for i = 1, leastDecimal do
					if tonumber(string.sub(aDecimal, (string.find(aDecimal, "%.") :: number) + i, (string.find(aDecimal, "%.") :: number) + i)) == tonumber(string.sub(bDecimal, (string.find(bDecimal, "%.") :: number) + i, (string.find(bDecimal, "%.") :: number) + i)) then
						continue
					elseif (tonumber(string.sub(aDecimal, (string.find(aDecimal, "%.") :: number) + i, (string.find(aDecimal, "%.") :: number) + i)) :: number) > (tonumber(string.sub(bDecimal, (string.find(bDecimal, "%.") :: number) + i, (string.find(bDecimal, "%.") :: number) + i)) :: number) then
						return returns[2]
					else
						return returns[3]
					end
				end

				if properties["FractionDigits"][1] == properties["FractionDigits"][2] then
					return returns[1]
				elseif properties["FractionDigits"][1] < properties["FractionDigits"][2] then	
					return returns[3]
				else
					return returns[2]
				end
			elseif properties["WholeDigits"][1] < properties["WholeDigits"][2] then			
				return returns[3]
			else
				return returns[2]
			end
		end
	end
end

function stringsForMathModule:ToInteger(number : NorS) : string?
	local dec = stringsForMathModule:ToDecimalFraction(number)
	local afterDot = string.match(dec, "%.0+")
	
	if afterDot == string.sub(dec, string.find(dec, "%.") :: number) then
		dec = string.gsub(dec, "%.0+", "")
	else
		return wwarn("Cannot transform to integer.")
	end
	
	return dec
end

function stringsForMathModule:Add(... : unknown) : string?
	local tab = essentialize(...)
	
	if tab then
		return add(tab :: {[any] : string}) :: string
	else
		return wwarn("Please make sure the parameters were passed correctly.")
	end
end

function stringsForMathModule:Subtract(... : unknown) : string?
	local tab = essentialize(...)

	if tab then 
		return subtract(tab :: {[any] : string}) :: string
	else
		return wwarn("Please make sure the parameters were passed correctly.")
	end
end

function stringsForMathModule:Multiply(... : unknown) : string?
	local tab = essentialize(...)

	if tab then 
		return multiply(tab :: {[any] : string}) :: string
	else
		return wwarn("Please make sure the parameters were passed correctly.")
	end
end

function stringsForMathModule:Divide(...) : string?
	local tab = essentialize(...)

	if tab then 
		return divide(tab :: {[any] : string}) :: string
	else
		return wwarn("Please make sure the parameters were passed correctly.")
	end
end

function stringsForMathModule:Root(num : NorS, root : NorS, digitTolerance : NorS)
	
end

function stringsForMathModule:ToThePower(base : NorS, power : NorS)
	local number = "0"
end

function stringsForMathModule:ExpandDecimal(dotDecimal : string, float : number?) : (string?, number?)
	if not float then
		float = 0
	elseif float < 0 or math.round(float) ~= float then
		return wwarn("Cannot float to left digits.")
	end
	
	if typeof(dotDecimal) == "number" and (dotDecimal > 2^53 or dotDecimal < -2^53) then
		dotDecimal = tostring(dotDecimal); wwarn("Number(s) might have lost precision while being converted to string.")
	end

	local dot : number = string.find(dotDecimal, "%.") :: number

	if not dot then
		return dotDecimal
	end
	
	local afterDot = string.sub(dotDecimal, if float ~= 0 then dot + float :: number else dot + 1)

	if string.find(afterDot, "%D") then
		return wwarn("Decimal is malformed.")
	end

	if float == 0 then
		dotDecimal = string.gsub(dotDecimal, "%.", "")
	else
		local num = (string.find(dotDecimal, "%.") :: number) + (float :: number)
		dotDecimal = string.gsub(dotDecimal, "%.", "")
		
		dotDecimal = string.sub(dotDecimal, 1, num - 1) .. "." .. string.sub(dotDecimal, num)
	end
	
	if string.match(dotDecimal, "[0]+") then
		dotDecimal = string.gsub(dotDecimal, "[0]+", "", 1)
	end
	
	return dotDecimal, string.len(afterDot)
end
	
function stringsForMathModule:IsENotation(str : string)
	local match = string.match(str, "[[%d+%.%-%+]?%.*[%d+]*[e?E?]]?[%-%+]*%d+")
	
	if match and (string.sub(match, 1, 1) == "e" or string.match(match, "[%-?%+?]e", 1)) then
		return false
	end
	
	return if match ~= nil then (if match then true else false) else nil
end

function stringsForMathModule:SetMetastring(str : NorS)
	if typeof(str) == "number" and (str > 2^53 or str < -2^53) then
		str = tostring(str); wwarn("Number(s) might have lost precision while being converted to string.")
	end
	
	return setmetatable({[1] = str}, metaProperties)
end

return stringsForMathModule
