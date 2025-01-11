# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PythonLibs/Genesis2/ErrorHandlers.py#1 $
# ** $DateTime: 2012/11/11 10:31:47 $
# ** $Change: 11340 $
# ** $Author: shacham $
# *************************************************************************

###################################################################################
# Copyright (c) 2013, Ofer Shacham and Stanford University                        #
# All rights reserved.                                                            #
#                                                                                 #
# Redistribution and use in source and binary forms, with or without              #
# modification, are permitted provided that the following conditions are met:     #
#                                                                                 #
# 1. Redistributions of source code must retain the above copyright notice, this  #
#    list of conditions and the following disclaimer.                             #
# 2. Redistributions in binary form must reproduce the above copyright notice,    #
#    this list of conditions and the following disclaimer in the documentation    #
#    and/or other materials provided with the distribution.                       #
#                                                                                 #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"     #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE  #
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR #
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES  #
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;    #
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND     #
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT      #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF        #
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               #
#                                                                                 #
# The views and conclusions contained in the software and documentation are those #
# of the authors and should not be interpreted as representing official policies, #
# either expressed or implied, of Stanford University.                            #
#                                                                                 #
# For more information please contact                                             #
#   Ofer Shacham (Stanford Univ./Chip Genesis)   shacham@alumni.stanford.edu      #
#   Professor Mark Horowitz (Stanford Univ.)     horowitz@stanford.edu            #
###################################################################################

import sys

class Error(Exception):
    """Base class for exceptions in Genesis2."""
    def __init__(self, msg=''):
        self.msg = msg
        if msg!='': sys.stderr.write('\n\tERROR: '+msg+'\n\n')
    pass

class XMLSchemaError(Error):
    """Exception raised for errors when the input does not match the Genesis2 XML Schema

    Attributes:
        msg  -- explanation of the error
    """

class XMLElementMissingError(Error):
    """Exception raised for errors when a sought after elelment is missing.

    Attributes:
        msg  -- explanation of the error
    """

class XMLParameterError(Error):
    """Exception raised for errors when a parameter value cannot be parsed.

    Attributes:
        msg  -- explanation of the error
    """
class XMLCrawlerError(Error):
    """Exception raised for errors when code is just broken

    Attributes:
        msg  -- explanation of the error
    """
class XMLCrawlerArgumentError(Error):
    """Exception raised for errors when code is just broken

    Attributes:
        msg  -- explanation of the error
    """
