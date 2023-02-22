function set_myFig(fig, w, h, x_offset, y_offset)
% Set the position of the figure depending on screen size
%
% INPUTS:
%  - fig: handle of figure
%  - is_proportional: if proportional set is required
%  - w: desired width of figure
%       - in pixel unit if > 1, otherwise is a ratio
%  - h: desired height of figure
%       - in pixel unit if > 1, otherwise is a ratio
%  - x_offset: desired distance between left side of figure and left side of screen
%  - y_offset: desired distance between up side of figure and up side of screen
%
% DISTANCES ARE IN PIXEL
%
% Figure position is defined by 4 components: X, Y, W, H
%   X - distance between left side of fig and left side of screen
%   Y - distance between bottom of fig and bottom of screen
%   W - width of fig
%   H - height of fig
%

ScreenSize =  get(0,'ScreenSize');
Xmin = 10;
Ymin = 90;

if h <= 1 && w <= 1 % proportional values for width and height
    W = (ScreenSize(3) - Xmin)*w;
    if x_offset > ScreenSize(3) - Xmin - W, x_offset = ScreenSize(3) - Xmin - W; end
    
    H = (ScreenSize(4) - Ymin)*h;
    if y_offset > ScreenSize(4) - Ymin - H, y_offset = ScreenSize(4) - Ymin - H; end
           
else % pixel values for width and height  
    if      w < ScreenSize(3) - Xmin - x_offset,  W = w;
    elseif  w < ScreenSize(3) - Xmin,             W = w; x_offset = ScreenSize(3) - Xmin - W;
    else                                          W = ScreenSize(3) - Xmin; x_offset = 0; 
    end 
    
    if      h < ScreenSize(4) - Ymin - y_offset,  H = h;
    elseif  h < ScreenSize(4) - Ymin,             H = h; y_offset = ScreenSize(4) - Ymin - H;
    else                                          H = ScreenSize(4) - Ymin; y_offset = 0; 
    end
end

X = x_offset + Xmin;
Y = ScreenSize(4) - H - y_offset - Ymin;

set(fig,'Position',[X Y W H])