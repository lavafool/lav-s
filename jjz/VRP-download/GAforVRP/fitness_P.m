path=Parent(i,l1:l2-1);
l=length(path);
for k=1:l
    if k==1
        fitness_value_P(i)=fitness_value_P(i)+sum(data(path,3))*dis(1,path(1))*3;
    else
        fitness_value_P(i)=fitness_value_P(i)+sum(data(path(k:l),3))*dis(path(k-1),path(k))*3;
    end
        
end 
fitness_value_P(i)=fitness_value_P(i)+dis(path(l),1)*2;