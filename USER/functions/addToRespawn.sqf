params ["_vehicle", ["_respawnInstant", true]];

if (!isServer) exitWith {};

clearItemCargoGlobal _vehicle;
clearWeaponCargoGlobal _vehicle;
clearMagazineCargoGlobal _vehicle;
clearBackpackCargoGlobal _vehicle;

private _isAir = if (_vehicle isKindOf "Air") then { true } else { false };
private _isOH = if (typeOf _vehicle == "RHS_MELB_H6M") then { true } else { false };

// opfor land vehicle
if (!_isAir) then {
    _vehicle addMagazineCargoGlobal ['rhs_45Rnd_545X39_AK_Green', 20]; 
    _vehicle addMagazineCargoGlobal ['rhs_100Rnd_762x54mmR_green', 20];
    [_vehicle, _respawnInstant, 5, "(_this select 0) addMagazineCargoGlobal ['rhs_45Rnd_545X39_AK_Green', 20]; 
    (_this select 0) addMagazineCargoGlobal ['rhs_100Rnd_762x54mmR_green', 20];"] call GRAD_vehiclerespawn_fnc_add;
} else {
    _vehicle addMagazineCargoGlobal ['rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_red', 20]; 
    _vehicle addMagazineCargoGlobal ['rhsusf_200Rnd_556x45_mixed_soft_pouch', 20];

    if (!_isOH) then {
        [_vehicle, _respawnInstant, 5, "(_this select 0) lockTurret [[0],true]; (_this select 0) addMagazineCargoGlobal ['rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_red', 20]; 
    (_this select 0) addMagazineCargoGlobal ['rhsusf_200Rnd_556x45_mixed_soft_pouch', 20];"] call GRAD_vehiclerespawn_fnc_add;
        _vehicle lockTurret [[0],true];
    } else {
        [_vehicle, _respawnInstant, 5, "(_this select 0) addMagazineCargoGlobal ['rhs_mag_30Rnd_556x45_M855A1_PMAG_Tracer_red', 20]; 
    (_this select 0) addMagazineCargoGlobal ['rhsusf_200Rnd_556x45_mixed_soft_pouch', 20];"] call GRAD_vehiclerespawn_fnc_add; 
    };
};


