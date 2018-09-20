#include <bsm/audit.h>
#include <security/audit/audit_ioctl.h>
#include <errno.h>
#include <bsm/libbsm.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <bsm/audit_uevents.h>
#include <bsm/audit_kevents.h>
#include <sys/sysctl.h>
#include <sys/proc.h>


// An almost 100% compatible praudit clone by J@NewOSXBook.com
//
// compile with gcc -lbsm 
//
#define PROGNAME	"praudit"
#define FLAG_NONEWLINE	0x1000


char *g_delim = "|";
void usage(char *MyName)
{

	fprintf(stderr, "usage: %s [-lnpx] [-r | -s] [-d del] [file ...]\n", MyName);


}



void processRecord (unsigned char *Buf, int RecSize, int Flags,char *Delimiter)
{
	   tokenstr_t      tok;

           int pos = 0;
	
           while (au_fetch_tok(&tok, 
                               Buf + pos, // u_char *buf, 
                               RecSize) == 0) //
           {
	 	au_print_flags_tok(stdout, // FILE *outfp, 
                                   &tok,   // tokenstr_t *tok, 
                                   Delimiter,    // char *del, 
                                   Flags); //Flags);     // int oflags);

                RecSize -= tok.len;
                pos += tok.len;
		if (!(Flags & FLAG_NONEWLINE)) fprintf(stdout,"\n");
		else {
			printf("%s",Delimiter);
			}
	   }

} // processRecord


void processFile (FILE *auditPipeFile, int Flags, char *Delim) {

	int recsize;

#define BUFSIZE	8192



	if (Flags & AU_OFLAG_XML) au_print_xml_header(stdout);

	unsigned char *buf;
	int recs  = 0;
	while ((recsize = au_read_rec(auditPipeFile, &buf)) > 0)
	{
	   recs++;

	   processRecord(buf, recsize, Flags,Delim);

	   if (Flags & FLAG_NONEWLINE) {
			fprintf(stdout,"\n");
		}
   	   free(buf);

	}
	if (!recs) {
		fprintf(stderr,"%sNot an audit log%s\n",
		(Flags & AU_OFLAG_XML) ?"<error>": "",
		(Flags & AU_OFLAG_XML) ?"</error>": "");
		}
	if (Flags & AU_OFLAG_XML) au_print_xml_footer(stdout);
} // processFile


int doFile(char *FileName, int Flags,char *Delim) {



	struct stat stBuf;
	
	int fd = open (FileName, O_RDONLY);
	if (fd < 0) { perror (FileName); return 3;}

	int rc = fstat (fd, &stBuf);
	if (rc != 0) { perror ("stat"); close (fd); return 4; }


	if (!(stBuf.st_mode & S_IFREG)) { 
			fprintf(stderr,"%s: Not a regular file\n", FileName);  close(fd); return 5;}

#if 0
	// This would be way more efficient, but au_read_rec (which is used later)
	// requires a FILE *. 

	char *mmapped = mmap (0,             // void *addr, 
			      stBuf.st_size, // size_t len, 
			      PROT_READ,     // int prot, 
			      MAP_PRIVATE,   // int flags, 
			      fd,            // int fd, 
			      0);            // off_t offset);

	if (mmapped == MAP_FAILED) { perror ("mmap"); close (fd); return 6; }
				
	// Audit files are just raw records, and don't have a magic. In practice,
	// however, they all start with "14 00 00 00" (AUT_HEADER32) or AUT_HEADER64
	// One way of checking would be to check for that header, like so

	if (*((uint32_t *) mmapped ) != AUT_HEADER32){
			fprintf(stderr,"%s is not an audit trail file\n", FileName); close (fd); return 7;}

	// But since processFile will call au_read_rec, which will fail if the record header
	// doesn't start the file, this is #ifdef'ed out.

#endif


	FILE *File = fdopen (fd, "r");
	processFile(File , Flags,Delim);
	return 0;

} // doFile
int doPipe(int Flags, char *Delim) {

	uint64_t selectMode;
	int auditPipe = open ("/dev/auditpipe", O_RDWR);
	if (auditPipe < 0) {
		fprintf(stderr,"Unable to open /dev/auditpipe!\n");
		exit(3);
	}

	if (ioctl (auditPipe, AUDITPIPE_GET_PRESELECT_MODE, &selectMode) < 0) {
		perror ("ioctl");
		exit(4);
	}
	// should be one

	selectMode = 2;
	if (ioctl (auditPipe, AUDITPIPE_SET_PRESELECT_MODE, &selectMode) < 0) {
		perror ("ioctl");
		exit(4);
	}


	selectMode =0xffffffffffffffff;
	if (ioctl (auditPipe, AUDITPIPE_SET_PRESELECT_FLAGS, &selectMode) < 0) {
		perror ("ioctl");
		exit(4);
	}

	selectMode= 0;
	if (ioctl (auditPipe, AUDITPIPE_GET_PRESELECT_FLAGS, &selectMode) < 0) {
		perror ("ioctl");
		exit(4);
	}
	uint32_t queueLimit = 0;
	if (ioctl (auditPipe, AUDITPIPE_GET_QLIMIT, &queueLimit) < 0) {
		perror ("ioctl");
		exit(4);
		}
	uint32_t queueLimitMax = 0;
	if (ioctl (auditPipe, AUDITPIPE_GET_QLIMIT_MAX, &queueLimitMax) < 0) {
		perror ("ioctl");
		exit(4);
		}
	if (ioctl (auditPipe, AUDITPIPE_SET_QLIMIT, &queueLimitMax) < 0) {
		perror ("ioctl");
		exit(4);
		}

/*
	if (ioctl (auditPipe, AUDITPIPE_GET_QLIMIT, &queueLimit) < 0) {

		perror ("ioctl");
		exit(4);
		}

	printf ("Queue limit: %d\n", queueLimit);
*/
	//printf("select flags: %d\n",  selectMode); // should be 1 AUDITPIPE_PRESELECT_MODE_TRAIL 

	selectMode= 0xffffffffffffffff;
	if (ioctl (auditPipe, AUDITPIPE_SET_PRESELECT_NAFLAGS, &selectMode) < 0) {
		perror ("ioctl");
		exit(4);
	}


	FILE *auditPipeFile = fdopen (auditPipe, "rw");

	// From this point, it's just a file

	processFile (auditPipeFile, Flags,Delim);




	return 0;

} // doPipe

