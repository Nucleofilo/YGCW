% Description: converts nx2 x and y matrices into nx5 matrices of their
% closed rectangles given by the intervals [xmin, xmax], [ymin, ymax]
% where n are the rows containing different rectangles   
%  USAGE:  
% Durante, 2018
%       [cux, cuy] = muadro([x1, x2], [y1, y2]);
%
function [cux, cuy] = muadro(x, y)
     for i = 1 : size(x, 1)
         cux(i, :) = [x(i, 1), x(i, 1), x(i, 2), x(i, 2), x(i, 1)];
         cuy(i, :) = [y(i, 1), y(i, 2), y(i, 2), y(i, 1), y(i, 1)];
     end  
end