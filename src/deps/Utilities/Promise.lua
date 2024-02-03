--Promise
--Scrypt, 23/07/2023

local Promise = {}

export type promise = {
	resolve : (value) -> nil,
	reject : (value) -> nil,
	andThen : (callback) -> promise,
	catch : (callback) -> promise,
	finally : (callback) -> promise
}

function Promise.new(callback)
	local promise = setmetatable({
		_state = "pending",
		_value = nil,
		_callbacks = {},
		_errors = {},
		_finalizer = {}
	},{
		__metatable = function()
			return "Promise"
		end,
		__tostring = function()
			return "Promise"
		end,
	})
	function promise:resolve(value)
		if self._state ~= "pending" then
			return
		end
		self._state = "resolved"
		self._value = value
		self:_resolvecb()
	end

	local function res(...)
		promise:resolve(...)
	end

	local function rej(...)
		promise:reject(...)
	end

	function promise:reject(err)
		if self._state ~= "pending" then
			return
		end
		self._state = "rejected"
		self._value = err
		self:_errorcb()
	end

	function promise:_finallycb()
		for _, callback in ipairs(self._finalizer) do
			pcall(callback,self._value)
		end
		self._finalizer = {}
	end

	function promise:_resolvecb()
		for _, callback in ipairs(self._callbacks) do
			pcall(callback,self._value)
		end
		self._callbacks = {}
		self:_finallycb()
	end

	function promise:_errorcb()
		for _, callback in ipairs(self._errors) do
			pcall(callback,self._value)
		end
		self._errors = {}
		self:_finallycb()
	end

	function promise:andThen(callback)
		if self.state == "resolved" then
			pcall(callback,self._value)
		else
			table.insert(self._callbacks, callback)
		end
		return self
	end

	function promise:catch(callback)
		if self._state == "rejected" then
			pcall(callback,self._value)
		else
			table.insert(self._errors,callback)
		end
		return self
	end

	function promise:finally(callback)
		if self._state == "rejected" or self._state == "resolved" then
			pcall(callback,self._value)
		else
			table.insert(self._finalizer,callback)
		end
		return self
	end

	pcall(callback,res,rej)

	return promise
end

return Promise
