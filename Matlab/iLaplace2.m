syms a b s t;
F = s/(s + a)/(s + a)/(s + b);
f_t = ilaplace(F, t)