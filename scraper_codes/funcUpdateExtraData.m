function report = funcUpdateExtraData(specs)
%% Initialization
firmTotal = size(specs, 1);
report = struct(...
    'success', num2cell(false(firmTotal, 1)),...
    'message', "");
option = weboptions('Timeout', 1);

%% Preparing Daily Database
fprintf('Preparing daily database\n');
databaseDaily = matfile('data/databaseDaily.mat', 'Writable', true);
if exist('data\databaseDaily.mat', 'file')
    fprintf('\t- database was loaded\n');
else
    fprintf('\t- database was created\n');
end

%% Working on the Daily Database
for n = 1:firmTotal
    fprintf('Updating extra data of %s (firm %u of %u)\n', specs.nameEnglish{n}, n, firmTotal);
    if ~ismember(specs.nameEnglish{n}, who(databaseDaily))
        fprintf('\t- database does not contain such record\n');
        continue;
    end
    firmDaily = databaseDaily.(specs.nameEnglish{n});
    
    %%Querying extra data
    fprintf('\t- querying extra data from tsetmc server...');
    try
        websave('data.txt', ['http://www.tsetmc.com/tsev2/data/clienttype.aspx?' specs.queryI{n}], option);
        extraData = split(fileread('data.txt'), ';');
        extraData = flip(extraData);
        delete('data.txt');
    catch
        report(n).message = "noExtraConncetion";
        fprintf('\b\b\b: no connection\n');
        delete('data.txt');
        continue;
    end
    if exist('extraData', 'var')
        report(n).message = "extraDataDownloaded";
        fprintf('\b\b\b: downloaded\n');
        
        %%Working on Daily Candles
        extraTotal = numel(extraData);
        fprintf('\t- processing %u daily candle(s)...', extraTotal);
        counter = 0;
        for i = 1:extraTotal
            temp = split(extraData(i), ',');
            idx = find(all(firmDaily.candle.dateGregorian==str2double({temp{1}(1:4) temp{1}(5:6) temp{1}(7:8)}), 2));
            if ~isempty(idx) && firmDaily.candle.status(idx)~='p'
                firmDaily.candle.status(idx) = 'p';
                firmDaily.candle.extra(idx, :, 1) = str2double(temp(2:5).');
                firmDaily.candle.extra(idx, :, 2) = str2double(temp(6:9).');
                firmDaily.candle.extra(idx, :, 3) = str2double(temp(10:13).')./str2double(temp(6:9).');
                counter = counter + 1;
            end
        end
        fprintf('\b\b\b: %u got completed\n', counter);
    end
    
    %%Writing the Record
    fprintf('\t- writing the record in the database...');
    report(n).success = true;
    databaseDaily.(specs.nameEnglish{n}) = firmDaily;
    fprintf('\b\b\b: successful\n');
end
end