
OPT=csvread('Opt_1000sims_1e-2s.csv');

OPT_flowrate=OPT(:,1);
OPT_tuberadius=OPT(:,2);
OPT_wire_tube_r_ratio=OPT(:,3);
OPT_capture_efficiency=OPT(:,4);

Flowrate_for_plot=0.67
indices_Flowrate_for_plot=find(OPT_flowrate==Flowrate_for_plot)
X=OPT_tuberadius(indices_Flowrate_for_plot);
Y=OPT_wire_tube_r_ratio(indices_Flowrate_for_plot);
Z=OPT_capture_efficiency(indices_Flowrate_for_plot)


[XX,YY] = meshgrid(X,Y);
% Z = sin(X) + cos(Y);
% surf(X,Y,Z)





X_lin=linspace(min(X),max(X),10);
Y_lin=linspace(min(Y),max(Y),10);
[XX_lin,YY_lin] = meshgrid(X_lin,Y_lin);
ZZ_lin=griddata(X,Y,Z,XX_lin,YY_lin,'linear')

figure(3)
hold on
surf(XX_lin,YY_lin,ZZ_lin)
plot3(X,Y,Z,'o','MarkerSize',10,'MarkerFaceColor','k')
alpha 0.5
hold off
set(gca,'FontSize',15,'box','on','LineWidth',1);
%legend('10 nm','50 nm','100 nm','250 nm','500 nm','Location','NorthEast')
ylabel('Tube radius [\mum]','FontSize',15)
xlabel('Wire-tube radius ratio [-]','FontSize',15)
grid on
axis tight
view(-67,20)
shading interp

















% figure(1)
% plot3(X,Y,Z,'o')
% hold off
% set(gca,'FontSize',15,'box','on','LineWidth',1);
% %legend('10 nm','50 nm','100 nm','250 nm','500 nm','Location','NorthEast')
% ylabel('Tube radius [\mum]','FontSize',15)
% xlabel('Wire-tube radius ratio [-]','FontSize',15)
% 
% 
% F = scatteredInterpolant(X,Y,Z);
% [XX,YY] = meshgrid(X,Y);
% F.Method = 'nearest';
% %F.ExtrapolationMethod = 'none';
% ZZ = F(XX,YY);
% 
% figure(2)
% hold on
% plot3(X,Y,Z,'o')
% mesh(XX,YY,ZZ)
% hold off
% set(gca,'FontSize',15,'box','on','LineWidth',1);
% %legend('10 nm','50 nm','100 nm','250 nm','500 nm','Location','NorthEast')
% ylabel('Tube radius [\mum]','FontSize',15)
% xlabel('Wire-tube radius ratio [-]','FontSize',15)
% shading interp

