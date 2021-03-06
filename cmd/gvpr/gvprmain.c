/*************************************************************************
 * Copyright (c) 2011 AT&T Intellectual Property 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors: Details at https://graphviz.org
 *************************************************************************/


/*
 * gvpr: graph pattern recognizer
 *
 * Written by Emden Gansner
 */


#include "config.h"

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#else
#include <ast/compat_unistd.h>
#endif



#include <cgraph/cgraph.h>
#include <cgraph/exit.h>
#include <gvpr/gvpr.h>

#ifdef DEBUG
#include <sfio/sfio.h>
static ssize_t outfn (void* sp, const char *buf, size_t nbyte, void* dp)
{
    write (1, "<stdout> ", 8);
    return write (1, buf, nbyte);
}

static ssize_t errfn (void* sp, const char *buf, size_t nbyte, void* dp)
{
    write (2, "<stderr> ", 8);
    return write (2, buf, nbyte);
}

static int iofread(void *chan, char *buf, int bufsize)
{
    return read(sffileno(chan), buf, bufsize);
}

static int ioputstr(void *chan, const char *str)
{
    return sfputr(chan, str, -1);
}

static int ioflush(void *chan)
{
    return sfsync(chan);
}

static Agiodisc_t gprIoDisc = { iofread, ioputstr, ioflush };

static Agdisc_t gprDisc = { &AgMemDisc, &AgIdDisc, &gprIoDisc };

int
main (int argc, char* argv[])
{
    Agraph_t* gs[2];
    Agraph_t* g = agread (sfstdin, &gprDisc);
    int rv;
    gvpropts opts;

    gs[0] = g;
    gs[1] = 0;
    opts.ingraphs = gs;
    opts.out = outfn;
    opts.err = errfn;
    opts.flags = GV_USE_OUTGRAPH;
    opts.bindings = 0;
    
    rv = gvpr (argc, argv, &opts);

    sfprintf (sfstderr, "rv %d\n", rv);
    /* for (i = 0; i < opts.n_outgraphs; i++) */
	/* agwrite (opts.outgraphs[i], sfstdout); */

    rv = gvpr (argc, argv, &opts);

    graphviz_exit(rv);
}

#else
int
main (int argc, char* argv[])
{
    gvpropts opts;
    opts.ingraphs = 0;
    opts.out = 0;
    opts.err = 0;
    opts.flags = GV_USE_EXIT;
    opts.bindings = 0;
    
    graphviz_exit(gvpr(argc, argv, &opts));
}

#endif

