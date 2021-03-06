function ElemNeighbors = GetConnectivity_2D
% Based on Connect1D from www.nudg.org
%
% input EToN: array that defines element to node mapping
% output Neighbors: row i tells us which elements element i is
% connected to
global EToN
global VX

K = size(EToN,1);
Nfaces = size(EToN,2);
TotalFaces = Nfaces*K;
Nv = size(VX,1);

% List of local face to local vertex connections
vn = [1,2;2,3;3,1];%4 2D

% Build global face to node sparse array
SpFToN = spalloc(TotalFaces, Nv, 2*TotalFaces);

sk = 1;
for k=1:K
  for face=1:Nfaces
     SpFToN( sk, EToN(k, vn(face,:))) = 1;
     sk = sk+1;
  end
end

% Build global face to global face sparse array
SpFToF = SpFToN*SpFToN' - speye(TotalFaces);

% Find complete face to face connections, find number of nodes two faces
% share
[faces1, faces2] = find(SpFToF==2);

% Convert face global number to element and face numbers
element1 = floor( (faces1-1)/Nfaces )  + 1;
face1    =   mod( (faces1-1), Nfaces ) + 1;
element2 = floor( (faces2-1)/Nfaces )  + 1;
face2    =   mod( (faces2-1), Nfaces ) + 1;

% rearrange EToE in an Nelements x Nfaces array
% sub2ind allows us to index into ElemNeighbors using
% "1D indexing"
ind = sub2ind([K, Nfaces], element1, face1);
ElemNeighbors      = (1:K)'*ones(1,Nfaces);
ElemNeighbors(ind) = element2;

% insert -1's if an element is on a boundary
for i=1:K
    % if we have a boundary element, is_boundary should not be empty
    boundary_face_index = find(ElemNeighbors(i,:) == i);
    if boundary_face_index
        ElemNeighbors(i,boundary_face_index) = -1;
    end
end
