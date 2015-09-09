#!/usr/bin/env perl

use Image::ExifTool;
#use Image::Magick;
use File::Compare;
use File::Basename;
use File::Path;
use File::Spec;
use File::Copy;
use File::Find;
use Data::Dumper;
#use Digest::MD5;

use strict;

# CSV $csv FIELD CONTENT :
# 1-  IMG_ID (empty, computed by Filemaker during import process or ... calculated if required) 
# 2-  IMG_FULL_FILENAME ( $File::Find::name )
# 3-  IMG_FILENAME ( $_ )
# 4-  IMG_SEQUENCE ( 4 derniers digits if dir3 <> SCANS, "" else or undefined
# 5-  IMG_EXT ( déjà fait )
# 6-  IMG_FORMAT ( exiftool mime-type )
# 7-  IMG_ORIENTATION  ( exiftool orientation )
# 8-  IMG_SIZE ( exiftool size )
# 9-  IMG_DATE ( exiftool 'FileModifyDate' if defined )
# 10- IMG_MONTH ( from dir1 if first word is a month )
# 11- IMG_MD5 ( nok : later must check to use md5 on File(open image) ) #### NOT USED
# 00- IMG_FULL_MD5 ( ok )
# 12- IMG_STATUS (set to "Créé" )
# 13- IMG_DIR1 : dir-1 name
# 14- IMG_DIR2 : dir-2 name
# 15- IMG_DIR3 : dir-3 name


# REC_FILES struct
#  2 {fullfilename} 	: Only FILENAME with complete PATH
#  3 {filename} 		: Only FILENAME without PATH
#  4 {sequence} 		: FROM filename if defined
#  5 {extension} 		: FROM fileparse
#  6 {image_format}		: FROM EXIF MIMEType
#  7 {orientation}		: FROM EXIF Orientation
#  8 {image_size}		: FROM EXIF ImageSize
#  9 {date}				: FROM EXIF FileModifyDate
# 10 {month}			: FROM premier word de dir-1 if correspond to a month without case
# 11 {md5}				: md5($File::Find::name); 
# 00 EMPTY
# 10 {dir_type}			: FROM fileparse $dir[$DIM_HOME_ENV+1];
# 12 {status}			: Créé 
# 13 {dir-1}			:
# 14 {dir-2}			:
# 15 {dir-3}			:



## UNUSED
#	{path}				: $File::Find::dir;
#	{size} 				: FROM EXIF FileSize
# 	{mtime} 			: FROM stat $mtime;		
#	{keywords} 			: FROM EXIF Keywords


# REC_DIRS struct
#	{dir_name} 			: FROM File::Spec->catdir( @dir );
#	{dir_level} 		: FROM $#dir;
#	{nb_files_in_dir}	: 


# REC_REPORT struct
#	{id} 				: FROM localtime
#	{proc} 				: FROM $#dir;
#	{arg}				: ARGUMENT (SALAR or ARRAY )
#	{nb_files_read}		: NB
#	{nb_files_mod}		: NB
#	{rep_status}		: Global status computed (1 if no error lines, 0 else )
#	{lines_status} 		: ARRAY OF HASHES
#		[	{inf}		: Input file
#		[	{ouf}		: Output file
#		[	{status}	: 1 for success, 0 for failure
#		[   {error}		: error if any

# REC_LINE_REPORT struct
#		{rec_line_id}		: line nb
#		{rec_line_if_file}	: Input file
#		{rec_line_of_file}	: Output file
#		{rec_line_status}	: 1 for success, 0 for failure
#		{rec_line_error}	: error if any

##########################################################################################
# CONSTANTS
##########################################################################################

my $CSV_T_IMAGES 			= "/Users/bertrand/GIT_REPO/PRJ-PHOTOS/check-scans/filemaker/RECORDS_4_IMPORT/T_IMAGES.csv";

# WITH NAS
my $BACKUP_VOLUME 			= "/Volumes/BACKUP";
# my $BACKUP_ENV_LOCATION 	= "/SAUVEGARDES/IMAGES/TEST_MINOLTA";
my $BACKUP_ENV_LOCATION 	= "/SAUVEGARDES/IMAGES/MINOLTA";
# my $BACKUP_ENV 				= "/TEST"; # For testing
# my $ENV 					= "MINOLTA"; # For production

