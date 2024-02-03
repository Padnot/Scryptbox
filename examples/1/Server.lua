local scb = require(game:GetService("ReplicatedStorage"):WaitForChild("Scryptbox"))
local box = scb.NewServer("Memo","Mamo")
local remote = box:RegisterEvent("Test")

remote:OnFalseAddress(function(wrongname,correctname,plr)
	print("lol",wrongname,correctname)
	plr:Kick(wrongname,correctname)
end)

remote:SetProcess({
	Inbound = function(args)
		args[1] += 1
		return args
	end,
})

remote:OnEventReceived(function(...)
	print(...)
end)
