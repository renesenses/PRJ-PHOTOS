#!/usr/bin/perl -w

# USAGE print_file_infos filename

use Data::Dumper;
use Image::ExifTool;


	my $file = $ARGV[0];
	my $exifTool_object = new Image::ExifTool;
	my $info = $exifTool_object->ImageInfo($file);

	print Dumper($info);
