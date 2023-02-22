function [col] = get_column(NAME, data_header)
% return the column number of the data matrix by comparing NAME with strings in data_header
% INPUT:
% - NAME of the parameter (string)
% - data_header header of the matrix containing the parameter
% OUTPUT:
% - column number where the param is

col = find(strcmp(data_header, NAME));

