#!/bin/bash
# Use this script to fix nose wrapping (nose appearing behind the head due to a poorly planned T1)
#

[ $# -eq 0 ] && { echo "Usage: $0 <original_wrapped_image>  <ymin> <ysize> <ymin_front> <ysize_front>
eg: ./nose_wrapping_fix.sh BEST_9999_RC9999_T1.nii.gz 76 180 3 76"; exit 1; }

file=$1

wrapped_image=`basename $file .nii`
roi_x_min='0'
roi_x_size=$(fslinfo ${file} |grep "dim1" -m 1 |awk '{print $2}')
roi_y_min=$2 #Decide you y coordinate carefully; use the most inferior axial slice as the y coordinate
roi_y_size=$3 #Use 256-(whatever y coordinate you end up selecting above)
roi_z_min='0'
roi_z_size=$(fslinfo ${file} |grep "dim3" -m 1 |awk '{print $2}')

roi_y_min_front=$4 # Use coordinate from the back of the head (generally single digit)
roi_y_size_front=$5 # Use 256 - roi_y_size


#step1: split image into front and back in a way that you avoid the wrapping nose. Select the y-cordinate (voxel not mm) carefully for this

fslroi $wrapped_image $wrapped_image\_back $roi_x_min $roi_x_size $roi_y_min $roi_y_size $roi_z_min $roi_z_size
fslroi $wrapped_image $wrapped_image\_front $roi_x_min $roi_x_size $roi_y_min_front $roi_y_size_front $roi_z_min $roi_z_size

#step2: merge image along y-axis

fslmerge -y $wrapped_image\_merged $wrapped_image\_front.nii.gz $wrapped_image\_back.nii.gz

#step3: make sure image dimensions match original image

og_dim1=$(fslinfo $wrapped_image |grep "dim1" -m 1 |awk '{print $2}')
og_dim2=$(fslinfo $wrapped_image |grep "dim2" -m 1 |awk '{print $2}')
og_dim3=$(fslinfo $wrapped_image |grep "dim3" -m 1 |awk '{print $2}')

new_dim1=$(fslinfo $wrapped_image\_merged.nii.gz -m 1 |grep "dim1" |awk '{print $2}')
new_dim2=$(fslinfo $wrapped_image\_merged.nii.gz -m 1 |grep "dim2" |awk '{print $2}')
new_dim3=$(fslinfo $wrapped_image\_merged.nii.gz -m 1 |grep "dim3" |awk '{print $2}')

echo $og_dim1 $new_dim1
echo $og_dim2 $new_dim2
echo $og_dim3 $new_dim3
