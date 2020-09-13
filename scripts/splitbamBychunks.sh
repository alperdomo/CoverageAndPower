filename=$1
samtools sort -O SAM $filename |awk -v n=125000 -v FS="\t" '
BEGIN { subset=0; lines=n }
/^@/ {header = header$0"\n"; next;}
{ if( lines>=n && $1!=last_line ) {print subset,lines; subset++; lines=1;}
  print lines==1 ? header""$0 : $0 | "samtools view -b -o "subset".bam"
  last_line = $1;
  lines++;
}
'
