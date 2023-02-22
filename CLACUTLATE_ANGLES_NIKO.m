% Matrix = [7.309	3.516	9.886	1.329	8.952	1.692	8.337	3.857
% 8.225	2.98	11.68	1.184	11.47	1.047	9.368	3.348
% 7.443	3.175	10.51	3.35	10.48	1.951	8.415	3.746
% 8.294	2.833	11.97	1.815	11.95	1.615	9.393	3.341
% 6.399	3.906	8.624	2.702	9.754	2.044	7.622	3.936
% 7.168	3.513	10.94	1.402	10.59	1.312	8.276	3.648
% 8.613	3.563	11.41	3.85	11.81	2.136	9.722	3.631
% 9.119	3.468	12.91	0.6572	12.65	0.5803	10.32	3.402
% 6.812	3.181	9.774	1.349	9.268	1.74	7.712	3.467
% 6.73	2.864	9.953	0.9883	9.877	0.9665	7.856	3.25
% 6.904	3.002	10.08	2	10.12	1.153	7.782	3.366
% 6.796	2.724	10.18	0.7454	10.19	0.7604	7.907	3.209
%  ];
% 
Matrix = [-19.112478	42.767582	40.112946	-24.53981	25.420048	-22.179552	9.415799	40.010479
-6.69875	34.847904	48.509266	-22.479933	44.737232	-23.64781	15.34339	33.913342
-17.893269	43.037907	43.11232	-21.957449	47.463932	-8.35566	10.64001	39.736454
-6.263867	34.876556	49.879139	-24.533197	49.193623	-24.962862	15.915548	33.639816
-18.8207	43.462685	40.227695	-23.466755	28.633486	-21.714211	9.735512	40.194927
-6.944623	35.319309	48.208424	-22.343382	45.004131	-23.466877	15.134523	34.151974
-18.669987	43.985474	38.453285	-22.603792	42.798557	-11.08569	9.712131	40.564617
-5.984042	35.293133	47.19075	-24.689333	46.682968	-24.715704	15.83819	33.731094];


