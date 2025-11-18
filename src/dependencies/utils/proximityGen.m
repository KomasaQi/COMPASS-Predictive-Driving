function P=proximityGen(n)
P=rand(n)*10;
for i=1:n
    perm=randperm(n);
    perm=perm(1:round(n*0.4));
    for j=1:length(perm)
       P(i,perm(j))=inf;
    end
end
P=P+P';
for i=1:n
    P(i,i)=0;
end
end