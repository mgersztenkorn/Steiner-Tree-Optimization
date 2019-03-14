function finalPts=pruneNodes(tempSol,tempEdges,tempWeights)
%This function takes input of a proposed set of mobile points, the index
%number of the edges being included, and the weights of the full tree given
%those point locations.  It then eliminates mobile points that connect to
%only 2 other points or that are too close to a fixed point.
tolerance=10^-3;

global f
finalPts=tempSol;
fullPts=[f;tempSol];
pointCollection=[];
pointFreq=zeros(length(fullPts),1);

%Collect points into a useful format
for i=1:length(tempEdges)
    pointCollection=[pointCollection;tempWeights(tempEdges(i),1:2)];
end

%Find number of edges connected to each point
for i=1:length(fullPts)
    pointFreq(i)=sum(pointCollection(:) == i);
end

%Get a sequential list of points to delete, so that they can be deleted in
%reverse order and not cause an index error.
toDelete=[];
for i=length(f)+1:length(fullPts)
    minDistance=100;
    for j=1:length(f)
       if abs(fullPts(i)-f(j))<minDistance
           minDistance=abs(fullPts(i)-f(j));
           closestPoint=j;
       end
    end
    if pointFreq(i)<=2
        toDelete=[toDelete;i-length(f)];
    elseif eDist([fullPts(i,1),fullPts(i,2)],[f(closestPoint,1),f(closestPoint,2)])<=tolerance
        toDelete=[toDelete;i-length(f)];
    end
end

%Delete unnecessary points.
for i=1:length(toDelete)
    finalPts([toDelete(length(toDelete)+1-i)],:)=[];
end