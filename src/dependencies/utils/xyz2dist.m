function distSequence = xyz2dist(path)
    distSequence=[0;cumsum(sqrt(diff(path(:,1)).^2+diff(path(:,2)).^2+diff(path(:,3)).^2))];
end