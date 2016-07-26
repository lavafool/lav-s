function pp=compute_prob(AA,cur_pos0,tao0,alpha0,belta0,pt,v,pun,c1,g,lg)
cos=0;
bprob=0;
if length(pt)>1;
for a=2:length(pt)
    bprob=bprob+dist(pt(a-1),pt(a))/v;
end
end
bprob=bprob+dist(AA,pt(length(pt)))/v;
cos=(pun*max((bprob-lg(AA)),0)+c1*g(AA)+(AA==1)'*100000)';
pp=(tao0(cur_pos0,AA)).^alpha0.*(1./cos).^belta0; 