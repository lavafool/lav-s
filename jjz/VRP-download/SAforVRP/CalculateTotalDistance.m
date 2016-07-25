function totaldistance = CalculateTotalDistance (solusi , distancematrix)
numberofjourney = numel (solusi) - 1;
totaldistance = 0 ;
for i = 1 : numberofjourney
    totaldistance = totaldistance + distancematrix (solusi (i), solusi (i+1));
end