my $BACKUP_HOME_ENV			= File::Spec->catdir( $BACKUP_VOLUME, $BACKUP_ENV_LOCATION ); 
my @BACKUP_HOME_ENV			= File::Spec->splitdir( $BACKUP_HOME_ENV );
my $DIM_BACKUP_HOME_ENV		= $#BACKUP_HOME_ENV ; # (5)

# my $BACKUP_DIR			= File::Spec->catdir( $BACKUP_VOLUME, $BACKUP_ENV_LOCATION, $BACKUP_ENV );

# FOR LOCAL PURPOSE

my $LOCAL_VOLUME			= "/Users";
my $LOCAL_ENV_LOCATION		= "/LochNessIT/Pictures"; 
my $LOCAL_ENV 				= "/MINOLTA";

my $LOCAL_HOME_ENV			= File::Spec->catdir( $LOCAL_VOLUME, $LOCAL_ENV_LOCATION, $LOCAL_ENV ); 
my @LOCAL_HOME_ENV			= File::Spec->splitdir( $LOCAL_HOME_ENV );
my $DIM_LOCAL_HOME_ENV		= $#LOCAL_HOME_ENV ; # (5)

# my $LOCAL_DIR				= File::Spec->catdir( $LOCAL_VOLUME, $LOCAL_ENV_LOCATION, $LOCAL_ENV );


my @MONTHS					= qw(janvier fevrier février mars avril mai juin juillet aout septembre octobre novembre decembre décembre);

my %MONTHS;


# LEVELS DIR LIST
my $SCAN_DIR 				= "SCANS";
my $TEMP_DIR 				= "TEMP";
my $POST_DIR 				= "POST";
my $META_DIR 				= "META";
my $JPG_DIR 				= "JPEG";
my $ERROR_DIR				= "ERROR";
my $TRASH_DIR				= "TRASH";
my $PHOTOS_DIR				= "PHOTOS";



my %REC_DIR;
my %REC_FILE;
my %REC_REPORT;
my %REC_LINE;

my $files_read;
my $files_mod; # files in csv
my $report_id;

##########################################################################################
# SUBS
##########################################################################################

sub build_hash_months {
	foreach my $month ( @MONTHS ) {
		$MONTHS{$month}++;
	}
}

sub is_an_image {
	my $file = $_[0];
	my $exifTool_object = new Image::ExifTool;
	my $info = $exifTool_object->ImageInfo($file);
	my $tag = 'MIMEType';
	my $val = $exifTool_object->GetValue($tag, 'ValueConv');
	
	if ( (defined $val) && ($val =~ /^(image)\/([^\/]+)/) ) {
		return 1;
	}	
	else {
		return 0;
	}
}

sub read_images {
	my $dir = $_[0];
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	$mon 	+= 1;
	$year 	+= 1900;
	$mday 	= substr("0".$mday,length("0".$mday)-2, 2);
	$mon 	= substr("0".$mon,length("0".$mon)-2, 2);
	$hour 	= substr("0".$hour,length("0".$hour)-2, 2);
	$min 	= substr("0".$min,length("0".$min)-2, 2);
	
	$report_id = join("_", $year, $mon, $mday, join("-", $hour,$min));
	
	my $proc = "BUILD_CSV";
	$files_read = 0,
	$files_mod = 0;
	init_proc_report($report_id, $proc, $dir);
	
	find(\&build_REC_FILE, $dir);

	if ( $REC_REPORT{$report_id}{rep_status} ) {
		print "Dossier ",$dir,",contenant ",$files_read," fichiers lus sur le NAS\n";
	}
	else {
		print "Echec de la procédure ", $proc," du dossier ",$dir,". ",$files_mod," / ",$files_read," ajoutés au fichier csv \n";
	}
}	

sub init_proc_report {

	my $report_id 	= $_[0];
	my $proc		= $_[1];
	my $dir			= $_[2];

	my $rec_report;
	
	$rec_report->{id} 					= $report_id;
	$rec_report->{proc}					= $proc;
	$rec_report->{args}					= $dir;
	$rec_report->{nb_files_read} 		= 0;
	$rec_report->{nb_files_mod}			= 0;
	$rec_report->{rep_status}			= -1;
	$rec_report->{lines_status}			= [ ];
	$REC_REPORT{ $rec_report->{id} } 	= $rec_report;
	
}

