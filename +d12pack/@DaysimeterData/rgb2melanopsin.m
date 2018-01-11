function CLA_mel = rgb2melanopsin(obj,Red,Green,Blue)
%RGB2MELANOPSIN Convert Daysimeter Red, Green, and Blue channels (RGB) to
% Circadian Light (CLA)

% Define constants
if obj.SerialNumber < 366
    C  = [ 0.617848  3.221534 0.265128 2.309656];
    M  = [ 0.000254  0.167237 0.261462];
    Sm = [-0.005701 -0.014015 0.241859];
    Vm = [ 0.381876  0.642883 0.067544];
    Vp = [ 0.004458  0.360213 0.189536];
elseif obj.SerialNumber >= 366 %&& obj.SerialNumber <= 415
    C  = [ 0.613631  3.385647 0.235952 2.310402];
    M  = [-0.001684  0.164230 0.265890];
    Sm = [-0.005284 -0.015436 0.243373];
    Vm = [ 0.380969  0.647984 0.057097];
    Vp = [ 0.001286  0.361920 0.191571];
else
    error(['Serial number: ',num2str(obj.SerialNumber),' is not supported']);
end

RGB = horzcat(Red(:),Green(:),Blue(:));

Scone      = sum(bsxfun(@times, Sm, RGB), 2);
Vmaclamda  = sum(bsxfun(@times, Vm, RGB), 2);
Melanopsin = sum(bsxfun(@times, M,  RGB), 2);
Vprime     = sum(bsxfun(@times, Vp, RGB), 2);

% Replace negative values with zero
Scone(Scone<0) = 0;
Vmaclamda(Vmaclamda<0) = 0;
Melanopsin(Melanopsin<0) = 0;
Vprime(Vprime<0) = 0;

CL = Melanopsin;


CLA_mel = C(4)*CL;


end

