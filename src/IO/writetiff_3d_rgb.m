function writetiff_3d_rgb(outIm,ImName)

imwrite(outIm(:,:,:,1),ImName);
for z=2:size(outIm,4)
    imwrite(outIm(:,:,:,z),ImName,'WriteMode','append');
end

end