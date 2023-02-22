function success=plot_gait_diagram(EVENT_HL, EVENT_FL, name)

figure(403),clf,hold on
set_myFig(figure(403),1100,225,10,700)
axis off

if ~isempty(EVENT_FL)
    nlimb=4;
else nlimb=2; end

for limb=1:nlimb
    
    switch limb
        case 1, EVENT=EVENT_HL;columns=2;bar=3;
        case 2, EVENT=EVENT_HL;columns=7;bar=1;
        case 3, EVENT=EVENT_FL;columns=2;bar=7;
        case 4, EVENT=EVENT_FL;columns=7;bar=5;
    end
    
    for i=1:size(EVENT,1)
        %%% STANCE
        if isnan(EVENT(i,columns:columns+1))~=1 & EVENT(i,columns:columns+1)~=0
            x=[EVENT(i,columns); EVENT(i,columns); EVENT(i,columns+1); EVENT(i,columns+1)];
            y=[bar; bar+1; bar+1; bar];
            patch(x, y, [0.7 0.7 0.7]);
        end
        
        %%% DRAG
        if limb==1 || limb==2
            if isnan(EVENT(i,columns+2))~=1 & EVENT(i,columns+1)~=0 & EVENT(i,columns+2)~=0
                x=[EVENT(i,columns+1); EVENT(i,columns+1); EVENT(i,columns+2); EVENT(i,columns+2)];
                y=[bar; bar+1; bar+1; bar];
                patch(x, y, [1 0 0]);
            end
        end       
    end  
end

title(name);
axis([min(min(EVENT_HL(find(EVENT_HL(:,2)~=0),2)), min(EVENT_HL(find(EVENT_HL(:,2)~=0),7))) max(max(EVENT_HL(find(EVENT_HL(:,2)~=0),2)), max(EVENT_HL(find(EVENT_HL(:,2)~=0),7))) 0 4+nlimb]);
text(max([max(EVENT_HL(:,2)),max(EVENT_HL(:,7))]), 3, 'HL_L');
text(max([max(EVENT_HL(:,2)),max(EVENT_HL(:,7))]), 1, 'HL_R');
if ~isempty(EVENT_FL)
    text(max([max(EVENT_HL(:,2)),max(EVENT_HL(:,7))]), 7, 'FL_L');
    text(max([max(EVENT_HL(:,2)),max(EVENT_HL(:,7))]), 5, 'FL_R');
end

success='Gait diagram created';
