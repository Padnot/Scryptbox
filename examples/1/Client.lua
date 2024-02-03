local scb = require(game:GetService("ReplicatedStorage"):WaitForChild("Scryptbox"))
local box = scb.NewClient("Mamo","Memo")
local remote = box:GetEvent("Test")

remote:SetProcess({
	Inbound = function(args)
		args[1] += 1
		return args
	end,
	Outbound = function(args)
		args[1] += 1
		return args
	end,
})

remote:ShipEvent(1)

remote:OnEventReceived(function(...)
	print(...)
end)
