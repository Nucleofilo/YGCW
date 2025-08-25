function dy=MicroCat(x0,y0,xt,yt)
%function dy=czcm(x0,y0,xt,yt)

%make x-vector
% x=[x0 x0 x0 x0+0.05*xt x0+0.05*xt x0+0.1*xt x0 x0];

%make y-vector
% y=[y0-0.5*yt y0+0.5*yt y0-0.25*yt y0-0.25*yt y0+(0.25-0.1)*yt  y0+.25*yt  y0+.25*yt y0+0.5*yt];
% fill(x,y,[0.2930         0    0.5078]); hold on

sc = scatter(x0, y0, '^b', 'markerfacecolor', 'b', 'SizeData', 90);
sc.MarkerFaceAlpha = 0.5;

% plot(x0+[0.15 1.1]*xt,y0+[0.2 0.2]*yt, '--k', x0+[0.15 1.1]*xt,y0+[0.2 0.4]*yt, '--k', x0+[0.15 1.1]*xt,y0+[0.2 0]*yt, '--k');
%text(xt(2),y0,'Corrientimetro + Termistor','fontsize',8,'fontwei','demi')

dy=1;


