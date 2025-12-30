function blurredMatrix = gaussianBlur(matrix, kernelSize, sigma)
% gaussianBlur - 对矩阵进行高斯模糊
%
% 输入参数:
%   matrix - 输入矩阵（可以是图像或任何数值矩阵）
%   kernelSize - 高斯核的大小，应为正奇数（如 3, 5, 7 等）
%   sigma - 高斯分布的标准差，控制模糊程度。如果省略，则默认为 (kernelSize-1)/6
%
% 输出参数:
%   blurredMatrix - 经过高斯模糊处理后的矩阵

% 检查输入参数
if nargin < 2
    kernelSize = 5;
end
if nargin < 3
    sigma = (kernelSize - 1) / 1; % 默认值
end

% 方法1：使用 imgaussfilt 函数（推荐）
% 该函数直接实现高斯模糊，自动处理边界
blurredMatrix = imgaussfilt(matrix, sigma, 'FilterSize', kernelSize);

% 方法2：使用 fspecial 创建高斯核，然后用 imfilter 卷积
% h = fspecial('gaussian', [kernelSize kernelSize], sigma);
% blurredMatrix = imfilter(matrix, h, 'replicate'); % 'replicate' 用于处理边界

% 方法3：使用 conv2 函数直接卷积
% h = fspecial('gaussian', [kernelSize kernelSize], sigma);
% blurredMatrix = conv2(matrix, h, 'same'); % 'same' 确保输出与输入大小相同
end
