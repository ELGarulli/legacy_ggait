%%
% h = gcf; %current figure handle   
% axesObjs = get(h, 'Children');  %axes handles
% dataObjs = get(axesObjs(2), 'Children'); %handles to low-level graphics objects in axes   
% xdata = get(dataObjs, 'XData');  %data from low-level grahics objects
% ydata = get(dataObjs, 'YData');
% 
% figure(10)
% plot(xdata(1:end-1), (ydata(2:end)-ydata(1:end-1))/(xdata(2)-xdata(1)));
% 
% figure(12)
% imagesc(smooth(abs([(ydata(2:end)-ydata(1:end-1))/(xdata(2)-xdata(1));(ydata(2:end)-ydata(1:end-1))/(xdata(2)-xdata(1))]))')
% figure(13)
% plot(smooth(abs([(ydata(2:end)-ydata(1:end-1))/(xdata(2)-xdata(1));(ydata(2:end)-ydata(1:end-1))/(xdata(2)-xdata(1))]))')
%%

[File7,x,y] = importdata('C:\Users\Niko\Desktop\Parkinsons\Ladder\Tracked_Parkinson_files\496_march18_d\496_LADDER_07_KIN.csv');
[File16,x,y] = importdata('C:\Users\Niko\Desktop\Parkinsons\Ladder\Tracked_Parkinson_files\496_march18_d\496_LADDER_16_KIN.csv');

% File7_COM_X = mean([File7.data(:,3),File7.data(:,6),File7.data(:,18),File7.data(:,21)],2);
% File16_COM_X = mean([File16.data(:,3),File16.data(:,6),File16.data(:,18),File16.data(:,21)],2);

MTP_Speed =File7.data(:,29:31);
MTP_Speed_2 = File16.data(:,29:31);

hold on
MTP_Vel = sqrt((MTP_Speed(2:end,2)-MTP_Speed(1:end-1,2)).^2+(MTP_Speed(2:end,3)-MTP_Speed(1:end-1,3)).^2);
MTP_Vel_2 = sqrt((MTP_Speed_2(2:end,2)-MTP_Speed_2(1:end-1,2)).^2+(MTP_Speed_2(2:end,3)-MTP_Speed_2(1:end-1,3)).^2);


plot(MTP_Vel,'r');
plot(MTP_Vel_2,'b');

figure(111)
imagesc([smooth(MTP_Vel);smooth(MTP_Vel)]')
axis([589.5 1300.5 0.5 1.5])

figure(112)
imagesc([smooth(MTP_Vel_2);smooth(MTP_Vel_2)]')
axis([471.5 830.5 0.5 1.5])