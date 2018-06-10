function phee=da_rom()
p = 28;
q = 172;
r = 503;
s = 906;
t = 1094;
u = -(8*196);
v = -(8*87);
%   b6   b5   b4   b3   b2   b1 b0
X = [v,  u,   t,   s,   r,  q,  p];

phee = zeros(128,1);

for k = 0:127
    s=dec2bin(k,7);  % binary representation of k
    for kk=1:7
        if s(kk)=='1'
           phee(k+1)= phee(k+1)+ X(kk); 
        end;
    end;
end;
phee=[phee;-phee];