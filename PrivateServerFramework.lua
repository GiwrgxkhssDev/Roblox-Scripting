--!strict
--[[
	PrivateServerFramework.lua
	Server-authoritative private server management framework for Roblox.

	Features:
	- Developer Product purchase flow for creating private servers
	- Ownership + registration tracking with 30-server cap per user
	- Per-server dedicated DataStore persistence
	- Global real-time public listing sync using MessagingService
	- Live server configuration updates (name, staff, uniforms, settings)
	- Livery submissions + moderation workflow (Pending/Approved/Rejected)
	- Modular services for future expansion (join codes, invites, teleports)
]]

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PrivateServerFramework = {}
PrivateServerFramework.__index = PrivateServerFramework

export type ServerStatus = "online" | "offline" | "in-game"
export type LiveryState = "Pending" | "Approved" | "Rejected"

export type LiveryEntry = {
	id: string,
	ownerId: number,
	assetId: string,
	title: string,
	state: LiveryState,
	reviewerId: number?,
	reviewerNote: string?,
	updatedAt: number,
	createdAt: number,
}

export type ServerConfig = {
	name: string,
	logo: string,
	uniformsEnabled: boolean,
	staffPermissions: { [number]: string },
	staffIds: { number },
	settings: { [string]: any },
	selectedLiveryId: string?,
}

export type PrivateServerRecord = {
	id: string,
	ownerId: number,
	coOwnerId: number?,
	status: ServerStatus,
	createdAt: number,
	updatedAt: number,
	config: ServerConfig,
}

type FrameworkOptions = {
	createServerProductId: number,
	maxServersPerUser: number?,
	listingTopic: string?,
	registryStoreName: string?,
	liveryStoreName: string?,
	remoteFolderName: string?,
}

local DEFAULT_MAX_SERVERS = 30
local DEFAULT_LISTING_TOPIC = "PrivateServerListingV1"
local DEFAULT_REGISTRY_STORE = "PrivateServerRegistryV1"
local DEFAULT_LIVERY_STORE = "PrivateServerLiveriesV1"
local DEFAULT_REMOTE_FOLDER = "PrivateServerRemotes"

local function now(): number
	return os.time()
end

local function deepCopy<T>(input: T): T
	if type(input) ~= "table" then
		return input
	end

	local copy = {}
	for key, value in pairs(input :: any) do
		(copy :: any)[key] = deepCopy(value)
	end
	return copy :: any
end

local function containsNumber(list: { number }, target: number): boolean
	for _, value in ipairs(list) do
		if value == target then
			return true
		end
	end
	return false
end

local function removeNumber(list: { number }, target: number)
	for i = #list, 1, -1 do
		if list[i] == target then
			table.remove(list, i)
		end
	end
end

local function sanitizeServerName(name: string): string
	local trimmed = name:match("^%s*(.-)%s*$") or ""
	if #trimmed == 0 then
		return "Private Server"
	end
	if #trimmed > 50 then
		return trimmed:sub(1, 50)
	end
	return trimmed
end

local function sanitizeLogo(logo: string): string
	if #logo > 120 then
		return logo:sub(1, 120)
	end
	return logo
end

local function createDefaultConfig(ownerName: string): ServerConfig
	return {
		name = string.format("%s's Private Server", ownerName),
		logo = "",
		uniformsEnabled = false,
		staffPermissions = {},
		staffIds = {},
		settings = {
			speedLimitCategory = "Default",
			clothing = true,
		},
		selectedLiveryId = nil,
	}
end

local function createFolder(name: string, parent: Instance): Folder
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

function PrivateServerFramework.new(options: FrameworkOptions)
	local self = setmetatable({}, PrivateServerFramework)
	self._options = options
	self._maxServersPerUser = options.maxServersPerUser or DEFAULT_MAX_SERVERS
	self._listingTopic = options.listingTopic or DEFAULT_LISTING_TOPIC
	self._registryStore = DataStoreService:GetDataStore(options.registryStoreName or DEFAULT_REGISTRY_STORE)
	self._liveryStore = DataStoreService:GetDataStore(options.liveryStoreName or DEFAULT_LIVERY_STORE)
	self._configStores = {}
	self._listingCache = {}
	self._connections = {}
	self._remotes = {}
	return self
