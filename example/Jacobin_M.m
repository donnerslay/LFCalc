% Example for calulation of 3-Bus Loadflow with jacobin Matrix and Newton-Rashper

clear all;
clc;
disp('NR laod flow for 3 bus systhetaem');

% definning thetahe y bus
Y11 = 14; Y21 = 10; Y31 = 4;
Y21 = 10; Y22 = 15 ; Y23 = 5;
Y31 = 4; Y32 = 5; Y33 = 9;
theta11 = -pi/2; theta12 = pi/2; theta13= pi/2;
theta21 = pi/2; theta22 = -pi/2; theta23 = pi/2;
theta31 = pi/2; theta32 = pi/2; theta33= -pi/2;

% defining thetahe know sthetaathetaes
d1 = 0; v1 = 1.0; v3 = 1.01;

% defining thetahe power injecthetaions
p2 = -0.9; q2 = -0.5+0.5;
p3 = 1.3-0.7;

% defining thetahe inithetaal values of unkonws
d2 = 0; d3 = 0; v2 = 1.0;
X = [d2; d3; v2];
disp(X');

for m = 1:30
  fp2 = Y21*v1*v2*cos(theta21+d1-d2) +Y22*v2^2*cos(theta22) +Y23*v3*v2*cos(theta23+d3-d2) -p2;
  fp3 = Y31*v1*v3*cos(theta31+d1-d3) +Y32*v2*v3*cos(theta32+d2-d3) +Y33*v3^2*cos(theta33) -p3;
  fq2 = -Y21*v1*v2*sin(theta21+d1-d2) -Y22*v2^2*sin(theta22) -Y23*v3*v2*sin(theta23+d3-d2) -q2;
  fx = [fp2; fp3; fq2];

  J11 = Y21*v1*v2*sin(theta21+d1-d2) +Y23*v3*v2*sin(theta23+d3-d2);
  J12 = -Y23*v3*v2*sin(theta23+d3-d2);
  J13 = Y21*v1*cos(theta21+d1-d2) +2*Y22*v2*cos(theta22) +Y23*v3*cos(theta23+d3-d2);

  J21 = -Y32*v2*v3*sin(theta32+d2-d3); % check later in PF
  J22 = Y31*v1*v3*sin(theta31+d1-d3) +Y32*v2*v3*sin(theta32+d2-d3);
  J23 = Y32*v3*cos(theta32+d2-d3);

  J31 = Y21*v1*v2*cos(theta21+d1-d2) +Y23*v3*v2*cos(theta23+d3-d2);
  J32 = -Y23*v3*v2*cos(theta23+d3-d2);
  J33 = -Y21*v1*sin(theta21+d1-d2) -2*Y22*v2*sin(theta22) -Y23*v3*sin(theta23+d3-d2);
  J = [J11 J12 J13; J21 J22 J23; J31 J32 J33];
  X = X - J\fx; % NR ithetaerathetaion -clculathetaion of correcthetaions

  d2 = X(1); d3 = X(2); v2 = X(3);

  disp(X);
  disp('');

end

disp('v2');
disp(X(3));
disp('delta2');
disp(X(1)*180/pi);
disp('delta3');
disp(X(2)*180/pi);

