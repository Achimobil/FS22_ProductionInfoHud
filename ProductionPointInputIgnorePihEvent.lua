ProductionPointInputIgnorePihEvent = {}
local ProductionPointInputIgnorePihEvent_mt = Class(ProductionPointInputIgnorePihEvent, Event)

InitEventClass(ProductionPointInputIgnorePihEvent, "ProductionPointInputIgnorePihEvent")

function ProductionPointInputIgnorePihEvent.emptyNew()
	local self = Event.new(ProductionPointInputIgnorePihEvent_mt)

	return self
end

function ProductionPointInputIgnorePihEvent.new(productionPoint, outputFillTypeId, ignoreInput)
	local self = ProductionPointInputIgnorePihEvent.emptyNew()
	self.productionPoint = productionPoint
	self.outputFillTypeId = outputFillTypeId
	self.ignoreInput = ignoreInput

	return self
end

function ProductionPointInputIgnorePihEvent:readStream(streamId, connection)
	self.productionPoint = NetworkUtil.readNodeObject(streamId)
	self.outputFillTypeId = streamReadUIntN(streamId, FillTypeManager.SEND_NUM_BITS)
	self.ignoreInput = streamReadBool(streamId)

	self:run(connection)
end

function ProductionPointInputIgnorePihEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.productionPoint)
	streamWriteUIntN(streamId, self.outputFillTypeId, FillTypeManager.SEND_NUM_BITS)
	streamWriteBool(streamId, self.ignoreInput)
end

function ProductionPointInputIgnorePihEvent:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection)
	end

	if self.productionPoint ~= nil then
		self.productionPoint:setInputIgnorePih(self.outputFillTypeId, self.ignoreInput, true)
	end
end

function ProductionPointInputIgnorePihEvent.sendEvent(productionPoint, outputFillTypeId, ignoreInput, noEventSend)
	if noEventSend == nil or noEventSend == false then
		if g_server ~= nil then
			g_server:broadcastEvent(ProductionPointInputIgnorePihEvent.new(productionPoint, outputFillTypeId, ignoreInput))
		else
			g_client:getServerConnection():sendEvent(ProductionPointInputIgnorePihEvent.new(productionPoint, outputFillTypeId, ignoreInput))
		end
	end
end
