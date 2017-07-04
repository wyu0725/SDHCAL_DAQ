function [ Charge ] = Voltage2Charge( Voltage)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
    p1 = 0.002217870966891;
    p2 = 3.444850897183087e-05;
    if(Voltage <= 0.882960035387687)
        Charge = (Voltage - p2)/p1;
    elseif(Voltage <= 0.95316)
        Charge = (Voltage - 0.88296)/0.001404 + 400;
    else
        Charge = (Voltage - 0.9532)/0.000956 + 450;
    end    
end

