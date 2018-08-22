#!/bin/bash
usage ()
{
  echo 'Usage : nose_wrapping_fix <original_wrapped_image> <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <xmin_front> <xsize_front> <ymin_front> <ysize_front> <zmin_front> <zsize_front>'
  exit
}

file=$1
wrapped_image=`basename $file .nii`
roi_x_min=$2
roi_x_size=$3
roi_y_min=$4
roi_y_size=$5
roi_z_min=$6
roi_z_size=$7

roi_x_min_front=$2
roi_x_size_front=$3
roi_y_min_front=$4
roi_y_size_front=$5
roi_z_min_front=$6
roi_z_size_front=$7

#step1: split image into front and back in a way that you avoid the wrapping nose. Select the y-cordinate (voxel not mm) carefully for this

fslroi $wrapped_image $wrapped_image\_back "$roi_x_min $roi_x_size $roi_y_min $roi_y_size $roi_z_min $roi_z_size"
fslroi $wrapped_image $wrapped_image\_front "$roi_x_min_front $roi_x_size_front $roi_y_min_front $roi_y_size_front $roi_z_min_front $roi_z_size_front""

#step2: merge image along y-axis

fslmerge -y $wrapped_image\_merged $wrapped_image\_back.nii.gz $wrapped_image\_front.nii.gz 

#step3: make sure image dimensions match original image

og_dim1=$(fslinfo $wrapped_image |grep "dim1" |awk '{print $1}')
og_dim2=$(fslinfo $wrapped_image |grep "dim2" |awk '{print $1}')
og_dim3=$(fslinfo $wrapped_image |grep "dim3" |awk '{print $1}')

new_dim1=$(fslinfo $wrapped_image\_merged.nii.gz |grep "dim1" |awk '{print $1}')
new_dim2=$(fslinfo $wrapped_image\_merged.nii.gz |grep "dim2" |awk '{print $1}')
new_dim3=$(fslinfo $wrapped_image\_merged.nii.gz |grep "dim3" |awk '{print $1}')

echo $og_dim1 $new_dim1
echo $og_dim2 $new_dim2
echo $og_dim3 $new_dim3
