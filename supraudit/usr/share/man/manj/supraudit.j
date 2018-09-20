.\" Copyright (c) 2004-2009 Apple Inc.
.\" All rights reserved.
.\"
.\" Redistribution and use in source and binary forms, with or without
.\" modification, are permitted provided that the following conditions
.\" are met:
.\" 1.  Redistributions of source code must retain the above copyright
.\"     notice, this list of conditions and the following disclaimer.
.\" 2.  Redistributions in binary form must reproduce the above copyright
.\"     notice, this list of conditions and the following disclaimer in the
.\"     documentation and/or other materials provided with the distribution.
.\" 3.  Neither the name of Apple Inc. ("Apple") nor the names of
.\"     its contributors may be used to endorse or promote products derived
.\"     from this software without specific prior written permission.
.\"
.\" THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND
.\" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
.\" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
.\" ARE DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR
.\" ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
.\" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
.\" OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
.\" HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
.\" STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
.\" IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
.\" POSSIBILITY OF SUCH DAMAGE.
.\"
.\" $P4: //depot/projects/trustedbsd/openbsm/bin/praudit/praudit.1#14 $
.\"
.Dd October 01, 2017
.Dt PRAUDIT j
.Os
.Sh NAME
.Nm supraudit
.Nd "Do what praudit does, only way better, and actually useful"
.Sh SYNOPSIS
.Nm
.Op Fl lnpx
.Op Fl r | s
.Op Fl d Ar del
.Op Ar
.Op Fl S 
.Op Fl C 
.Op Fl J 
.Op Fl R Ar addr 
.Op Fl F Ar proc/net/files
.Op Fl O Ar outputfile

.Sh DESCRIPTION
The
.Nm
utility matches praudit's functionality, but then adds the following useful behaviors:
.Pp
.Bl -tag -width indent
.It Fl S 
Specifies that "supraudit" format is desired. The format is tabular (pipe '|' separated) and resembles that of Linux strace:

TIMESTAMP    |   PROCESS NAME | PID/UID |operation (modifiers) (arguments) = return value
-------------+----------------+---------+--------------------------------------------------
1507164879.89|      vmnet-natd|53832/501|open (read)(flags=0 path=/private/etc/hosts ) = 10
1507164879.89|      vmnet-natd|53832/501|close(fd=10 path=/private/etc/hosts ) = 0

.It Fl C
Turns on color output, which makes it easier to sift through the copious data.
You can also omit this option if the JCOLOR environment variable is set.
If this option is specified and you pipe the output, do so with 'less -R' instead
of more, because the latter can't handle the color curses sequences.

.It Fl J
Indicates JSON output is desired. Cannot be used with -S and will ignore -C

.It Fl R Ar addr 
Rather than log locally, send all the output to a remote supraudit server. This is a great
option if you want to centralize logging, which helps ensure logging integrity and detailed forensics.
The supraudit-GUI may be used to view the logs.

.It Fl O Ar outputfile

Log full (unfiltered) output to specified outputfile (/tmp/supraudit.YYYYMMDDHHmmss is default)
 
.It Fl F 
files proc net

Use pre-defined filters for file operations (files), IPv4/IPv6 (net) or process lifecycle (proc)

.Sh FILES
Unlike the 
.Xr praudit 1
utility, supraudit doesn't care about whatever audit policy is configured via the files in /etc/security.

.Sh OTHER NOTES

supraudit will turn on auditing (the equivalent of 
.Xr audit 1 
-i) when started. Note that a call to 
.Xr audit 1 
-t when supraudit is started will freeze auditing, and supraudit will warn about it. This is expected behavior, and may be changed in a future release.


Future versions of this tool may use a config file, as does the pro version. 

.El
.Sh SEE ALSO
.Xr praudit 1 ,
.Xr auditreduce 1 ,
.Xr audit 4 ,
.Xr auditpipe 4 ,
.Xr audit_class 5 ,
.Xr audit_event 5
.Sh HISTORY
The OpenBSM implementation was created by McAfee Research, the security
division of McAfee Inc., under contract to Apple Computer Inc.\& in 2004.
It was subsequently adopted by the TrustedBSD Project as the foundation for
the OpenBSM distribution.
.Sh AUTHORS
.An -nosplit
This software was created by Jonathan Levin, as part of the toolchest of http://NewOSXBook.com

If you have suggestions for improvement, email J@NewOSXBook.com

.Sh LICENSE

This software is free for personal use. For commercial use, please contact 
.Pp
The Basic Security Module (BSM) interface to audit records and audit event
stream format were defined by Sun Microsystems. God bless Solaris. RIP.
