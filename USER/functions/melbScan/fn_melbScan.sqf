/*

    [vehicle player] call hoppers_fnc_melbScan;

*/

params ["_vehicle"];

HOPPERS_LASERBATTERY_FILL_RATE = ["HOPPERS_LASERBATTERY_FILL_RATE", 0.1] call BIS_fnc_getParamValue;
HOPPERS_LASERBATTERY_DRAIN_RATE = 0.1;
HOPPERS_BOSS_MARKING_FADEOUT = 20; // time 3d marker and map markers are shown


hoppers_fnc_createCoolDownBar = {

    private _text = (findDisplay 46) ctrlCreate ["RscText", -1];
    _text ctrlSetPosition [
        (SafezoneX + ((SafezoneW - SafezoneH) / 2)) + 3*   (0.01875 * SafezoneH),
        safeZoneY + (15.3 *   (0.025 * SafezoneH)),
        13 *   (0.01875 * SafezoneH),
        2 *   (0.025 * SafezoneH)
    ];
    _text ctrlSetFontHeight (0.0255*SafezoneH);
    _text ctrlSetText "....................";
    _text ctrlCommit 0;
    _text
};

hoppers_fnc_createStatusBar = {

    private _text = (findDisplay 46) ctrlCreate ["RscText", -1];
    _text ctrlSetPosition [
        (SafezoneX + ((SafezoneW - SafezoneH) / 2)) + 3*   (0.01875 * SafezoneH),
        safeZoneY + (14.3 *   (0.025 * SafezoneH)),
        13 *   (0.01875 * SafezoneH),
        2 *   (0.025 * SafezoneH)
    ];
    _text ctrlSetFontHeight (0.0255*SafezoneH);
    _text ctrlSetText "";
    _text ctrlSetTextColor [1,0,0,1];
    _text ctrlCommit 0;
    _text
};

/*

safeZoneX + SafeZoneW + (3*   (0.01875 * SafezoneH)),
        safeZoneY + (14.1 *   (0.025 * SafezoneH)),
        13 *   (0.01875 * SafezoneH),
        2 *   (0.025 * SafezoneH)
    ]; _text ctrlCommit 0;

*/

private _mouseButtonDown = (findDisplay 46) displayAddEventhandler ["MouseButtonDown", {
    params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button == 0) then {
        uiNamespace setVariable ["hoppers_scanActive", true];
        private _soundDummy = playSound "scanner_loading";
        missionNamespace setVariable ["GRAD_GPM_soundLoading", _soundDummy];
    };
}];

private _mouseButtonUp = (findDisplay 46) displayAddEventhandler ["MouseButtonUp", {
    params ["_control", "_button", "_xPos", "_yPos", "_shift", "_ctrl", "_alt"];
    if (_button == 0) then {
        uiNamespace setVariable ["hoppers_scanActive", false];
        if (vehicle player isKindOf "Air") then {
            private _soundDummy = missionNamespace getVariable ["GRAD_GPM_soundLoading", objNull];
            if (!isNull _soundDummy) then { deleteVehicle _soundDummy; };
            playSound "scanner_firing";
            [screenToWorld [0.5,0.5], vehicle player] call hoppers_fnc_melbScanMan;
        };
    };
}];

player setVariable ["hoppers_clickEH", [_mouseButtonUp, _mouseButtonDown]];

private _coolDownBar = call hoppers_fnc_createCoolDownBar;
private _statusBar = call hoppers_fnc_createStatusBar;
uiNamespace setVariable ["hoppers_coolDownBar", _coolDownBar];
uiNamespace setVariable ["hoppers_statusBar", _statusBar];

