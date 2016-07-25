function distancematrix =  GenerateDistanceMatrix(x_coordinate, y_coordinate)
numberofcities = numel(x_coordinate);
distancematrix = zeros(numberofcities);
for i = 1 : numberofcities
    for j = 1 : numberofcities
        distancematrix(i,j)= ((x_coordinate(i)-x_coordinate(j))^2 + (y_coordinate(i) - y_coordinate (j))^2)^0.5 ;
    end
end
