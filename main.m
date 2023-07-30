%% Computer Vision
% Practical Assignment - Spring 2023
% Joona Kareinen, Sara Heikkinen, and Emma Hirvonen
%% Main
clc
close all
clearvars

% Load the calibration image
img = imread("images/calibration_demo.png");
res = calibrate(img);

% Red cube to red goal
img = imread("images/test_img5.png");
move_block("red", img, res);

% Green cube to green goal
% img = imread("second_demo.png");
% move_block("green", img, res);

% Blue cube to blue goal
% img = imread("third_demo.png");
% move_block("blue", img, res);
