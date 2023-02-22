function []= plot_patch_empty(TXlegend, AXE, Xstart, Xstop)

set(TXlegend,'string','');
axes(AXE), cla(AXE), hold off
patch([Xstart, Xstart, Xstop, Xstop], [0, 1, 1, 0],[1 1 1]);
axis([Xstart Xstop 0 1]);
