ChangeIgnoreInputEvent = {}

local ChangeIgnoreInputEvent_mt = Class(ChangeIgnoreInputEvent, Event)

InitEventClass(ChangeIgnoreInputEvent, "ChangeIgnoreInputEvent")

function ChangeIgnoreInputEvent.emptyNew()
	return Event.new(ChangeIgnoreInputEvent_mt);
end

function ChangeIgnoreInputEvent.new(productionPointId, fillTypeName, value)
	local self = ChangeIgnoreInputEvent.emptyNew();
	self.productionPointId = productionPointId;
	self.fillTypeName = fillTypeName;
	self.value = value;

	return self
end

function ChangeIgnoreInputEvent:writeStream(streamId, connection)
	streamWriteUInt16(streamId, self.productionPointId)
	streamWriteString(streamId, self.fillTypeName)
	streamWriteBool(streamId, self.value)
end

function ChangeIgnoreInputEvent:readStream(streamId, connection)
	self.productionPointId = streamReadUInt16(streamId)
	self.fillTypeName = streamReadString(streamId)
	self.value = streamReadBool(streamId)

	self:run(connection)
end

function ChangeIgnoreInputEvent:run(connection)
	ProductionInfoHud:changeIgnoreInput(self.productionPointId, self.fillTypeName, self.value)
end