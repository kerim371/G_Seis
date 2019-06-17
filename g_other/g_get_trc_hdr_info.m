function [trc_hdr_info,ind] = g_get_trc_hdr_info
trc_hdr_info(3,:) = {1 5 9 13 17 21 25 29 31 33 35 37 41 45 49 53 57 61 65 69 71 73 77 81 85 89 91 93 95 97 99 101 103 105 107 109 111 113 115 117 119 121 123 125 127 129 131 133 135 137 139 141 143 145 147 149 151 153 155 157 159 161 163 165 167 169 171 173 175 177 179 181 185 189 193 197 201 203};
trc_hdr_info(4,:) = {4 4 4 4 4 4 4 2 2 2 2 4 4 4 4 4 4 4 4 2 2 4 4 4 4 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 4 4 4 4 4 2 2};
trc_hdr_info = trc_hdr_info';

trc_hdr_info(:,1:2) = {
  '* Trace sequence number within line' 'SEQWL';
  'Trace sequence number within reel' 'SEQWR';
  '* FFID - Original field record number' 'FFID';
  '* Trace number within field record' 'TRCFLD';
  'SP - Energy source point number' 'SP';
  'CDP ensemble  number' 'CDP';
  'Trace  number' 'TRCNUM';
  '* Trace identification code' 'TRCID';
  'Number of vertically summed traces' 'NVST';
  'Number of horizontally stacked traces' 'NHST';
  'Data use ( 1-production, 2-test )' 'DU';
  'Distance from source point to receiv grp' 'DSREG';
  'Receiver group elevation' 'RGE';
  'Surface elevation at source' 'SES';
  'Source depth below surface' 'SDBS';
  'Datum elevation at receiver group' 'DERG';
  'Datum elevation at source' 'DES';
  'Water depth at source' 'WDS';
  'Water depth at group' 'WGD';
  'Scaler to all elevations & depths' 'SAED';
  'Scaler to all coordinates' 'SAC';
  'Source X coordinate' 'SRCX';
  'Source Y coordinate' 'SRCY';
  'Group  X coordinate' 'GRPX';
  'Group  Y coordinate' 'GRPY';
  'Coordinate units (1-lenm/ft 2-secarc)' 'UNITS';
  'Weathering velocity' 'WVEL';
  'Subweathering velocity' 'SVEL';
  'Uphole time at source' 'UTSRC';
  'Uphole time at group' 'UTGRP';
  'Source static correction' 'SECSCOR';
  'Group  static correction' 'GRPSCOR';
  'Total static applied' 'TSA';
  'Lag time A' 'LAGTA';
  'Lag time B' 'LAGTB';
  'Delay Recording time' 'DELRECT';
  'Mute time start' 'MTSTART';
  'Mute time end' 'MTEND';
  '* Number of samples in this trace' 'NSMP';
  '* Sample interval in ms for this trace' 'SI';
  'Gain type of field instruments' 'GTFI';
  'Instrument gain' 'IG';
  'Instrument gain constant' 'IGC';
  'Correlated (1-yes / 2-no)' 'CORREL';
  'Sweep frequency at start' 'SFSTART';
  'Sweep frequency at end' 'SFEND';
  'Sweep lenth in ms' 'SLEN';
  'Sweep type 1-lin,2-parabol,2-exp,4-ohter' 'STYP';
  'Sweep trace taper length at start in ms' 'SSTRLS';
  'Sweep trace taper length at end   in ms' 'SSTLE';
  'Taper type 1-lin,2-cos2,3-other' 'TTYP';
  'Alias filter frequency, if used' 'AFF';
  'Alias filter slope' 'AFS';
  'Notch filter frequency, if used' 'NFF';
  'Notch filter slope' 'NFS';
  'Low cut frequency,  if used' 'LOCF';
  'High cut frequency, if used' 'HOCF';
  'Low cut slope' 'LOCS';
  'High cut slope' 'HICS';
  'Year data recorded' 'YEAR';
  'Day of year' 'DAY';
  'Hour of day' 'HOUR';
  'Minute of hour' 'MINUTE';
  'Second of minute' 'SCE';
  'Time basis code 1-local,2-GMT,3-other' 'TMBS';
  'Trace weighting factor' 'TWF';
  'Geophone group number of roll sw pos 1' 'GGNSW';
  'Geophone group number of trace # 1' 'GGN1ST';
  'Geophone group number of last trace' 'GGNLST';
  'Gap size (total # of groups dropped)' 'GAPSZ';
  'Overtravel assoc w taper of beg/end line' 'OAWT';
  '+ CDP X' 'CDP_X';
  '+ CDP Y' 'CDP_Y';
  '+ Inline Number' 'INLINE';
  '+ Clossline Number' 'XLINE';
  '+ Shot Point Number' 'SPN';
  '+ Shot Point Scalar' 'SPS';
  '+ Trace value measurement unit' 'TVMU'}; % 203-204 bytes
%   'Transduction Constant';
%   'Trunsduction Units';
%   'Device/Trace Identifier';
%   'Scalar to be applied to times in Trace Header bytes 95-114 to give the true times value in milliseconds';
%   'Source Type/Orientation';
%   'Source Energy Direction';
%   'Source Measurement';
%   'Source Measurement Unit'};

% нахождение индексов 4-х и 2-х байтовых заголовков трасс, если они
% объединены в один столбец (4-х байтовые, а потом 2-х байтовые)
trc_byte = cell2mat(trc_hdr_info(:,3:4));

h4 = 1:4:240;
h4 = h4';

h2 = 1:2:240;
h2 = h2';
ind = [];
for n = 1:size(trc_byte,1)
    h_len = trc_byte(n,2);
    h_start = trc_byte(n,1);
    if h_len == 4
        ind = [ind; find(h4==h_start)];
    elseif h_len == 2
        ind = [ind; find(h2==h_start)+60];
    end
end