function cllbckRestoreDefaults(~, ~, handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph)
handleFigure = gcf();
handleFigure.UserData.currentIndex = 0;
funcInvertInformation('', handleLabelIndex, handleLineHintOscillator, handleLineHintIndicatorAndGraph);
end