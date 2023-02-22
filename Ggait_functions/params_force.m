function [FORCE_LEFT FORCE_RIGHT]=params_force(DATA_FORCE, FORCE_SS)


start=find(DATA_FORCE(:,2)==FORCE_SS(1,1));
stop=find(DATA_FORCE(:,2)==FORCE_SS(end,1));

FORCE_LEFT= DATA_FORCE(start:stop,1:2); % Copy FRAME and TIME columns
for i=3:size(DATA_FORCE,2)
    FORCE_LEFT(:,i)=DATA_FORCE(start:stop,i).*FORCE_SS(:,2);
end

FORCE_RIGHT=DATA_FORCE(start:stop, 1:2); % Copy FRAME and TIME columns
for i=3:size(DATA_FORCE,2)
    FORCE_RIGHT(:,i)=DATA_FORCE(start:stop,i).*FORCE_SS(:,3);
end


