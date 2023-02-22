function sortedMatrix=sort_matrix_ref_header(orderIndices,myHeader)
% Sort myHeader as a function of orderIndices
% myHeader and orderIndices should have the same number of columns

[unused sortedIndices] = sortrows(orderIndices',1);
sortedMatrix = myHeader(sortedIndices);