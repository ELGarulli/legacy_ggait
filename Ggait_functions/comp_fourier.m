function [output]=comp_fourier(data, fe, output_type)

nbpts=max(size(data));

% FFT
fourier=fft(data);

% scale and spectrum
fc = fe / 2;
moitie=round(nbpts/2);
%frq = linspace(0,fc,nbpts/2);
DemiFourier = fourier(1:moitie);

AMP = abs(DemiFourier);
[max_AMP frq_MAX] = max(AMP(2:moitie,1));
PHASE = angle(DemiFourier);

switch output_type
    case 1, output=[PHASE(frq_MAX+1,1) max_AMP];  
    case 2, output=[PHASE(frq_MAX+1,1)];
    case 3, output=[PHASE(2:round(6*(nbpts/2)/fc)+1,1)];
end
