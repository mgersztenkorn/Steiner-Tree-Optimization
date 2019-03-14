function distance=eDist(pt1,pt2)
%Find and return Euclidean distance between 2 provided points.
distance=sqrt( (pt1(1)-pt2(1))^2 + (pt1(2)-pt2(2))^2);