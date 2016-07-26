
% the procedure of ant colony algorithm for VRP
%
% % % % % % % % % % %

%initialize the parameters of ant colony algorithms
clc;clear all;
load datatest.txt;
d=datatest(:,2:3);
d=d*pi/180;
ld=length(d(:,1));
g=datatest(:,4); %订单需求
lg=datatest(:,5);%时间窗要求
load pairs.txt;
shop=pairs(length(pairs(:,1)));
pairs(:,2)=pairs(:,2)+shop;
con=ld-shop;
big=100;

m=ld; % 蚂蚁数
NC=1; %迭代次数
alpha=1;
belta=2;% 决定tao和miu重要性的参数
rou=0.75; %衰减系数
q0=0.7; %概率
tao0=1/(m*13); %初始信息素
Q=1; % 蚂蚁循环一周所释放的信息素
defined_phrm=tao0; % initial pheromone level value
QV=10; % 订单容量
A=[];
ind=[];
v=5;%速度
pun=3;%惩罚系数
c1=6;%配送单价格


% 计算两点的距离
for i=1:ld
for j=1:ld
dist(i,j)= real(6370*acos(sin(d(i,2))*sin(d(j,2))+cos(d(i,2))*cos(d(j,2))*cos(d(j,1)-d(j,1))));
if (size(find(sum(abs(ones(size(pairs,1),1)*[i,j]-pairs)')'==0),1)) 
    ind(i,j)=1;
else
    ind(i,j)=0;
end
if i==j&&(i<shop+1)
    ind(i,j)=1;
end;
end;
end;

%给tao miu赋初值
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

best_cost_temp=100000*ones(shop,1);
best_cost=100000;

for n_gen=1:NC
    part_sol=[];
    final_sol=[];
cc=[];
cur_pos=[];
cost=zeros(m,shop);
temp=zeros(shop,big);
best_solution_temp=zeros(shop,big);
S=randperm(shop);
%print_head(n_gen);
for si= 1:shop
for i=1:m

%print_head2(i);
sumload=0;
cur_pos(i)=S(si);

rn=1:ld; %产生随机序列
rn_temp=(1-ind(S(si),rn)).*rn;
rn=setdiff(rn,rn_temp);
if si>1
    rn=setdiff(rn,best_solution_temp(1:si-1,:));
end
rn= rn(randperm(length(rn)));

n=1;
nn=1;
part_sol(nn)=S(si);
n_sol=0; % 由蚂蚁产生的路径数量
t=0; %最佳路径数组的元素数为0


while sumload<=QV;

for k=1:length(rn)%提取剩余可用配送点
if sumload+g(rn(k))<=QV;
    A(n)=rn(k);
    n=n+1;
end;
end;

p=compute_prob_md(A,cur_pos(i),tao,alpha,belta,part_sol,v,pun,c1,g,lg,S(si));
maxp=0;
na=length(A);
for j=1:na
if p(j)>maxp;
maxp=p(j);
index_max=j;
end;
end;%p最大下标

old_pos=cur_pos(i);%地点转移

if rand(1)<q0;
cur_pos(i)=A(index_max);
else
krnd=randperm(na);
cur_pos(i)=A(krnd(1));
bbb=[old_pos cur_pos(i)];
ccc=[S(si) S(si)];
if bbb==ccc;%防止0长度路径
cur_pos(i)=A(krnd(2));
end;
end

tao(old_pos,cur_pos(i))=taolocalupdate(tao(old_pos,cur_pos(i)),rou,tao0);%对所经弧进行局部更新

sumload=sumload+g(cur_pos(i));

nn=nn+1;
part_sol(nn)=cur_pos(i);%构建停靠路线
temp_load=sumload;

if cur_pos(i)~=S(si);
rn=setdiff(rn,cur_pos(i));%移除已用配送点
rn=rn(randperm(length(rn)));
n=1;
A=[];
end;

if cur_pos(i)==S(si); % 如果当前点为车场,将当前路径中的已访问用户去掉后,开始产生新路径
if isempty(setdiff(part_sol,S(si)))==0;
    n_sol=n_sol+1; 

% 对所得路径进行路径内2-opt优化
final_sol=Perform2Opt_md(part_sol);

 
for nt=1:length(final_sol)% 将所有产生的路径传给一个数组
temp(si,t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;
cc(n_sol)=CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg);

sumload=0;
final_sol=setdiff(final_sol,S(si));
rn=setdiff(rn,final_sol);
part_sol=[];
final_sol=[];
nn=1;
part_sol(nn)=cur_pos(i);
A=[];
n=1;

end;
end

if isempty(setdiff(rn,S(si)))==1;% 产生最后一条终点不为起点的路径
    n_sol=n_sol+1;
    nl=length(part_sol); 
    part_sol(nl+1)=S(si);%将路径的最后1位补起点

% 对所得路径进行路径内2-opt优化
final_sol=Perform2Opt_md(part_sol);

for nt=1:length(final_sol); % 将所有产生的路径传给一个数组
temp(si,t+nt)=final_sol(nt);
end;
t=t+length(final_sol)-1;

cost(i,si)=sum(cc)+CalculateTotalDistance(final_sol,dist,c1,pun,v,g,lg); %计算由蚂蚁i产生的路径总长度

cc=[];
cvt=[];
cvt=temp(si,:);
cvt(cvt==0)=[];
for ki=1:length(cvt)-1
deltao(cvt(ki),cvt(ki+1))=deltao(cvt(ki),cvt(ki+1))+Q/cost(i,si);
end;

%更新以商店S(si)为起点的m只蚂蚁产生的最优路径
if cost(i,si)<best_cost_temp(si);
best_cost_temp(si)=cost(i,si);
best_solution_temp(si,:)=temp(si,:);
end;

%更新n_gen代最优结果
if si==shop&& sum(best_cost_temp)<best_cost;
best_cost=sum(best_cost_temp);
best_gen=n_gen; % 产生最小费用的代数
best_solution=best_solution_temp;
end;

%如果所有蚂蚁均完成一次循环，，则用最佳费用所对应的路径对弧进行整体更新
if si==shop&&i==m;
for ii=1:ld
for jj=1:ld
tao(ii,jj)=(1-rou)*tao(ii,jj);
end;
end;

for ss=1:shop
    bss=best_solution(ss,:);bss(bss==0)=[];
for kk=1:length(bss)-1;
tao(bss(kk),bss(kk+1))=tao(bss(kk),bss(kk+1))+rou*deltao(bss(kk),bss(kk+1));
end;
bss=[];
bc(n_gen)=sum(best_cost);
end;

fid=fopen('out_solution_md.txt','a+');
fprintf(fid,'%s %f\n','总费用是:',cost(i,si));
fprintf(fid,'------------------------------\n');
fprintf(fid,'%s\n','最终路径是:');
fprintf(fid,'%i-',temp(si,:));
fprintf(fid,'------------------------------\n');
fclose(fid);
temp=[];
end;
break;
end;

end;
end;
part_sol=[];

end;
end;
