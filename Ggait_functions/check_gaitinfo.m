function INFO = check_gaitinfo(INFO)

Ncycles = size(INFO,1);

for i=1:2
    
    if i==1, stance=2; swing=3; drag_end=4; % left side
    else     stance=7; swing=8; drag_end=9; % right side
    end
    
    Ncycles = find(INFO(:,stance) ~=0,1,'last'); % cycles with stepping
    for cycle = 1:Ncycles-1
        if INFO(cycle,drag_end) == 0
            if INFO(cycle,swing) == 0
                INFO(cycle,swing) = INFO(cycle+1,stance);
            end
            INFO(cycle,drag_end) = INFO(cycle,swing); % No dragging
        end
        if INFO(cycle,swing) == 0
            INFO(cycle,swing) = INFO(cycle,drag_end);
        end
    end
end