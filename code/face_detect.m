%---包括：part1-5:总共五个部分
%-----
%-------------------------------------------part1:全局参数设置：
m = 112;  %行 
n = 92;   %列
k = 38;   %特征长度

%------
%-------------------------------------------part2:调用dataset_gen:
%随机划分train_dataset和test_dataset：
warning('off')
dataset_gen()

%------
%-------------------------------------------part3:train训练过程：
%总共40个人，每个人有5张图像，最后取平均，就得到了我们所需要的eigen_matrix_avg
eigen_matrix = [];
for i = 1:40
    total_img = zeros(m*n,1);
    for j = 1:5
        tmp_dir = sprintf('train_dataset\\s%d\\%d.pgm',[i,j]);
        tmp_img = im2double(imread(tmp_dir));
        tmp_img = reshape(tmp_img,m*n,1);
        total_img = total_img + tmp_img;
    end
    eigen_matrix = cat(2,eigen_matrix,total_img./5);
end

%最终eigen_matrix的维度是 mn*40
%下面这个eigen_matrix_avg的维度是 mn*1
eigen_matrix_avg = mean(eigen_matrix,2);             %计算所有人的平均特征一个列向量
dif = eigen_matrix - repmat(eigen_matrix_avg,1,40);  %减去均值后的矩阵
L_matrix = dif'*dif;            %计算协方差矩阵 L_matrix = 40*40
[W,G] = eig(L_matrix);          %协方差矩阵最多39个特征值

dif_W = dif*W ;                 %将dif投射到所有特征向量生成的空间W中
G_arr = diag(G,0);              %去除所有的特征值组成一个一维的向量

%找出前k个最大的特征值的index下标
[values,indexes] = sort(G_arr,'descend');
k_index = indexes(1:k);

%找到前dif_W中的对应位置的k列个mn维列向量
dif_Wk = dif_W(:,k_index);
%按"列"数据进行归一化操作：
for i = 1:k
    dif_Wk(:,i) = dif_Wk(:,i)./norm(dif_Wk(:,i));
end

%最后，只要将原来的dif：mn*40 ，与dif_Wk:mn*k
%把dif投射到dif_Wk空间，得到k*40.这样每个人只要k维度的向量就可以表示其特征
eigen_dif_matrix = dif_Wk'*dif;


%生成k个特征脸--把dif_Wk拆开成k个特征图像
figure
for i = 1:k
    I = reshape(dif_Wk(:, i), m, n);
    subplot(5, 8, i), imshow(I, []), title(['no.', num2str(i), ''])
end


%------
%------------------------------------------part4:test测试部分
%所以，通过上面的train，可以为下面的test提供：
%eigen_dif_matrix —— k*40维度
%dif_Wk —— mn*k维度
%eigen_matrix_avg ——mn*1维度

%如果需要：可以打开一下代码，用于本次训练得到的模型参数的保存
%save_best
%save('best.mat','eigen_matrix_avg',"dif_Wk",'eigen_dif_matrix');
load('best.mat');

acc = 0;
for i = 1:40
    for j = 1:5
        %读取test_dataset中的si文件夹下的第j张pgm
        tmp_dir = sprintf('test_dataset\\s%d\\%d.pgm',[i,j]);
        tmp_img = im2double(imread(tmp_dir));
        tmp_img = reshape(tmp_img,m*n,1);
        %利用dif_Wk —— 计算这张图片的特征空间的系数:
        score_vec = dif_Wk'*(tmp_img-eigen_matrix_avg);
        %计算这个score_vec和所有40个列向量的差值
        score_dif = eigen_dif_matrix - repmat(score_vec,1,40);
        %计算二范数距离
        value_dif = zeros(1,40); %初始化一个1*40个数组，每个位置存一个距离值
        for k = 1:40
            value_dif(k) = sum(score_dif(:,k).*score_dif(:,k));
        end
        %根据这个value_dif数组每个位置的距离值最小的那个，作为预测的结果
        [tmp_value,tmp_index] = min(value_dif);
        acc = acc+sum(tmp_index == i);

    end
end

%-------
%----------------------------------------part5:计算并输出最终的test训练集的正确率
avg_acc = acc/200;
disp(avg_acc)



