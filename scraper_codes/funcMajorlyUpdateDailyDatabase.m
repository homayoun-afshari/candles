function funcMajorlyUpdateDailyDatabase(specs)
%% Initialization
firmTotal = size(specs, 1);
option = weboptions('Timeout', 1);
interval = [0.9 1.1];

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
    fprintf('Working on %s (firm %u of %u)\n', specs.nameEnglish{n}, n, firmTotal);
    
    %%Querying main data
    fprintf('\t- querying main data from tsetmc server...');
    try
        mainData = webread(['http://www.tsetmc.com/tsev2/data/Export-txt.aspx?t=i&a=1&b=0&' specs.queryI{n}], option);
        mainData = split(mainData);
        mainData(1) = [];
        mainData(end) = [];
        mainData = flip(mainData);
        mainData = split(mainData, ',');
    catch
        fprintf('\b\b\b: no connection\n');
        continue;
    end
    fprintf('\b\b\b: downloaded\n');

    %%Working on Daily Candles
    candleTotal = size(mainData, 1);
    fprintf('\t- processing %u daily candle(s)...', candleTotal);
    creation = ~ismember(specs.nameEnglish{n}, who(databaseDaily)) || specs.renew(n);
    if creation
        firmDaily = struct(...
            'nameFarsi', specs.nameFarsi{n},...
            'description', regexprep(mainData{1, 1}, '[^a-zA-Z0-9]', ''),...
            'total', candleTotal,...
            'candle', '');
        temp = datevec(mainData(:, 2), 'yyyymmdd');
        firmDaily.candle = struct(...
            'status', repmat('b', candleTotal, 1),... Dimension 1: b (basic), i (incomplete), p (perfect)
            'IndexDay', uint16((1:candleTotal).'),...
            'dateGregorian', uint16(temp(:, 1:3)),...
            'dateJalali', uint16(dmmyDateGregorianToJalali(temp)),...
            'quantity', uint32(str2double(mainData(:, 9))),...
            'volume', uint64(str2double(mainData(:, 8))),...
            'start', uint32(str2double(mainData(:, 11))),...
            'low', uint32(str2double(mainData(:, 5))),...
            'open', uint32(str2double(mainData(:, 3))),...
            'close', uint32(str2double(mainData(:, 12))),...
            'high', uint32(str2double(mainData(:, 4))),...
            'mean', uint32(str2double(mainData(:, 7))./str2double(mainData(:, 8))),...
            'last', uint32(str2double(mainData(:, 6))),...
            'adjustment', zeros(candleTotal, 1 ,'single'),...
            'extra', nan(firmDaily.total, 4, 3, 'double')); %Dimension 1: index | Dimension 2: buyInd, buyIns, saleInd, saleIns | Dimension 3: total, volume, mean
    else
        firmDaily = databaseDaily.(specs.nameEnglish{n});
        daysOld = datenum(double(firmDaily.candle.dateGregorian));
        daysNew = datenum(mainData(:, 2), 'yyyymmdd');
        idxOld = {find(firmDaily.candle.status=='i')};
        idxOld{1}(~any(bsxfun(@eq, daysNew, daysOld(idxOld{1}).'), 1)) = [];
        idxNew = {find(any(bsxfun(@eq, daysNew, daysOld(idxOld{1}).'), 2))};
        updateTotal = numel(idxNew{1});
        temp = find(daysNew>max(daysOld));
        idxOld{2} = (double(firmDaily.total)+(1:numel(temp))).';
        idxNew{2} = temp;
        addTotal = numel(idxNew{2});
        firmDaily.total = firmDaily.total + addTotal;
        temp = datevec(mainData(5:2, 2), 'yyyymmdd');
        firmDaily.candle.status(idxOld{2}, :) = repmat('b', addTotal, 1);
        firmDaily.candle.IndexDay(firmDaily.total-addTotal+1:firmDaily.total) = uint16((1:addTotal).');
        firmDaily.candle.dateGregorian([idxOld{1}; idxOld{2}], :) = uint16(temp(:, 1:3));
        firmDaily.candle.dateJalali([idxOld{1}; idxOld{2}], :) = uint16(dmmyDateGregorianToJalali(temp));
        firmDaily.candle.quantity([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 9)));
        firmDaily.candle.volume([idxOld{1}; idxOld{2}]) = uint64(str2double(mainData([idxNew{1}; idxNew{2}], 8)));
        firmDaily.candle.start([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 11)));
        firmDaily.candle.low([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 5)));
        firmDaily.candle.open([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 3)));
        firmDaily.candle.close([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 12)));
        firmDaily.candle.high([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 4)));
        firmDaily.candle.mean([idxOld{1}; idxOld{2}]) = uint32(str2double(mainData([idxNew{1}; idxNew{2}], 7))./str2double(mainData([idxNew{1}; idxNew{2}], 8)));
        firmDaily.candle.last([idxOld{1}; idxOld{2}]) = single(str2double(mainData([idxNew{1}; idxNew{2}], 6)));
        firmDaily.candle.adjustment = zeros(firmDaily.total, 1);
        firmDaily.candle.extra(idxOld{2}, :, :) = nan(addTotal, 4, 3, 'double');
    end
    temp = {'low' 'open' 'close' 'high' 'mean'};
    limit = interval.*double(firmDaily.candle.start);
    for j = 1:numel(temp)
        idx = double(firmDaily.candle.(temp{j})) < limit(:, 1);
        firmDaily.candle.(temp{j})(idx) = uint32(limit(idx, 1));
        idx = double(firmDaily.candle.(temp{j})) > limit(:, 2);
        firmDaily.candle.(temp{j})(idx) = uint32(limit(idx, 2));
    end
    firmDaily.candle.adjustment = firmDaily.candle.last;
    for i = flip(2:firmDaily.total)
        firmDaily.candle.adjustment(1:i-1) = firmDaily.candle.adjustment(1:i-1)*firmDaily.candle.start(i)/firmDaily.candle.last(i-1);
    end
    firmDaily.candle.adjustment = firmDaily.candle.adjustment./firmDaily.candle.last;
    if creation
        fprintf('\b\b\b: %u got created\n', candleTotal);
    else
        fprintf('\b\b\b: %u got updated and %u got created\n', updateTotal, addTotal);
    end
    
    %%Querying extra data
    fprintf('\t- querying extra data from tsetmc server...');
    try
        websave('data.txt', ['http://www.tsetmc.com/tsev2/data/clienttype.aspx?' specs.queryI{n}], option);
        extraData = split(fileread('data.txt'), ';');
        extraData = flip(extraData);
    catch
        fprintf('\b\b\b: no connection\n');
        delete('data.txt');
    end
    if exist('data.txt', 'file')
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
    databaseDaily.(specs.nameEnglish{n}) = firmDaily;
    fprintf('\b\b\b: successful\n');
end

%%Clearing extra files
delete('data.txt');
end