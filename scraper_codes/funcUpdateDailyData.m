function report = funcUpdateDailyData(specs)
%% Initialization
firmTotal = size(specs, 1);
report = struct(...
    'success', num2cell(false(firmTotal, 1)),...
    'message', "");
option = weboptions('Timeout', 1);
trial = struct(...
    'total', 5,...
    'delay', 0.5);

%% Preparing the Daily Database
fprintf('Preparing daily database\n');
if ~exist('data/databaseDaily.mat', 'file')
    fprintf('\t- No database was found\n');
    return;
end
databaseDaily = matfile('data/databaseDaily.mat', 'Writable', true);

%% Working on the Daily Database
for n = 1:firmTotal
    fprintf('Updating daily data of %s (firm %u of %u)\n', specs.nameEnglish{n}, n, firmTotal);
    if ~ismember(specs.nameEnglish{n}, who(databaseDaily))
        report(n).message = "recordNotFound";
        fprintf('\t- database does not contain such record\n');
        continue;
    end
    firmDaily = databaseDaily.(specs.nameEnglish{n});
    
    %%Querying daily data
    fprintf('\t- querying daily data from tsetmc server: trial #00');
    for t = 1:trial.total
        fprintf('\b\b\b\b\b\b\b\b\btrial #%02u', t);
        try
            data = split(webread(['http://www.tsetmc.com/tsev2/data/instinfodata.aspx?' specs.queryI{n} '&' specs.queryC{n}], option), ';');
            if strlength(data{1})
                break;
            end
        catch
        end
        pause(trial.delay);
    end
    if ~exist('data', 'var') || ~strlength(data{1})
        report(n).message = "noDailyConncetion";
        fprintf('\b\b\b\b\b\b\b\b\bno conncetion\n');
        continue;
    end
    if ~strlength(data{5})
        report(n).message = "mainDailyDataDownloaded";
        temp = 'main data downloaded';
        data = [split(data(1), ','); num2cell(nan(10, 1))];
    else
        report(n).message = "allDailyDataDownloaded";
        temp = 'all data downloaded';
        data = [split(data(1), ','); split(data(5), ',')];
    end
    fprintf('\b\b\b\b\b\b\b\b\b%s\n', temp);
    
    %%Working on Daily Candles
    firmDaily.lastUpdate = datetime('now');
    creation = datenum(data{13}, 'yyyymmdd') > datenum(double(firmDaily.candle.dateGregorian(firmDaily.total, :)));
    if ~creation && firmDaily.candle.status(firmDaily.total, :)=='p'
        report(n).message = "dailyDataIsUpToDate";
        fprintf('\t- data is up to date\n');
        continue;
    end
    firmDaily.total = firmDaily.total + creation;
    fprintf('\t- processing %u daily candle...', firmDaily.total);
    temp = datevec(data{13}, 'yyyymmdd');
    firmDaily.candle.status(firmDaily.total) = 'i';
    firmDaily.candle.IndexDay(firmDaily.total) = firmDaily.total;
    firmDaily.candle.dateGregorian(firmDaily.total, :) = temp(:, 1:3);
    firmDaily.candle.dateJalali(firmDaily.total, :) = dmmyDateGregorianToJalali(temp);
    firmDaily.candle.quantity(firmDaily.total) = str2double(data(9));
    firmDaily.candle.volume(firmDaily.total) = str2double(data(10));
    firmDaily.candle.start(firmDaily.total) = str2double(data(6));
    firmDaily.candle.low(firmDaily.total) = str2double(data(8));
    firmDaily.candle.open(firmDaily.total) = str2double(data(5));
    firmDaily.candle.close(firmDaily.total) = str2double(data(3));
    firmDaily.candle.high(firmDaily.total) = str2double(data(7));
    firmDaily.candle.mean(firmDaily.total) = str2double(data(11))/str2double(data(10));
    firmDaily.candle.last(firmDaily.total) = str2double(data(4));
    firmDaily.candle.adjustment = zeros(firmDaily.total, 1);
    firmDaily.candle.extra(firmDaily.total, :, :) = zeros(1, 4, 3);
    firmDaily.candle.adjustment = single(firmDaily.candle.last);
    for i = flip(2:firmDaily.total)
        firmDaily.candle.adjustment(1:i-1) = firmDaily.candle.adjustment(1:i-1)*double(firmDaily.candle.start(i))/double(firmDaily.candle.last(i-1));
    end
    firmDaily.candle.adjustment = single(firmDaily.candle.adjustment./double(firmDaily.candle.last));   
    firmDaily.candle.extra(firmDaily.total, :, 1) = str2double(data([20 21 23 24]).');
    firmDaily.candle.extra(firmDaily.total, :, 2) = str2double(data([15 16 18 19]).');
    firmDaily.candle.extra(firmDaily.total, :, 3) = double(firmDaily.candle.mean(firmDaily.total))*ones(1, 4);
    if creation
        fprintf('\b\b\b: 1 got created\n');
    else
        fprintf('\b\b\b: 1 got updated\n');
    end
    
    %%Writing the Record
    fprintf('\t- writing the record in the database...');
    report(n).success = true;
    databaseDaily.(specs.nameEnglish{n}) = firmDaily;
    fprintf('\b\b\b: successful\n');
end
end