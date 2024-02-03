--Maid
--Scrypt, 23/07/2023

local maid = {}
maid.__index = maid

maid.__metatable = function()
	return "Maid"
end

maid.__tostring = function()
	return "Maid"
end

function maid.new()
	local self = setmetatable({},maid)
	self._objects = {}
	return self
end

local function Cleaner(self)
	local _type = self.selfObj
	table.remove(self.self._objects, table.find(self.self._objects,_type))
	if type(_type) == "function" then
		_type()
	elseif typeof(_type) == "Instance" then
		_type:Destroy()
	elseif typeof(_type) == "RBXScriptConnection" then
		_type:Disconnect()
	end
end

function maid:List(_task)
	if table.find(self._objects,_task) then return _task,setmetatable({self = self, selfObj = _task,Deconstruct = Cleaner},{__metatable = function() return "Deconstructor" end, __tostring = function() return "Deconstructor" end}) end
	table.insert(self._objects,_task)
	return _task,setmetatable({self = self, selfObj = _task,Deconstruct = Cleaner},{__metatable = function() return "Deconstructor" end, __tostring = function() return "Deconstructor" end})
end
local a : RBXScriptConnection

function maid:Construct(_type)
	if type(_type) == "function" then
		return self:List(_type)
	elseif typeof(_type) == "string" then
		return self:List(Instance.new(_type))
	elseif typeof(_type) == "RBXScriptConnection" then
		return self:List(_type)
	end
end

function maid:Clear()
	for _, _type in ipairs(self._objects) do
		if type(_type) == "function" then
			_type()
		elseif typeof(_type) == "Instance" then
			_type:Destroy()
		elseif typeof(_type) == "RBXScriptConnection" then
			_type:Disconnect()
		end
	end
	self._objects = {}
end

return table.freeze(maid)