end

function PrivateServerFramework:_userIndexKey(userId: number): string
	return string.format("user:%d", userId)
end

function PrivateServerFramework:_serverRecordKey(serverId: string): string
	return string.format("server:%s", serverId)
end

function PrivateServerFramework:_liveryKey(liveryId: string): string
	return string.format("livery:%s", liveryId)
end

function PrivateServerFramework:_serverConfigStore(serverId: string)
	if self._configStores[serverId] then
		return self._configStores[serverId]
	end
	local store = DataStoreService:GetDataStore("PS_Config_" .. serverId)
	self._configStores[serverId] = store
	return store
end

function PrivateServerFramework:_publishListing(record: PrivateServerRecord)
	local listing = {
		id = record.id,
		ownerId = record.ownerId,
		name = record.config.name,
		logo = record.config.logo,
		status = record.status,
		updatedAt = record.updatedAt,
	}
	self._listingCache[record.id] = listing

	task.spawn(function()
		local ok, err = pcall(function()
			MessagingService:PublishAsync(self._listingTopic, {
				action = "upsert",
				listing = listing,
			})
		end)
		if not ok then
			warn("[PrivateServerFramework] Failed to publish listing", err)
		end
	end)
end

function PrivateServerFramework:_publishListingDelete(serverId: string)
	self._listingCache[serverId] = nil
	task.spawn(function()
		local ok, err = pcall(function()
			MessagingService:PublishAsync(self._listingTopic, {
				action = "delete",
				serverId = serverId,
			})
		end)
		if not ok then
			warn("[PrivateServerFramework] Failed to delete listing", err)
		end
	end)
end

function PrivateServerFramework:_subscribeListings()
	local ok, subscription = pcall(function()
		return MessagingService:SubscribeAsync(self._listingTopic, function(message)
			local data = message.Data
			if type(data) ~= "table" then
				return
			end

			if data.action == "upsert" and type(data.listing) == "table" then
				self._listingCache[data.listing.id] = data.listing
			elseif data.action == "delete" and type(data.serverId) == "string" then
				self._listingCache[data.serverId] = nil
			end
		end)
	end)

	if not ok then
		warn("[PrivateServerFramework] Listing subscription failed", subscription)
		return
	end
	table.insert(self._connections, subscription)
end

function PrivateServerFramework:_getUserServerIds(userId: number): { string }
	local ok, data = pcall(function()
		return self._registryStore:GetAsync(self:_userIndexKey(userId))
	end)
	if not ok or type(data) ~= "table" then
		return {}
	end
	return data
end

function PrivateServerFramework:_saveUserServerIds(userId: number, ids: { string })
	local ok, err = pcall(function()
		self._registryStore:SetAsync(self:_userIndexKey(userId), ids)
	end)
	if not ok then
		error(string.format("Failed to save user server index for %d: %s", userId, tostring(err)))
	end
end

function PrivateServerFramework:_saveServerRecord(record: PrivateServerRecord)
	local ok, err = pcall(function()
		self._registryStore:SetAsync(self:_serverRecordKey(record.id), record)
	end)
	if not ok then
		error(string.format("Failed to save server record %s: %s", record.id, tostring(err)))
	end
end

function PrivateServerFramework:GetServerRecord(serverId: string): PrivateServerRecord?
	local ok, data = pcall(function()
		return self._registryStore:GetAsync(self:_serverRecordKey(serverId))
	end)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data :: PrivateServerRecord
end

function PrivateServerFramework:_assertOwnership(userId: number, serverId: string): PrivateServerRecord
	local record = self:GetServerRecord(serverId)
	if not record then
		error("Server not found")
	end
	if record.ownerId ~= userId and record.coOwnerId ~= userId then
		error("Unauthorized")
	end
	return record
end

