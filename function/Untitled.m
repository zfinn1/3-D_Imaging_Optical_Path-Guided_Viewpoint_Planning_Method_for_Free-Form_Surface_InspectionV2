clear all
% 读取图像  
img = imread('D:\\新建文件夹\\pic.dng');%载入待编码图像   
 
% 检查图像的大小和数据类型  
[a b c]=size(img);  % 显示图像的尺寸（对于彩色图像，这是[高度, 宽度, 通道数]）  

gray_matrix=img(:,:,1);

freq_dict = zeros(1, 256); % 初始化一个大小为256的数组来存储频率  
for i = 1:size(gray_matrix, 1)  
    for j = 1:size(gray_matrix, 2)  
        pixel_value = gray_matrix(i, j);  
        freq_dict(pixel_value + 1) = freq_dict(pixel_value + 1) + 1; % 注意：索引从1开始，因为MATLAB的索引从1开始  
    end  
end

[M,N]=size(gray_matrix);
freq_dict1=zeros(1,256);
for t=1:256
    count=0;
    for i=1:M
        for j=1:N
            if gray_matrix(i,j)==t-1
                count=count+1;
            end
        end
    end
    freq_dict1(t)=count;
    p0=freq_dict1;
end


indices = 1:numel(freq_dict);
  
% 使用sort函数对值和它们的索引进行排序  
[sorted_values, sorted_indices] = sort(freq_dict, 'descend'); % 如果你想降序排序 
% 如果图像是彩色的，可以分别访问红、绿、蓝三个通道  
red_channel = img(:,:,1);  
green_channel = img(:,:,2);  
blue_channel = img(:,:,3);