sub get_sequence {
	my $fullname = $_[0];
	my ($file,$dir,$ext) = fileparse($fullname, qr/\.[^.]*/);
	if ($file =~ /_([0-9]{3})$/ ) {
		return $1;
	}
	else {
		return 0;
	}		
}

sub is_a_month {
	my $str = $_[0];
	if ( $MONTHS{uc($str)} ) {
		return 1;
	}
	else {
		return 0;
	}		
}

sub get_file_extension {
	my $fullname = $_[0];
	my ($file,$dir,$ext) = fileparse($fullname, qr/\.[^.]*/);
	if ($ext eq "") {
		return $ext;
	}
	else {
		return substr($ext,1);
	}
}

sub compute_md5_file {
    my $filename = shift;
    open (my $fh, '<', $filename) or die "Can't open '$filename': $!";
    binmode ($fh);
    return Digest::MD5->new->addfile($fh)->hexdigest;
}

sub build_REC_FILE {
	
	if ( !($_ =~ /^\./) ) {
		if ( -d $_ ) {
			
    	}	
    	else {
    	
    		# my ($file,$dir,$ext) 	= fileparse($File::Find::name, qr/\.[^.]*/);  
    		
    		my @dir_array 			= File::Spec->splitdir( $File::Find::dir );
    		
    		$files_read++;
    		
    		my $rec_line;
    		
	   		$rec_line->{id}		= $files_read;
	   		$rec_line->{inf}	= $File::Find::name;
    		
    		my $exifTool_object 	= new Image::ExifTool;
    		my $info 				= $exifTool_object->ImageInfo($File::Find::name); 
    		my $mimetype_val 		= $exifTool_object->GetValue('MIMEType', 'ValueConv');
	
			if ( (defined $mimetype_val) && ($mimetype_val =~ /^(image)\/([^\/]+)/) ) {
				$files_mod++;
				$rec_line->{error} 	= "Image insérée dans le csv ";
				$rec_line->{status} = 1;
			
    			my $rec_file;
    			
    			$rec_file->{fullfilename}		= $File::Find::name; 
    			$rec_file->{filename} 			= $_;
    			$rec_file->{sequence} 			= get_sequence($File::Find::name);
				$rec_file->{extension} 			= get_file_extension($File::Find::name);
				$rec_file->{image_format}		= $exifTool_object->GetValue('MIMEType','ValueConv');
				$rec_file->{file_size}			= $exifTool_object->GetValue('FileSize','ValueConv');
#				$rec_file->{image_size} 		= $exifTool_object->GetValue('ImageSize','ValueConv');
				$rec_file->{orientation}		= $exifTool_object->GetValue('Orientation','ValueConv');	
				$rec_file->{date}				= $exifTool_object->GetValue('FileModifyDate','ValueConv');
				$rec_file->{rep1}				= $dir_array[$DIM_BACKUP_HOME_ENV+2];
				$rec_file->{rep2}				= $dir_array[$DIM_BACKUP_HOME_ENV+1];
				$rec_file->{rep3}				= $dir_array[$DIM_BACKUP_HOME_ENV];
#				$rec_file->{md5}				= compute_md5_file($File::Find::name);
				$rec_file->{status}				= "Créée";
				
				my $keywords_val 				= $exifTool_object->GetValue('Keywords', 'ValueConv');
				
				
#				print scalar(@{ $keywords_val }),"\n"; # DEBUD
				
				if ( (ref $keywords_val eq 'ARRAY') && (scalar(@{ $keywords_val }) == 3) ) {			
					$rec_file->{read_source}	= $$keywords_val[2];
				}			
				else {
					$rec_file->{read_source}	= "";
				}
				
#				$rec_file->{read_source}		= $$keywords_val[2];	
								
				my @temp						= split(" ",$rec_file->{rep1});
			
    			$REC_FILE{ $rec_file->{fullfilename} } = $rec_file;
			}
			# NOT AN IMAGE FILE
			
			else {
   				
   				$rec_line->{error} 	= "Not an image file";
				$rec_line->{status} = 0;
				
				$REC_REPORT{$report_id}{rep_status} = 0;
			}	
			
			$REC_LINE{ $rec_line->{id} } = $rec_line;
			
			push @{ $REC_REPORT{$report_id}{lines_status} }, $REC_LINE{$files_read}; 
			 
	   		$REC_REPORT{$report_id}{nb_files_read}		= $files_read;
	   		$REC_REPORT{$report_id}{nb_files_mod} 		= $files_mod;
	   		$REC_REPORT{$report_id}{rep_status} 		**= 2; # RULE TO COMPUTE GLOBAL STATUS 1 FOR SUCESS
						
		}	
	}
}

