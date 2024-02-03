--ServerType
--Scrypt, 10/01/2024

export type RemoteEventPackage = {
	ShipEvent : (self : RemoteEventPackage, Player : Player, ...any) -> (),
	ShipEventToAllClients : (self : RemoteEventPackage, ...any) -> (),
	OnEventReceived : (self : RemoteEventPackage, Connection : (Player : Player, ...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : RemoteEventPackage) -> (),
	SetProcess : (self : RemoteEventPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : RemoteEventPackage, Connection : (Address : string, Player : Player) -> ()) -> ()
}

export type BindEventPackage = {
	ShipEvent : (self : BindEventPackage, ...any) -> (),
	OnEventReceived : (self : BindEventPackage, Connection : (...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : BindEventPackage) -> (),
	SetProcess : (self : BindEventPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : BindEventPackage, Connection : (Address : string) -> ()) -> ()
}

export type RemoteFunctionPackage = {
	ShipFunction : (self : RemoteFunctionPackage, Player : Player, ...any) -> (),
	OnFunctionReceived : (self : RemoteFunctionPackage, Connection : (Player : Player, ...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : RemoteFunctionPackage) -> (),
	SetProcess : (self : RemoteFunctionPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : RemoteFunctionPackage, Connection : (Address : string) -> ()) -> ()
}

export type BindFunctionPackage = {
	ShipFunction : (self : BindFunctionPackage,...any) -> (),
	OnFunctionReceived : (self : BindFunctionPackage, Connection : (...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
	Destroy : (self : BindFunctionPackage) -> (),
	SetProcess : (self : BindFunctionPackage, Process : {Inbound : (...any) -> ...any, Outbound : (...any) -> ...any}) -> (),
	OnFalseAddress : (self : BindFunctionPackage, Connection : (Address : string) -> ()) -> ()
}

export type Serverbox = {
	GetEvent : (self : Serverbox, Name : string) -> RemoteEventPackage,
	GetFunction : (self : Serverbox, Name : string) -> RemoteFunctionPackage,
	GetBindEvent : (self : Serverbox, Name : string) -> BindEventPackage,
	GetBindFunction : (self : Serverbox, Name : string) -> BindFunctionPackage,
	RegisterEvent : (self : Serverbox, Name : string) -> RemoteEventPackage,
	RegisterFunction : (self : Serverbox, Name : string) -> RemoteFunctionPackage,
	RegisterBindEvent : (self : Serverbox, Name : string) -> BindEventPackage,
	RegisterBindFunction : (self : Serverbox, Name : string) -> BindFunctionPackage,
}

return {}
