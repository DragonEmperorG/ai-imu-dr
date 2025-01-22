function [] = exportLatexTable(exportFilePath,evalutationTable)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明

wEvalutationTableVal =  evalutationTable';
wEvalutationTableMar = zeros(size(wEvalutationTableVal));

% cEvaLatexList = [
%     "$\vb*{AOE}_{MAE}$" 
%     "$\vb*{AOE}_{RMSE}$"
%     "$\vb*{ROE}_{MAE}$"
%     "$\vb*{ROE}_{RMSE}$"
% ];

cEvaLatexList = [
    "$\vb*{AOE}_{MAE}$", ...
    "$\vb*{AOE}_{RMSE}$", ...
    "$\vb*{ROE}_{MAE,\Delta l}$", ...
    "$\vb*{ROE}_{RMSE,\Delta l}$", ...
    "$\vb*{ROE}_{MAE,unit \Delta l}$", ...
    "$\vb*{ROE}_{RMSE,unit \Delta l}$", ...
];

% cEvaLatexList = [
%     "$\vb*{AVE}_{MAE}$" 
%     "$\vb*{AVE}_{RMSE}$"
%     "$\vb*{RVE}_{MAE}$"
%     "$\vb*{RVE}_{RMSE}$"
% ];

cEvaLatexList = [
    "$\vb*{APE}_{MAE}$", ...
    "$\vb*{APE}_{RMSE}$", ...
    "$\vb*{RPE}_{MAE,\Delta l}$", ...
    "$\vb*{RPE}_{RMSE,\Delta l}$", ...
    "$\vb*{RPE}_{MAE,unit \Delta l}$", ...
    "$\vb*{RPE}_{RMSE,unit \Delta l}$", ...
    "$\vb*{RPE}_{MAE,\Delta l}^{horizontal}$", ...
    "$\vb*{RPE}_{RMSE,\Delta l}^{horizontal}$", ...
    "$\vb*{RPE}_{MAE,unit \Delta l}^{horizontal}$", ...
    "$\vb*{RPE}_{RMSE,unit \Delta l}^{horizontal}$", ...
];

cEvaCounts = size(cEvaLatexList,2);

tTraCounts = size(wEvalutationTableVal,2);
tMetCounts = size(wEvalutationTableVal,1) / cEvaCounts;

for col = 1:tTraCounts
    for j = 1:cEvaCounts
        tEvaluationMethodIndex = j:cEvaCounts:(j+cEvaCounts*(tMetCounts-1));
        tEvaluationMethodValue = wEvalutationTableVal(tEvaluationMethodIndex,col);
        [~,tI] = min(tEvaluationMethodValue);
        wEvalutationTableMar(j+cEvaCounts*(tI-1),col) = 1;
    end
end

fileID = fopen(exportFilePath,'w');
for i = 1:tMetCounts
    for j = 1:cEvaCounts
        fprintf(fileID,'& %s',cEvaLatexList(j));
        for col = 1:tTraCounts
            row = cEvaCounts * (i - 1) + j;
            if wEvalutationTableMar(row,col) == 1
                fprintf(fileID,' & \\textbf{%.1f}',wEvalutationTableVal(row,col));
                % fprintf(fileID,' & %.1f',wEvalutationTableVal(row,col));
            else
                fprintf(fileID,' & %.1f',wEvalutationTableVal(row,col));
            end
        end
        fprintf(fileID,' \\\\\n');
    end
end
fclose(fileID);

end