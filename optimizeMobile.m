function tD=optimizeMobile(xVar)
%A function that is designed to function alongside fminsearch to optimize
%over the mobile point coordinates, which are passed to this function.
%Total sum of edge lengths is returned to be optimized over. Global
%variables are used so that they are not considered as variables that can
%be optimized over.

global f
fullPts=[f;xVar];
global goodEdges
ptWeights=[];

%Calculate updated edge lengths.
for i=1:length(fullPts)
    for j=i+1:length(fullPts)
        ptWeights=[ptWeights;[i,j,eDist(fullPts(i,:),fullPts(j,:))]];
    end
end

%Find and return sum of edge lengths.
tD=totalDistance(fullPts,ptWeights,goodEdges);