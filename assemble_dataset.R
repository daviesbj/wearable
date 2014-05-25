## assemble_dataset
## Returns a dataframe for a UCI HAR dataset contained in & below the directory that the distribution unzips into
## Key files in unzip directory, per-set fils in named subdirectory
## Checks file availability, and if so assembles the dataset
## Changes activity to a factor, and adds headings to 561 feature values and 3x3x128 raw data values per record
## Returns a dataframe, optionally saves it to a file
assemble_dataset <- function( set.name, source.dir = "~/wearable/UCI HAR Dataset", verbose=TRUE, savefile = "" ){

if( verbose ) message( " ... checking file availability for dataset '", set.name, "'" )
file.list <- file_info( set.name, source.dir = source.dir, verbose = verbose )
if( any( ! file.list$ok) ) stop( "Something wrong with data files -- run file_info and investigate")
if( verbose ) message( " ... looks good!" )

if( verbose ) message( " ... reading ", "activity_labels.txt" )
activity_labels.frame <- read.table( as.character(file.list["activity_labels.txt",]$file) )

if( verbose ) message( " ... reading ", "features.txt" )
features_desc.frame   <- read.table( as.character(file.list["features.txt",]$file) )

subject.file <- paste( "subject_", set.name, ".txt", sep="" )
if( verbose ) message( " ... reading ", subject.file )
subject.frame <- read.table( as.character(file.list[subject.file,]$file) )
colnames(subject.frame)<-c('subject')

y.file <- paste( "y_", set.name, ".txt", sep="" )
if( verbose ) message( " ... reading ", y.file )
y.frame <- read.table( as.character(file.list[y.file,]$file) )
y.factor <- activity_labels.frame$V2[y.frame$V1]
y.frame2 <- as.data.frame(y.factor)
colnames(y.frame2) <- c('activity')

X.file <- paste( "X_", set.name, ".txt", sep="" )
if( verbose ) message( " ... reading ", X.file )
X.frame <- read.table( as.character(file.list[X.file,]$file) )
colnames(X.frame) <- features_desc.frame$V2

if( verbose ) message( " ... starting assembly" )
result.frame<-cbind(subject.frame,y.frame2,X.frame)
rm(X.frame)

for( inert.type in c( "body_acc", "body_gyro", "total_acc" ) ){
  for( axis in c( "x", "y", "z") ){
    inert.id <- paste( inert.type, "_", axis, sep="" )
    inert.file <- paste( inert.id, "_", set.name, ".txt", sep="" )
    if( verbose ) message( " ... reading ", inert.file )
    inert.frame <- read.table( as.character(file.list[inert.file,]$file) )
    inert.labels <- sapply( c(1:128), function(x){ sprintf( paste( inert.id, '.', "%03d", sep="" ), x ) } )
    colnames(inert.frame) <- inert.labels
    result.frame <- cbind(result.frame,inert.frame)
    rm(inert.frame)
  }
}

if( savefile != "" ){
  if( verbose ) message(  " ... attempting to write to ", savefile )
  write.csv( result.frame, savefile )
}

result.frame
}