char *processArguments(int argc, char **argv,int *Flags)
{

	// the real praudit uses getopt(3). Me, I'm not a fan

	char *filename = NULL;

	int arg;
	for (arg = 1; arg < argc; arg++)
	{
		
		if (argv[arg][0] == '-')
		{
			switch (argv[arg][1])
			{
				case 'd':
					g_delim = argv[arg+1];
					arg++;
					break;
				case 's':
					*Flags |= AU_OFLAG_SHORT;
					break;
				case 'r':
					*Flags |= AU_OFLAG_RAW;
					break;
				case 'x':
					*Flags |= AU_OFLAG_XML;
					break;
				case 'l':
					*Flags |= FLAG_NONEWLINE;
					break;
				case 'n':
					*Flags |= AU_OFLAG_NORESOLVE;		
					break;

				default: 
					fprintf(stderr,"%s: illegal option -- %s\n", argv[0],argv[arg]);
					usage(argv[0]);
					exit(1);
	
			}

		}
		else {
			// Could be a filename
			if (access(argv[arg], R_OK) == 0)
			{
				// This IS a filename
				filename = argv[arg];
			}
			else
			{
				fprintf(stderr,"praudit: %s - Not a file I can read from\n", argv[arg]);
				exit(2);
			}
		}

	} // end for
	return (filename);
}


__attribute__((__used__)) static char sccsid[] = "@(#)     PROGRAM:praudit  PROJECT:j-auditutils-39.0.0";



int main (int argc, char **argv)
{

	// This is a compatible, but not identical implementation of praudit

	if (geteuid()) {
		fprintf(stderr,"You're wasting my time, little man. I need root privileges\n");
		exit(2);
	}

	/*
	int t = AUDIT_TRIGGER_INITIALIZE;
	auditon( A_SENDTRIGGER, &t, sizeof(int));

	*/

	int Flags = 0;

	char *fileName = processArguments(argc, argv, &Flags);

	if (!fileName) {
		if (isatty(0))
		{
		fprintf(stderr,"supraudit won't read audit records directly from the terminal. Use a pipe (|) instead. -h will get you help\n");
		exit(1);
		}

		}
	else 
		{
			if (strcmp(fileName,"/dev/auditpipe") == 0) doPipe(Flags, g_delim);
			doFile(fileName, Flags, g_delim);
		}
	exit(0);


}

