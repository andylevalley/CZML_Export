function f = czmlexport(fname,scenario,sats)
%CZMLEXPORT  Produces a CZML scenario/satellite file
%   fname     STRING file path\name
%   scenario  STRUCT containing scenario information
%       .dtg.start  DATETIME start
%       .dtg.stop   DATETIME stop
%
%   sats();   STRUCT ARRAY of STRUCTs containing satellite information
%       .id         STRING unique satellite identification number
%       .name       STRING satellite name
%       .hist       4xN MATRIX of position history in ECI frame, [t;x;y;z]
%                   time in seconds starting from zero
%       .fillColor  VECTOR, 1x4 RGBA, 0-255
%       .pathColor  VECTOR, 1x4 RGBA, 0-255

% url = 'http://localhost:8080/Apps/CesiumViewer/index.html';
% cesium = web(url,'-new','-noaddressbox','-notoolbar');
% web(url,'-browser');
% url = '"http://localhost:8080/Apps/CesiumViewer/index.html"';
% !start chrome --new-window url

% convert DATETIME to formatted strings
strClockInterval = [datestr(scenario.dtg.start,'yyyy-mm-dd') 'T' ...
    datestr(scenario.dtg.start,'HH:MM:SS') 'Z/' ...
    datestr(scenario.dtg.stop,'yyyy-mm-dd') 'T' ...
    datestr(scenario.dtg.stop,'HH:MM:SS') 'Z'];
strClockCurrentTime = [datestr(scenario.dtg.start,'yyyy-mm-dd') 'T' ...
    datestr(scenario.dtg.start,'HH:MM:SS') 'Z'];
trailTime = seconds(scenario.dtg.stop-scenario.dtg.start);

% scene
scene.id = 'document';
scene.name = 'name';
scene.description = 'description';
scene.version = '1.0';
scene.clock.interval = strClockInterval;
scene.clock.currentTime = strClockCurrentTime;
s = {scene};

% satellites
nsats = length(sats);
for idx=1:nsats
    % satellite properties
    satellites(idx).id = sats(idx).id;
    satellites(idx).name = sats(idx).name;
    satellites(idx).label.text = sats(idx).name;
    satellites(idx).label.fillColor.rgba = sats(idx).fillColor;
    % path properties
    satellites(idx).path.width = 3;
    satellites(idx).path.leadTime = 0;
    satellites(idx).path.trailTime = trailTime;
    satellites(idx).path.material.polylineOutline.color.rgba = sats(idx).pathColor;
    satellites(idx).path.material.polylineOutline.outlineColor.rgba = [0,0,0,0];
    satellites(idx).path.material.polylineOutline.outlineWidth = 0;
    % path
    satellites(idx).position.interpolationAlgorithm = 'LAGRANGE';
    satellites(idx).position.interpolationDegree = 5;
    satellites(idx).position.referenceFrame = 'INERTIAL';
    satellites(idx).position.epoch = strClockCurrentTime;
    satellites(idx).position.cartesian = sats(idx).hist(:);
    
    s{end+1} = satellites(idx);
end

% create JSON and write CZML file
s = jsonencode(s);
[FID,MESSAGE] = fopen([fname '.czml'],'w');
fprintf(FID,s);
fclose(FID);

end