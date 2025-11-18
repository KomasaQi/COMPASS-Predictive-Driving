function distSequence = xy2dist(path)
    distSequence=[0;cumsum(sqrt(diff(path(:,1)).^2+diff(path(:,2)).^2))];
end