% poes_plot.m
% Todd Anderson
% October 19 2022
%
% Import and plot variables from small numbers of POES files.  Includes
% basic operations for interacting with NetCDF (.nc) files.
%
% Spacecraft operating as of October 2022:
%   MetOp-01
%   MetOp-03
%   NOAA-15
%   NOAA-18
%   NOAA-19

% display contents of single file
ncdisp("data/poes_n19_20221018_proc.nc");