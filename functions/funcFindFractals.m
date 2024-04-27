function fractal = funcFindFractals(low, high, depth)
total = numel(low);
temp = {0 true};
fractal = nan(total, 1);
for i = 1+floor(0.5*(depth-1)):total-ceil(0.5*(depth-1))
    u = all(high(i)>=(high(i-floor(0.5*(depth-1)):i-1))) && all(high(i)>=(high(i+1:i+ceil(0.5*(depth-1)))));
    d = all(low(i)<=(low(i-floor(0.5*(depth-1)):i-1))) && all(low(i)<=(low(i+1:i+ceil(0.5*(depth-1)))));
    if u || d
        temp{1} = i;
        temp{2} = u&~(temp{2}&d);
        fractal(i) = ~temp{2}*low(i)+temp{2}*high(i);
    end
end
end