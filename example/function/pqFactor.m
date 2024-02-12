function [M_p,M_q] = pqFactor(M_Y, M_theta, M_U, M_phi)
%PQFACTOR calculating the p, q factor for simplfy calculation, see p.192,
%EVS1. 
% Notice: the size of output can be defined by the size of Y-Matrix
% Args:
%     param1 (Matrix): Admittance Matrix
%     param2 (Matrix): Angle-Matrix of addmitance
%     param3 (Matrix): Voltage Matrix (x, 1)
%     param4 (Matrix): Voltage phase angle matrix (x, 1)     
% 
% Returns:
%     Matrix: M_p and M_q for simplify the calculation.
% 
% Examples:
%     Calculation of a [3x3]-Addmidance matrix:
%     >>> p = pfFactor(M_Y, M_theta, M_U, M_phi)

%   Detailed explanation goes here
p = zeros(size(M_Y));
q = zeros(size(M_Y));

% calculation the pre-calculated values for helping calculation
for i = 1:3
  for j = 1:3
    % calculating some pre-calculated values
      % pii = 3*Yii*Ui²*cos(theta_ii)
    if i == j 
      p(i,j) = M_Y(i, i)*M_U(i)^2*cos(M_theta(i, i));
        % qii = 3*Yii*Ui²*sin(theta_ii)
      q(i,j) = M_Y(i, i)*M_U(i)^2*sin(M_theta(i, i));
    else
        % pij = 3*Ui*Yij*Uj*cos(phi_i-phi_j+theta_ij)
      p(i,j) = M_U(i) * M_Y(i, j) * M_U(j) * cos(M_phi(i)- M_phi(j) + M_theta(i, j));
        % qij = 3*Ui*Yij*Uj*cos(phi_i-phi_j+theta_ij)
      q(i,j) = M_U(i) * M_Y(i, j) * M_U(j) * sin(M_phi(i)- M_phi(j) + M_theta(i, j));
    end
  end
end

M_p = p;
M_q = q;

end

