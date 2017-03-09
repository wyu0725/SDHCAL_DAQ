tao_f = 2000;
t = -1:0.1:20000;
% Q = 10fC, Cf = 400fF
%Q/Cf = 1/40
Q = 10;
Cf = 400;
v1 = Q/Cf*exp(-t./tao_f);
for i = 1:1:100
    v1(i) = 0;
end
[Maxx, l] = max(v1);
plot(t,v1);
axis([-1000 inf 0 0.03]);
xlabel('Time Scale ns');
ylabel('V');
legend('Asumme the input charge is 10fC  \tau_f = 2000ns');