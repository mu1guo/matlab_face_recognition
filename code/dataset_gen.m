%说明：这个函数用来生成train_dataset和test_dataset
%通过将每个人的10张图像分别随机对半分到train_dataset和test_dataset文件夹下
%为后续的train和test的过程提供 数据支撑:

function dataset_gen()

    %调用randperm函数创建打乱的1-10的序号
    random_1_10 = randperm(10);
    
    %创建路径——train_dataset和test_dataset文件夹
    %然后，下面是s1-40的文件夹——都要创建
    for i = 1:40

        %创建dataset下面的s1-40的文件夹
        path1 = sprintf('train_dataset\\s%d',i);
        path2 = sprintf('test_dataset\\s%d',i);
        if ~exist(path1, 'dir')
            mkdir(path1);
        end
        if ~exist("path2", 'dir')
            mkdir(path2);
        end
    
        %最后，只要把raw_face\\s1-s40
        %拆分到train_dataset\\s1-40和test_dataset\\s1-40即可
        for j = 1:10
            if j < 6
                %把前1-5的random_1_10(j)的图片给到train_dataset
                train_dir = sprintf('train_dataset\\s%d\\%d.pgm',[i,j]);
                raw_dir = sprintf('raw_face\\s%d\\%d.pgm',[i,random_1_10(j)]);
                copyfile(raw_dir,train_dir);
    
            else
                %把后6-10的ranm_1_10(j)的图片给到test_dataset
                test_dir = sprintf('test_dataset\\s%d\\%d.pgm',[i,j-5]);
                raw_dir = sprintf('raw_face\\s%d\\%d.pgm',[i,random_1_10(j)]);
                copyfile(raw_dir,test_dir);
            end
        end
    end
end
