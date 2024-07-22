-- Important: These are global temporary variables. We need to capture them while the main lua file is being loaded.
MOD_NAME = g_currentModName
MOD_DIRECTORY = g_currentModDirectory

-- A couple of aliases for more readable code later on
local uniqueSpecializationName = "FSTC4_ImplCounterSpec" -- call this however you like. It needs to be unique across all mods, though
local specClassName = "ImplementCounterSpecialization" -- this must match the name of your specialization table/class
local specIdentifier = MOD_NAME .. "." .. uniqueSpecializationName
local specPath = MOD_DIRECTORY .. "scripts/specializations/" .. specClassName .. ".lua"

-- Define a function which registers our specialization
local function registerSpecialization(manager)

    -- This method will be called multiple times. Skip it unless the vehicle types are being validated
    if manager.typeName == "vehicle" then

        -- Register our specialization once so we can assign it to vehicles
        g_specializationManager:addSpecialization(uniqueSpecializationName, specClassName, specPath, nil)

        -- Add the specialization to any motorized vehicle (note that trailers and even pallets are considered vehicles as well, we are not interested in those)
        for typeName, typeEntry in pairs(g_vehicleTypeManager:getTypes()) do
            if typeEntry ~= nil and SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations) and
                SpecializationUtil.hasSpecialization(AttacherJoints, typeEntry.specializations) then

                -- Add the specialization to this vehicle. Every vehicle object of this type will then get this specialization later on
                g_vehicleTypeManager:addSpecialization(typeName, specIdentifier)

            end
        end
    end
end

-- Just before all types are ready for validation, we can register our specialization since all vehicle types have been registered already
TypeManager.validateTypes = Utils.prependedFunction(TypeManager.validateTypes, registerSpecialization)