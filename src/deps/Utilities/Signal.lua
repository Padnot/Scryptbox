--Signal
--Scrypt, 23/07/2023
--Some part of the functions are from "GoodSignal", credits to stravant.

local con = {}
con.__index = con
con.__metatable = function()
	return "RBXScriptConnection"
end

con.__tostring = function()
	return "RBXScriptConnection"
end

local signal = {}
signal.__index = signal
signal.__metatable = function()
	return "RBXScriptSignal"
end

signal.__tostring = function()
	return "RBXScriptSignal"
end

function con.new(f)
	local self = setmetatable({},con)
	self._callback = f
	self._connected = true
	return self
end

function con:Disconnect()
	self._connected = false
	self._callback = nil
end

function con:Fire(...)
	if self._callback then
		self._callback(...)
	end
end

export type sig = {
	GetSignal : (self : signal|{}) -> signal|nil,
	new : (name) -> signal, 
	Connect : (self : signal,f : () -> ()) -> {Disconnect : () -> ()},
	Fire : (self : signal,...any) -> (),
	GetConnections : (self : signal) -> (),
	DisconnectAll : (self : signal) -> (),
	Wait : (self : signal) -> any,
}

function signal.new(name)
	if signal:GetSignal(name) then return signal:GetSignal(name) end
	local self = setmetatable({},signal)
	self._connections = {}
	self._parallels = {}
	return self :: sig
end

function signal:Connect(f)
	local cur = tick()
	self._connections[tostring(f)..cur] = con.new(f)
	return {Disconnect = function()
		self._connections[tostring(f)..cur]:Disconnect()
	end,}
end

function signal:Fire(...)
	for _, f in pairs(self._connections) do
		f:Fire(...)
	end
end

function signal:Wait()
	local cor = coroutine.running()
	local cn
	cn = self:Connect(function(...)
		cn:Disconnect()
		task.spawn(cor,...)
	end)
	return coroutine.yield()
end

function signal:GetConnections()
	return self._connections
end

function signal:DisconnectAll()
	for i in pairs(self:GetConnections()) do
		self._connections[i] = nil
	end
	self._connections = {}
end

function signal:Once(f)
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		f(...)
	end)
end

return signal
