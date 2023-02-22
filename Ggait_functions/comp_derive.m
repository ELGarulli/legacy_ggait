function dataXd=comp_derive(data, freq)
% output is derivate of input data

for i=1:size(data,2)   
    xd=diff(data(:,i)')';
    xd_1=[xd(1); xd]'*freq;
    xd_2=[xd; xd(end)]'*freq;
    dataXd(:,i)=mean([xd_1; xd_2])';   
end
