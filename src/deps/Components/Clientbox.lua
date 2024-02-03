--!strict
--Clientbox
--Scrypt, 27/07/2023

local clientbox = {}
clientbox.__index = clientbox

local clientbox_public = {}
clientbox_public.__index = clientbox_public

local _container = script.Parent.Parent

local _components = _container.Components
	local _boxesModule = _components.Boxes; local _boxes = require(_boxesModule)
	local _clientTypeModule = _components.ClientType; local _clientType = require(_clientTypeModule)
local _resources = _container.ClientResources
	local _binds = _resources.Binds
		local _bindEvents = _binds.Events
		local _bindFunctions = _binds.Functions

local _serverResources = _container.ServerResources

local _utilities = _container.Utilities
	local _maidModule = _utilities.Maid; local _maid = require(_maidModule)

function clientbox.new(name : string, address : string?)
	if _boxes.Clientboxes[name] then return _boxes.Clientboxes[name] end
	local self = setmetatable({},clientbox_public)
	self._name = name
	self._remoteEvents = {}
	self._remoteFunctions = {}
	self._bindEvents = {}
	self._bindFunctions = {}
	self._falseBoxAdress = nil
	self._address = address
	self._public = setmetatable({},clientbox_public)
	self._public._parent = self
	self._maid = _maid.new()
	_boxes.Clientboxes[name] = self._public
	return self._public
end

local packager = {}
packager.__index = packager

local function GetRevEFromName(name, link)
	for _, remote in ipairs(_serverResources.Remotes.Events:GetChildren()) do
		if string.find(remote.Name, name) then
			local _name, _link = string.match(remote.Name,"(%w+)%-(%w+)")
			if _name and link and _name == name and link == _link then return remote end
		end
	end return
end

local function GetRevFFromName(name,link)
	for _, remote in ipairs(_serverResources.Remotes.Functions:GetChildren()) do
		if string.find(remote.Name, name) then
			local _name, _link = string.match(remote.Name,"(%w+)%-(%w+)")
			if _name and link and _name == name and link == _link then return remote end
		end
	end return
end

function packager.newRemoteEvent(name : string,public_clientbox) : any
	if public_clientbox._parent._remoteEvents[name .. "Package"] then return public_clientbox._parent._remoteEvents[name .. "Package"] end
	local remote = GetRevEFromName(name,public_clientbox._parent._address)
	if not name then return error("Cannot find and filter remote event name!") end
	local maid = public_clientbox._parent._maid
	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicClientBox = public_clientbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	public_clientbox._parent._remoteEvents[name .. "Package"] = self
	return self
end

