function C = mycolor

colormatrix=[];
[color_head,text_column_cell_array,colormatrix] = load_data_file('G_colormap.txt',0,10)
C = usercolormap(colormatrix, 1);


