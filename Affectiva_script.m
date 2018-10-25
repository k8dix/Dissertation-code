%Script reads raw metric data from Affectiva, gets rid of NaNs,
%matches up timing of test trials (Datavyu) with timing in Affectiva data.
%Using only Affectiva data during a test trial, calculates min, max, and
%range for AUs.
%Also matches up hand-coded smiling behavior timing with timing of positive
%AUs

%Produces 4 graphs
%Output is an excel file with 5 sheets

%Note: The main excel file goes through several changes during the script,
%including multiple name changes. Each new name is followed by a number,
%indicating that it is the main file. Ex: whole_excel_file1 becomes 
%NaNless_excel_file2.

%% Clears variables from workspace
clearvars

%Gets individual participant excel(xlsx) files into a matrix called
%whole_excel_file1
whole_excel_file1 = xlsread('238338');

%Gets rid of any rows that have a NaN value and creates a matrix called
%Nanless_excel_file2
NaNless_excel_file2 = whole_excel_file1(all(~isnan(whole_excel_file1),2),:); %I think I need to remove the NaNs(or at least count them) in a later step, but it's okay for now 

%Gets length of whole_excel_file before and after getting rid of NaN rows
%Calculates % of good data per participant and % data lost due to NaNs
%Will use values later to look at average data loss during entire video
%recording
length_whole = length(whole_excel_file1);
length_NaN = length(NaNless_excel_file2);
percent_lost_data_duetoNaNs = (length_NaN/length_whole);
percent_good_data = (1 - percent_lost_data_duetoNaNs);

%% Changing time to milliseconds to match Datavyu coding timing
%Also calculating time in minutes to be able to compare to length of video
converted_timeMS = (NaNless_excel_file2(:,1)*1000);
converted_timeMinutes = (converted_timeMS/60000);

%Adding new time variables into the NaNless_excel_file
excel_file_newTimes3 = [converted_timeMS, converted_timeMinutes, NaNless_excel_file2];

%Getting trial times from Datavyu coding and separating the onset times
%from offset times
trial_times = xlsread('238338 AR TT timing');
timeOn = trial_times(:,1);
timeOff = trial_times(:,2);

%Match up timing of trials to Affectiva time stamp, 1-4 = test trials, 0 = attention getter/pre- or post-test 
test_trial_timing = [];
    for i = 1:length(excel_file_newTimes3)
        if excel_file_newTimes3(i,1) >= timeOn(1) && excel_file_newTimes3(i,1) <= timeOff(1)
            test_trial_timing(i) = 1;
        elseif excel_file_newTimes3(i,1) >= timeOn(2) && excel_file_newTimes3(i,1)<= timeOff(2)
            test_trial_timing(i) = 2;
        elseif excel_file_newTimes3(i,1) >= timeOn(3) && excel_file_newTimes3(i,1)<= timeOff(3)
            test_trial_timing(i) = 3;
         elseif excel_file_newTimes3(i,1) >= timeOn(4) && excel_file_newTimes3(i,1)<= timeOff(4)
            test_trial_timing(i) = 4;
        else
            test_trial_timing(i) = 0;
        end
    end
    
%Adding test_trial_timing to the excel file as a new column
test_trial_timing = test_trial_timing';
excel_file_TestTrial_timing4 = [excel_file_newTimes3, test_trial_timing]; 

%Makes a new excel file with this data (and new headings) on Sheet 1
columnHeadings = {'converted_timeMS', 'converted_timeMinutes', 'original_fileTimes', 'face_id', 'anger', 'contempt', 'disgust', 'engagement', 'fear','joy','sadness','surprise','valence','attention','inner_brow_raise','brow_raise','brow_furrow','eye_widen','cheek_raise','lid_tighten','nose_wrinkle','upper_lip_raise','dimpler','lip_corner_depressor','chin_raise','lip_pucker','lip_stretch','lip_press','mouth_open','jaw_drop','lip_suck','eye_closure','smile','smirk','pitch','yaw','roll','mean_face_luminance','interocular_distance','test_trial_number_DVyu'};
xlswrite('238338_processedML',columnHeadings,'Sheet1','A1')
xlswrite('238338_processedML',excel_file_TestTrial_timing4,'Sheet1','A2')


%% Getting rid of Affectiva data for non-test trial time (i.e., attention getter)
excel_file_only_testTrial_data5 = [];
excel_file_only_testTrial_data5 = excel_file_TestTrial_timing4(logical(excel_file_TestTrial_timing4(:,40)),:);

%Makes a new sheet (Sheet 2) on the previously created excel file that has Affectiva data for
%test trials ONLY now
xlswrite('238338_processedML',columnHeadings,'Sheet2','A1')
xlswrite('238338_processedML',excel_file_only_testTrial_data5,'Sheet2','A2')

%Figure 1 - Plots time X intensity, positive AUs only, test trials are boxed in cyan
TimeInSec1 = excel_file_only_testTrial_data5(:,3);
cheek_raise_only = excel_file_only_testTrial_data5(:,19);
mouth_open_only = excel_file_only_testTrial_data5(:,29);
jaw_drop_only = excel_file_only_testTrial_data5(:,30);
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

%% Min, max, range of each variable
minimum_values = min(excel_file_only_testTrial_data5);
maximum_values = max(excel_file_only_testTrial_data5);
range_values = maximum_values - minimum_values;

%Writing min, max, range values to Sheet 3 of excel file 
rowHeadings = {'minimum'; 'maximum'; 'range'}
xlswrite('238338_processedML',rowHeadings,'Sheet3','A2')
xlswrite('238338_processedML',columnHeadings,'Sheet3','B1')
xlswrite('238338_processedML',minimum_values,'Sheet3','B2')
xlswrite('238338_processedML',maximum_values,'Sheet3','B3')
xlswrite('238338_processedML',range_values,'Sheet3','B4')

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

