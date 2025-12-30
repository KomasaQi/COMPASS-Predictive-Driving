function patchHandle = customShowExtendedMesh(meshObj, varargin)
    % CUSTOMSHOWEXTENDEDMESH 终极适配版：支持无核心属性的extendedObjectMesh对象
    % 修正：1. 对象属性用isprop判断 2. 提取几何数据（兼容无Vertices/Faces场景）
    %       3. 逻辑运算转为标量 4. 完全兼容无位姿属性的对象
    % 输入：meshObj - extendedObjectMesh对象；varargin - Parent/Color/Alpha/EdgeColor
    % 输出：patchHandle - 渲染后的Patch句柄

    % --------------------------
    % 步骤1：解析可选参数（带校验）
    % --------------------------
    p = inputParser;
    addParameter(p, 'Parent', gca);
    addParameter(p, 'Color', [0.5 0.5 0.5], @isnumeric);
    addParameter(p, 'Alpha', 1, @(x) isnumeric(x) && x>=0 && x<=1);
    addParameter(p, 'EdgeColor', 'none');
    parse(p, varargin{:});

    ax = p.Results.Parent;
    faceColor = p.Results.Color;
    faceAlpha = p.Results.Alpha;
    edgeColor = p.Results.EdgeColor;

    % --------------------------
    % 步骤2：提取几何数据（兼容无Vertices/Faces的对象）
    % 核心思路：先临时用show渲染，提取Patch的几何数据，再删除临时Patch
    % --------------------------
    if ~isprop(meshObj, 'Vertices') || ~isprop(meshObj, 'Faces')
        % 临时创建隐藏坐标系，用于提取几何数据
        tempFig = figure('Visible', 'off');
        tempAx = axes(tempFig);
        % 用自带show渲染，获取临时Patch句柄
        show(meshObj, tempAx);
        tempPatch = findobj(tempAx, 'Type', 'patch');
        % 提取临时Patch的Vertices和Faces（这是对象的真实几何数据）
        vertices = tempPatch.Vertices;
        faces = tempPatch.Faces;
        % 关闭临时窗口
        close(tempFig);
    else
        % 若对象有属性，直接提取
        vertices = meshObj.Vertices;
        faces = meshObj.Faces;
    end

    % 校验几何数据有效性
    if size(vertices, 2) ~= 3 || ~isnumeric(vertices)
        error('提取的顶点数据无效，需为n×3数值矩阵');
    end
    if ~isnumeric(faces) || size(faces, 2) < 3
        error('提取的面索引数据无效，需为m×3或m×4数值矩阵');
    end

    % --------------------------
    % 步骤3：获取位姿（完全兼容无位姿属性的对象）
    % --------------------------
    pose = eye(4); % 默认单位矩阵（无位姿变换）
    % 对象属性判断用isprop，优先级：Pose > Transform
    if isprop(meshObj, 'Pose')
        tempPose = meshObj.Pose;
        % 逻辑运算转为标量（用all()），避免非标量错误
        if all(size(tempPose) == [4 4]) && isnumeric(tempPose)
            pose = tempPose;
        end
    elseif isprop(meshObj, 'Transform')
        tempPose = meshObj.Transform;
        if all(size(tempPose) == [4 4]) && isnumeric(tempPose)
            pose = tempPose;
        end
    end

    % --------------------------
    % 步骤4：位姿变换（局部→世界坐标系）
    % --------------------------
    [n, ~] = size(vertices);
    verticesHom = [vertices, ones(n, 1)];  % 齐次坐标
    verticesWorldHom = (pose * verticesHom')';
    verticesWorld = verticesWorldHom(:, 1:3);  % 笛卡尔坐标

    % --------------------------
    % 步骤5：绘制网格（确保参数有效）
    % --------------------------
    patchHandle = patch(...
        'Parent', ax, ...
        'Vertices', verticesWorld, ...
        'Faces', faces, ...
        'FaceColor', faceColor, ...
        'FaceAlpha', faceAlpha, ...
        'EdgeColor', edgeColor ...
    );

    % --------------------------
    % 步骤6：可视化设置
    % --------------------------
    % view(ax, 3);
    % grid(ax, 'on');
    hold(ax, 'on');
end