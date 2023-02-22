function [FFT_features, phase_relationship]=comp_FFT(ANGLE, fe)
% FFT_features: phase and value of max amplitude of the signal 
%
% phase_relationship: difference of phases between two signals
%                (-pi <= phase_relationship <= pi)
% 
for angle=1:5
    FFT_features(1,2*angle-1:2*angle) = comp_fourier(ANGLE(:,angle),fe,1); % return PHASE and VALUE of max amplitude of the signal 
    main_angle_fft_features(1,angle) = FFT_features(1,2*angle-1); % take PHASE only
end

for angle=1:4
   phase_relationship(1,angle)=main_angle_fft_features(1,angle+1)-main_angle_fft_features(1,angle);
   if phase_relationship(1,angle)> pi
       phase_relationship(1,angle)=phase_relationship(1,angle)-2*pi;
   end
end