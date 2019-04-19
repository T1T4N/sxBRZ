//
//  Kernel.swift
//  sxBRZ
//
//  Created by T!T@N on 04.25.16.
//

import Foundation

struct Kernel_4x4 : CustomStringConvertible //kernel for preprocessing step
{
    var
    /**/a:UInt32, b:UInt32, c:UInt32, d:UInt32,
    /**/e:UInt32, f:UInt32, g:UInt32, h:UInt32,
    /**/i:UInt32, j:UInt32, k:UInt32, l:UInt32,
    /**/m:UInt32, n:UInt32, o:UInt32, p:UInt32
    
    var description: String {
        get {
            return String(format: "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d", self.a, self.b, self.c, self.d, self.e, self.f, self.g, self.h, self.i, self.j, self.k, self.l, self.m, self.n, self.o, self.p )
        }
    }
};

struct Kernel_3x3: CustomStringConvertible
{
    var
    /**/a:UInt32,  b:UInt32,  c:UInt32,
    /**/d:UInt32,  e:UInt32,  f:UInt32,
    /**/g:UInt32,  h:UInt32,  i:UInt32
    
    var description: String {
        get {
            return String(format: "%d %d %d %d %d %d %d %d %d", self.a, self.b, self.c, self.d, self.e, self.f, self.g, self.h, self.i)
        }
    }
};
