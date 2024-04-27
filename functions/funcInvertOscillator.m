function funcInvertOscillator(handleLabelPercentage, oscillator, handleTicksIndex, handleTicksPercentage)
handleFigure = gcf();
current = handleFigure.UserData.currentOscillator;
if current
    handleLabelPercentage.String = sprintf('Indicator: %s%s%s', oscillator(current).name, dmmyVectorToList(oscillator(current).rule, '%s', ', ', '[]'), dmmyVectorToList(oscillator(current).parameter, '%u', ', ', ' ()'));
else
    handleLabelPercentage.String = 'Oscillator: none';
end
for j = 1:numel(oscillator)
    for h = 1:numel(oscillator(j).handle)
        oscillator(j).handle(h).Visible = 'off';
    end
end
for h = 1:numel(oscillator(current).handle)
    oscillator(current).handle(h).Visible = 'on';
end
temp = dmmyIf(oscillator(current).grid(1), 'on', 'off');
for h = 1:size(handleTicksIndex, 2)
    handleTicksIndex(1, h).Visible = temp;
    handleTicksIndex(2, h).Visible = temp;
    handleTicksIndex(3, h).Visible = temp;
end
temp = dmmyIf(oscillator(current).grid(2), 'on', 'off');
for h = 1:size(handleTicksPercentage, 2)
    handleTicksPercentage(1, h).Visible = temp;
    handleTicksPercentage(2, h).Visible = temp;
end
end

