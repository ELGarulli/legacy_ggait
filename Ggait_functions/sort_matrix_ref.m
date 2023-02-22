function sortedMatrix=sort_matrix_ref(orderIndices,myMatrix)
% Sort myMatrix as a function of orderIndices
% myMatrix and orderIndices should have the same number of columns

sortedMatrix = sortrows([orderIndices; myMatrix]',1);
sortedMatrix = sortedMatrix(:,2:end)';