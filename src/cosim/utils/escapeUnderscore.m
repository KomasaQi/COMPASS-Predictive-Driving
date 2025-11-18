
function newStr = escapeUnderscore(str)
    % 查找字符串中所有下划线的位置
    underscoreIndices = strfind(str, '_');
    % 如果找到了下划线
    if ~isempty(underscoreIndices)
        % 预先分配新字符串的空间
        newStr = repmat(' ', 1, length(str) + length(underscoreIndices));
        insertIndex = 1;
        strIndex = 1;
        % 遍历原字符串
        while strIndex <= length(str)
            if ~isempty(underscoreIndices) && strIndex == underscoreIndices(1)
                % 插入反斜杠
                newStr(insertIndex) = '\';
                insertIndex = insertIndex + 1;
                % 移除已处理的下划线索引
                underscoreIndices(1) = [];
            end
            % 插入原字符串的字符
            newStr(insertIndex) = str(strIndex);
            insertIndex = insertIndex + 1;
            strIndex = strIndex + 1;
        end
    else
        % 如果没有下划线，直接返回原字符串
        newStr = str;
    end
end
