% Working on von Frey data with Mollie 

% setup workspace 
clc, clear, close all

% Where are your files 
filepath = 'C:\Users\basbaum\Box Sync\Postdoctoral Work - Basbaum\PROJECTS_CIPN_ACC\Pilot 01\Von Frey Data\Pilot_3_Updated Spreasheets\';
DIXON_LUT_filename = 'VonFrey_LUT.xlsx'; 
VFF_LUT_filename = 'VonFreyFiber_LUT.xlsx';
vF_filenames = dir([filepath '*Baseline.xlsx']); 

% Open VF LUT 
DX_LUT = readtable([filepath '\' DIXON_LUT_filename]); 

% Open VFF LUT
VF_LUT = readtable([filepath '\' VFF_LUT_filename]);

% Calculate d value 
vF_unit = [0.04, 0.07, 0.16, 0.4, 0.6, 1.0, 2.0]; 
d_value = mean(diff(log10(vF_unit))); 
d_value_katie = 0.354; 

for bb = 1:length(vF_filenames)

    % Open vF Data
    VF_DATA = readtable([vF_filenames(bb).folder '\' vF_filenames(bb).name]); 
    clear ed50_ ed50_old_

    for aa = 1:size(VF_DATA,1)

        %% New equation 
        % Trial 1
        log_val = log10(VF_LUT.vF_g(VF_DATA.Lastsize1(aa) == VF_LUT.vF_val)) + 4;
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial1(aa)), DX_LUT.OBSERVATION)); 
        ed50_(aa,1) = (10^(log_val + (k_value*d_value)))/10^4; 

        % Trial 2
        log_val = log10(VF_LUT.vF_g(VF_DATA.Lastsize2(aa) == VF_LUT.vF_val)) + 4;
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial2(aa)), DX_LUT.OBSERVATION)); 
        ed50_(aa,2) = (10^(log_val + (k_value*d_value)))/10^4; 

        % Trial 3
        log_val = log10(VF_LUT.vF_g(VF_DATA.Lastsize3(aa) == VF_LUT.vF_val)) + 4;
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial3(aa)), DX_LUT.OBSERVATION)); 
        ed50_(aa,3) = (10^(log_val + (k_value*d_value)))/10^4; 

        %% Old equation 
        % Trial 1
        log_val = VF_DATA.Lastsize1(aa);
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial1(aa)), DX_LUT.OBSERVATION)); 
        ed50_old_(aa,1) = (10^(log_val + (k_value*d_value_katie)))/10^4; 

        % Trial 2
        log_val = VF_DATA.Lastsize2(aa);
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial2(aa)), DX_LUT.OBSERVATION)); 
        ed50_old_(aa,2) = (10^(log_val + (k_value*d_value_katie)))/10^4; 

        % Trial 3
        log_val = VF_DATA.Lastsize3(aa);
        k_value = DX_LUT.STATISTIC(strcmp(upper(VF_DATA.Trial3(aa)), DX_LUT.OBSERVATION)); 
        ed50_old_(aa,3) = (10^(log_val + (k_value*d_value_katie)))/10^4; 

    end
    if bb > 1
        VF_out = [VF_out; VF_DATA(:,1:2), array2table(ed50_) array2table(ed50_old_) cell2table(repmat({['Day' num2str(bb)]}, size(ed50_,1), 1))]; 
    else
        VF_out = [VF_DATA(:,1:2), array2table(ed50_) array2table(ed50_old_) cell2table(repmat({['Day' num2str(bb)]}, size(ed50_,1), 1))]; 
    end
    
end
VF_out

%% Plot everything
figure
hold on
for aa = 1:size(VF_out,1)
    plot(table2array(VF_out(aa,3:5)), table2array(VF_out(aa,6:end-1)), 'xr')
end
plot([0 1.5], [0 1.5], '--k')
hold off 
axis([0 1.5 0 1.5])
axis square
grid on
xticks(0:0.1:1.5)
yticks(0:0.1:1.5)
xlabel('est. 50% Withdrawal Threshold (g) - updated')
ylabel('est. 50% Withdrawal Threshold (g) - previous')
title('Baseline von Frey - Up/Down Method')

%% Compare values 

% Convert
tbl = VF_out(end-7:end,:); 
mean_table = [  tbl(:,1:2), ...
                array2table([mean(table2array(tbl(:,3:5)), 2), mean(table2array(tbl(:,6:8)), 2)])] 

% Open percent files 
per_tbl = readtable([filepath 'Pilot_3_Baseline 2_Percent Withdrawal' '.xlsx']); 

% Plot 
figure
for aa = 1:size(per_tbl, 1)
    
    temp_tbl = VF_out; 
    
    temp_tbl(   (temp_tbl.Animal ~= per_tbl.Animal(aa)) | ...
                ~strcmp(temp_tbl.Paw, per_tbl.Paw(aa)), :) = []; 
    
    subplot(2,4,aa)
    hold on
    plot([0 1.2], [50 50], '--k')
    for bb = 1:size(temp_tbl,1)
            plot(repmat(mean(table2array(temp_tbl(bb,3:5))), 1, 2), [0 100], 'g')
            plot(repmat(mean(table2array(temp_tbl(bb,6:8))), 1, 2), [0 100], 'r')
    end
    plot(   [per_tbl.Filament(aa) per_tbl.Filament_1(aa)], ...
            [per_tbl.Percent(aa) per_tbl.Percent_1(aa)]*10, 'k')
    plot(   [per_tbl.Filament(aa) per_tbl.Filament_1(aa)], ...
            [per_tbl.Percent(aa) per_tbl.Percent_1(aa)]*10, 'xk')
    hold off 
    xlim([0 1])
    ylim([0 100])
    axis square
    ylabel('Percent Responding')
    xlabel('Fiber Weight (g)')
    title([per_tbl.Animal(aa) ' ' per_tbl.Paw(aa)])
end






