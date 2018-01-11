function Illuminance = rgb2lux(obj,Red,Green,Blue)
%RGB2LUX Summary of this function goes here
%   Detailed explanation goes here

if obj.SerialNumber < 366
    V = [0.382859 0.604808 0.017628];
elseif obj.SerialNumber >= 366 %&& obj.SerialNumber <= 415
    V = [0.327647	0.638611	0.012176];
else
    error(['Serial number: ',num2str(obj.SerialNumber),' is not supported']);
end

Illuminance = V(1)*Red + V(2)*Green + V(3)*Blue;

end

