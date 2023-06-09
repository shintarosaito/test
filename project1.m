clc
clear all
close all


f = fred
startdate = '01/01/1994';
enddate = '01/01/2022';

YJP = fetch(f,'JPNRGDPEXP',startdate,enddate);
YUK = fetch(f,'NGDPRSAXDCGBQ',startdate,enddate);
yjp = log(YJP.Data(:,2));
yuk = log(YUK.Data(:,2));
q = YJP.Data(:,1);

T = size(yjp,1);

% Hodrick-Prescott filter
lam = 1600;
A = zeros(T,T);

% unusual rows
A(1,1)= lam+1; A(1,2)= -2*lam; A(1,3)= lam;
A(2,1)= -2*lam; A(2,2)= 5*lam+1; A(2,3)= -4*lam; A(2,4)= lam;

A(T-1,T)= -2*lam; A(T-1,T-1)= 5*lam+1; A(T-1,T-2)= -4*lam; A(T-1,T-3)= lam;
A(T,T)= lam+1; A(T,T-1)= -2*lam; A(T,T-2)= lam;

% generic rows
for i=3:T-2
    A(i,i-2) = lam; A(i,i-1) = -4*lam; A(i,i) = 6*lam+1;
    A(i,i+1) = -4*lam; A(i,i+2) = lam;
end

tauJPGDP = A\yjp;
tauUKGDP = A\yuk;

% detrended GDP
yjptilde = yjp-tauJPGDP;
yuktilde = yuk-tauUKGDP;

% plot detrended GDP
dates = 1994:1/4:2022.1/4;
figure
title('Detrended log(real GDP) 1994Q1-2022Q1'); hold on
plot(q, yjptilde,'b', q, yuktilde,'r')
legend('Japan', 'United Kingdom')
datetick('x', 'yyyy-qq')

% compute sd(y), sd(c), rho(y), rho(c), corr(y,c) (from detrended series)
jpysd = std(yjptilde)*100;
ukysd = std(yuktilde)*100;
corryjpuk = corrcoef(yjptilde(1:T),yuktilde(1:T)); corryjpuk = corryjpuk(1,2);

disp(['Percent standard deviation of detrended log real GDP for Japan: ', num2str(jpysd),'.']); disp(' ')
disp(['Percent standard deviation of detrended log real GDP for United Kingdom: ', num2str(ukysd),'.']); disp(' ')
disp(['Contemporaneous correlation between detrended log real GDP for Japan and United Kingdom: ', num2str(corryjpuk),'.']);
