%% Initialization
clc;
addpath scraper_codes;
clearvars -except specs
warning('off');

%% Preparations
fprintf('Preparing the specifications\n');
if ~exist('specs', 'var')
    if ~exist('data\specs.xls', 'file')
        fprintf('\t- no file was found\n');
        return;
    end
    specs = readtable('data\specs.xls');
    specs(specs.readOnly==1, :) = [];
    specs.readOnly = [];
end
fprintf('\t- %u writable firm(s) got found: %s\n', size(specs, 1), dmmyVectorToList(specs.nameEnglish, '%s', '|', ''));
while true
    decision = split(input(sprintf('\t- choose your desired firm(s): '), 's'), '|');
    if strcmp(decision, 'none')
        clearvars specs
        return;
    end
    if strcmp(decision, 'all')
        decision = specs.nameEnglish;
    end
    [~, temp] = ismember(decision, specs.nameEnglish);
    if all(temp)
        break;
    end
end
specsScrape = specs(temp, :);
methodLog = {'daily' 'main' 'extra' 'both'};
fprintf('\t- %u updating method(s) got found: %s\n', numel(methodLog), dmmyVectorToList(methodLog, '%s', '|', ''));
while true
    method = input(sprintf('\t- choose your desired method: '), 's');
    if ismember(method, methodLog)
        break;
    end
end

%% Updating Daily Database
fprintf('%s\n', repmat('-', 1, 100));
switch method
    case methodLog{1}
        report = funcUpdateDailyData(specsScrape);
    case methodLog{2}
        report = funcUpdateMainData(specsScrape);
    case methodLog{3}
        report = funcUpdateExtraData(specsScrape);
    case methodLog{4}
        reportMain = funcUpdateMainData(specsScrape);
        reportExtra = funcUpdateExtraData(specsScrape);
        report = struct('temp', cell(size(specsScrape, 1), 1));
        temp = num2cell(any([reportMain.success; reportExtra.success], 1));
        [report.success] = temp{:};
        temp = mat2cell([reportMain.message; reportExtra.message].', ones(size(specsScrape, 1), 1));
        [report.message] = temp{:};
        report = rmfield(report, 'temp');
end

%% Updating Weekly Databse
temp = [report.success];
if any(temp)
    fprintf('%s\n', repmat('-', 1, 100));
    funcUpdateWeeklyData(specsScrape(temp, :));
end

%% Reporting
fprintf('%s\n', repmat('-', 1, 100));
fprintf('Reporting daily data update\n');
temp = reshape([report.message], numel(report), size(report(1).message, 2));
outcome = unique(temp, 'stable');
for j = 1:numel(outcome)
    if isempty(outcome{j})
        continue;
    end
    idx = any(strcmp(temp, outcome{j}), 2);
    fprintf('\t- %s (%u of %u): %s\n', outcome{j}, sum(idx), size(specsScrape, 1), dmmyVectorToList(specsScrape.nameEnglish(idx), '%s', '|', ''));
end

%% Finalization
warning('on');