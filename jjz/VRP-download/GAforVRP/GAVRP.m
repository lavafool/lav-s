%�Ŵ��㷨 VRP ���� Matlabʵ��

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc
load matlab.mat
Sup_Parent=[3 6 7 17 18 5 8 16 19 15 26 25 4 27 29 2 9 14 20 28 30 31 13 22 21 24 11 12 23 10]-1;
G=100;%��Ⱥ��С
Parent=rand(G,30);%�漴����
for i=1:G
[m n]=sort(Parent(i,:));                                                                                       %��ʼ������
Parent(i,:)=n;
end
Pc=0.8;%�������
Pm=0.2;%�������
species=[Sup_Parent;Parent];%��Ⱥ
children=[];%�Ӵ�
%fitness_value(4070,1)=0;%��Ӧֵ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

g=input('����ʱ������:');
for generation=1:g 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Parent=species;%�Ӵ���ɸ���
children=[];%�Ӵ�
%ѡ�񽻲游��
[n m]=size(Parent);
% select=rand(1,n)<Pc;
% select=find(select==1);
                                                                                                                %����
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
    parent=Parent(i,:);%�������
    X=floor(rand*30)+1;
    Y=floor(rand*30)+1;
    Z=parent(X);
    parent(X)=parent(Y);
    parent(Y)=Z;                                                                                                 %����
    children=[children;parent];
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�����Ӵ���Ӧֵ
[m n]=size(children);
fitness_value_c=zeros(m,1);%�Ӵ���Ӧֵ
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
                                                                                                                  %������Ӧֵ
        
    
    end
end
%���㸸����Ӧֵ
[m n]=size(Parent);
fitness_value_P=zeros(m,1);%������Ӧֵ
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
%��̭�Ӵ�
[m n]=sort(fitness_value_c);
children=children(n(1:G),:);
fitness_value_c=fitness_value_c(n(1:G));
%��̭����
[m n]=sort(fitness_value_P);
Parent=Parent(n(1:G),:);
fitness_value_P=fitness_value_P(n(1:G));
%��̭��Ⱥ
species=[children;Parent];
fitness_value=[fitness_value_c;fitness_value_P];
[m n]=sort(fitness_value);
species=species(n(1:G),:);
fitness_value=fitness_value(n(1:G));                                                                             %��������


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
species(1,:)%������·
fitness_value(1)%���ŷ���