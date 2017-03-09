syms a b c s t;
F = s/(s + a)/(s + b)/(s + c);
f_t = ilaplace(F, t)
% x = -100 : 0.1 : 5000;
% y = f_t(x);