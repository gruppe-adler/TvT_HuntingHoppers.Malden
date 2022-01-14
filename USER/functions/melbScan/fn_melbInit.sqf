if (side player == west) then {
    player addEventHandler ["GetInMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];

        if (_vehicle isKindOf "Air" && _role == "driver") then {
            [_vehicle] call hoppers_fnc_melbScan;
        };
    }];

    player addEventHandler ["GetOutMan", {
        params ["_unit", "_role", "_vehicle", "_turret"];

        private _3dhandle = player getVariable ["hoppers_3ddrawHandler", -1];
        private _uihandle = player getVariable ["hoppers_uidrawHandler", -1];
        private _clickhandle = player getVariable ["hoppers_clickEH", []];


        if (_3dhandle > -1) then {
            removeMissionEventHandler ["Draw3D", _3dhandle];
        };
        if (_uihandle > -1) then {
            [_uihandle] call CBA_fnc_removePerFrameHandler;
        };
        if (count _clickhandle > -1) then {
            _clickhandle params ["_mousebuttonup", "_mousebuttondown"];
            findDisplay 46 displayRemoveEventHandler ["MouseButtonUp", _mousebuttonup];
            findDisplay 46 displayRemoveEventHandler ["MouseButtonDown", _mousebuttondown];
            Hint "removed eh";
        };
    }];

    player addEventHandler ["SeatSwitchedMan", {
        params ["_unit1", "_unit2", "_vehicle"];

        if ((assignedVehicleRole player)#0 == "driver") then {
            if (_vehicle isKindOf "Air") then {
                [_vehicle] call hoppers_fnc_melbScan;
            };
        } else {
            private _3dhandle = player getVariable ["hoppers_3ddrawHandler", -1];
            private _uihandle = player getVariable ["hoppers_uidrawHandler", -1];
            private _clickhandle = player getVariable ["hoppers_clickEH", []];


            if (_3dhandle > -1) then {
                removeMissionEventHandler ["Draw3D", _3dhandle];
            };
            if (_uihandle > -1) then {
                [_uihandle] call CBA_fnc_removePerFrameHandler;
            };
            if (count _clickhandle > -1) then {
                _clickhandle params ["_mousebuttonup", "_mousebuttondown"];
                findDisplay 46 displayRemoveEventHandler ["MouseButtonUp", _mousebuttonup];
                findDisplay 46 displayRemoveEventHandler ["MouseButtonDown", _mousebuttondown];
                Hint "removed eh";
            };
        };
    }];
};