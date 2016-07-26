function totaldistance = CalculateTotalDistance (solusi , distancematrix,c1,pun,v,g,lg)
numberofjourney = numel (solusi) - 1;
totaldistance = 0 ;
b=0;
for kk = 1 : numberofjourney
    b = b + distancematrix (solusi (kk), solusi (kk+1))/v;
    totaldistance = totaldistance + c1*g(solusi (kk+1)) + pun*max((b-lg(solusi (kk+1))),0);
end
