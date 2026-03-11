function gyromagneticRatio = getgyro_Hyscorean(Nuc_str, IsotopeTags)
    %Gyromagnetic ratios in MHz/T
    
    % Read leading integer and get the end position
    [isoNum, count, ~, nextIdx] = sscanf(Nuc_str, '%d', 1);
    
    if count ~= 1
        error('Could not read isotope number from string.');
    end
    
    % Extract remaining substring as element symbol
    isoElem = strtrim(Nuc_str(nextIdx:end));
    
    % Convert number to string for comparison with IsotopeTags.isotope
    isoNumStr = sprintf('%d', isoNum);
    
    % Find matching entry in IsotopeTags
    ind = find(strcmp({IsotopeTags.isotope}, isoNumStr) & strcmp({IsotopeTags.name}, isoElem), 1);
    
    if isempty(ind)
        error('Isotope not found in IsotopeTags.');
    end
    
    gyromagneticRatio = IsotopeTags(ind).gn;
    
    gyromagneticRatio = 5.050783746100000e-27*abs(gyromagneticRatio)/planck/1e6;

end