P2 = Matrix(:,7:8); 
P1 = Matrix(:,3:4); 
P3 = Matrix(:,5:6); 
%RelativeP2 =[ mean([P1(:,1), P3(:,1)]')',P2(:,2)];
RelativeP2 =[ P1(:,1),P2(:,2)];

numberDAT = 8;

angle = [];
for x = 1:numberDAT
angle(x) = acos(dot(P1(x,1:2)-P2(x,1:2),P3(x,1:2)-P2(x,1:2)) / norm(P1(x,1:2)-P2(x,1:2)) / norm(P3(x,1:2)-P2(x,1:2)));
end
angleSpecial=[];
for x = 1:numberDAT
angleSpecial(x) = acos(dot(P1(x,1:2)-RelativeP2(x,1:2),P3(x,1:2)-RelativeP2(x,1:2)) / norm(P1(x,1:2)-RelativeP2(x,1:2)) / norm(P3(x,1:2)-RelativeP2(x,1:2)));
end

DeltalimbLength=[];
for x = 1:numberDAT
    new = sort([sqrt(((P3(x,1)-P2(x,1)).^2)+(P3(x,2)-P2(x,2)).^2),sqrt(((P1(x,1)-P2(x,1)).^2)+(P1(x,2)-P2(x,2)).^2)]);
DeltalimbLength(x) = new(1)/new(2);
end

ChangePos =[];
for x = 1:numberDAT
    new = sqrt(((P3(x,1)-P1(x,1)).^2)+(P3(x,2)-P1(x,2)).^2);
ChangePos(x) = new;
end

variable1 = angle(3:4:numberDAT);
variable2 = angle(4:4:numberDAT);
MAXV = max([variable1,variable2]);
[h,p]= ttest2(variable1./variable1,variable2./variable1);
[h,p]= ttest(variable1,variable2);
kruskalwallis(variable1,variable2)

figure(11)

angle

L2R_r = mean(abs(angle(1:4:numberDAT)));
L2R_l = mean(abs(angle(2:4:numberDAT)));
S1R_r = mean(abs(angle(3:4:numberDAT)));
S1R_l = mean(abs(angle(4:4:numberDAT)));



eL2R_r = std(abs(angle(1:4:numberDAT)))/sqrt(3);
eL2R_l = std(abs(angle(2:4:numberDAT)))/sqrt(3);
eS1R_r = std(abs(angle(3:4:numberDAT)))/sqrt(3);
eS1R_l = std(abs(angle(4:4:numberDAT)))/sqrt(3);
bar(radtodeg([L2R_r,L2R_l,-S1R_r,-S1R_l]))
hold on
errorbar(radtodeg([L2R_r,L2R_l,-S1R_r,-S1R_l]),radtodeg([eL2R_r,eL2R_l,eS1R_r,eS1R_l]),'x')

figure(2)
L2R_r = mean(abs(angleSpecial(1:4:numberDAT)));
L2R_l = mean(abs(angleSpecial(2:4:numberDAT)));
S1R_r = mean(abs(angleSpecial(3:4:numberDAT)));
S1R_l = mean(abs(angleSpecial(4:4:numberDAT)));

eL2R_r = std(abs(angleSpecial(1:4:numberDAT)))/sqrt(3);
eL2R_l = std(abs(angleSpecial(2:4:numberDAT)))/sqrt(3);
eS1R_r = std(abs(angleSpecial(3:4:numberDAT)))/sqrt(3);
eS1R_l = std(abs(angleSpecial(4:4:numberDAT)))/sqrt(3);
bar(radtodeg([L2R_r,L2R_l,-S1R_r,-S1R_l]))
hold on
errorbar(radtodeg([L2R_r,L2R_l,-S1R_r,-S1R_l]),radtodeg([eL2R_r,eL2R_l,eS1R_r,eS1R_l]),'x')
figure(3)

L2R_r = mean(abs(DeltalimbLength(1:4:numberDAT)));
L2R_l = mean(abs(DeltalimbLength(2:4:numberDAT)));
S1R_r = mean(abs(DeltalimbLength(3:4:numberDAT)));
S1R_l = mean(abs(DeltalimbLength(4:4:numberDAT)));

eL2R_r = std(abs(DeltalimbLength(1:4:numberDAT)))/sqrt(3);
eL2R_l = std(abs(DeltalimbLength(2:4:numberDAT)))/sqrt(3);
eS1R_r = std(abs(DeltalimbLength(3:4:numberDAT)))/sqrt(3);
eS1R_l = std(abs(DeltalimbLength(4:4:numberDAT)))/sqrt(3);
bar(([L2R_r,L2R_l,S1R_r,S1R_l]))
hold on
errorbar(([L2R_r,L2R_l,S1R_r,S1R_l]),([eL2R_r,eL2R_l,eS1R_r,eS1R_l]),'x')


figure(4)
variable = ChangePos;

L2R_r = mean(abs(variable(1:4:numberDAT)));
L2R_l = mean(abs(variable(2:4:numberDAT)));
S1R_r = mean(abs(variable(3:4:numberDAT)));
S1R_l = mean(abs(variable(4:4:numberDAT)));

eL2R_r = std(abs(variable(1:4:numberDAT)))/sqrt(3);
eL2R_l = std(abs(variable(2:4:numberDAT)))/sqrt(3);
eS1R_r = std(abs(variable(3:4:numberDAT)))/sqrt(3);
eS1R_l = std(abs(variable(4:4:numberDAT)))/sqrt(3);
bar(([L2R_r,L2R_l,S1R_r,S1R_l]))
hold on
errorbar(([L2R_r,L2R_l,S1R_r,S1R_l]),([eL2R_r,eL2R_l,eS1R_r,eS1R_l]),'x')
