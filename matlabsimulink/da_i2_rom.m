function [phee_1,phee_2]=da_i2_rom()
%%  Filter coefficients
p = 28*2;   % 2x factor to force gain to 1.0 in interpolate by 2 filter
q = 172*2;
r = 503*2;
s = 906*2;
t = 1094*2;
u = -(8*196);
v = -(8*87);

%% ROM 1
%      b4   b3   b2   b1   b0
X1 = [  v,  u,   t,  r,    p];
phee_1 = zeros(2^5,1);
for k = 0:31
    ss=dec2bin(k,5);  % binary representation of k
    for kk=1:5
        if ss(kk)=='1'
           phee_1(k+1)= phee_1(k+1)+ X1(kk); 
        end;
    end;
end;
phee_1=[phee_1;-phee_1];

%%  ROM 2

%     b3   b2   b1   b0
X2 = [v,   u,   s,    q];
phee_2 = zeros(2^4,1);
for k = 0:15
    ss=dec2bin(k,4);  % binary representation of k
    for kk=1:4
        if ss(kk)=='1'
           phee_2(k+1)= phee_2(k+1)+ X2(kk); 
        end;
    end;
end;
phee_2=[phee_2;-phee_2];

