--Scryptbox
--Scrypt, 10/01/2024

local scrypt = {}

local _container = script

local _components = _container:WaitForChild("Components")
	local _boxesModule = _components:WaitForChild("Boxes"); local _boxes = require(_boxesModule)
	local _serverboxModule = _components:WaitForChild("Serverbox"); local _serverbox = require(_serverboxModule)
	local _clientboxModule = _components:WaitForChild("Clientbox"); local _clientbox = require(_clientboxModule)
	local _serverTypeModule = _components:WaitForChild("ServerType"); local _serverType = require(_serverTypeModule)
	local _clientTypeModule = _components:WaitForChild("ClientType"); local _clientType = require(_clientTypeModule)


local _utilities = _container:WaitForChild("Utilities")
	local _maidModule = _utilities:WaitForChild("Maid"); local _maid = require(_maidModule)

local _runService = game:GetService("RunService")



function scrypt.NewServer(name : string, address : string?) : _serverType.Serverbox
	return _serverbox.new(name, address)
end

function scrypt.NewClient(name : string, address : string?) : _clientType.Clientbox
	return _clientbox.new(name, address)
end

function scrypt.GetServer(name : string) : _serverType.Serverbox
	return _boxes.Serverboxes[name]
end

function scrypt.GetClient(name : string) : _clientType.Clientbox
	return _boxes.Clientboxes[name]
end

return scrypt
