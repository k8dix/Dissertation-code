%Script reads raw metric data from Affectiva, gets rid of NaNs,
%matches up timing of test trials (Datavyu) with timing in Affectiva data.
%Using only Affectiva data during a test trial, calculates min, max, and
%range for AUs.
%Creates a sheet in excel file for individual trials and calculates min,
%max, and range for AUs in each
%Also matches up hand-coded smiling behavior timing with timing of positive
%AUs

%Produces 4 graphs
%Output is an excel file with multiple sheets

%Note: The main excel file goes through several changes during the script,
%including multiple name changes. Each new name is followed by a number,
%indicating that it is the main file.

%% Clears variables from workspace
clearvars

%Gets individual participant excel(xlsx) files into a matrix called
%whole_excel_file1
whole_excel_file1 = xlsread('237611');

%% Changing time to milliseconds to match Datavyu coding timing
%Also calculating time in minutes to be able to compare to length of video
converted_timeMS = (whole_excel_file1(:,1)*1000);
converted_timeMinutes = (converted_timeMS/60000);

%Adding new time variables into the NaNless_excel_file
excel_file_newTimes2 = [converted_timeMS, converted_timeMinutes, whole_excel_file1];

%Getting trial times from Datavyu coding and separating the onset times
%from offset times
trial_times = xlsread('237611 AR TT timing');
timeOn = trial_times(:,1);
timeOff = trial_times(:,2);

%Match up timing of trials to Affectiva time stamp, 1-4 = test trials, 0 = attention getter/pre- or post-test 
test_trial_timing = [];
    for i = 1:length(excel_file_newTimes2)
        if excel_file_newTimes2(i,1) >= timeOn(1) && excel_file_newTimes2(i,1) <= timeOff(1)
            test_trial_timing(i) = 1;
        elseif excel_file_newTimes2(i,1) >= timeOn(2) && excel_file_newTimes2(i,1)<= timeOff(2)
            test_trial_timing(i) = 2;
        elseif excel_file_newTimes2(i,1) >= timeOn(3) && excel_file_newTimes2(i,1)<= timeOff(3)
            test_trial_timing(i) = 3;
         elseif excel_file_newTimes2(i,1) >= timeOn(4) && excel_file_newTimes2(i,1)<= timeOff(4)
            test_trial_timing(i) = 4;
        else
            test_trial_timing(i) = 0;
        end
    end
    
%Adding test_trial_timing to the excel file as a new column
test_trial_timing = test_trial_timing';
excel_file_TestTrial_timing3 = [excel_file_newTimes2, test_trial_timing]; 

%Makes a new excel file with this data (and new headings) on Sheet 1
columnHeadings = {'converted_timeMS', 'converted_timeMinutes', 'original_fileTimes', 'face_id', 'anger', 'contempt', 'disgust', 'engagement', 'fear','joy','sadness','surprise','valence','attention','inner_brow_raise','brow_raise','brow_furrow','eye_widen','cheek_raise','lid_tighten','nose_wrinkle','upper_lip_raise','dimpler','lip_corner_depressor','chin_raise','lip_pucker','lip_stretch','lip_press','mouth_open','jaw_drop','lip_suck','eye_closure','smile','smirk','pitch','yaw','roll','mean_face_luminance','interocular_distance','test_trial_number_DVyu'};
xlswrite('237611_processedML',columnHeadings,'Sheet1','A1')
xlswrite('237611_processedML',excel_file_TestTrial_timing3,'Sheet1','A2')


%% Getting rid of Affectiva data for non-test trial time (i.e., attention getter)
excel_file_only_testTrial_data4 = [];
excel_file_only_testTrial_data4 = excel_file_TestTrial_timing3(logical(excel_file_TestTrial_timing3(:,40)),:);

%Makes a new sheet (Sheet 2) on the previously created excel file that has Affectiva data for
%test trials ONLY now
xlswrite('237611_processedML',columnHeadings,'Sheet2','A1')
xlswrite('237611_processedML',excel_file_only_testTrial_data4,'Sheet2','A2')

%Gets rid of any rows that have a NaN value and creates a matrix called
%Nanless_excel_file2
NaNless_excel_file_justTT5 = excel_file_only_testTrial_data4(all(~isnan(excel_file_only_testTrial_data4),2),:);

%Gets length of whole_excel_file before and after getting rid of NaN rows
%Calculates % of good data per participant and % data lost due to NaNs
%Will use values later to look at average data loss during entire video
%recording
length_whole = length(excel_file_only_testTrial_data4);
length_NaN = length(NaNless_excel_file_justTT5);
percent_lost_data_duetoNaNs = (length_NaN/length_whole);
percent_good_data = (1 - percent_lost_data_duetoNaNs);

