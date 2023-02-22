function [] = plot_cycles(Ncycle, Xstart, Xstop, Yparam)


for cycle=1:Ncycle
    plot([Xstart(cycle) Xstart(cycle)], [min(Yparam) max(Yparam)], 'LineWidth',2,'Color',[0 0 0]);hold on
    plot([Xstop(cycle) Xstop(cycle)], [min(Yparam) max(Yparam)], 'LineWidth',1,'Color',[0.5 0.5 0.5]);hold on
end