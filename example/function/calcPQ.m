function [M_P, M_Q] = calcPQ(clsNode1,clsNode2,clsNode3,M_Y,M_theta)
%CALCPQ calculate the p and q acc. to known U and phi at every nodes and
%the addmitance matrix, see p.191, Formular 8.22 in EVS1
% Args:
%     param1 (Matrix): Name of table
%     param2 (Matrix): colum value as condition
% 
% Returns:
%     Matrix: matrix of P and Q
% 
% Examples:
%     >>> [d_deltaP_d_theta,d_deltaP_d_U, d_deltaQ_d_theta, d_deltaQ_d_U] = ...
%         jacobiM(M_p, M_q)

M_U = [clsNode1.voltage_pu;
       clsNode2.voltage_pu;
       clsNode3.voltage_pu;];
M_phi = [clsNode1.phi_rad;
         clsNode2.phi_rad;
         clsNode3.phi_rad;];

M_U_complex = M_U .* exp(1i * M_phi);
M_Y_complex = M_Y .* exp(1i * M_theta);

M_P = zeros(3,1);
M_Q = zeros(3,1);

for i = 1:3
  for j = 1:3
    if i ~= j
      % f. 8.16 in EVS1
      M_P(i, 1) = M_P(i, 1) +...
                  real(0.5*conj(M_Y_complex(i,i))*abs(M_U_complex(i,1))^2+ ...
                  M_U_complex(i,1)*conj(M_Y_complex(i,j))*conj(M_U_complex(j,1)));

      M_Q(i, 1) = M_Q(i, 1) +...
                  imag(0.5*conj(M_Y_complex(i,i))*abs(M_U_complex(i,1))^2+ ...
                  M_U_complex(i,1)*conj(M_Y_complex(i,j))*conj(M_U_complex(j,1)));
    end
  end
end

end

