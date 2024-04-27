function list = dmmyVectorToList(vector, format, delimiter, bracket)
if iscell(vector)
    temp = '';
    for i = 1:numel(vector)
        if isempty(vector{i})
            continue;
        end
        temp = sprintf([temp format delimiter], vector{i});
    end
else
    temp = sprintf([format delimiter], vector);
end
list = temp(1:end-numel(delimiter));
if ~isempty(list) && ~isempty(bracket)
    list = [bracket(1:ceil(0.5*numel(bracket))) list bracket(ceil(0.5*numel(bracket))+1:end)];
end
end