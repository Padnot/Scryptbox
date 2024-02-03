--ClientType
--Scrypt, 10/01/2024

export type RemoteEventPackage = {
	ShipEvent : (self : RemoteEventPackage, ...any) -> (),
	OnEventReceived : (self : RemoteEventPackage, Connection : (...any) -> ()) -> {Deconstruct : (self : {}) -> ()},
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
	ShipFunction : (self : RemoteFunctionPackage, ...any) -> (),
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

export type Clientbox = {
	GetEvent : (self : Clientbox, Name : string) -> RemoteEventPackage,
	GetFunction : (self : Clientbox, Name : string) -> RemoteFunctionPackage,
	GetBindEvent : (self : Clientbox, Name : string) -> BindEventPackage,
	GetBindFunction : (self : Clientbox, Name : string) -> BindFunctionPackage,
	RegisterBindEvent : (self : Clientbox, Name : string) -> BindEventPackage,
	RegisterBindFunction : (self : Clientbox, Name : string) -> BindFunctionPackage,
}

return {}
