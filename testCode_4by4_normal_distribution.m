%Use global variables so that they are not mistaken as variables to optimize
%in regards to and can still be changed here as opposed to hard coded in
%the function call.
global f
global goodEdges

%16-point Large Square Lattice
f=[0,0;1,0;1,1;0,1;2,0;2,1;3,0;3,1;0,2;0,3;1,2;1,3;2,2;2,3;3,2;3,3];
mCount=36;

%Initialize variables and record keeping
xVar=zeros(mCount,2);
recordPts=zeros(mCount,2);
minDistance=10^7;

%Loop to find a collection of local minima, from which the best is chosen
%as the global solution.
for iter=1:50
    %Set up random initial mobile point locations using a normal
    %distribution.  Mean is being set as average of the extremes in each
    %direction (x and y).  Standard deviation is being set at the
    %difference of these extremes divided by 7, extending the 99.7% of data
    %a little outside the boundaries, but also getting some points a bit
    %futher out from the center.
    
    for i=1:mCount
        xVar(i,1)=random('Normal',(max(f(:,1))+min(f(:,1)))/2,(max(f(:,1))-min(f(:,1)))/7);
        xVar(i,2)=random('Normal',(max(f(:,2))+min(f(:,2)))/2,(max(f(:,2))-min(f(:,2)))/7);
    end   
    
    %Forced values for 4x4 grid:
    %xVar=[.25,.5;.75,.5;2.25,.5;2.5,.5;1.25,1.5;1.75,1.5;.25,2.5;.75,2.5;2.25,2.5;2.75,2.5;.5,1.5];
    %mCount=length(xVar);  
    
    %Uniform Distribution for 4x4 grid:
    %for i=1:mCount
    %    xVar(i,1)=3*rand;
    %    xVar(i,2)=3*rand;
    %end
    
    %Lattice for 4x4 grid:
    %lattice=[0:.25:3];
    %temp=[lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice, lattice];
    %xVar=sort(temp);
    %xVar=[xVar;temp];
    %mCount=13*13;
    
    %Set up necessary data structures for grMinSpanTree, then find said
    %optimal span tree given the initial random mobile nodes.
    fullPts=[f;xVar];
    ptWeights=[];
    for i=1:length(fullPts)
        for j=i+1:length(fullPts)
            ptWeights=[ptWeights;[i,j,eDist(fullPts(i,:),fullPts(j,:))]];
        end
    end
    goodEdges=grMinSpanTree(ptWeights);
    
    %Find optimal locations of the mobile nodes based on the chosen edges
    %from grMinSpanTree.
    sol=fminsearch(@optimizeMobile,xVar);
    fullPts=[f;sol];
    
    %Calculate total length of optimized span tree.  Record best solution
    %value and point locations.
    tD=totalDistance(fullPts,ptWeights,goodEdges);
    if tD<minDistance
        recordPts=sol;
        minDistance=tD;
        recordEdges=goodEdges;
        recordWeights=ptWeights;
    end
end

%The following loop removes extra nodes and recalculates the spanning tree.
%This is being iterated because small clusters of mobile points in
%the same location fail to delete correctly otherwise (and in an extreme
%case where they are connected in a web, are not removed).  From here, the
%optimization routine is re-evaluated from a fresh set of initial
%conditions.

finalSol=recordPts;
finalEdges=recordEdges;
finalWeights=recordWeights;
for iter=1:3 %abs(mCount-length(f))
    finalSol=pruneNodes(finalSol,finalEdges,finalWeights);
    fullPts=[f;finalSol];
    finalWeights=[];
    for i=1:length(fullPts)
        for j=i+1:length(fullPts)
            finalWeights=[finalWeights;[i,j,eDist(fullPts(i,:),fullPts(j,:))]];
        end
    end
    finalEdges=grMinSpanTree(finalWeights);
    
    %Reoptimize using the post-pruning solution for initial locations.
    goodEdges=finalEdges;
    finalSol=fminsearch(@optimizeMobile,finalSol);
end

finalDistance=totalDistance(fullPts,finalWeights,finalEdges);

%Create scatter plot of points with correct connections:
clf
axis([0 3 0 3])
pbaspect([1 1 1])
hold on
scatter(fullPts(:,1),fullPts(:,2))
for i=1:length(finalEdges)
   plot([fullPts(finalWeights(finalEdges(i),1),1),fullPts(finalWeights(finalEdges(i),2),1)],[fullPts(finalWeights(finalEdges(i),1),2),fullPts(finalWeights(finalEdges(i),2),2)])    
end
hold off

%Data output
disp('The mobile points are located at:')
disp(finalSol)

disp('The best solution found gives a sum of edge lengths of:')
disp(finalDistance)