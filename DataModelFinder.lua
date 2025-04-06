local function GetModuleHandleA()
    return 0x400000
end

local function REBASE(x)
    return x + GetModuleHandleA()
end

local Roblox = {
    Datamodel = 0,
    Jobs = {},
    VisualEngine = 0
}

local Offsets = {
    vm__fake_datamodel = 0x61EB418,
    vm__get_scheduler = 0x62A17B8,
    JobsPointer = 0x62A1990,
    VisualEnginePointer = 0x5FFA5E0,
    DataModelDeleterPointer = 0x61EB420,
    
    JobsName = 0x150,
    JobsStart = 0x1D0,
    JobsEnd = 0x1D8,
    ScriptContext = 0x3C0,
    Parent = 0x50,
    Children = 0x78,
    
    FakeDataModelToDataModel = 0x1B8,
    DataModelToRenderView1 = 0x1B0,
    DataModelToRenderView2 = 0x8,
    DataModelToRenderView3 = 0x28,
    RenderJobToDataModel = 0x1A8,
    RenderJobToFakeDataModel = 0x38,
    RenderJobToRenderView = 0x218,
    VisualEngineToDataModel1 = 0x720,
    VisualEngineToDataModel2 = 0x1B8
}

local function GetScheduler()
    return REBASE(Offsets.vm__get_scheduler)
end

local function Scheduler()
    local scheduler = GetScheduler()
    local jobs = {}
    
    for i = 1, 8 do
        table.insert(jobs, scheduler + (i * 0x10))
    end
    
    Roblox.Jobs = jobs
    return jobs
end

local function GetJobs()
    return Scheduler()
end

local function GetJobByName(name)
    local jobNames = {
        [1] = "WaitingHybridScriptsJob",
        [2] = "RenderJob",
        [3] = "PhysicsJob",
        [4] = "NetworkJob",
        [5] = "DataModelJob",
        [6] = "FinishJob",
        [7] = "LogicJob",
        [8] = "ContentProviderJob"
    }
    
    for i, job in ipairs(GetJobs()) do
        if jobNames[i] == name then
            return job
        end
    end
    return nil
end

local function GetDatamodelByJob()
    print("Method 1: Getting Datamodel by WaitingHybridScriptsJob")
    local waitingHybridScriptsJob = GetJobByName("WaitingHybridScriptsJob")
    if not waitingHybridScriptsJob then
        print("Failed to find WaitingHybridScriptsJob")
        return nil
    end
    
    local scriptContext = waitingHybridScriptsJob + Offsets.ScriptContext
    local dataModel = scriptContext + Offsets.Parent
    
    Roblox.Datamodel = dataModel
    print("Datamodel found at:", string.format("0x%X", dataModel))
    return dataModel
end

local function GetDatamodelByDeleter()
    print("Method 2: Getting Datamodel by Fake DataModel")
    local fakeDataModel = REBASE(Offsets.vm__fake_datamodel)
    local realDataModel = fakeDataModel + Offsets.FakeDataModelToDataModel
    
    Roblox.Datamodel = realDataModel
    print("Datamodel found at:", string.format("0x%X", realDataModel))
    return realDataModel
end

local function GetDatamodelByRenderJob()
    print("Method 3: Getting Datamodel by RenderJob")
    local renderJob = GetJobByName("RenderJob")
    if not renderJob then
        print("Failed to find RenderJob")
        return nil
    end
    
    local datamodel = renderJob + Offsets.RenderJobToDataModel
    
    Roblox.Datamodel = datamodel
    print("Datamodel found at:", string.format("0x%X", datamodel))
    return datamodel
end

local function GetDatamodelByVisualEngine()
    print("Method 4: Getting Datamodel by VisualEngine")
    local visualEngine = REBASE(Offsets.VisualEnginePointer)
    Roblox.VisualEngine = visualEngine
    
    local dataModel = visualEngine + Offsets.VisualEngineToDataModel1
    local realDataModel = dataModel + Offsets.VisualEngineToDataModel2
    
    Roblox.Datamodel = realDataModel
    print("Datamodel found at:", string.format("0x%X", realDataModel))
    return realDataModel
end

local function GetDatamodelByDeleterPointer()
    print("Method 5: Getting Datamodel by Deleter Pointer")
    local deleterPtr = REBASE(Offsets.DataModelDeleterPointer)
    
    local dataModel = deleterPtr + 0x10
    
    Roblox.Datamodel = dataModel
    print("Datamodel found at:", string.format("0x%X", dataModel))
    return dataModel
end

local function GetDatamodelByDataModelJob()
    print("Method 6: Getting Datamodel by DataModelJob")
    local dataModelJob = GetJobByName("DataModelJob")
    if not dataModelJob then
        print("Failed to find DataModelJob")
        return nil
    end
    
    local dataModel = dataModelJob + 0x48
    
    Roblox.Datamodel = dataModel
    print("Datamodel found at:", string.format("0x%X", dataModel))
    return dataModel
end

local function GetDatamodelByJobsPointer()
    print("Method 7: Getting Datamodel by JobsPointer")
    local jobsPtr = REBASE(Offsets.JobsPointer)
    
    local renderPtr = jobsPtr + 0x58
    local dataModel = renderPtr + Offsets.RenderJobToDataModel
    
    Roblox.Datamodel = dataModel
    print("Datamodel found at:", string.format("0x%X", dataModel))
    return dataModel
end

local function ValidateDatamodel(dataModel)
    if not dataModel then
        return false
    end
    
    local workspace = dataModel + 0x158
    if workspace == 0 then
        return false
    end
    
    return true
end

print("Testing all Datamodel acquisition methods...")
print("============================================")

local methods = {
    GetDatamodelByJob,
    GetDatamodelByDeleter,
    GetDatamodelByRenderJob,
    GetDatamodelByVisualEngine,
    GetDatamodelByDeleterPointer,
    GetDatamodelByDataModelJob,
    GetDatamodelByJobsPointer
}

local results = {}
local successCount = 0

for i, method in ipairs(methods) do
    local success, result = pcall(method)
    if success then
        table.insert(results, {
            method = i,
            address = result,
            valid = ValidateDatamodel(result)
        })
        
        if ValidateDatamodel(result) then
            successCount = successCount + 1
        end
    else
        print("Method", i, "failed with error:", result)
    end
end

print("============================================")
print("Results summary:")
for _, result in ipairs(results) do
    local status = result.valid and "VALID" or "INVALID"
    print(string.format("Method %d: Address 0x%X - %s", result.method, result.address, status))
end
print("============================================")
print(string.format("Success rate: %d/%d methods", successCount, #methods))

local function GetMostReliableDatamodel()
    local addressCounts = {}
    local bestAddress = nil
    local bestCount = 0
    
    for _, result in ipairs(results) do
        if result.valid then
            addressCounts[result.address] = (addressCounts[result.address] or 0) + 1
            
            if addressCounts[result.address] > bestCount then
                bestCount = addressCounts[result.address]
                bestAddress = result.address
            end
        end
    end
    
    if bestAddress then
        print("Most reliable Datamodel address:", string.format("0x%X", bestAddress), 
              "found by", bestCount, "methods")
        return bestAddress
    else
        print("No reliable Datamodel address found")
        return nil
    end
end

return GetMostReliableDatamodel()
