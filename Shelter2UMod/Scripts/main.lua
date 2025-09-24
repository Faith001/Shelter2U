--[[
┌──────────────────────────────────────────────────────┐
│ Filename    : main.lua                               │
│ Author      : Faith001                               │
│ Description : Implementation for the Shelter2U mod.  │
│               Loads and teleports a shelter to the   │
│               player while out in the open world.    │
│──────────────────────────────────────────────────────│
│ History                                              │
│ 2025-09-21  : Initial creation                       │
│                                                      │
└──────────────────────────────────────────────────────┘
]]

-- Imports
local UEHelpers       = require("UEHelpers")
local Config          = require("config")

-- Definitions
local StreamLevelName = "LVL_P01_WM_R1_BeachForest_A_LD"
local ShelterClass    = "BP_NTR_Shelter_C"

---@class FLatentActionInfo
local DummyLatentInfo

-- Functions
function LineTraceToLookingAtLocation()
    -- Performs a line trace towards where the camera is looking,
    -- using the ImpactPoint as the shelter spawn location.
    print("[Shelter2U] Calling LineTraceToLookingAtLocation.\n")

    local KismetSystemLibrary   = UEHelpers.GetKismetSystemLibrary()
    local KismetMathLibrary     = UEHelpers.GetKismetMathLibrary()
    local FirstPlayerController = UEHelpers.GetPlayerController()
    local Pawn                  = FirstPlayerController.Pawn
    local PlayerCameraManager   = FirstPlayerController.PlayerCameraManager

    local StartVector           = PlayerCameraManager:GetCameraLocation()
    local CameraForwardVector   = KismetMathLibrary:GetForwardVector(PlayerCameraManager:GetCameraRotation())
    local AddMultValue          = KismetMathLibrary:Multiply_VectorInt(CameraForwardVector, 9999)
    local EndVector             = KismetMathLibrary:Add_VectorVector(StartVector, AddMultValue)

    local TraceColorBoth        = { R = 0, G = 0, B = 0, A = 0 }
    local OutHitResult          = {}
    local GotHit                = KismetSystemLibrary:LineTraceSingle(
        Pawn, StartVector, EndVector, 0, false, {}, 0, OutHitResult, true, TraceColorBoth, TraceColorBoth, 0.0
    )

    if GotHit then
        print(
            string.format(
                "[Shelter2U] Got a hit, ImpactPoint XYZ:\t%s,\t%s,\t%s.\n",
                OutHitResult.ImpactPoint.X, OutHitResult.ImpactPoint.Y, OutHitResult.ImpactPoint.Z
            )
        )
        return OutHitResult.ImpactPoint
    end
end

function GetLoadedShelter()
    ---Returns the loaded shelter instance filtered by the StreamLevelName.
    local ShelterInstances = FindAllOf(ShelterClass)
    for _, ShelterInstance in pairs(ShelterInstances) do
        local ShelterInstanceName = ShelterInstance:GetFullName()
        if string.find(ShelterInstanceName, StreamLevelName) then
            print(string.format("[Shelter2U] Found valid shelter with name: %s.\n", ShelterInstanceName))
            return ShelterInstance
        end
    end
end

RegisterKeyBind(Config.keybind_key, { Config.keybind_modkey }, function()
    ExecuteInGameThread(function()
        print("[Shelter2U] Hotkey pressed.\n")

        local World                 = UEHelpers.GetWorld()
        local FirstPlayerController = UEHelpers:GetPlayerController()
        local GameplayStatics       = UEHelpers.GetGameplayStatics()
        local Pawn                  = FirstPlayerController.Pawn

        -- First "proper" shelter after the prologue
        print(string.format("[Shelter2U] Calling LoadStreamLevel for %s.\n", StreamLevelName))
        GameplayStatics:LoadStreamLevel(World, FName(StreamLevelName), true, true, DummyLatentInfo)

        -- A few checks before teleporting the shelter
        if (
                FirstPlayerController:IsInCombat() or
                FirstPlayerController:IsInCinematicSequence() or
                FirstPlayerController:GetIsInMovingElevator() or
                FirstPlayerController:GetIsInMovingBoat() or
                FirstPlayerController:GetIsInElevator() or
                FirstPlayerController:GetIsInBoat()
            ) then
            print("[Shelter2U] Player not in idle state, can't teleport shelter right now.\n")
            return
        end

        -- Need a slight delay to let the shelter construction finish
        ExecuteWithDelay(Config.shelter_teleport_delay_ms, function()
            -- If the line trace doesn't return a hit, just teleport it next to the player
            local TelportLocation  = LineTraceToLookingAtLocation() or Pawn:K2_GetActorLocation()
            local TeleportRotation = Pawn:K2_GetActorRotation()

            TelportLocation.Z      = TelportLocation.Z + 5
            TeleportRotation.Yaw   = TeleportRotation.Yaw + 90

            Shelter                = GetLoadedShelter()
            print("[Shelter2U] Teleporting shelter to player.\n")
            Shelter:K2_TeleportTo(TelportLocation, TeleportRotation)
        end)
    end)
end)

print("[Shelter2U] Mod loaded!\n")
