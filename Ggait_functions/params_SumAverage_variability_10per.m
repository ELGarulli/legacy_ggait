function SumAverage=params_SumAverage_variability_10per(SumAverage, ANGLEmean_L, ANGLEmean_R)

for side=1:2
    
    if side==1
        ANGLEmean=ANGLEmean_L(:,13:24)-ANGLEmean_L(:,1:12); % retrieve standard deviation
    else ANGLEmean=ANGLEmean_R(:,13:24)-ANGLEmean_R(:,1:12); % retrieve standard deviation
    end
    
    ANGLEmean=resample(ANGLEmean, 10);
    
    for angle=1:12        
        for sample=1:10
            SumAverage(side,107+12*(angle-1)+sample)=ANGLEmean(sample,angle);
        end      
        SumAverage(side,107+12*(angle-1)+11)=mean(ANGLEmean(2:5,angle),1); % mean SD mid-stance
        SumAverage(side,107+12*(angle-1)+12)=mean(ANGLEmean(8:9,angle),1); % mean SD mid-swing       
    end 
end