private _handle = [{
    params ["_args", "_handle"];
    _args params ["_vehicle"];

    // (findDisplay 46 displayCtrl 158) ctrlsetText "";

    private _coolDownBar = uiNamespace getVariable ["hoppers_coolDownBar", controlNull];
    private _statusBar = uiNamespace getVariable ["hoppers_statusBar", controlNull];

    if (isNull _coolDownBar) then {
        _coolDownBar = call hoppers_fnc_createCoolDownBar;
        uiNamespace setVariable ["hoppers_coolDownBar", _coolDownBar];
    };
    if (isNull _statusBar) then {
        _statusBar = call hoppers_fnc_createStatusBar;
        uiNamespace setVariable ["hoppers_statusBar", _statusBar];
    };

    private _laserBatteryStatus = _vehicle getVariable ["hoppers_laserBattery", 1];
    private _overheated = _vehicle getVariable ["hoppers_laserOverheated", false];
    private _armaColor = if (_laserBatteryStatus > 0.5) then {
        "colorGreen"
    } else {
        if (_laserBatteryStatus > 0.25) then {
            "colorYellow"
        } else {
            if (_laserBatteryStatus > 0) then {
                "colorOrange"
            } else {
                "colorRed"
            };
        };
    };

    private _characterAmount = linearConversion [1, 0, _laserBatteryStatus, 0, 20, true];
    private _stringCoolDown = ["||||||||||||||||||||", 0, _characterAmount] call BIS_fnc_trimString;

    // systemChat str _coolDownBar;

    private _color = (configfile >> "CfgMarkerColors" >> _armaColor >> "color") call BIS_fnc_colorConfigToRGBA;

    if ((uiNamespace getVariable ["hoppers_scanActive", false]) && !(_vehicle getVariable ["hoppers_laserOverheated", false])) then {

        if (_laserBatteryStatus > 0) then {
            _laserBatteryStatus = _laserBatteryStatus - HOPPERS_LASERBATTERY_DRAIN_RATE;
            _statusBar ctrlsetText ("CHARGING." + selectRandom ["","."] + selectRandom ["","."]);
            // uiNamespace setVariable ["hoppers_scanActive", false];
        } else {
            playSound "ace_javelin_locked";
            _vehicle setVariable ["hoppers_laserOverheated", true];
            _statusBar ctrlsetText "OVERHEATED";
        };
    } else {
        if (_laserBatteryStatus < 1) then {
            _laserBatteryStatus = _laserBatteryStatus + HOPPERS_LASERBATTERY_FILL_RATE;
            playSound "ace_javelin_locking";
            if ((uiNamespace getVariable ["hoppers_scanActive", false])) then {
                _statusBar ctrlsetText "OVERHEATED";
            } else {
                _statusBar ctrlsetText "COOLDOWN";
            };
        } else {
            _vehicle setVariable ["hoppers_laserOverheated", false];
            _statusBar ctrlsetText "READY";
        };
    };


    // (findDisplay 46 displayCtrl 158) ctrlSetTextColor _color;

    _coolDownBar ctrlsetText _stringCoolDown;
    _coolDownBar ctrlSetTextColor _color;
    _coolDownBar ctrlCommit 0;

    _vehicle setVariable ["hoppers_laserBattery", _laserBatteryStatus];

}, 0.1, [_vehicle]] call CBA_fnc_addPerFrameHandler;


private _drawEH = addMissionEventHandler ["Draw3D", {

    private _nearEntities = player getVariable ["hoppers_drawEntities", []];

    {
        private _position = ASLToAGL getPosASL _x;
        private _lastPing = _x getVariable ["hoppers_lastPing", 0];
        private _boss = missionNamespace getVariable ["hoppers_boss", objNull];
        private _isBoss = _boss == _x;
        private _isDrawn = if (_isBoss) then { true } else { (_x distance _boss) > HOPPERS_MAX_DISTANCE_BOSS };

        if (_isDrawn) then {
            _position params ["_xPos", "_yPos", "_zPos"];

            private _colorR = 1;
            private _colorG = .2;
            private _colorB = .2;
            private _alpha = 0;

            if (!_isBoss) then {
                _colorR = .2; _colorG = 1;
            };

            drawIcon3D [getMissionPath "USER\data\flare.paa", [_colorR, _colorG, _colorB, linearConversion [0, HOPPERS_BOSS_MARKING_FADEOUT, CBA_missionTime - _lastPing, 1, 0, true]], [_xPos, _yPos, _zPos + 1] , 2, 2, 0, "", 0, 0.05, "TahomaB", "center", true];
        };
    } forEach _nearEntities;
}];

player setVariable ["hoppers_3ddrawHandler", _drawEH];
player setVariable ["hoppers_uidrawHandler", _handle];
