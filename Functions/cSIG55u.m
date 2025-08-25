function dy=cSIG55u(x0,y0,xt,yt)
%function dy=c324(x0,y0)
%M4 plot ADCP and large float 47" diametre
%make circle of radius 1
a=30;
ang=linspace(-pi,pi,a);
x=sin(ang)*0.3; x=x*xt;
y=cos(ang)*0.3; y=y*yt;
% now plot float
fill(x+x0,y+y0,[0.1328    0.5430    0.1328]);hold on

%make x-vector
x=[x0 x0+0.1*xt x0+0.1*xt x0 x0-0.1*xt x0-0.1*xt x0 ];
x1=[x0-0.2*xt x0+0.2*xt x0 x0-0.2*xt];
x2=[x0+.1*xt x0+.4*xt; x0+.1*xt x0+.55*xt; x0+.1*xt x0+.7*xt];
x3=[x0-.1*xt x0-.4*xt; x0-.1*xt x0-.55*xt; x0-.1*xt x0-.7*xt];

%make y-vector
y=[y0-0.3*yt y0-0.3*yt y0+0.3*yt y0+.3*yt y0+0.3*yt y0-0.3*yt y0-.3*yt];
y1=[y0+0.3*yt y0+0.3*yt y0+0.38*yt y0+0.3*yt];
y2=[y0+.365*yt y0+1.1*yt; y0+.365*yt y0+1.1*yt; y0+.365*yt y0+1.1*yt];

% plot ADCP
fill(x,y,[0.1953    0.8008    0.1953])
fill(x1,y1,[0.1953    0.8008    0.1953])
plot([x0 x0],[y0-0.5*yt y0-.3*yt],'-k',[x0 x0],[y0+.38*yt y0+.5*yt],'-k',x1,y1,'-k',x2',y2','--k',x3',y2','--k')

%text(xt(2),y0,'LR-up+MCT+Fl47','fontsize',8,'fontwei','demi')

dy=1;
