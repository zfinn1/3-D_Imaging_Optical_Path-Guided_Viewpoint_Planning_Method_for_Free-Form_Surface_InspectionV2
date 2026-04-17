clear all; 
load  red.mat %载入图片码流和编码对应表
load  green.mat 
load  blue.mat 

%将字符串的大小和字典的大小用变量表示，方便后续函数表示
DZ0=size(dictionary);
IZ0=size(imcore);
DZ1=size(dictionary1);
IZ1=size(imcore1);
DZ2=size(dictionary2);
IZ2=size(imcore2);

len = 256;

f0=uint8(jiemafunction(IZ0(2),DZ0(1),imcore,dictionary,256,171));
f1=uint8(jiemafunction(IZ1(2),DZ1(1),imcore1,dictionary1,256,171));
f2=uint8(jiemafunction(IZ2(2),DZ2(1),imcore2,dictionary2,256,171));

colorImage = cat(3, f0, f1, f2);%将三个像素灰度值矩阵拼接成一个新的图像矩阵
%将原图显示方便对比
subplot(121)
img=imread('D:\\新建文件夹\\pic.dng');
imshow(img);
xlabel('\fontsize{16}原始图像');
%将解码图显示方便对比
subplot(122)
imshow(colorImage);
xlabel('\fontsize{16}解码后的图像');

%定义一个解码函数，参数分别为总字符串长度，总灰度值数，霍夫曼码字典
function [f]=jiemafunction(a,b,imc,dict,len,len1)
flag=0;%内部像素值是否匹配huffman码的标志位
i=1;%像素矩阵列数
j=1;%像素矩阵行数
cz=char();%内部搬运字符串
for n=1:a
    if flag==0  %若标志位为0，则说明和字典里对应的字符串匹配不上，则继续从字符串里继续取
        cz=[cz,imc(n)];
    else       %若标志位为1，则说明和字典里相应的字符串匹配上了，说明一个像素值的huffman码已经取完了，则取下一个新的huffman码
        cz=imc(n);
        flag=0; %并在此时将标志位取为0
    end
    for t=1:b  %将所有灰度值遍历一遍
        if strcmp(cz,dict{t}) %若字符串与Huffman字典中字符匹配则将该字符的行数，则该行数就是用该字符表示的灰度，把这个灰度赋值到像素矩阵里
            flag=1;
            f(j,i)=t;
            while i<len
               if i==len-1 %如若列>256，则说明一行已经遍历完了，则在判断内将列重设，列数加1
                   i=1;
                   j=j+1;
                   if j>len1+1 %若列数到了极限，则归位
                    j=1;
                   end  
               end
               i=i+1; %列没达到上限就加一列
               break;
           end
           break;
        end
    end
end

end

