#!/usr/bin/perl -w

# USAGE print_file_infos filename


use Image::ExifTool;


	my $file = $ARGV[0];
	my $exifTool_object = new Image::ExifTool;
	my $info = $exifTool_object->ImageInfo($file);
	my $tag = 'Keywords';

#	my $val = $exifTool_object->GetValue($tag, 'ValueConv');

		my $val = $$info{$tag};
    	if ( defined $val ) {
    		print $val, "\n";
    	}
		else {
			print "No value for $tag !\n";
		}	

