clear all;
clc;
%% add the path of functions

fucPath = './function';
clsPath = './class';
addpath(fucPath, clsPath);
userpath(pwd);
disp('NR laod flow for 3 bus systhetaem\n');
%% global configuration

minError = 1e-4; % define the minimal error
maxStep = 20; % define the max steps
%% definding the matrix
% check the dimension of final matrix

% definning thetahe y bus
Y11 = 14; Y12 = 10; Y13 = 4;
Y21 = 10; Y22 = 15 ; Y23 = 5;
Y31 = 4; Y32 = 5; Y33 = 9;

% nebendiagnoal: negative Summe alle längstadmiidatanz
% hauptdiagnoal: positive Summe alle dran geschlossenen Admittanz
% Vorsicht: die o.g. Addmitanz ohne Vorzeichen! Alles Positive
% d.h. Yij hat negitive Addmitanzwinkel. S. 191 EVS1
theta11 = pi/2; theta12 = -pi/2; theta13= -pi/2;
theta21 = -pi/2; theta22 = pi/2; theta23 = -pi/2;
theta31 = -pi/2; theta32 = -pi/2; theta33= pi/2;

% voltage matrix
M_U = ones(3, 1);
% phi matrix (voltage angle) of voltage
M_phi = zeros(3, 1);
M_P = ones(3, 1);
M_Q = zeros(3, 1);

% create the Y and theta matrix
% M_Y = createMatrix(3, 3, 'Matrix of Addmitanz');
% M_theta = createMatrix(3, 3, 'Matrix of Theta (for admittanz)');
M_Y = [Y11, Y12, Y13;
       Y21, Y22, Y23;
       Y31, Y32, Y33]

M_theta = [theta11, theta12, theta13;
           theta21, theta22, theta23;
           theta31, theta31, theta33]
%% defining the initial states

% defining thetahe know sthetaathetaes
% M_phi(1,1) = 0; M_U(1,1) = 1.0; M_U(3,1) = 1.01;

% define node 1, 2, 3
node1 = node("Slack", 1.0, 0, 1);
node2 = node("PQ", -0.9, -0.5, 2);
node3 = node("PV", (1.3-0.7), 1.01, 3)

% defining thetahe power injecthetaions
% Vorsicht: LF-calculation base on 3-phase, so the value in jacobin is
% treated as sigal phase, that means, by given the initial value first 
% use singel phase, then times 3 - No! I change it to per unit...
vars = whos;
lObj = {};
% loop all nodes
for i = 1:numel(vars)
  % check if the variable is an object of class node
  if strcmp(vars(i).class, 'node')
    % append it to list
    lObj{end+1} = eval(vars(i).name);
  end
end

% predefine the initial values of unkonws
% % todo: create loop to do that
iSlackAmount = 0;
iPQAmount = 0;
iPVAmount = 0;

for i = 1:numel(lObj)
  if lObj{i}.sType == "Slack"
    lObj{i} = lObj{i}.setVal('p_pu', 1.0);
    lObj{i} = lObj{i}.setVal('q_pu', 0);
    iSlackAmount = iSlackAmount + 1;

  elseif lObj{i}.sType == "PQ"
    lObj{i} = lObj{i}.setVal('voltage_pu', 1.0);
    lObj{i} = lObj{i}.setVal('phi_rad', 0);
    iPQAmount = iPQAmount + 1;

  else
    lObj{i} = lObj{i}.setVal('phi_rad', 0);
    lObj{i} = lObj{i}.setVal('q_pu', 0);
    iPVAmount = iPVAmount + 1;

  end
end


% node1 = node1.setVal('p_pu', 1.0);
% node1 = node1.setVal('q_pu', 0);
% node2 = node2.setVal('voltage_pu', 1.0);
% node2 = node2.setVal("phi_rad", 0);
% node3 = node3.setVal('phi_rad', 0);
% node3 = node3.setVal('q_pu', 0);

% define unknow acc. to nodes information
% notice: first P-relevent then Q-relevant for better present
nodeAmount = 2*iPQAmount+iPVAmount
X_cell = {}; % for dynamic passing the elements
idxPQ_cell = {}; % for sort the fx function elements
idxPV_cell = {}; % for sort the fx function elements
for i = 1:numel(lObj)
  if (lObj{i}.sType == "PV")||(lObj{i}.sType == "PQ")
    X_cell{end+1} = lObj{i}.phi_rad;
    idxPQ_cell{end+1} = lObj{i}.index;
  else
    % slack node do nothing
  end
end

for i = 1:numel(lObj)
  if lObj{i}.sType == "PQ"
    X_cell{end+1} = lObj{i}.voltage_pu;
    idxPV_cell{end+1} = lObj{i}.index;
  else
    % slack node do nothing
  end
end

