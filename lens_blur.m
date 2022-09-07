function [flt_img] = lens_blur(img, flt_half_width, blur_mag, inv_blur ,disp_res)

flt_img = zeros(size(img));
for k = 1:size(img, 3)
    ch = img(:, :, k);

    % add margin
    mar_img = ones(size(ch)+2*flt_half_width);
    mar_img = mar_img*mean(ch(:));
    mar_img(flt_half_width+1:end-flt_half_width, flt_half_width+1:end-flt_half_width) = ch;
    mar_img = double(mar_img);

    [R, C] = size(mar_img);

    % calc blur_map
    blur_ctrl = zeros(size(mar_img));
    for row = 1+flt_half_width : R-flt_half_width
        for col = 1+flt_half_width : C-flt_half_width
            blur_ctrl(row, col) = blur_mag*(sqrt((row-R/2).^2 + (col-C/2).^2)) / (R*C);
        end
    end

    if inv_blur
        blur_ctrl = max(blur_ctrl(:))-blur_ctrl;
    end

    % apply filter
    flt_ch = zeros(size(mar_img));

    for row = 1+flt_half_width : R-flt_half_width
        for col = 1+flt_half_width : C-flt_half_width
            [x, y] = meshgrid(-flt_half_width : flt_half_width);
            win_dist = sqrt(x.^2+y.^2);

            h = reshape(gaussmf(win_dist(:), [eps+blur_ctrl(row, col), 0]), size(win_dist));
            h = h/sum(h(:));

            flt_ch(row,col) = sum(sum(h.*mar_img(row-flt_half_width:row+flt_half_width, col-flt_half_width:col+flt_half_width)));
        end
    end

    % remove margin
    flt_ch = flt_ch(flt_half_width+1:end-flt_half_width, flt_half_width+1:end-flt_half_width);

    % return to rgb
    flt_img(:, :, k) = flt_ch;
end

flt_img = uint8(flt_img);

% show results
if disp_res
    figure(disp_res)
    subplot(1,2,1); imshow(img);
    subplot(1,2,2); imshow(flt_img);
end
