%遗传算法 VRP 问题 Matlab实现

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc
load matlab.mat
Sup_Parent=[3 6 7 17 18 5 8 16 19 15 26 25 4 27 29 2 9 14 20 28 30 31 13 22 21 24 11 12 23 10]-1;
G=100;%种群大小
Parent=rand(G,30);%随即父代
for i=1:G
[m n]=sort(Parent(i,:));                                                                                       %初始化数据
Parent(i,:)=n;
end
Pc=0.8;%交叉比率
Pm=0.2;%变异比率
species=[Sup_Parent;Parent];%种群
children=[];%子代
%fitness_value(4070,1)=0;%适应值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g=input('更新时代次数:');
for generation=1:g 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parent=species;%子代变成父代
children=[];%子代
%选择交叉父代
[n m]=size(Parent);
% select=rand(1,n)<Pc;
% select=find(select==1);
                                                                                                                %交叉
for i=1:n
    for j=i:n
        if i~=j & rand<Pc
            jiaocha
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:n
    if rand<Pm
    parent=Parent(i,:);%变异个体
    X=floor(rand*30)+1;
    Y=floor(rand*30)+1;
    Z=parent(X);
    parent(X)=parent(Y);
    parent(Y)=Z;                                                                                                 %变异
    children=[children;parent];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%计算子代适应值
[m n]=size(children);
fitness_value_c=zeros(m,1);%子代适应值
for i=1:m
    l1=1;
    for l2=1:n
        if sum(data(children(i,l1:l2),3))>25
            fitness_c
            l1=l2;
        end
        if l2==n
            l2=l2+1;
            fitness_c
        end
                                                                                                                  %计算适应值
        
    
    end
end
%计算父代适应值
[m n]=size(Parent);
fitness_value_P=zeros(m,1);%父代适应值
for i=1:m
    l1=1;
    for l2=1:n
        if sum(data(Parent(i,l1:l2),3))>25
            fitness_P
            l1=l2;
        end
        if l2==n
            l2=l2+1;
            fitness_P
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%淘汰子代
[m n]=sort(fitness_value_c);
children=children(n(1:G),:);
fitness_value_c=fitness_value_c(n(1:G));
%淘汰父代
[m n]=sort(fitness_value_P);
Parent=Parent(n(1:G),:);
fitness_value_P=fitness_value_P(n(1:G));
%淘汰种群
species=[children;Parent];
fitness_value=[fitness_value_c;fitness_value_P];
[m n]=sort(fitness_value);
species=species(n(1:G),:);
fitness_value=fitness_value(n(1:G));                                                                             %更新世代


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
species(1,:)%最优线路
fitness_value(1)%最优费用