function PrivateServerFramework:CreatePrivateServer(ownerId: number, ownerName: string): PrivateServerRecord
	local ownedServerIds = self:_getUserServerIds(ownerId)
	if #ownedServerIds >= self._maxServersPerUser then
		error("Private server limit reached")
	end

	local serverId = HttpService:GenerateGUID(false)
	local record: PrivateServerRecord = {
		id = serverId,
		ownerId = ownerId,
		coOwnerId = nil,
		status = "online",
		createdAt = now(),
		updatedAt = now(),
		config = createDefaultConfig(ownerName),
	}

	table.insert(ownedServerIds, serverId)
	self:_saveServerRecord(record)
	self:_saveUserServerIds(ownerId, ownedServerIds)

	local configStore = self:_serverConfigStore(serverId)
	pcall(function()
		configStore:SetAsync("config", deepCopy(record.config))
	end)

	self:_publishListing(record)
	return record
end

function PrivateServerFramework:SetServerStatus(serverId: string, status: ServerStatus)
	local record = self:GetServerRecord(serverId)
	if not record then
		return
	end
	record.status = status
	record.updatedAt = now()
	self:_saveServerRecord(record)
	self:_publishListing(record)
end

function PrivateServerFramework:UpdateServerConfig(requesterId: number, serverId: string, patch: { [string]: any }): PrivateServerRecord
	local record = self:_assertOwnership(requesterId, serverId)
	local config = record.config

	if patch.name ~= nil then
		config.name = sanitizeServerName(tostring(patch.name))
	end
	if patch.logo ~= nil then
		config.logo = sanitizeLogo(tostring(patch.logo))
	end
	if patch.uniformsEnabled ~= nil then
		config.uniformsEnabled = patch.uniformsEnabled == true
	end
	if patch.settings ~= nil and type(patch.settings) == "table" then
		for k, v in pairs(patch.settings) do
			config.settings[tostring(k)] = v
		end
	end
	if patch.staffIds ~= nil and type(patch.staffIds) == "table" then
		local sanitizedStaff = {}
		for _, id in ipairs(patch.staffIds) do
			if type(id) == "number" and id > 0 and not containsNumber(sanitizedStaff, id) then
				table.insert(sanitizedStaff, id)
			end
		end
		config.staffIds = sanitizedStaff
	end
	if patch.staffPermissions ~= nil and type(patch.staffPermissions) == "table" then
		local sanitizedPermissions = {}
		for userId, permission in pairs(patch.staffPermissions) do
			local numericUserId = tonumber(userId)
			if numericUserId and type(permission) == "string" then
				sanitizedPermissions[numericUserId] = permission
			end
		end
		config.staffPermissions = sanitizedPermissions
	end

	if patch.coOwnerId ~= nil then
		local coOwnerId = tonumber(patch.coOwnerId)
		if coOwnerId and coOwnerId > 0 then
			record.coOwnerId = coOwnerId
			if not containsNumber(config.staffIds, coOwnerId) then
				table.insert(config.staffIds, coOwnerId)
			end
		else
			record.coOwnerId = nil
		end
	end

	if patch.removeStaffId ~= nil then
		local removeId = tonumber(patch.removeStaffId)
		if removeId then
			removeNumber(config.staffIds, removeId)
			config.staffPermissions[removeId] = nil
			if record.coOwnerId == removeId then
				record.coOwnerId = nil
			end
		end
	end

	if patch.selectedLiveryId ~= nil then
		local liveryId = tostring(patch.selectedLiveryId)
		local livery = self:GetLivery(liveryId)
		if not livery or livery.state ~= "Approved" then
			error("Only approved liveries can be selected")
		end
		if livery.ownerId ~= record.ownerId and not containsNumber(config.staffIds, requesterId) then
			error("Cannot equip a livery you do not control")
		end
		config.selectedLiveryId = liveryId
	end

	record.updatedAt = now()
	self:_saveServerRecord(record)

	local configStore = self:_serverConfigStore(serverId)
	pcall(function()
		configStore:SetAsync("config", deepCopy(config))
	end)

	self:_publishListing(record)
	return record
end

function PrivateServerFramework:GetPublicListings(): { [string]: any }
	return deepCopy(self._listingCache)
end