% main order: phi, second order: U and node
% node1:PV, node2:PQ, node3:PV, node4:PV
% e.g. [node1.phi; node2.phi; node3.phi; node4.phi; node2.U]
X = transpose(cell2mat(X_cell));

if size(X) ~= [nodeAmount,1]
   msg = sprintf(['the Size of unknown matrix %f is not compatible' ...
                  'with the theroretical node Amount %d'], size(x), nodeAmount);
   error(msg);
end


% create Matrix U and phi
% todo: later automatic it.
for i = 1:numel(lObj)
  M_U(i,1)=lObj{i}.voltage_pu;
  M_phi(i,1)=lObj{i}.phi_rad;
  M_P(i,1)=lObj{i}.p_pu;
  M_Q(i,1)=lObj{i}.q_pu;
end

% M_phi(2,1)=0; M_phi(3,1)=0;  
% M_U(2,1) = 1.0;
%% jacobi-matrix
% pre define the helping calculators...

[p, q] = pqFactor(M_Y, M_theta, M_U, M_phi);
%% calculating Elements of Jacobi-Matrix
% d(delta_Pi)/d(theta_i)

[d_deltaP_d_theta,d_deltaP_d_U, d_deltaQ_d_theta, d_deltaQ_d_U] = ...
fullJacobiM(p, q);
%% roll the dice

% define the condition of iteration
step = 1;
IterError = 1;
disp(X);
% convert the index of nodes for identify the PQ, PV information
% this information will be used for dynamic creation of jacobiM
matIdxP = cell2mat(idxPQ_cell);
matIdxQ = cell2mat(idxPV_cell);

% let's rockin roll !
while (abs(IterError) > minError)
  str = sprintf('step: %i', step);
  % break for devergence
  if step > maxStep
    break;
  end
  % update the p, q and Jacobi Matrix
  if step > 1
    [p, q] = pqFactor(M_Y, M_theta, M_U, M_phi);

    [d_deltaP_d_theta,d_deltaP_d_U, d_deltaQ_d_theta, d_deltaQ_d_U] = ...
    fullJacobiM(p, q);
  end
  
  % update the search function fx by assgine new p and q values
  % Notice: this part must be inside of the iteration!!! Don't do
  % stupied things....
  fpx_cell = {};
  fqx_cell = {};
  for i = 1:numel(lObj)
    % here must be also automatic, 1 2 3 works only with 3x3
    fpx_cell{end+1} = (p(lObj{i}.index,1) +...
                        p(lObj{i}.index,2) +...
                        p(lObj{i}.index,3)) - M_P(lObj{i}.index,1);
    fqx_cell{end+1} = (q(lObj{i}.index,1) +...
                        q(lObj{i}.index,2) +...
                        q(lObj{i}.index,3)) - M_Q(lObj{i}.index,1);
  end
  
  matFpx = zeros(size(idxPQ_cell,2),1);
  matFqx = zeros(size(idxPV_cell,2),1);

  for i = 1:numel(idxPQ_cell)
    matFpx(i,1) = fpx_cell{idxPQ_cell{i}};
  end

  for i = 1:numel(idxPV_cell)
    matFqx(i,1) = fqx_cell{idxPV_cell{i}};
  end

  fx = [matFpx; matFqx];

  % use idx-Array to select the elements from jacobiM.m
  J = dynJacobiM(d_deltaP_d_theta, d_deltaP_d_U,...
                 d_deltaQ_d_theta, d_deltaQ_d_U,...
                 matIdxP, matIdxQ);

  % check size of fx and create empty J-Matrix
  JSize = zeros(size(fx, 1), size(fx, 1));

  % check if the jacobi-Matrix was properly calculated
  if size(JSize) ~= size(J)
    msg = sprintf(['the size of the output jacobi matrix from dynJacobiM \n' ...
                   '%dx%d dosent fit the calcualted size %dx%d'], size(JSize), size(J));
    error(msg);
  end


  % NR ithetaerathetaion -clculathetaion of correcthetaions
  X = X - J\fx; 
  
  IterError = X(3)- M_U(2,1);

  % M_phi(1,1) = X(1);
  M_phi(2,1) = X(1); 
  M_phi(3,1) = X(2); 
  % M_U(1,1) = X(4);
  M_U(2,1) = X(3);
  % M_U(3,1) = X(6);
  
  step = step +1;

  disp(X);

end

disp('v2');
disp(M_U(2,1));
disp('delta2');
disp(M_phi(2,1)*180/pi);
disp('delta3');
disp(M_phi(3,1)*180/pi);
disp(fprintf('%i', step));

%% reassgine the value to corresponding notes
% todo: automatic it
node2 = node2.setVal("phi_rad", X(1));
node3 = node3.setVal("phi_rad", X(2));
node2 = node2.setVal("voltage_pu", X(3));

%% recalculate the p, q at notes
% formular (8.22) EVS1
[Mp,Mq] = calcPQ(node1, node2, node3, M_Y, M_theta);