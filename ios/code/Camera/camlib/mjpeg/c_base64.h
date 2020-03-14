//
//  c_base64.h
//  PooeaMonitor
//
//  Created by sohn on 11-9-6.
//  Copyright 2011年 Pooea. All rights reserved.
//

#include "stdio.h"
#include "stdlib.h"

long int base64_encode( char *src,long int src_len, char *dst);
long int base64_decode(char *src, long int src_len, char *dst);
