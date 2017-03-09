t = -100:0.1:5000;
%prompt = {'Input the Charge(fC):','Input C1 (pF)(0.32pF,0.96pF,2.24pF):','Input C2 (fF)(100fF,300fF,700fF):','Input Vref(V)(Default:2.2V):'};
prompt = {'Input the Charge(fC):','Input sw_lg<0> :','Input sw_lg<1>:','Input Vref(V)(Default:2.2V):'};
dlg_title = 'Input the parameter';
answer = inputdlg(prompt,dlg_title);
% taof = 2000;
%tao1 = 25;
% Q = 10fC, Cf = 400fF
%Q/Cf = 1/40
Q = str2double(answer{1});
sw_lg0 = str2double(answer{2});
sw_lg1 = str2double(answer{3});
Vref = str2double(answer{4});
Cf = 400;
C1 = 0.32 + sw_lg0*0.64 + sw_lg1*1.28;
C2 = 100 + sw_lg0*400 + sw_lg1*200;
%R2 = 250k R1 = 80k
R2dR1 = 250.0/80.0;
%R2/R1 = 12.5
tao1 = 80*C1;
taof = 2000;
tao2 = 0.25*C2;
a1 = 1.0/tao1;
b1 = 1.0/taof;
c1 = 1.0/tao2;
if(tao1 == tao2)
    v2 = -R2dR1*Q/Cf/tao1*((b1*exp(-t.*a1))/(a1 - b1)^2 - (b1*exp(-t.*b1))/(a1 - b1)^2 + (t.*a1.*exp(-t.*a1))/(a1 - b1)) + Vref;
else
    v2 = -R2dR1*Q/Cf/tao2*((b1*exp(-t.*b1))/((a1 - b1)*(b1 - c1)) - (a1*exp(-t.*a1))/((a1 - b1)*(a1 - c1)) - (c1*exp(-t.*c1))/((a1 - c1)*(b1 - c1))) + Vref;
end
for i = 1:1:1000
    v2(i) = Vref;
end
[Min1, min_t] = min(v2);
[Max1, max_t] = max(v2);
plot(t,v2);
Max_v = Max1 - Min1;
Delt_v = Max_v/10;
Miny = Min1 - Delt_v;
Maxy = Max1 + 4*Delt_v;
Maxx = 15*max(tao1,tao2);
axis([-50 Maxx Miny Maxy]);

textout = sprintf('Min voltage is %.3fV, Position:%.3fns, \\DeltaV : %.3fV',Min1,(min_t-1000)/10,Vref-Min1);
text((min_t-1000)/10+5,Min1,textout);
xlabel('Time Scale ns');
ylabel('V');
legendout = sprintf('Q = %.1ffC, V_r_e_f = %.2fV \n\\tau_1 = %.1fns, \\tau_2 = %.1fns, \\tau_f = %.0fns',Q, Vref, tao1, tao2, taof);
legend(legendout);