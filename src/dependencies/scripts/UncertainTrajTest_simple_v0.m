

SampleNum = 100;
obs_pos = [2500,250];
tic
figure(1)
for j = 1:length(obs_pos)
    subplot(1,length(obs_pos),j)
    hold on 
    for i = 1:SampleNum
        idm = IDM_Uncertain();
        [p1, p2, p3, t] = simOneTime(idm,obs_pos(j));
        plot(t,p1,'Color', [0 0.4470 0.7410,1/SampleNum],LineWidth=5)
        plot(t,p2,'Color', [0.8500 0.3250 0.0980,1/SampleNum],LineWidth=5);
        plot(t,p3,'Color', [0.9290 0.6940 0.1250,1/SampleNum],LineWidth=5);
    end
    hold off
    xlabel('时间 [s]')
    ylabel('位置 [m]')
    legend('vehicle 01', ...
            'vehilce 02', ...
            'vehilce 03','Location','northwest')
    toc
    grid on
    ylim([0 500])
end
set(gcf,'Color','white')
function [p1, p2, p3, t] = simOneTime(idm,obs_pos)
    Ts = 0.5;
    t = (0:Ts:20)';

    v1 = zeros(size(t));
    p1 = zeros(size(t));
    
    v2 = zeros(size(t));
    p2 = zeros(size(t));
    
    v3 = zeros(size(t));
    p3 = zeros(size(t));

    v1(1) = 12;
    p1(1) = 30;
    v2(1) = 12;
    p2(1) = 20;
    v3(1) = 18;
    p3(1) = 0;


    for i = 2:length(t)
        % if t(i)<10
        %     a1 = idm.acc(v1(i-1),0,150-p1(i-1));
        % else
        %     a1 = idm.acc(v1(i-1),0,250-p1(i-1));
        % end
        a1 = idm.acc(v1(i-1),0,obs_pos-p1(i-1));

        % a1 = idm.acc(v1(i-1),0,150);
        v1(i) = v1(i-1) + a1*Ts;
        p1(i) = p1(i-1) + v1(i)*Ts;

        a2 = idm.acc(v2(i-1),v1(i-1),p1(i-1)-p2(i-1));
        v2(i) = v2(i-1) + a2*Ts;
        p2(i) = p2(i-1) + v2(i)*Ts;

        a3 = idm.acc(v3(i-1),v2(i-1),p2(i-1)-p3(i-1));
        v3(i) = v3(i-1) + a3*Ts;
        p3(i) = p3(i-1) + v3(i)*Ts;
    end

end