%Makes a new sheet (Sheet 3) on the previously created excel file that has Affectiva data for
%test trials ONLY now with no NANs
xlswrite('237611_processedML',columnHeadings,'Sheet3','A1')
xlswrite('237611_processedML',NaNless_excel_file_justTT5,'Sheet3','A2')

%% 
%Figure 1 - Plots time X intensity, positive AUs only, test trials are boxed in cyan
TimeInSec1 = NaNless_excel_file_justTT5(:,3);
cheek_raise_only = NaNless_excel_file_justTT5(:,19);
mouth_open_only = NaNless_excel_file_justTT5(:,29);
jaw_drop_only = NaNless_excel_file_justTT5(:,30);
PosAUsOnly = [cheek_raise_only, mouth_open_only, jaw_drop_only];
timeOnSec = timeOn/1000;
timeOffSec = timeOff/1000;
timeDiff1 = timeOffSec(1) - timeOnSec(1);
timeDiff2 = timeOffSec(2) - timeOnSec(2);
timeDiff3 = timeOffSec(3) - timeOnSec(3);
timeDiff4 = timeOffSec(4) - timeOnSec(4);
middleTrial1 = (timeDiff1/2) + timeOnSec(1);
middleTrial2 = (timeDiff2/2) + timeOnSec(2);
middleTrial3 = (timeDiff3/2) + timeOnSec(3);
middleTrial4 = (timeDiff4/2) + timeOnSec(4);

