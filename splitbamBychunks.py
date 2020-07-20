import pysam
import sys
#infile = pysam.Samfile(sys.argv[1],'rb')
infile = pysam.AlignmentFile(sys.argv[1],'rb')
#infile = pysam.AlignmentFile("inbam")

chunk_size = 1000000
outfile_pattern = "output_segment%d.sam"

chunk = 0
reads_in_this_chunk = 0
old_name = None
outfile = pysam.AlignmentFile(outfile_pattern % chunk, "w", template = infile)

for read in infile.fetch(until_eof=True):

    if old_name != read.query_name and reads_in_this_chunk > chunk_size:
        reads_in_this_chunk = 0
        chunk += 1
        outfile.close()
        outfile = pysam.AlignmentFile(outfile_pattern % chunk, "w", template = infile)

    outfile.write(read)
    old_name = read.query_name
    reads_in_this_chunk += 1

outfile.close()
