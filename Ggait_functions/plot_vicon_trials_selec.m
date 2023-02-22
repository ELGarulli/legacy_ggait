function [] = plot_vicon_trials_selec(vicon, t, x)
%% Plot histograms for all vicon times
plot_data=1;
N = size(vicon,2)/2;
time=t;

Listtrial = NaN(N,1);
for i=1:N
    Listtrial(i)={['VICON TRIAL #' char(num2str(i))]};
end
[trial, ok] = listdlg('ListString',Listtrial, 'SelectionMode', 'single')


figure(trial)
ii = find((time >= vicon(2,1+(trial-1)*2)) & (time <= vicon(2,trial*2)));

if plot_data==1
    
    subplot(711)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,1),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,1),3), 'k', 'linewidth', 1)
    axis tight
    legend('100ms bins', 'moving avg')
    ylabel('Firing rate [Hz]')
    title(['Vicon File #' num2str(trial)])
    
    subplot(712)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,2),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,2),3), 'k', 'linewidth', 1)
    axis tight
    ylabel('Firing rate [Hz]')
    
    subplot(713)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,3), 5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,3),3), 'k', 'linewidth', 1)
    axis tight
    
    subplot(714)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,4),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,4),3), 'k', 'linewidth', 1)
    axis tight
    ylabel('Firing rate [Hz]')
    
    subplot(715)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,5), 5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,5),3), 'k', 'linewidth', 1)
    axis tight
    
    subplot(716)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,6),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,6),3), 'k', 'linewidth', 1)
    axis tight
    ylabel('Firing rate [Hz]')
    
    subplot(717)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,7), 5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,7),3), 'k', 'linewidth', 1)
    axis tight
    
    ylabel('Firing rate [Hz]')
    xlabel('Time [s]')
    
elseif plot_data==2
    
    subplot(311)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,1),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,1),3), 'k', 'linewidth', 1)
    axis tight
    legend('100ms bins', 'moving avg')
    ylabel('Firing rate [Hz]')
    title(['Vicon File #' num2str(trial)])
    
    subplot(312)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,2),5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,2),3), 'k', 'linewidth', 1)
    axis tight
    ylabel('Firing rate [Hz]')
    
    subplot(313)
    scatter(0.1: 0.1 : length(ii)/10, 10*x(ii,4), 5)
    hold all
    plot(0.2 : 0.1 :length(ii)/10, ...
        10*smoothJ2(x(ii,4),3), 'k', 'linewidth', 1)
    axis tight
    ylabel('Firing rate [Hz]')
    xlabel('Time [s]')
    
end
