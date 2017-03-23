t = -100:0.1:5000;
taof = 2000;
tao1 = 50;
tao2 = 25;


% Q = 10fC, Cf = 400fF
%Q/Cf = 1/40
Q = 10;
Cf = 400;
%R2 = 250k R1 = 20k
%R2/R1 = 12.5
R2dR1 = 12.5;
a2 = 1.0/taof;
b2 = 1.0/tao1;
c2 = 1.0/tao2;

Vref = 2.2;
v3 = -R2dR1*Q/Cf/tao2*((b2*exp(-t.*b2))/((a2 - b2)*(b2 - c2)) - (a2*exp(-t.*a2))/((a2 - b2)*(a2 - c2)) - (c2*exp(-t.*c2))/((a2 - c2)*(b2 - c2))) + Vref;
for i = 1:1:1000
    v3(i) = Vref;
end
[Minn, k] = min(v3);
plot(t,v3);
Miny = Minn - 0.05;
axis([-100 500 Miny 2.25]);
%text(k-1000,Minn,'test');
textout = sprintf('Min voltage is %.3f, Position:%.3fns',Minn,(k-1000)/10);
text((k-1000)/10+5,Minn,textout);
xlabel('Time Scale ns');
ylabel('V');
%legend('Q=10fC,\tau_1 =50ns, \tau_2 = 25ns, V_r_e_f = 2.2V')
legend(textout)