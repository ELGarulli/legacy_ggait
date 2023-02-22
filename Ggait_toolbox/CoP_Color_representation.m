function [ distribution ] = CoP_Color_representation(CoPL, CoPR, dimension)

CoPL=resample(CoPL,20*size(CoPL,1));
CoPR=resample(CoPR,20*size(CoPR,1));

figure(113);
set_myFig(figure(113),330,420,(560+15)*2,50)

for side=1:2
    
    progressbar

        
    if side==1;CoP=CoPL; end
    if side==2;CoP=CoPR; end
    
    center=mean(CoP,1);
    range=3;
    
    Xmin=center(1,1)-range;
    Ymin=center(1,2)-range;
    
    step=2*range/dimension;
    
    for i=1:dimension
        for j=1:dimension
            distribution(i,j)=length(find(CoP(:,1)>=(Xmin+(j-1)*step) & CoP(:,1)<(Xmin+j*step) ...
                & CoP(:,2)>=(Ymin+(i-1)*step) & CoP(:,2)<(Ymin+i*step)));
        end
        progressbar(i/dimension)
    end
    
    subplot(2,1,side);hold on
    if side==1, title('Left CoP'), else title('Right CoP'), end
    [X, Y, d, dimension, cm]=custom_colorplot(distribution, 64, 6, 64);
    pcolor(X,Y,d); shading interp;
    colormap(jet); C=colormap; C(1,1:3)=[1 1 1];colormap(C);
    
    colorbar('location','EastOutside');
    axis([1 size(distribution,2) 1 size(distribution,1)]);
    plot([0 0 64 64],[0 64 64 0], 'k');
    set(gca,'YTick',linspace(1, 64, 8));
    set(gca,'XTick',linspace(1, 64, 8));
    xlabel('LATERAL (cm)'), ylabel('FORWARD (cm)')
end

suptitle('Joint probability distribution')

progressbar(1)
