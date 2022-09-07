clc
clear
close all

flt_half_width = 3;
img = imread('baby.jpg');
img = imresize(img, 0.125);

flt_img = lens_blur(img, 7, 3500, 0, 1);
