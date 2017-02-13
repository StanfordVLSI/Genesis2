# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PythonLibs/Genesis2/ErrorHandlers.py#1 $
# ** $DateTime: 2012/11/11 10:31:47 $
# ** $Change: 11340 $
# ** $Author: shacham $
# *************************************************************************



################################################################################
# Copyright by Ofer Shacham and Stanford University.  ALL RIGHTS RESERVED.     #
# The code, the algorithm, or any parts of it is not to be copied/reproduced   #
#                                                                              #
# This code is intended for educational use only. The code, the algorithm, or  #
# the results from running this code is not to be used for any commercial use. #
#                                                                              #
# Genesis2 is patent pending. For information regarding the patent please      #
# contact the Stanford Technology Licensing Office:                            #
#   Web: http://otl.stanford.edu/                                              #
#   Email: info@otlmail.stanford.edu                                           #
#                                                                              #
# For more information please contact                                          #
#   Stanford Researcher Ofer Shacham   (shacham@alumni.stanford.edu)           #
#   Stanford's Professor Mark Horowitz  (horowitz@stanford.edu)                #
################################################################################

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
