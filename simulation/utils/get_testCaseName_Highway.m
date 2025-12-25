% 连云港到盐城的仿真中获取仿真名称等信息
function [sumo_file_name, rou_file_name, DepartTime, InitTime, EndPos, ...
    S_main, S_exit, S_merge, Avg_Stream, If_Finish, Case_Name] = get_testCaseName_Highway(case_number)
    tb = readtable(".\data\test_cases\COMPASS_TestCase_LianYG_YanC.xlsx");
    DepartTime  = tb.DepartTime(case_number);
    InitTime = tb.InitTime(case_number);
    EndPosX = tb.EndPosX(case_number);
    EndPosY = tb.EndPosY(case_number);
    S_main = tb.S_main(case_number);
    S_exit = tb.S_exit(case_number);
    S_merge = tb.S_merge(case_number);
    Avg_Stream = tb.Avg_Stream(case_number);
    If_Finish = tb.If_Finish(case_number);
    Case_Name = tb.Name{case_number};
    file_name = ['no' num2str(case_number) '_' ...
        num2str(Avg_Stream) '_' Case_Name];
    sumo_file_name = [file_name '.sumocfg'];
    rou_file_name = [file_name '.rou.xml'];
    EndPos = [EndPosX,EndPosY];
    
end