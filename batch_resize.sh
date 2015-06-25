#! /bin/bash

# Name: Weinnig, Jack
# Project: PA-4 (Shell Programming)
# File: bash_resize.sh
# Instructor: Feng Chen
# Class: cs4103-sp15
# LogonID: cs410372

# Program works with directories with images in the base folder
# and in subfolders, but does not work recursively. 
# Sample runs: ./batch_resize lfw output "10 20"
#			   ./batch_resize lfw/Madonna output "10 20"

input_dir=$1
output_dir=$2
ratio_list=$3
let subdir_count=0
let num_processed=0
let total_size_original=0
let total_size_reduced=0

print_help() {
	echo
	echo "---------------------------------------------------------------"
	echo "Version: Batch Resizer 1.0"
	echo "Author: Jack Weinnig"
	echo "Dependencies: Imagemagick"
	echo "Usage: ./batch_resize [input_dir] [output_dir]\"[ratio_list]\""
	echo "---------------------------------------------------------------"
	echo
}

test_env() {
	if [ $# -gt 0 ]; then
		if [ $input_dir == "help" ]; then 
			printHelp
			exit 0
		fi

 		if [ -d $input_dir ]; then
 			if [ -d $output_dir ]; then
 				echo Output directory $output_dir already exists
 				exit
			fi
		else
			echo $input_dir not found!
			exit 0
 		fi
	else
		print_help
		exit 0
	fi
}

create_output_dir() {
	echo
  	mkdir $output_dir
  	subdir_count=`find $input_dir -maxdepth 1 -type d | wc -l`
  	if [ $subdir_count -gt 1 ]; then
		for dir in $input_dir/*/; do
 			mkdir $output_dir/$(basename $dir)
		done
	fi
}

#resize_image(original_image, resized_image)
resize_image() {
	original_image=$1

	name=`echo "$(basename $original_image)" | cut -d'.' -f1`
	ext=`echo "$original_image" | cut -d'.' -f2`
	
	if [ $subdir_count -gt 1 ];
		then
			base=$(basename $(basename $(dirname $original_image)))"/"
		else
			base=""
	fi

	original_filesize=$(wc -c $original_image | awk '{print $1;}')
	total_size_original=$((total_size_original+$original_filesize))
	echo Original File: $(basename $original_image): $original_filesize KB

  for ratio in $ratio_list; do
    new_name="$name""-r""$ratio"".""$ext"
    dest="$output_dir""/""$base""$new_name"

    convert -resize "$ratio%" $original_image $dest
    resized_filesize=$(wc -c $dest | awk '{print $1;}')
    total_size_reduced=$((total_size_reduced+$resized_filesize))
    echo Reduced File: $new_name :$resized_filesize KB
  done
}

batch_resize(){
  	if [ $subdir_count -gt 1 ]; then
		for dir in $input_dir/*;
		do
			for image in $dir/*;
			do
				resize_image $image
				num_processed=$((num_processed+1))
			done
		done
	else
		for image in $input_dir/*;
			do
				resize_image $image 
				num_processed=$((num_processed+1))
			done
	fi
}

print_summary() {
	echo
	echo "---------------------------------------------------------------"
	echo "                          Summary:"
	echo "Number of Images Processed: 		$num_processed"
	echo "Total Size of Original Files:		$total_size_original KB"	
	echo "Total Size of Reduced Files :		$total_size_reduced KB"
	echo "---------------------------------------------------------------"
	echo
}

test_env input_dir output_dir
create_output_dir
batch_resize
print_summary



