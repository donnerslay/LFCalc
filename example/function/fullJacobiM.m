function [d_deltaP_d_theta,d_deltaP_d_U,...
          d_deltaQ_d_theta, d_deltaQ_d_U] = fullJacobiM(M_p, M_q)
% Creating the full jacobi-Matrix acc. to matrix p and q, see p. 192-193 EVS1
% with Area A B C D
% Args:
%     param1 (Matrix): Name of table
%     param2 (Matrix): colum value as condition
% 
% Returns:
%     Matrix: all four elements of Jacobi-Matrix
% 
% Examples:
%     >>> [d_deltaP_d_theta,d_deltaP_d_U, d_deltaQ_d_theta, d_deltaQ_d_U] = ...
%         jacobiM(M_p, M_q)


%   Detailed explanation goes here
  d_deltaP_d_theta = zeros(3, 3);
  d_deltaP_d_U = zeros(3, 3);
  d_deltaQ_d_theta = zeros(3, 3);
  d_deltaQ_d_U = zeros(3, 3);

  for i = 1:3
    for j = 1:3
      if i ~= j
        % d(deltaP)/d(theta)
        d_deltaP_d_theta(i, i) = d_deltaP_d_theta(i, i) - M_q(i, j); 
        d_deltaP_d_theta(i, j) = M_q(i, j); 
        
        % d(deltaP)/d(U)
          % we enter loop twice so only half of the 2*pii
          % todo: we have to adjust the multiply factor acc. to matrix size
          % here is only for special case with m-size = 3x3
        d_deltaP_d_U(i, i) = d_deltaP_d_U(i, i) + 2*M_p(i,i)/2 + M_p(i, j);
        d_deltaP_d_U(i, j) = M_p(i, j); 

        % d(Q)/d(theta)
        d_deltaQ_d_theta(i, i) = d_deltaQ_d_theta(i, i) + M_p(i, j);
        d_deltaQ_d_theta(i, j) = -M_p(i, j); 

        % d(Q)/d(theta)
          % we enter loop twice so only half of the 2*qii
          % see comment line 32!
        d_deltaQ_d_U(i, i) = d_deltaQ_d_U(i, i) + 2*M_q(i, i)/2 + M_q(i, j);
        d_deltaQ_d_U(i, j) = M_q(i, j); 
      end
    end
  end
end