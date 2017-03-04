require(GetScriptDirectory().."/storageapi/json")
require(GetScriptDirectory().."/storageapi/class")

STORAGEAPI_API_URL = ":9200/doublepull/run/?"--/api/v1/storage"

--[[
	Storage API interface to store data for Dota 2 Custom Game players.
	Get API key from http://dota2.tools/api/v1/storage/createApiKey?game=<Name of your custom game>&author=<Your name>
		or make your own server receiver and edit STORAGEAPI_API_URL.

	See info on server responses at http://github.com/elinea/

	Usage:

		Storage:SetApiKey(api_key)

		Storage:Put( steam_id, data, function( resultTable, successBool )
			if successBool then
				print("Successfully put data in storage")
			end
		end)

		Storage:Get( steam_id, function( resultTable, successBool )
			if successBool then
				DeepPrintTable(resultTable)
			end
		end)

	To test:
		GET: STORAGEAPI_API_URL?api_key=<api_key>&steam_id=<steam_id>
		PUT (POST): STORAGEAPI_API_URL?api_key=<api_key>&steam_id=<steam_id>&data=<json>


	@author Elinea

	This is free and unencumbered software released into the public domain.

	Anyone is free to copy, modify, publish, use, compile, sell, or
	distribute this software, either in source code form or as a compiled
	binary, for any purpose, commercial or non-commercial, and by any
	means.

	In jurisdictions that recognize copyright laws, the author or authors
	of this software dedicate any and all copyright interest in the
	software to the public domain. We make this dedication for the benefit
	of the public at large and to the detriment of our heirs and
	successors. We intend this dedication to be an overt act of
	relinquishment in perpetuity of all present and future rights to this
	software under copyright law.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
	ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
	OTHER DEALINGS IN THE SOFTWARE.

	For more information, please refer to <http://unlicense.org>
]]

if Storage == nil then
	_G.Storage = class({})
end

--[[
	Storage:Put
	Used for putting stuff inside of the storage
	Invalidates any previously cached storage

	callback(dataTable, successBool)
		Will return the result + if the call was successful

	@param 	steam_id int 	The steamID you want to access the storage for
	@param 	data 	table 	The data you want stored
	@param 	callback handle	The function that should run when the storage is put
]]
function Storage:Put(data, callback)

	if not pcall(function()
		data = JSON:encode(data)
	end) then
		Warning("[dota2.tools.Storage] data is not a valid lua table")
		return
	end


	-- Send the request
	self:SendHTTPRequest(
		{
			data = data
		},

		function(result)
			-- Decode response into a lua table
			local resultTable = {}
			if not pcall(function()
				resultTable = JSON:decode(result)
			end) then
				Warning("[dota2.tools.Storage] Can't decode result: " .. result)
			end

			-- If we get an error response, successBool should be false
			if resultTable ~= nil and resultTable["errors"] ~= nil then
				callback(resultTable["errors"], false)
				return
			end

			-- If we get a success response, successBool should be true
			if resultTable ~= nil and resultTable["data"] ~= nil  then
				callback(resultTable["data"], true)
				return
			end

			callback(resultTable, false)

		end
	)
end

--[[
	Storage:Get
	Used for getting stuff inside the storage
	Uses a cache to balance server load. Call Storage:Invalidate() or Storage:Put() to invalidate cache.

	callback(dataTable, successBool)
		Will return the result + if the call was successful

	@param  steam_id int    The steamID you want to access the storage for
	@param 	callback handle	The function that should run when the storage is retrieved
]]
--function Storage:Get(steam_id, callback)
--
--	-- Send the request
--	self:SendHTTPRequest("GET",
--		{
--			steam_id = tostring(steam_id)
--		},
--
--		function(result)
--			-- Decode response into lua table
--
--			local resultTable = {}
--			if not pcall(function()
--				resultTable = JSON:decode(result)
--			end) then
--				Warning("[dota2.tools.Storage] Can't decode result: " .. result)
--			end
--
--
--			-- If we get an error response, successBool should be false
--			if resultTable ~= nil and resultTable["errors"] ~= nil then
--				storeCache[steam_id] = resultTable["errors"]
--				callback(storeCache[steam_id], false)
--				return
--			end
--
--			if resultTable ~= nil and resultTable["data"] ~= nil and resultTable["data"]["data"] ~= nil then
--				storeCache[steam_id] = resultTable["data"]["data"]
--			end
--			-- If we get a success response, successBool should be true
--			callback(storeCache[steam_id], true)
--		end
--	)
--end

--function Storage:SetApiKey(key)
--	-- Set the api key
--	api_key = key
--end

--[[
	Storage:Invalidate
	Invalidates the cache for a user

	@param  steam_id int    The steamID we invalidate the cache for
]]

--[[
	Storage:InvalidateAll
	Invalidates all cache
]]

--[[
	Storage:SendHTTPRequest

	@param method 	string 	Sets the method. Can be either "GET" or "POST"
	@param values 	table 	Table with query parameters we want to send
	@param callback handle 	Callback we call for the response
]]

function Storage:SendHTTPRequest(values, callback)
	CreateHTTPRequest(':8000')--/doublepull/run/?\'{"hero": "lion","damage_spread_lane": 1}\'')
	print("done request")
	--local req = CreateHTTPRequest(STORAGEAPI_API_URL):Send
--	req:Send(function(result)
--		callback(result.Body)
--	end)
end