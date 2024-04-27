function funcInvertInformation(information, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph)
handleFigure = gcf();
idx = handleFigure.UserData.currentIndex;
if idx
    handleLabelIndex.String = dmmyVectorToList({information(idx).index information(idx).date information(idx).price information(idx).(['oscillator' int2str(handleFigure.UserData.currentOscillator)]) information(idx).(['indicator' int2str(handleFigure.UserData.currentIndicator)])}, '%s', ' | ', '');
    handleLineHintOscillator.XData = idx*[1 1];
    handleLineHintOscillator.Visible = 'on';
    handleLineHintIndicatorAndGraph.XData = idx*[1 1];
    handleLineHintIndicatorAndGraph.Visible = 'on';
else
    handleLabelIndex.String = handleLabelIndex.UserData.default;
    handleLineHintOscillator.Visible = 'off';
    handleLineHintIndicatorAndGraph.Visible = 'off';
end
end