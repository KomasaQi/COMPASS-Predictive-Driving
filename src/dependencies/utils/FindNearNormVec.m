function nearNormVec=FindNearNormVec(vec,targetVec)
NormVec{1}=rotate(vec,pi/2);
NormVec{2}=rotate(vec,-pi/2);
for i=1:2
    if sum(NormVec{i}.*targetVec)>0
        nearNormVec=NormVec{i};
        break;
    end
end

end

function vec1 = rotate(vec0,th)
vec1(1)=cos(th)*vec0(1)-sin(th)*vec0(2);
vec1(2)=sin(th)*vec0(1)+cos(th)*vec0(2);
end