%% Matching up the timing of hand-coded smiling/postive affect times with
%Affectiva postive AU times
HCsmileTimes = xlsread('testHCdata2');

HCsmilingDuringAffectiva = [];
for p = 1:length(excel_file_only_testTrial_data5) 
    for o = 1:length(HCsmileTimes)
        if excel_file_only_testTrial_data5(p,1) >= HCsmileTimes(o,1) && excel_file_only_testTrial_data5(p,1) <= HCsmileTimes(o,2)
            HCsmilingDuringAffectiva(p) = 100;
        else
            HCsmilingDuringAffectiva(p) = 0;
        end
    end
end

%Makes an new sheet (Sheet 4) on the previously created excel file that has
%hand-coded data (0 = no HC smile, 100 = HC smile) in new column
HCsmilingDuringAffectiva = HCsmilingDuringAffectiva';
excel_file_HCdata6 = [excel_file_only_testTrial_data5,HCsmilingDuringAffectiva];
columnHeadings2 = {'converted_timeMS', 'converted_timeMinutes', 'original_fileTimes', 'face_id', 'anger', 'contempt', 'disgust', 'engagement', 'fear','joy','sadness','surprise','valence','attention','inner_brow_raise','brow_raise','brow_furrow','eye_widen','cheek_raise','lid_tighten','nose_wrinkle','upper_lip_raise','dimpler','lip_corner_depressor','chin_raise','lip_pucker','lip_stretch','lip_press','mouth_open','jaw_drop','lip_suck','eye_closure','smile','smirk','pitch','yaw','roll','mean_face_luminance','interocular_distance','test_trial_number_DVyu','HC_smiling'};
xlswrite('131708_processedML',columnHeadings2,'Sheet4','A1')
xlswrite('131708_processedML',excel_file_HCdata6,'Sheet4','A2')

%% Hand-coded smiling and Affectiva positive AUs time series- finding when positive AUs 
%are greater than 20
%Getting data ready for gantt chart and reading to 5th tab of excel file
HCsmilingDuringAffectiva;
TimeInMS = excel_file_HCdata6(:,1);
cheek_raise_all = excel_file_HCdata6(:,19);
mouth_open_all = excel_file_HCdata6(:,29);
jaw_drop_all = excel_file_HCdata6(:,30);

cheek_raise_great20 = [];
for q = 1:length(cheek_raise_all)
    if cheek_raise_all(q) >= 20
        cheek_raise_great20(q) = 40;
    else
        cheek_raise_great20(q) = 0;
    end
end
cheek_raise_great20 = cheek_raise_great20';

mouth_open_great20 = [];
for q = 1:length(mouth_open_all)
    if mouth_open_all(q) >= 20
        mouth_open_great20(q) = 60
    else
        mouth_open_great20(q) = 0;
    end
end
mouth_open_great20 = mouth_open_great20';

jaw_drop_great20 = []
for q = 1:length(jaw_drop_all)
    if jaw_drop_all(q) >= 20
        jaw_drop_great20(q) = 80
    else
        jaw_drop_great20(q) = 0
    end
end
jaw_drop_great20 = jaw_drop_great20'

%Makes an new sheet (Sheet 5) on the previously created excel file that has
%time in MS, HC smiling (0 = no smile, 100 = smile), jaw drop (0 =
%intensity below 20, 80 = intensity >= 20), mouth open (0 =
%intensity below 20, 60 = intensity >= 20), and cheek raise (0 =
%intensity below 20, 40 = intensity >= 20)
TimingAUsandHC = [TimeInMS, HCsmilingDuringAffectiva, cheek_raise_great20, mouth_open_great20, jaw_drop_great20]
columnHeadings3 = {'TimeInMS', 'HCsmiles', 'cheek_raise_great20', 'mouth_open_great20', 'jaw_drop_great20'}
xlswrite('131708_processedML',columnHeadings3,'Sheet5','A1')
xlswrite('131708_processedML',TimingAUsandHC,'Sheet5','A2')

%% Figure 4: Gantt chart of the presence of Affectiva positive AUs >=20 and hand-coded smiling
%across test trials
TimeInSec = TimeInMS/1000;
TimeInSecRange = (TimeInMS(end) - TimeInMS(1))/1000;
TimeInSecBegin = TimeInMS(1)/1000;
TimeInSecEnd = TimeInMS(end)/1000;

figure(4)
plot(TimeInSec,HCsmilingDuringAffectiva, 'go')
hold on
plot(TimeInSec,jaw_drop_great20,'ro')
hold on
plot(TimeInSec,mouth_open_great20, 'co')
hold on
plot(TimeInSec,cheek_raise_great20, 'mo')
hold on
rectangle('Position',[timeOnSec(1) 0 timeDiff1 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(2) 0 timeDiff2 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(3) 0 timeDiff3 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
rectangle('Position',[timeOnSec(4) 0 timeDiff4 105],'FaceColor', [0 1 1 0.15], 'EdgeColor','none')
hold on
text([middleTrial1 middleTrial2 middleTrial3 middleTrial4], [10 10 10 10], {'TT1','TT2','TT3','TT4'})
title('Timing of HC smiles and Positive AUs (values >= 20)')
xlabel('Time in seconds')
set(gca,'YTick',[])
box on
grid on
legend({'Hand-coded smiling', 'Jaw Drop', 'Mouth Open', 'Cheek Raise'})
legend('Location','eastoutside')
axis([(TimeInSecBegin-10) (TimeInSecEnd+10) 0 105])

