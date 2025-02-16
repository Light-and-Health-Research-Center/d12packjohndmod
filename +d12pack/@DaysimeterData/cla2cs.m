function CircadianStimulus = cla2cs(CircadianLight)
%CLA2CS Calculate circadian stimulus (CS) from circadian light (CLA)
%   Detailed explanation goes here

% CircadianStimulus = 0.7*(1 - (1./(1 + (CircadianLight/355.7).^(1.1026))));
CircadianLight(CircadianLight==0) = 0.5;
loglight = log(CircadianLight);
CircadianStimulus = rescale(loglight,0,0.7);
end