function PrivateServerFramework:SubmitLivery(requesterId: number, serverId: string, assetId: string, title: string): LiveryEntry
	local record = self:_assertOwnership(requesterId, serverId)
	if requesterId ~= record.ownerId then
		error("Only server owner can submit liveries")
	end

	local livery: LiveryEntry = {
		id = HttpService:GenerateGUID(false),
		ownerId = requesterId,
		assetId = tostring(assetId),
		title = sanitizeServerName(title),
		state = "Pending",
		reviewerId = nil,
		reviewerNote = nil,
		updatedAt = now(),
		createdAt = now(),
	}

	local ok, err = pcall(function()
		self._liveryStore:SetAsync(self:_liveryKey(livery.id), livery)
	end)
	if not ok then
		error("Unable to submit livery: " .. tostring(err))
	end

	return livery
end

function PrivateServerFramework:GetLivery(liveryId: string): LiveryEntry?
	local ok, data = pcall(function()
		return self._liveryStore:GetAsync(self:_liveryKey(liveryId))
	end)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data
end

function PrivateServerFramework:ReviewLivery(moderatorId: number, liveryId: string, approve: boolean, note: string?): LiveryEntry
	local livery = self:GetLivery(liveryId)
	if not livery then
		error("Livery not found")
	end

	livery.state = if approve then "Approved" else "Rejected"
	livery.reviewerId = moderatorId
	livery.reviewerNote = note
	livery.updatedAt = now()

	local ok, err = pcall(function()
		self._liveryStore:SetAsync(self:_liveryKey(liveryId), livery)
	end)
	if not ok then
		error("Failed to review livery: " .. tostring(err))
	end

	return livery
end

function PrivateServerFramework:_bindRemotes()
	local remoteFolder = createFolder(self._options.remoteFolderName or DEFAULT_REMOTE_FOLDER, ReplicatedStorage)

	local function remoteEvent(name: string): RemoteEvent
		local existing = remoteFolder:FindFirstChild(name)
		if existing and existing:IsA("RemoteEvent") then
			return existing
		end
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remoteFolder
		return r
	end

	local function remoteFunction(name: string): RemoteFunction
		local existing = remoteFolder:FindFirstChild(name)
		if existing and existing:IsA("RemoteFunction") then
			return existing
		end
		local r = Instance.new("RemoteFunction")
		r.Name = name
		r.Parent = remoteFolder
		return r
	end

	self._remotes.updateConfig = remoteFunction("UpdatePrivateServerConfig")
	self._remotes.getListings = remoteFunction("GetPublicPrivateServerListings")
	self._remotes.submitLivery = remoteFunction("SubmitPrivateServerLivery")
	self._remotes.moderateLivery = remoteFunction("ReviewPrivateServerLivery")
	self._remotes.listingChanged = remoteEvent("PrivateServerListingChanged")

	self._remotes.updateConfig.OnServerInvoke = function(player: Player, serverId: string, patch: { [string]: any })
		local ok, result = pcall(function()
			return self:UpdateServerConfig(player.UserId, serverId, patch)
		end)
		if not ok then
			return false, tostring(result)
		end
		self._remotes.listingChanged:FireAllClients(self:GetPublicListings())
		return true, result
	end

	self._remotes.getListings.OnServerInvoke = function(_player: Player)
		return self:GetPublicListings()
	end

	self._remotes.submitLivery.OnServerInvoke = function(player: Player, serverId: string, assetId: string, title: string)
		local ok, result = pcall(function()
			return self:SubmitLivery(player.UserId, serverId, assetId, title)
		end)
		if not ok then
			return false, tostring(result)
		end
		return true, result
	end

	self._remotes.moderateLivery.OnServerInvoke = function(player: Player, liveryId: string, approve: boolean, note: string?)
		local ok, result = pcall(function()
			return self:ReviewLivery(player.UserId, liveryId, approve, note)
		end)
		if not ok then
			return false, tostring(result)
		end
		return true, result
	end
end

function PrivateServerFramework:_bindPurchaseHandler()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		if receiptInfo.ProductId ~= self._options.createServerProductId then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local buyer = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not buyer then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local ok, err = pcall(function()
			self:CreatePrivateServer(buyer.UserId, buyer.Name)
		end)

		if not ok then
			warn("[PrivateServerFramework] Purchase processing failed:", err)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
end

function PrivateServerFramework:Start()
	self:_subscribeListings()
	self:_bindRemotes()
	self:_bindPurchaseHandler()
	print("[PrivateServerFramework] Started")
end

function PrivateServerFramework:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	self._connections = {}
end

return PrivateServerFramework
