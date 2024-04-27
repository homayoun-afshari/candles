function nOut = dmmyClip(nIn, varargin)
nOut = nIn;
if isempty(varargin)
    return;
end
if isnumeric(varargin{1})
    nOut(nOut<varargin{1}(1)) = varargin{1}(1);
    nOut(nOut>varargin{1}(2)) = varargin{1}(2);
    return;
end
switch varargin{1}
    case 'Below'
        nOut(nOut<varargin{2}) = varargin{2};
        return;
    case 'Above'
        nOut(nOut>varargin{2}) =  varargin{2};
        return;
    otherwise
        error('Such command does not exist.');
end
end