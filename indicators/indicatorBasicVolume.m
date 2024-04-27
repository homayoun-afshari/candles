function [line, area] = indicatorBasicVolume(firm, ~, ~, ~, ~)
line = struct(...
    'volume', firm.candle.volume);
area = '';
end