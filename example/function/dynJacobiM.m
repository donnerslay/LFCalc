function J = dynJacobiM(A,B,C,D,idxP,idxQ)
% This function create a jacobi-Matrix acc. to input size of the system
% The full jacobi-Matrix of the whole system must be calculated in advance!
% There will be four matrixs depends on the system size:
% A: dP/dtheta, B: dP/dU, C: dQ/dtheta, D: dQ/dU
% final matrix: [A B
%                C D]

% Args:
%     param1 (Matrix): pre-calculated dP/dthata
%     param2 (Matrix): pre-calculated dP/dUa
%     param3 (Matrix): pre-calculated dQ/dtheta
%     param4 (Matrix): pre-calculated dQ/dU
%     param5 (Matrix): index of the PQ-nodes
%     param6 (Matrix): index of the PV-nodes
% 
% Returns:
%     Matrix: final jacobi-Matrix for LF-Calculation
% 
% Examples:
%     >>> [d_deltaP_d_theta,d_deltaP_d_U, d_deltaQ_d_theta, d_deltaQ_d_U] = ...
%         jacobiM(M_p, M_q)

%% define the size of the final output
matA = zeros(size(idxP, 2), size(idxP, 2));
matB = zeros(size(idxP, 2), size(idxQ, 2));
matC = zeros(size(idxQ, 2), size(idxP, 2));
matD = zeros(size(idxQ, 2), size(idxQ, 2));

%% assgine the value to ABCD
for i = 1:size(idxP, 2)
  for j = 1:size(idxP, 2)
    matA(i,j) = A(idxP(i), idxP(j));
  end
end

for i = 1:size(idxP, 2)
  for j = 1:size(idxQ, 2)
    matB(i,j) = B(idxP(i), idxQ(j));
  end
end

for i = 1:size(idxQ, 2)
  for j = 1:size(idxP, 2)
    matC(i,j) = C(idxQ(i), idxP(j));
  end
end

for i = 1:size(idxQ, 2)
  for j = 1:size(idxQ, 2)
    matD(i,j) = D(idxQ(i), idxQ(j));
  end
end

J = [matA, matB; matC, matD];

end

