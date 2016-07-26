
% the procedure of ant colony algorithm for VRP
%
% % % % % % % % % % %

%initialize the parameters of ant colony algorithms
clc;clear all;
load data.txt;
d=data(:,2:3);
d=d*pi/180;
ld=length(d(:,1));
g=data(:,4); %��������
lg=data(:,5);%ʱ�䴰Ҫ��
% lg=ones(ld,1);

m=ld; % ������
NC=300; %��������
alpha=1;
belta=2;% ����tao��miu��Ҫ�ԵĲ���
rou=0.9; %˥��ϵ��
q0=0.95; %����
tao0=1/(m*114); %��ʼ��Ϣ��
Q=1; % ����ѭ��һ�����ͷŵ���Ϣ��
defined_phrm=tao0; % initial pheromone level value
QV=10; % ��������
A=[];
v=10;%�ٶ�
pun=3;%�ͷ�ϵ��
c1=6;%���͵��۸�

% ��������ľ���
for i=1:ld
for j=1:ld
dist(i,j)= 6370*acos(sin(d(i,2))*sin(d(j,2))+cos(d(i,2))*cos(d(j,2))*cos(d(j,1)-d(j,1)));
if i==j;
    dist(i,j)=0;
end;
end;
end;

%��tao miu����ֵ
for i=1:ld
for j=1:ld
if i~=j;
tao(i,j)=defined_phrm;
end;
end;
end;

for i=1:ld
for j=1:ld
deltao(i,j)=0;
end;
end;

best_cost=10000;
for n_gen=1:NC

%print_head(n_gen);

for i=1:m
%best_solution=[];
%print_head2(i);
sumload=0;
cur_pos(i)=1;
rn=randperm(ld);%�����������
n=1;
nn=1;
part_sol(nn)=1;
%cost(n_gen,i)=0.0;
n_sol=0; % �����ϲ�����·������
t=0; %���·�������Ԫ����Ϊ0

while sumload<=QV;

for k=1:length(rn)%��ȡʣ��������͵�
if sumload+g(rn(k))<=QV;
A(n)=rn(k);
n=n+1;
end;
end;

fid=fopen('out_customer.txt','a+');
fprintf(fid,'%s %i\t','the current position is:',cur_pos(i));
fprintf(fid,'\n%s','the possible customer set is:');
fprintf(fid,'\t%i\n',A);
fprintf(fid,'------------------------------\n');
fclose(fid);

p=compute_prob(A,cur_pos(i),tao,alpha,belta,part_sol,v,pun,c1,g,lg);
maxp=1e-20;
na=length(A);
for j=1:na
if p(j)>maxp;
maxp=p(j);
index_max=j;
end;
end;%p����±�
if index_max>na;
    index_max=na;
end
old_pos=cur_pos(i);%�ص�ת��
if rand(1)<q0;
cur_pos(i)=A(index_max);
else
krnd=randperm(na);
cur_pos(i)=A(krnd(1));
bbb=[old_pos cur_pos(i)];
ccc=[1 1];
if bbb==ccc;%��ֹ0����·��
cur_pos(i)=A(krnd(2));
end;
end;

tao(old_pos,cur_pos(i))=taolocalupdate(tao(old_pos,cur_pos(i)),rou,tao0);%�����������оֲ�����

sumload=sumload+g(cur_pos(i));

nn=nn+1;
part_sol(nn)=cur_pos(i);%����ͣ��·��
temp_load=sumload;

if cur_pos(i)~=1;
rn=setdiff(rn,cur_pos(i));%�Ƴ��������͵�
rn=rn(randperm(length(rn)));
n=1;
A=[];
end;

if cur_pos(i)==1; % �����ǰ��Ϊ����,����ǰ·���е��ѷ����û�ȥ����,��ʼ������·��
if isempty(setdiff(part_sol,1))==0;
n_sol=n_sol+1; % ��ʾ������·����,n_sol=1,2,3,..5,6...,����5��������ü��ϳ�������ǲ����
fid=fopen('out_solution.txt','a+');
fprintf(fid,'%s%i%s','NO.',n_sol,'��·����:');
fprintf(fid,'%i ',part_sol);
fprintf(fid,'\n');
fprintf(fid,'%s','��ǰ���û���������:');
fprintf(fid,'%i\n',temp_load);
fprintf(fid,'------------------------------\n');
fclose(fid);
% ������·������·����2-opt�Ż�
final_sol=Perform2Opt(part_sol);

for nt=1:length(final_sol)% �����в�����·������һ������
temp(t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;
cc(n_sol)=CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg);

sumload=0;
final_sol=setdiff(final_sol,1);
rn=setdiff(rn,final_sol);
part_sol=[];
final_sol=[];
nn=1;
part_sol(nn)=cur_pos(i);
A=[];
n=1;
end;
end;

if isempty(setdiff(rn,1))==1;% �������һ���յ㲻Ϊ1��·��
    n_sol=n_sol+1;
nl=length(part_sol);
part_sol(nl+1)=1;%��·�������1λ��1

% ������·������·����2-opt�Ż�
final_sol=Perform2Opt(part_sol);

for nt=1:length(final_sol); % �����в�����·������һ������
temp(t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;

cost(n_gen,i)=sum(cc)+CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg); %����������i������·���ܳ���
cc=[];
for ki=1:length(temp)-1
deltao(temp(ki),temp(ki+1))=deltao(temp(ki),temp(ki+1))+Q/cost(n_gen,i);
end;

if cost(n_gen,i)<best_cost;
best_cost=cost(n_gen,i);
old_cost=best_cost;
best_gen=n_gen; % ������С���õĴ���
best_ant=i; %������С���õ�����
best_solution=temp;
end;

if i==m; %����������Ͼ����һ��ѭ����������ѷ�������Ӧ��·���Ի������������
for ii=1:ld
for jj=1:ld
tao(ii,jj)=(1-rou)*tao(ii,jj);
end;
end;

for kk=1:length(best_solution)-1;
tao(best_solution(kk),best_solution(kk+1))=tao(best_solution(kk),best_solution(kk+1))+rou*deltao(best_solution(kk),best_solution(kk+1));
end;
end;

fid=fopen('out_solution.txt','a+');
fprintf(fid,'%s%i%s','NO.',n_sol,'·����:');
fprintf(fid,'%i ',part_sol);
fprintf(fid,'\n');
fprintf(fid,'%s %i\n','��ǰ���û���������:',temp_load);
fprintf(fid,'%s %f\n','�ܷ�����:',cost(n_gen,i));
fprintf(fid,'------------------------------\n');
fprintf(fid,'%s\n','����·����:');
fprintf(fid,'%i-',temp);
fprintf(fid,'------------------------------\n');
fclose(fid);
temp=[];

break;
end;
end;
end;
end;



