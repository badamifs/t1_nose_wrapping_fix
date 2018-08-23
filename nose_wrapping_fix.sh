#!/bin/bash
# Use this script to fix nose wrapping (nose appearing behind the head due to a poorly planned T1)
#

[ $# -eq 0 ] && { echo "Usage: $0 <original_wrapped_image> <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <ymin_front> <ysize_front>
eg: ./nose_wrapping_fix.sh BEST_9999_RC9999_T1.nii.gz 0 184 76 180 0 256 3 76"; exit 1; }

file=$1
wrapped_image=`basename $file .nii`
roi_x_min=$2
roi_x_size=$3
roi_y_min=$4 #Decide you y coordinate carefully; use the most inferior axial slice as the y coordinate
roi_y_size=$5 #Use 256-(whatever y coordinate you end up selecting above)
roi_z_min=$6
roi_z_size=$7

roi_x_min_front=$2
roi_x_size_front=$3
roi_y_min_front=$4 # Use coordinate from the back of the head (generally single digit)
roi_y_size_front=$5 # Use 256 - roi_y_size
roi_z_min_front=$6
roi_z_size_front=$7

#step1: split image into front and back in a way that you avoid the wrapping nose. Select the y-cordinate (voxel not mm) carefully for this

fslroi $wrapped_image $wrapped_image\_back "$roi_x_min $roi_x_size $roi_y_min $roi_y_size $roi_z_min $roi_z_size"
fslroi $wrapped_image $wrapped_image\_front "$roi_x_min $roi_x_size $roi_y_min_front $roi_y_size_front $roi_z_min $roi_z_size"

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
