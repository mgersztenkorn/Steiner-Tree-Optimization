function rVal=totalDistance(points,weights,edges)
%Given inputs of a matrix of points, the optimal selection of edges to create
%a spanning tree, and the list of all the edges and their lengths, returns
%the sum of included edge lengths.

rVal=0;
for i=1:length(edges)
    rVal=rVal+eDist(points(weights(edges(i),1),:),points(weights(edges(i),2),:));
end