function packager:ShipEvent(...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : RemoteEvent = self.Remote
	if not remote:IsA('RemoteEvent') then error('Cannot trigger remote, self-class is not a remote event!') end
	if self.Processes.Outbound then
		remote:FireServer(self._PublicClientBox._parent._name,unpack(self.Processes.Outbound({...}) or {}))
	else
		remote:FireServer(self._PublicClientBox._parent._name,...)
	end
end

function packager:OnEventReceived(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : RemoteEvent = self.Remote
	if not remote:IsA('RemoteEvent') then error('Cannot trigger remote, self-class is not a remote event!') end
	local _, result = self.Maid:Construct(remote.OnClientEvent:Connect(function(shipperAddress : string,...)
		if self._PublicClientBox._parent._address and shipperAddress ~= self._PublicClientBox._parent._address then
			if self.WrongAddressHandler then
				self.WrongAddressHandler(shipperAddress,self._name)
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

function packager.newRemoteFunction(name : string,public_clientbox)
	if public_clientbox._parent._remoteFunctions[name .. "Package"] then return public_clientbox._parent._remoteFunctions[name .. "Package"] end
	local maid = public_clientbox._parent._maid
	local remote = GetRevFFromName(name,public_clientbox._parent._address)
	if not remote then return error("Cannot find and filter remote function name!") end
	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicClientBox = public_clientbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	public_clientbox._parent._remoteFunctions[name .. "Package"] = self
	return self
end

function packager:ShipFunction(...)
	local self = self
	if not self.Remote then error('Cannot trigger remote, self-class expected!',2) end
	local remote : RemoteFunction = self.Remote
	if not remote:IsA('RemoteFunction') then error('Cannot trigger remote, self-class is not a remote function!') end
	if self.Processes.Outbound then
		return remote:InvokeClient(self._PublicClientBox._parent._name,unpack(self.Processes.Outbound({...}) or {}))
	else
		return remote:InvokeClient(self._PublicClientBox._parent._name,...)
	end
end

function packager:OnFunctionReceived(connection)
	local self = self
	if not self.Remote then error('Cannot receive trigger remote, self-class expected!',2) end
	local remote : RemoteFunction = self.Remote
	if not remote:IsA('RemoteFunction') then error('Cannot trigger remote, self-class is not a remote function!') end
	remote.OnClientInvoke = function(shipperAddress : string,...)
		if self._PublicClientBox._parent._address and shipperAddress ~= self._PublicClientBox._parent._address then
			if self.WrongAddressHandler then
				return self.WrongAddressHandler(shipperAddress,self._name)
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
		remote.OnClientInvoke = function()end
	end)
	table.insert(self._Deconstructors,result)
	return result
end

function packager.newBindEvent(name : string,public_clientbox)
	if public_clientbox._parent._bindEvents[name .. "Package"] then return public_clientbox._parent._bindEvents[name .. "Package"] end
	local maid = public_clientbox._parent._maid
	local remote, decon = maid:Construct('BindableEvent')
	remote.Name = name .. '-' ..public_clientbox._parent._name
	remote.Parent = _bindEvents

	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicClientBox = public_clientbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_clientbox._parent._bindEvents[name .. "Package"] = self
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
		if self._PublicClientBox._parent._address and shipperAddress ~= self._PublicClientBox._parent._address then
			if self.WrongAddressHandler then
				self.WrongAddressHandler(shipperAddress,self._name)
			end
		else
			if self.Processes.Inbound then
				connection(unpack(self.Processes.Inbound({...})))
			else
				connection(...)
			end
		end
	end))
	table.insert(self._Deconstructors,result)
	return result
end

function packager.newBindFunction(name : string,public_clientbox)
	if public_clientbox._parent._bindFunctions[name .. "Package"] then return public_clientbox._parent._bindFunctions[name .. "Package"] end
	local maid = public_clientbox._parent._maid
	local remote, decon = maid:Construct('BindableFunction')
	remote.Name = name .. '-' ..public_clientbox._parent._name
	remote.Parent = _bindFunctions

	local self = setmetatable({},packager)
	self.Remote = remote
	self.Processes = {Outbound = nil, Inbound = nil}
	self.Maid = maid
	self._name = remote.Name
	self._PublicClientBox = public_clientbox
	self.WrongAddressHandler = nil
	self._Deconstructors = {}
	table.insert(self._Deconstructors, decon)
	public_clientbox._parent._bindFunctions[name .. "Package"] = self
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
		if self._PublicClientBox._parent._address and shipperAddress ~= self._PublicClientBox._parent._address then
			if self.WrongAddressHandler then
				return self.WrongAddressHandler(shipperAddress,self._name)
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

function clientbox_public:GetEvent(name)
	--return self._parent._remoteEvents[name .. "Package"]
	return packager.newRemoteEvent(name,self)
end

function clientbox_public:GetFunction(name)
	--return self._parent._remoteFunctions[name .. "Package"]
	return packager.newRemoteFunction(name,self)
end

function clientbox_public:GetBindEvent(name)
	return self._parent._bindEvents[name .. "Package"]
end

function clientbox_public:GetBindFunction(name)
	return self._parent._bindFunction[name .. "Package"]
end

--Shadow-removed because :Get is simpler to use rather than :Set + :Get.
--function clientbox_public:RegisterEvent(name)
--	return packager.newRemoteEvent(name,self)
--end

--function clientbox_public:RegisterFunction(name)
--	return packager.newRemoteFunction(name,self)
--end

function clientbox_public:RegisterBindEvent(name)
	return packager.newBindEvent(name,self)
end

function clientbox_public:RegisterBindFunction(name)
	return packager.newRemoteFunction(name,self)
end

return clientbox
