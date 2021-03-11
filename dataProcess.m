x = 1:Nx;
y = 1:Ny;
[X, Y] = meshgrid(x,y);
Z = 0;

x_o = 100
y_o = 76
for i = 1:amountSources
    m = (i-1)*2+1;
    Z_t = t(1,i)-(sqrt((X-double(coordinate_set(m))).^2+(Y-double(coordinate_set(m+1))).^2)/340);
    Z_t = -Z_t;
    Z = Z+Z_t;
end

imagesc(Z)

max = 1e03;
Mx = 0;
My = 0;
for i = 1:Nx
    for m = 1:Ny
        if(Z(i,m)<max)
           max = Z(i,m);
           Mx = i;
           My = m;
        end
    end
end

sourceMask = zeros(Nx, Ny);
for i=1:length(source_set)
    sourceMask = sourceMask + source_set(i).p_mask;
end

highestMask = zeros(Nx,Ny);
highestMask(Mx,My) = 10;

originalMask = zeros(Nx,Ny);
originalMask(x_o,y_o) = 5;
figure;
subplot(1,3,1)
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, originalMask + highestMask, [0, 10]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;

subplot(1,3,2)
imagesc(Z)
colormap(getColorMap)
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;

subplot(1,3,3)
imagesc(kgrid.y_vec * 1e3, kgrid.x_vec * 1e3, sensor.mask+ sourceMask, [-1, 1]);
colormap(getColorMap);
ylabel('x-position [mm]');
xlabel('y-position [mm]');
axis image;

%(x-double(coordinate_set(1))).^2 + y-double(coordinate_set(2))
%x = 182
%y = 100
display('found the following variables')
Mx
My
display('The actual coordinate is')
x_o
y_o
display('Calculated error is')
dis = sqrt((Mx-x_o)^2+(My-y_o)^2)