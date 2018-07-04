N_ROW=480;  % 画像の行（縦方向）の数
N_COL=640;  % 画像の列（横方向）の数

fi=fopen('image/statue.txt','r');
sph = 10;%画像枚数
sn=zeros(N_ROW,N_COL,3);  % 法線（背景ならば0ベクトル）
s=zeros(sph,3);  % 光線方向ベクトル
s0=zeros(sph,3);
img=zeros(N_ROW,N_COL,sph);%画像の画素値....枚数分
ro=zeros(sph,1)%拡散反射率用
%% 光線ベクトル代入
for ii=1:sph
 fscanf(fi,'%s',1)
    for k=1:3
        s(ii,k)=fscanf(fi,'%f',1);
        s0(ii,k)=s(ii,k);
    end

    ro(ii,1)=fscanf(fi,'%f',1);
    
end
MASK = 'image/statue_mask.pgm';
fclose(fi);
for ii=1:sph
    for k=1:3
       s0(ii,k)=s0(ii,k);
    end
end
%%

%% 画像から画素値取り込む
for ii = 1:sph
   IMAGE='image/statue_linear_0?.pgm';
    if ii ~= 10
        IMAGE(22) = '0'+ii;
    else
        IMAGE='image/statue_linear_10.pgm';
    end
    A=imread(IMAGE);

    BW=imread(MASK);
    
    for i=1:N_ROW
        for j=1:N_COL
            if BW(i,j)~=255
                A(i,j)=0;
            end
        end
    end
    %ファイルを読み込んで画素値をimgに代入
    for i=1:N_ROW
        for j=1:N_COL
            img(i,j,ii)=A(i,j);    
        end
    end
end 

li =zeros(sph,1);
sn_es=zeros(N_ROW,N_COL,3);%推定した法線ベクトル

 for i=1:N_ROW
     for j=1:N_COL
         
         s=zeros(sph,3);
         for ii=1:sph
            for k=1:3
             s(ii,k)=s0(ii,k);
            
            end
         end
         
         for ii=1:sph
             
               if img(i,j,ii)>10%暗電流ノイズを消す
                li(ii,1)=img(i,j,ii);

                else
                 li(ii,1)=img(i,j,ii);
                  for k=1:3
                     s(ii,k)= 0;
                  end
               end
               
         end
         
         for ii=1:sph
             li(ii,1)=img(i,j,ii);
         end
         
         
         sq = pinv(s);
         b=sq*li;%法線ベクトル計算
         if any(b)%単位ベクトルに
             b = b/norm(b);
         end
         for k=1:3
            sn_es(i,j,k)= b(k,1);
         end
         
         %%

     end
 end

 %% colormapを*.ppmに出力
   fpc = fopen('colorsphere.ppm','w');
   f0=fopen('sn_statue.txt','w');
  g = N_ROW;
r = N_COL;%g行r列
fprintf(fpc,'P3\n');
fprintf(fpc,'%d',r);
fprintf(fpc,' %d\n',g);
fprintf(fpc,'255\n');
for ig = 1:g
    for ir=1:r
            fprintf(fpc,'%d %d %d ',round((sn_es(ig,ir,1)+1)*255/2),round((sn_es(ig,ir,2)+1)*255/2),round((sn_es(ig,ir,3)+1)*255/2));
            fprintf(f0,'%d %d %f %f %f\n',ig,ir,sn_es(ig,ir,1),sn_es(ig,ir,2),sn_es(ig,ir,3));
    end
    
    fprintf(fpc,'\n');
end
fclose(fpc);
fclose(f0);
