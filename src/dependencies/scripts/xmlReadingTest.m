% 读取XML文件
doc = xmlread('netdemo.net.xml');

% 获取根节点
rootNode = doc.getDocumentElement();

% 显示根节点的名称
disp(['Root element: ' char(rootNode.getNodeName())]);

% 获取所有子节点
childNodes = rootNode.getChildNodes();

% 遍历子节点并显示其名称和内容
for i = 1 : childNodes.getLength()
    childNode = childNodes.item(i - 1);
    disp(['Element name: ' char(childNode.getNodeName())]);
    disp(['Element content: ' char(childNode.getTextContent())]);
end