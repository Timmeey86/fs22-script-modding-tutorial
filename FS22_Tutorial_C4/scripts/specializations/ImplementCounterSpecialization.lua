-- Define a table (doesn't even have to be a class)
ImplementCounterSpecialization = {}

---Checks whether or not required specializations exist. This is being called automatically
---@param specializations table @The table of existing specializations
---@return boolean @True if the list of specializations contains the AttacherJoins specialization
function ImplementCounterSpecialization.prerequisitesPresent(specializations)
    -- Test if the "AttacherJoints" specialization exists. Without that, nothing could ever be attached to a tractor and counting implements would be pointless.
    return SpecializationUtil.hasSpecialization(AttacherJoints, specializations)
end

---Initializes the specialization. This is being called automatically whenever you define it.
function ImplementCounterSpecialization.initSpecialization()
    -- Here you could register XML properties and other things. Let's keep it simple for now, though    
end

---Hooks into events which are published by other specializations (or by the game engine).
---This is being called automatically whenever you define it.
---@param vehicleType table @The type of vehicle to be handled
function ImplementCounterSpecialization.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", ImplementCounterSpecialization)
	SpecializationUtil.registerEventListener(vehicleType, "onPreAttachImplement", ImplementCounterSpecialization)
	SpecializationUtil.registerEventListener(vehicleType, "onPostDetachImplement", ImplementCounterSpecialization)
end

---Overwrites functions which are defined by parent specializations (Vehicle in this case).
---This is being called automatically whenever you define it.
---@param vehicleType table @The type of vehicle to be handled
function ImplementCounterSpecialization.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "drawUIInfo", ImplementCounterSpecialization.drawUIInfo)
end

---Initializes the implement counter on load. Note that the "onPreAttachImplement" event will be fired upon loading vehicles with attached implements
---from the savegame, so we don't have to store and load anything ourselves.
---@param savegame table @The savegame which is being loaded
function ImplementCounterSpecialization.onLoad(vehicle, savegame)
    vehicle.implementCounter = 0
end

---Increments the implement counter when an implement is about to be attached
function ImplementCounterSpecialization.onPreAttachImplement(vehicle)
    vehicle.implementCounter = vehicle.implementCounter + 1
end

---Decrements the implement counter when an implement has finished detaching
function ImplementCounterSpecialization.onPostDetachImplement(vehicle)
    vehicle.implementCounter = vehicle.implementCounter - 1
end

---Draws the implement counter near the speedometer
function ImplementCounterSpecialization.drawUIInfo(vehicle, superFunc)
    -- Let the base game draw stuff first
    superFunc(vehicle)

    -- Only render the implement counter for the vehicle the player is sitting in
    if vehicle == g_currentMission.controlledVehicle then

        -- Get the position of the speedometer (its bottom left corner in fact)
        local speedMeter = g_currentMission.hud.speedMeter
        local refX, refY = speedMeter.gaugeBackgroundElement:getPosition()
        local textSize = speedMeter:scalePixelToScreenHeight(20)

        -- Render the implement count slightly below the speedometer (0.02 is 2% of the screen height)
        setTextColor(1, 1, 1, 1) -- RGBA
        setTextBold(false)
        setTextAlignment(RenderText.ALIGN_CENTER)
        renderText(refX, refY - .02, textSize, "Implements: " .. tostring(vehicle.implementCounter))
    end
end