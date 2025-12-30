params = LianYG_YC_params(simCaseNumber);
testNum = 100;
for i = 1:testNum
    G_emb = cloud_db.getCurrentGraphs(40);
end
plotGraph(G_emb,'risk')