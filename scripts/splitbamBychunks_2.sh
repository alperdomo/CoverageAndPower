samtools sort -n -O SAM input.bam|awk -v n=1000000 -v FS="\t" '
BEGIN { part=0; line=n }
/^@/ {header = header$0"\n"; next;}
{ if( line>=n && $1!=last_read ) {print part,line; part++; line=1;}
  print line==1 ? header""$0 : $0 | "samtools view -b -o "part".bam"
  last_read = $1;
  line++;
}
