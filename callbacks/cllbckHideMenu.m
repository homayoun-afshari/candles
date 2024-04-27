function cllbckHideMenu(~, ~, handleAxesMenu)
handleFigure = gcf();
for j = 1:numel(handleAxesMenu.Children)
    handleAxesMenu.Children(j).Visible = 'off';
end
end