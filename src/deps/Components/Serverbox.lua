--!strict
--Serverbox
--Scrypt, 23/07/2023

local serverbox = {}
serverbox.__index = serverbox

local serverbox_public = {}
serverbox_public.__index = serverbox_public

local _container = script.Parent.Parent

local _components = _container.Components
	local _boxesModule = _components.Boxes; local _boxes = require(_boxesModule)

local _resources = _container.ServerResources
	local _remotes = _resources.Remotes
		local _remoteEvents = _remotes.Events
		local _remoteFunctions = _remotes.Functions
	local _binds = _resources.Binds
		local _bindEvents = _binds.Events
		local _bindFunctions = _binds.Functions

local _utilities = _container.Utilities
	local _maidModule = _utilities.Maid; local _maid = require(_maidModule)

--TYPE
type EventPackage = {
	ShipEvent : (self : EventPackage, Player : Player, ...any) -> (),
	ShipEventToAllClients : (self : EventPackage, ...any) -> (),
	OnEventReceived : (self : EventPackage, Connection : (Player : Player, ...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : EventPackage) -> (),
	SetProcess : (self : EventPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : EventPackage, Connection : (Address : string, Player : Player) -> ()) -> ()
}

type BindEventPackage = {
	ShipEvent : (self : BindEventPackage, Player : Player, ...any) -> (),
	OnEventReceived : (self : BindEventPackage, Connection : (...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : BindEventPackage) -> (),
	SetProcess : (self : BindEventPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : BindEventPackage, Connection : (Address : string) -> ()) -> ()
}

type RemoteFunctionPackage = {
	ShipFunction : (self : RemoteFunctionPackage, Player : Player, ...any) -> (),
	OnFunctionReceived : (self : RemoteFunctionPackage, Connection : (Player : Player, ...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : RemoteFunctionPackage) -> (),
	SetProcess : (self : RemoteFunctionPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : RemoteFunctionPackage, Connection : (Address : string) -> ()) -> ()
}

type BindFunctionPackage = {
	ShipFunction : (self : BindFunctionPackage,...any) -> (),
	OnFunctionReceived : (self : BindFunctionPackage, Connection : (...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : BindFunctionPackage) -> (),
	SetProcess : (self : BindFunctionPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : BindFunctionPackage, Connection : (Address : string) -> ()) -> ()
}

type public_serverbox = {
	GetEvent : (self : public_serverbox, Name : string) -> EventPackage,
	GetFunction : (self : public_serverbox, Name : string) -> RemoteFunctionPackage,
	GetBindEvent : (self : public_serverbox, Name : string) -> BindEventPackage,
	GetBindFunction : (self : public_serverbox, Name : string) -> BindFunctionPackage,
	RegisterEvent : (self : public_serverbox, Name : string) -> EventPackage,
	RegisterFunction : (self : public_serverbox, Name : string) -> RemoteFunctionPackage,
	RegisterBindEvent : (self : public_serverbox, Name : string) -> BindEventPackage,
	RegisterBindFunction : (self : public_serverbox, Name : string) -> BindFunctionPackage,
}

function serverbox.new(name : string, address : string?)
	if _boxes.Serverboxes[name] then return _boxes.Serverboxes[name] end
	local self = setmetatable({},serverbox_public)
	self._name = name
	self._remoteEvents = {}
	self._remoteFunctions = {}
	self._bindEvents = {}
	self._bindFunctions = {}
	self._falseBoxAdress = nil
	self._address = address
	self._public = setmetatable({},serverbox_public)
	self._public._parent = self
	self._maid = _maid.new()
	_boxes.Serverboxes[name] = self._public
	return self._public
end

local packager = {}
packager.__index = packager

function packager.newRemoteEvent(name : string,public_serverbox)
	if public_serverbox._parent._remoteEvents[name .. "Package"] then return public_serverbox._parent._remoteEvents[name .. "Package"] end
	local maid = public_serverbox._parent._maid
	local remote, decon = maid:Construct('RemoteEvent')
	remote.Name = name .. '-' ..public_serverbox._parent._name
	remote.Parent = _remoteEvents
	
	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicServerBox = public_serverbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_serverbox._parent._remoteEvents[name .. "Package"] = self
	return self
end

function packager:ShipEvent(player : Player, ...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : RemoteEvent = self.Remote
	if not remote:IsA('RemoteEvent') then error('Cannot trigger remote, self-class is not a remote event!') end
	if self.Processes.Outbound then
		remote:FireClient(self._PublicClientBox._parent._name,player,unpack(self.Processes.Outbound({...})))
	else
		remote:FireClient(self._PublicClientBox._parent._name,player,...)
	end
end

function packager:ShipEventToAllClients(...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : RemoteEvent = self.Remote
	if not remote:IsA('RemoteEvent') then error('Cannot trigger remote, self-class is not a remote event!') end
	if self.Processes.Outbound then
		remote:FireAllClients(self._PublicClientBox._parent._name,unpack(self.Processes.Outbound({...}) or {}))
	else
		remote:FireAllClients(self._PublicClientBox._parent._name,...)
	end
end

function packager:OnEventReceived(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : RemoteEvent = self.Remote
	if not remote:IsA('RemoteEvent') then error('Cannot trigger remote, self-class is not a remote event!') end
	local _, result = self.Maid:Construct(remote.OnServerEvent:Connect(function(player, shipperAddress : string,...)
		if self._PublicServerBox._parent._address and shipperAddress ~= self._PublicServerBox._parent._address then
			if self.WrongAddressHandler then
				self.WrongAddressHandler(shipperAddress,player)
			end
		else
			if self.Processes.Inbound then
				connection(player,unpack(self.Processes.Inbound({...}) or {}))
			else
				connection(player,...)
			end
		end
	end))
	table.insert(self._Deconstructors,result)
	return result
end

function packager.newRemoteFunction(name : string,public_serverbox)
	if public_serverbox._parent._remoteFunctions[name .. "Package"] then return public_serverbox._parent._remoteFunctions[name .. "Package"] end
	local maid = public_serverbox._parent._maid
	local remote, decon = maid:Construct('RemoteFunction')
	remote.Name = name .. '-' ..public_serverbox._parent._name
	remote.Parent = _remoteFunctions

	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicServerBox = public_serverbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_serverbox._parent._remoteFunctions[name .. "Package"] = self
	return self
end

function packager:ShipFunction(player : Player, ...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : RemoteFunction = self.Remote
	if not remote:IsA('RemoteFunction') then error('Cannot trigger remote, self-class is not a remote function!') end
	if self.Processes.Outbound then
		return remote:InvokeClient(self._PublicClientBox._parent._name,player,unpack(self.Processes.Outbound({...}) or {}))
	else
		return remote:InvokeClient(self._PublicClientBox._parent._name,player,...)
	end
end

function packager:OnFunctionReceived(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : RemoteFunction = self.Remote
	if not remote:IsA('RemoteFunction') then error('Cannot trigger remote, self-class is not a remote function!') end
	remote.OnServerInvoke = function(player, shipperAddress : string,...)
		if self._PublicServerBox._parent._address and shipperAddress ~= self._PublicServerBox._parent._address then
			if self.WrongAddressHandler then
				return self.WrongAddressHandler(shipperAddress,player)
			end
		else
			if self.Processes.Inbound then
				return connection(player,unpack(self.Processes.Inbound({...}) or {}))
			else
				return connection(player,...)
			end
		end
	end
	local _, result = self.Maid:Construct(function()
		remote.OnServerInvoke = function()end
	end)
	table.insert(self._Deconstructors,result)
	return result
end

function packager.newBindEvent(name : string,public_serverbox)
	if public_serverbox._parent._bindEvents[name .. "Package"] then return public_serverbox._parent._bindEvents[name .. "Package"] end
	local maid = public_serverbox._parent._maid
	local remote, decon = maid:Construct('BindableEvent')
	remote.Name = name .. '-' ..public_serverbox._parent._name
	remote.Parent = _bindEvents

	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicServerBox = public_serverbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_serverbox._parent._bindEvents[name .. "Package"] = self
	return self
end

function packager:TriggerEvent(...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : BindableEvent = self.Remote
	if not remote:IsA('BindableEvent') then error('Cannot trigger remote, self-class is not a bind event!') end
	if self.Processes.Outbound then
		remote:Fire(unpack(self.Processes.Outbound({...}) or {}))
	else
		remote:Fire(...)
	end
end

function packager:OnEventTriggered(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : BindableEvent = self.Remote
	if not remote:IsA('BindableEvent') then error('Cannot trigger remote, self-class is not a bind event!') end
	local _, result = self.Maid:Construct(remote.Event:Connect(function(shipperAddress : string,...)
		if self._PublicServerBox._parent._address and shipperAddress ~= self._PublicServerBox._parent._address then
			if self.WrongAddressHandler then
				self.WrongAddressHandler(shipperAddress)
			end
		else
			if self.Processes.Inbound then
				connection(unpack(self.Processes.Inbound({...}) or {}))
			else
				connection(...)
			end
		end
	end))
	table.insert(self._Deconstructors,result)
	return result
end

function packager.newBindFunction(name : string,public_serverbox)
	if public_serverbox._parent._bindFunctions[name .. "Package"] then return public_serverbox._parent._bindFunctions[name .. "Package"] end
	local maid = public_serverbox._parent._maid
	local remote, decon = maid:Construct('BindableFunction')
	remote.Name = name .. '-' ..public_serverbox._parent._name
	remote.Parent = _bindFunctions

	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicServerBox = public_serverbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_serverbox._parent._bindFunctions[name .. "Package"] = self
	return self
end

function packager:TriggerFunction(...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : BindableFunction = self.Remote
	if not remote:IsA('BindableFunction') then error('Cannot trigger remote, self-class is not a bind function!') end
	if self.Processes.Outbound then
		return remote:Invoke(unpack(self.Processes.Outbound({...}) or {}))
	else
		return remote:Invoke(...)
	end
end

function packager:OnFunctionTriggered(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : BindableFunction = self.Remote
	if not remote:IsA('BindableFunction') then error('Cannot trigger remote, self-class is not a bind function!') end
	remote.OnInvoke = function(plr, shipperAddress : string,...)
		if self._PublicServerBox._parent._address and shipperAddress ~= self._PublicServerBox._parent._address then
			if self.WrongAddressHandler then
				return self.WrongAddressHandler(shipperAddress)
			end
		else
			if self.Processes.Inbound then
				return connection(unpack(self.Processes.Inbound({...}) or {}))
			else
				return connection(...)
			end
		end
	end
	local _, result = self.Maid:Construct(function()
		remote.OnInvoke = function()end
	end)
	table.insert(self._Deconstructors,result)
	return result
end

function packager:Destroy()
	local self = self
	if not self.Remote then error('Cannot destroy remote, self-class expected!',2) end
	for _, decon in ipairs(self._Deconstructors) do
		decon:Deconstruct()
	end
end

function packager:OnFalseAddress(hook)
	local self = self
	if type(hook) ~= "function" then error("Hook must be a function! Got "..type(hook),2) end
	if not self.Remote then error('Cannot hook remote, self-class expected!',2) end
	self.WrongAddressHandler = hook
end

function packager:SetProcess(process)
	if typeof(process) ~= "table" then error("Process must be a table! Got "..type(process),2) end
	self.Processes = process
end

function serverbox_public:GetEvent(name)
	return self._parent._remoteEvents[name .. "Package"]
end

function serverbox_public:GetFunction(name)
	return self._parent._remoteFunctions[name .. "Package"]
end

function serverbox_public:GetBindEvent(name)
	return self._parent._bindEvents[name .. "Package"]
end

function serverbox_public:GetBindFunction(name)
	return self._parent._bindFunction[name .. "Package"]
end

function serverbox_public:RegisterEvent(name)
	return packager.newRemoteEvent(name,self)
end

function serverbox_public:RegisterFunction(name)
	return packager.newRemoteFunction(name,self)
end

function serverbox_public:RegisterBindEvent(name)
	return packager.newBindEvent(name,self)
end

function serverbox_public:RegisterBindFunction(name)
	return packager.newRemoteFunction(name,self)
end

return serverbox
