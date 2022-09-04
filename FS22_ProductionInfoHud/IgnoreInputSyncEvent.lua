IgnoreInputSyncEvent = {}

local IgnoreInputSyncEvent_mt = Class(IgnoreInputSyncEvent, Event)

InitEventClass(IgnoreInputSyncEvent, "IgnoreInputSyncEvent")

function IgnoreInputSyncEvent.emptyNew()
	return Event.new(IgnoreInputSyncEvent_mt);
end

function IgnoreInputSyncEvent.new(ignoreInputList)
	local self = IgnoreInputSyncEvent.emptyNew();
    self.simpleList = {};
    
	for productionPointId, fillTypeList in pairs(ignoreInputList) do 
        for fillTypeName, value in pairs(fillTypeList) do
            table.insert(self.simpleList, {productionPointId = productionPointId, fillTypeName = fillTypeName, value = value})
        end
    end

	return self
end

function IgnoreInputSyncEvent:writeStream(streamId, connection)
	streamWriteUInt8(streamId, #self.simpleList)

	for i = 1, #self.simpleList do
        streamWriteUInt16(streamId, self.simpleList[i].productionPointId)
        streamWriteString(streamId, self.simpleList[i].fillTypeName)
        streamWriteBool(streamId, self.simpleList[i].value)
	end
end

function IgnoreInputSyncEvent:readStream(streamId, connection)
	self.simpleList = {}
	local num = streamReadUInt8(streamId)

	for i = 1, num do
        self.simpleList[i] = {};
        self.simpleList[i].productionPointId = streamReadUInt16(streamId)
        self.simpleList[i].fillTypeName = streamReadString(streamId)
        self.simpleList[i].value = streamReadBool(streamId)
	end

	self:run(connection)
end

function IgnoreInputSyncEvent:run(connection)
	if connection:getIsServer() then
		ProductionInfoHud:SetIngoreInput(self.simpleList)
	end
end