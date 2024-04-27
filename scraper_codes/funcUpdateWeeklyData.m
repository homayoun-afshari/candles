function funcUpdateWeeklyData(specs)
%% Initialization
firmTotal = size(specs, 1);

%% Preparing the Databases
fprintf('Preparing weekly database\n');
if ~exist('data/databaseDaily.mat', 'file')
    fprintf('\t- No daily database was found\n');
    return;
end
databaseDaily = matfile('data/databaseDaily.mat', 'Writable', true);
databaseWeekly = matfile('data/databaseWeekly.mat', 'Writable', true);

%% Working on the Weekly Database
for n = 1:firmTotal
    fprintf('Working on %s (firm %u of %u)\n', specs.nameEnglish{n}, n, firmTotal);
    if ~ismember(specs.nameEnglish{n}, who(databaseDaily))
        fprintf('\t- database does not contain such record\n');
        continue;
    end
    
    %%Querying data
    fprintf('\t- querying data from local server...');
    firmDaily = databaseDaily.(specs.nameEnglish{n});
    fprintf('\b\b\b: downloaded\n');
    
    %%Finding weekly periods
    fprintf('\t- searching %u daily candle(s)...', firmDaily.total);
    counter = 1;
    period = [ones(firmDaily.total, 1) firmDaily.total*ones(firmDaily.total, 1)];
    date = datenum(double(firmDaily.candle.dateGregorian));
    weekDay = weekday(date(1));
    for i = 1:firmDaily.total
        if date(i)-date(period(counter, 1)) >=  mod(6-weekDay, 7)+1
            counter = counter + 1;
            period(counter, 1) = i;
            period(counter-1, 2) = i - 1;
            weekDay = weekday(date(period(counter, 1)));
        end
    end
    period(counter+1:end, :) = [];
    fprintf('\b\b\b: %u period(s) got found\n', counter);
    
    %%Working on Weekly Candles
    fprintf('\t- processing %u weekly candle(s)...', counter);
    firmWeekly = firmDaily;
    firmWeekly.total = size(period, 1);
    for i = 1:firmWeekly.total
        if all(firmDaily.candle.status(period(i, 1):period(i, 2))=='p')
            firmWeekly.candle.status(i) = 'p';
        elseif all(firmDaily.candle.status(period(i, 1):period(i, 2))=='b')
            firmWeekly.candle.status(i) = 'b';
        else
            firmWeekly.candle.status(i) = 'i';
        end
        firmWeekly.candle.IndexDay(i, :) = firmDaily.candle.IndexDay(period(i, 1));
        firmWeekly.candle.dateGregorian(i, :) = firmDaily.candle.dateGregorian(period(i, 1), :);
        firmWeekly.candle.dateJalali(i, :) = firmDaily.candle.dateJalali(period(i, 1), :);
        firmWeekly.candle.quantity(i) = sum(firmDaily.candle.quantity(period(i, 1):period(i, 2)));
        firmWeekly.candle.volume(i) = sum(firmDaily.candle.volume(period(i, 1):period(i, 2)));
        firmWeekly.candle.start(i) = firmDaily.candle.start(period(i, 1));
        firmWeekly.candle.low(i) = min(firmDaily.candle.low(period(i, 1):period(i, 2)));
        firmWeekly.candle.open(i) = firmDaily.candle.open(period(i, 1));
        firmWeekly.candle.close(i) = firmDaily.candle.close(period(i, 2));
        firmWeekly.candle.high(i) = max(firmDaily.candle.high(period(i, 1):period(i, 2)));
        firmWeekly.candle.mean(i) = uint32(sum(double(firmDaily.candle.volume(period(i, 1):period(i, 2))).*double(firmDaily.candle.mean(period(i, 1):period(i, 2))))/double(firmWeekly.candle.volume(i)));
        firmWeekly.candle.last(i) = firmDaily.candle.last(period(i, 2));
        firmWeekly.candle.adjustment(i) = firmDaily.candle.adjustment(period(i, 1));
        firmWeekly.candle.extra(i, :, 1) = sum(firmDaily.candle.extra(period(i, 1):period(i, 2), :, 1), 1, 'omitnan');
        firmWeekly.candle.extra(i, :, 2) = sum(firmDaily.candle.extra(period(i, 1):period(i, 2), :, 2), 1, 'omitnan');
        firmWeekly.candle.extra(i, :, 3) = sum(firmDaily.candle.extra(period(i, 1):period(i, 2), :, 2).*firmDaily.candle.extra(period(i, 1):period(i, 2), :, 3), 1, 'omitnan')./firmWeekly.candle.extra(i, :, 2);
    end
    temp = fieldnames(firmWeekly.candle);
    for j = 1:numel(temp)
        firmWeekly.candle.(temp{j})(firmWeekly.total+1:end, :, :) = [];
    end
    fprintf('\b\b\b: all got created\n');
    
    %%Writing the Record
    fprintf('\t- writing the record in the database...');
    databaseWeekly.(specs.nameEnglish{n}) = firmWeekly;
    fprintf('\b\b\b: successful\n');
end
end