sub create_csv_T_IMAGES {

 	open my $csv, '+>', $CSV_T_IMAGES or die "Can't open '$CSV_T_IMAGES': $!";

	printf $csv "IMG_ID,IMG_FULL_FILENAME,IMG_FILENAME,IMG_SEQUENCE,IMG_EXT,IMG_FORMAT,IMG_ORIENTATION,IMG_FILESIZE,IMG_DATE,IMG_STATUS,IMG_DIR1,IMG_DIR2,IMG_DIR3,IMG_SOURCE\n";

	# a sort can be usefull !!
	
	for my $line ( keys %REC_FILE ) {
		print $csv ",";											# empty IMG_ID
		print $csv $REC_FILE{$line}->{fullfilename},","; 		# IMG_FULL_FILENAME
		print $csv $REC_FILE{$line}->{filename},",";			# IMG_FILENAME
		print $csv $REC_FILE{$line}->{sequence},",";	 		# IMG_SEQUENCE
		print $csv $REC_FILE{$line}->{extension},",";			# IMG_EXT
		print $csv $REC_FILE{$line}->{image_format},",";		# IMG_FORMAT
		print $csv $REC_FILE{$line}->{orientation},",";			# IMG_ORIENTATION
#		print $csv $REC_FILE{$line}->{image_size},",";	 		# IMG_SIZE		
		print $csv $REC_FILE{$line}->{file_size},",";	 		# IMG_FILESIZE		
		print $csv $REC_FILE{$line}->{date},",";	  			# IMG_DATE
#		print $csv $REC_FILE{$line}->{month},",";		 		# IMG_MONTH
#		print $csv $REC_FILE{$line}->{md5},",";		 			# IMG_MD5
		print $csv $REC_FILE{$line}->{status},",";	 			# IMG_STATUS
		print $csv $REC_FILE{$line}->{rep1},",";	 			# IMG_DIR1
		print $csv $REC_FILE{$line}->{rep2},",";	 			# IMG_DIR2
		print $csv $REC_FILE{$line}->{rep3},",";	 			# IMG_DIR3
		print $csv $REC_FILE{$line}->{read_source},"\n";	 	# IMG_SOURCE
	}
	close($csv);
}	

sub print_SIMPLE_REPORT {
	print "[ REPORT FOR : ",$report_id," ] \n";

	print 		"\t ", $REC_REPORT{$report_id}{proc},"\n", 
				"\t ", $REC_REPORT{$report_id}{args},"\n",	
				"\t ", $REC_REPORT{$report_id}{nb_files_read},"\n",
				"\t ", $REC_REPORT{$report_id}{nb_files_mod},"\n",
				"\t ", $REC_REPORT{$report_id}{rep_status},"\n";
	for my $line ( @{ $REC_REPORT{$report_id}{lines_status} } ) {
		# print "\t [ ",$line->{id},"\t",$line->{inf},"\t",$line->{ouf},"\t",$line->{status},"\t",$line->{error}," ] \n";
		print "\t [ ",$line->{id},"\t",$line->{inf},"\t",$line->{status},"\t",$line->{error}," ] \n";
		}	
			
}

sub print_SIMPLE_REC_LINE {
	print "REC LINE FOR : ",$files_read,"\n";

	print "( ", 
			$REC_LINE{$files_read}{inf},"\t", 
#			$REC_LINE{$files_read}{ouf},"\t",	
			$REC_LINE{$files_read}{status},"\t",
			$REC_LINE{$files_read}{errro},"\n";
}

# MAIN
build_hash_months;
read_images($BACKUP_HOME_ENV);
print_SIMPLE_REPORT;
create_csv_T_IMAGES;