figure(1)
plot(TimeInSec1,PosAUsOnly)
hold on
legend({'Cheek Raise','Mouth Open','Jaw Drop'})
legend('Location','eastoutside')
title('Intensity of Positive AUs Over Time')
xlabel('Time in seconds')
ylabel('Intensity')
ylim([0 115])
set(findall(gca, 'Type', 'Line'),'LineWidth',2);
hold on
rectangle('Position',[timeOnSec(1) 0 timeDiff1 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(2) 0 timeDiff2 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(3) 0 timeDiff3 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(4) 0 timeDiff4 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
text([middleTrial1 middleTrial2 middleTrial3 middleTrial4], [110 110 110 110], {'TT1','TT2','TT3','TT4'})
grid on

%% Min, max, range of each variable (total)
minimum_values = min(NaNless_excel_file_justTT5);
maximum_values = max(NaNless_excel_file_justTT5);
range_values = maximum_values - minimum_values;

%Writing min, max, range values to Sheet 4 of excel file (total)
rowHeadings = {'minimum'; 'maximum'; 'range'}
xlswrite('237611_processedML',rowHeadings,'Sheet4','A2')
xlswrite('237611_processedML',columnHeadings,'Sheet4','B1')
xlswrite('237611_processedML',minimum_values,'Sheet4','B2')
xlswrite('237611_processedML',maximum_values,'Sheet4','B3')
xlswrite('237611_processedML',range_values,'Sheet4','B4')

%Figure 2 - Visualization(bar graph) of individual AUs and expressions (max values)
meaningful_maximum_values = maximum_values(5:34);
BarChartLabels1 = categorical({'anger', 'contempt', 'disgust', 'engagement', 'fear','joy','sadness','surprise','valence','attention','inner brow raise','brow raise','brow furrow','eye widen','cheek raise','lid tighten','nose wrinkle','upper lip raise','dimpler','lip corner depressor','chin raise','lip pucker','lip stretch','lip press','mouth open','jaw drop','lip suck','eye closure','smile','smirk'});

figure(2)
bar(BarChartLabels1,meaningful_maximum_values)
title('All Affectiva Metrics (max values)')
hold on
plot(xlim,[20 20], 'r')
ylabel('Intensity')
box on
grid on
ylim([0 105])

%Figure 3 - Visualization(bar graph) of positive AUs (max) only
max_cheek_raise = maximum_values(19);
max_mouth_open = maximum_values(29);
max_jaw_drop = maximum_values(30);
maxPositiveAUs = [max_cheek_raise, max_mouth_open, max_jaw_drop];
BarChartLabels2 = categorical({'Cheek raise', 'Mouth open', 'Jaw drop'});

figure(3)
bar(BarChartLabels2,maxPositiveAUs)
title('Positive AUs (max values)')
ylabel('Intensity')
ylim([0 105])
hold on
plot(xlim,[20 20], 'r')   %Can't figure out a way to get this to extend the full length of the chart
                          %Has something to do with using the categorical
                          %variables and where they are on the x-axis
                          
%% Writing data from each test trial to a separate sheet (sheets 5-8)
% Min, max, range for each metric for each test trial individually

excel_file_justTT1 = []
excel_file_justTT2 = []
excel_file_justTT3 = []
excel_file_justTT4 = []

for v = 1:length(NaNless_excel_file_justTT5)
if NaNless_excel_file_justTT5(v,40) == 1
    excel_file_justTT1(v,:) = NaNless_excel_file_justTT5(v,:)
elseif NaNless_excel_file_justTT5(v,40) == 2    
    excel_file_justTT2(v,:) = NaNless_excel_file_justTT5(v,:)
elseif NaNless_excel_file_justTT5(v,40) == 3    
    excel_file_justTT3(v,:) = NaNless_excel_file_justTT5(v,:)
elseif NaNless_excel_file_justTT5(v,40) == 4    
    excel_file_justTT4(v,:) = NaNless_excel_file_justTT5(v,:)
end
end

excel_file_justTT2(~any(excel_file_justTT2,2),:) = [];
excel_file_justTT3(~any(excel_file_justTT3,2),:) = [];
excel_file_justTT4(~any(excel_file_justTT4,2),:) = [];

minimum_valuesTT1 = min(excel_file_justTT1);
maximum_valuesTT1 = max(excel_file_justTT1);
range_valuesTT1 = maximum_valuesTT1 - minimum_valuesTT1;

minimum_valuesTT2 = min(excel_file_justTT2);
maximum_valuesTT2 = max(excel_file_justTT2);
range_valuesTT2 = maximum_valuesTT2 - minimum_valuesTT2;

minimum_valuesTT3 = min(excel_file_justTT3);
maximum_valuesTT3 = max(excel_file_justTT3);
range_valuesTT3 = maximum_valuesTT3 - minimum_valuesTT3;

minimum_valuesTT4 = min(excel_file_justTT4);
maximum_valuesTT4 = max(excel_file_justTT4);
range_valuesTT4 = maximum_valuesTT4 - minimum_valuesTT4;


xlswrite('237611_processedML',columnHeadings,'Sheet5','A1')
xlswrite('237611_processedML',excel_file_justTT1,'Sheet5','A2')

xlswrite('237611_processedML',columnHeadings,'Sheet6','A1')
xlswrite('237611_processedML',excel_file_justTT2,'Sheet6','A2')

xlswrite('237611_processedML',columnHeadings,'Sheet7','A1')
xlswrite('237611_processedML',excel_file_justTT3,'Sheet7','A2')

xlswrite('237611_processedML',columnHeadings,'Sheet8','A1')
xlswrite('237611_processedML',excel_file_justTT4,'Sheet8','A2')


xlswrite('237611_processedML',rowHeadings,'Sheet9','B2')
xlswrite('237611_processedML',rowHeadings,'Sheet9','B5')
xlswrite('237611_processedML',rowHeadings,'Sheet9','B8')
xlswrite('237611_processedML',rowHeadings,'Sheet9','B11')

xlswrite('237611_processedML',columnHeadings,'Sheet9','C1')

xlswrite('237611_processedML',minimum_valuesTT1,'Sheet9','C2')
xlswrite('237611_processedML',maximum_valuesTT1,'Sheet9','C3')
xlswrite('237611_processedML',range_valuesTT1,'Sheet9','C4')

xlswrite('237611_processedML',minimum_valuesTT2,'Sheet9','C5')
xlswrite('237611_processedML',maximum_valuesTT2,'Sheet9','C6')
xlswrite('237611_processedML',range_valuesTT2,'Sheet9','C7')

xlswrite('237611_processedML',minimum_valuesTT3,'Sheet9','C8')
xlswrite('237611_processedML',maximum_valuesTT3,'Sheet9','C9')
xlswrite('237611_processedML',range_valuesTT3,'Sheet9','C10')

xlswrite('237611_processedML',minimum_valuesTT4,'Sheet9','C11')
xlswrite('237611_processedML',maximum_valuesTT4,'Sheet9','C12')
xlswrite('237611_processedML',range_valuesTT4,'Sheet9','C13')

xlswrite('237611_processedML','1', 'Sheet9','A2')
xlswrite('237611_processedML','2', 'Sheet9','A5')
xlswrite('237611_processedML','3', 'Sheet9','A8')
xlswrite('237611_processedML','4', 'Sheet9','A11')