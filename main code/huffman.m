clear; 
close all; 
clc;
img=imread('D:\\新建文件夹\\pic.dng');
%此前代码用的是把dng文件转为灰色图片再来压缩的
% if ndims(f0) == 3
%     f0 = rgb2gray(f0);
% end 
f0=img(: ,: ,1);
%把像素矩阵大小缩小一半，方便调试速度
% f0 = imresize(f0, 0.5); 

subplot(241)
imshow(uint8(img));
xlabel('原始图像');

red_matrix=f0;%对图像的像素进行调整
[M,N]=size(red_matrix);

freq_dict = zeros(1, 256); % 初始化一个大小为256的数组来存储频率  
for i = 1:size(red_matrix, 1)  
    for j = 1:size(red_matrix, 2)  
        pixel_value = red_matrix(i, j);  
        freq_dict(pixel_value + 1) = freq_dict(pixel_value + 1) + 1; 
        % 在freq_dict中找到该列，若像素值等于该列就加一
    end  
end

freq_dict1=freq_dict;%因为往后要合成频率，就做个频率矩阵的复制，方便调试

%将频率矩阵中的所有像素值为0的频率定为0.01，方便合成频率之后的判断（因为0+0还是0与左子节点清零后的值好区分）
for t=1:256
    if freq_dict(t)==0
        freq_dict(t)=0.01;
    end
end

dictionary=cell(256,1);%字典
sign=zeros(256);%记录父子节点关系的符号矩阵

for cishu=1:256
    min_value=M*N;
    for t=1:256
        if (freq_dict(t)<min_value)&&(freq_dict(t)>0)
            min_value=freq_dict(t);
        end
    end
    %遍历出频率矩阵的最小值
    t=1;
    while (freq_dict(t)~=min_value)&&(t<256)
        t=t+1;
    end
    %找到像素灰度频率最小值，并标记好他的灰度值t
%     min_value=M*N;
%     for t = 1:256  
%         if (freq_dict(t)>0)&&(freq_dict(t)<min_value)
%             min_value= freq_dict(t);  
%             min_index = t; 
%         end  
%     end  
%     t = min_index;
    if sign(t,1)==0
        dictionary{t}='0';%如果该最小频率并没有子节点，就在huffman字典中编一次‘0’
    else
        dictionary{t}=['0',dictionary{t}];
        %若该最小频率的灰度值有子节点，说明他不是一个孤立的点，至少是个二元二叉树，
        %而且这个灰度点是他的左树和子树合成概率的树，所以为该树加上'0'，即为右节点加上'0'
        i=1;
        while (sign(t,i)~=0)&&(i<256)
            dictionary{sign(t,i)}=['0',dictionary{sign(t,i)}];
            %找该灰度级的子节点（或是左节点），若不为0则一直有子节点就在每一个子节点的编码前加0，直到找不到子节点
            i=i+1;
        end
    end
    freq_dict(t)=0;%将该灰度级的频率清0，不影响下次的编码（找最小值的时候）
    zuo=t;%将最小值的灰度级保存起来，方便后面嫁接入更高级的父节点的目录中
    
    secmin_value=M*N;
    for t=1:256
        if (freq_dict(t)<secmin_value)&&(freq_dict(t)>0)
            secmin_value=freq_dict(t);
        end
    end
    %遍历出频率矩阵的次最小值
    t=1;
    while (freq_dict(t)~=secmin_value)&&(t<256)
        t=t+1;
    end
%     %找到像素灰度频率次最小值，并标记好他的灰度值
%     min_value2=M*N;
%     for t = 1:256  
%         if (freq_dict(t)>0)&&(freq_dict(t)<min_value2)
%             min_value2= freq_dict(t);  
%             min_index = t; 
%         end  
%     end  
%     t = min_index;
    
    if sign(t,1)==0
        dictionary{t}='1';%如果该最小频率并没有子节点，说明他就是单独一个点，就在huffman字典中编一次'1'
    else
        dictionary{t}=['1',dictionary{t}];
        %若该最小频率的灰度值有子节点，说明他不是一个孤立的点，至少是个二元二叉树，
        %而且这个灰度点是他的左树和子树合成概率的树，所以为该树加上'1'，即为右节点加上'1'
        i=1;
        while (sign(t,i)~=0)&&(i<256)
            dictionary{sign(t,i)}=['1',dictionary{sign(t,i)}];
            %找该灰度级的子节点（或是左节点），若不为0则一直有子节点就在每一个子节点的编码前加1，直到找不到子节点
            i=i+1;
        end
    end
    freq_dict(t)=freq_dict(t)+min_value;
    %将左边更小概率灰度值的概率与右边次小概率灰度合成到右边次小灰度里
    %这样就是右节点又可视作该两个节点的父节点，左节点就是该父节点的字节点
    you=t;%将右边的节点的灰度值保存起来，方便后面加他目录底下子节点
    i=1;
    while (sign(t,i)~=0)&&(i<256)
        i=i+1;
    end
    %为新合成的左节点在右节点（父节点）的子节点门路下找个位置
    sign(t,i)=zuo;
    %以下的操作是将左节点可能有的所有子节点放入新的父节点的目录下
    i=i+1;%在刚刚找的位置下，为新来的左节点的子节点（或是左节点）找新的位置
    j=1;
    while (sign(zuo,j)~=0)&&(j<61)
        sign(t,i)=sign(zuo,j);
        i=i+1;
        j=j+1;
        %把子节点的子节点放到父母结点的子节点目录下，相当于户主是爷爷，新生的孙子上到爷爷为户主的户口
        %并且该过程是节节推进的，并不会改变原有的节点放入的顺序
    end
end
% 整个产生huffman码的过程

%构建一个用字典中的huffman码代替的像素矩阵
fc = cell(M, N);
k= red_matrix < 256;
fc(k) = dictionary(red_matrix(k) + 1);



% 将 fc 转换为一个行向量,然后将所有列串联得到一个长字符串
fc2 = reshape(fc.', 1, []);
% 使用 sprintf 函数将行向量转换为字符串
imcore = sprintf('%s', fc2{:});


save('red.mat','imcore','dictionary');%保存图片码流和编码对应表
