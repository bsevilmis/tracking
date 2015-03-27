function klDivergence = getSymmetricKLDivergence(histogram1, histogram2)

divergence1to2 = 0;
divergence2to1 = 0;
histogramSizes = size(histogram1,1)*size(histogram1,2)*size(histogram1,3);
logDivisionByZero = 6;

for i = 1:histogramSizes
    if(histogram1(i) ~= 0 && histogram2(i) ~= 0)
        divergence1to2 = divergence1to2 + histogram1(i)*log(histogram1(i)/histogram2(i));
        divergence2to1 = divergence2to1 + histogram2(i)*log(histogram2(i)/histogram1(i));
    elseif(histogram1(i) ~= 0 && histogram2(i) == 0)
        divergence1to2 = divergence1to2 + histogram1(i)*logDivisionByZero;
    elseif(histogram2(i) ~= 0 && histogram1(i) == 0)
        divergence2to1 = divergence2to1 + histogram2(i)*logDivisionByZero;
    end
end

klDivergence = (divergence1to2 + divergence2to1) / 2;
end