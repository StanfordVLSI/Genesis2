# *************************************************************************
# ** From Perforce:
# **
# ** $Id: //Smart_design/ChipGen/bin/Genesis2Tools/PythonLibs/Genesis2/XMLCrawler.py#4 $
# ** $DateTime: 2013/06/11 02:47:41 $
# ** $Change: 11877 $
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
import copy
import re
import xml.etree.ElementTree as ET
from xml.etree.ElementTree import Element
from Genesis2.ErrorHandlers import *



class XMLCrawler:
  """ Class for parsing Genesis2 XML output """
  _Debug = 0;
  
  ############################
  # constructor and friends
  ############################

  def __init__(self, debug=0):
    _Debug = debug
    self._DB = None
    self._XMLPos = None
    self._XmlFileName = None
    self._Parent = None
    self._SubInsts = []
    
  def copy(self):
    return copy.copy(self)

  def __str__(self):
    if self._XmlFileName is None:
      return self.__class__.__name__+"(file=None) instance at "+hex(id(self))
    else:  
      return self.__class__.__name__+"(file="\
          +self._XmlFileName+") instance '"+self.iname()+"' at "\
          +hex(id(self))

  def read_xml(self, xmlfilename):
    self._XmlFileName = xmlfilename
    self._DB = ET.parse(xmlfilename)
    self._XMLPos = self._DB.getroot()
    self._map();

  def _map(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    subInstsElem =  self._XMLPos.find('SubInstances')
    if subInstsElem is None:
      return
    for subInstItemElem in subInstsElem.findall('SubInstanceItem'):
      c = self.copy()
      c._Parent = self
      c._SubInsts = []
      c._XMLPos = subInstItemElem
      self._SubInsts.append(c)
      c._map() # recursive call to map the hierarchy
    


  #################################################
  #### Getters
  #################################################

  #### Traversal related methods
  ##############################
  def get_parent(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    # is parent already saved?
    if self._Parent is not None:
      return self._Parent
    # am I top?
    elif self._XMLPos == self._DB.getroot():
      return None
    else:
      raise XMLCrawlerError("Internal error: self._Parent not found!")

  def get_top(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    c = self
    while (c.get_parent() is not None):
      c = c.get_parent()
    return c

  def iname(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    nameElem =  self._XMLPos.find('InstanceName')
    return nameElem.text

  def mname(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    nameElem =  self._XMLPos.find('UniqueModuleName')
    return nameElem.text

  def bname(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    nameElem =  self._XMLPos.find('BaseModuleName')
    return nameElem.text

  def sname(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    nameElem =  self._XMLPos.find('SynonymFor')
    if nameElem is None:
      nameElem =  self._XMLPos.find('BaseModuleName')
    return nameElem.text


  def exists_subinst(self, name):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    for subinst in self._SubInsts:
      if subinst.iname() == name:
        return True
    return False


  def get_subinst(self, name):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    c = None
    for subinst in self._SubInsts:
      if subinst.iname() == name:
        c = subinst
        break
    if c == None:
        raise XMLElementMissingError("No sub instance named '" + name + "' found")
    return c

  def get_subinst_array(self,pattern='.*'):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    c_arr = []
    for subinst in self._SubInsts:
      if re.search(pattern, subinst.iname()):
        c_arr.append(subinst)
    return c_arr

  def get_instance_path(self):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    path = self.iname()
    c = self.get_parent()
    if c is not None: path = c.get_instance_path() + '.' + path
    return path

  def _search_subinst_params(self, from_node, depth, iNameRegex, mNameRegex, bNameRegex, sNameRegex, reverse):
    """
    Helper function for subinstance searching that works with the paramters
    directly rather than building and re-parsing a dictionary for every node
    """
    results = []
      
    if (depth>=0 and not reverse): # Pre-order traversal, add ourselves after children
      # Use short-circuiting OR to evaluate each case
      if (iNameRegex is None or re.search(iNameRegex, from_node.iname())) and \
         (mNameRegex is None or re.search(mNameRegex, from_node.mname())) and \
         (bNameRegex is None or re.search(bNameRegex, from_node.bname())) and \
         (sNameRegex is None or re.search(sNameRegex, from_node.sname())):
      	results.append(from_node)

    if (depth>=1):
      subinsts = from_node.get_subinst_array('.*')
      for s in subinsts:
        subresults = s._search_subinst_params(s, depth - 1, iNameRegex, mNameRegex, bNameRegex, sNameRegex, reverse)
        results.extend(subresults)

    if (depth>=0 and reverse): # Post-order traversal, add ourselves after children
      # This is/should be identical to the preorder traversal case
      if (iNameRegex is None or re.search(iNameRegex, from_node.iname())) and \
         (mNameRegex is None or re.search(mNameRegex, from_node.mname())) and \
         (bNameRegex is None or re.search(bNameRegex, from_node.bname())) and \
         (sNameRegex is None or re.search(sNameRegex, from_node.sname())):
      	results.append(from_node)

    return results


  def search_subinst(self, options = dict()):
    """
    API method for searching the entire design hierarchy or portions of it
    according to user defined criteria. All criteria are optional. The
    returned value is a list of objects that match ALL specified criteria.

    From - Either pointer or text path to an instance work here (default is the design top)
    Depth - How deep in the hierarchy should we search? (default is 10000 ;-)
    PathRegex - Return only instances who's path matches some regular expression (e.g., '.*\.ahb0\..*')
    INameRegex - Return only instances who's instance name matches a regular expression
    MNameRegex - Return only instances who's finalized module name matches a regular expression
    BNameRegex - Return only instances who's base module name (before uniquification) matches a regular expression
    SNameRegex - Return only instances who's source file name matches a regular expression
    HasParamRegex - Return only instances that has a parameter who's name matches the regular 
                    expression. The HasParamRegex arg can be either a string (e.g., 'Width') 
                    or a string array ref (e.g., ['Width', 'Radix']). Note that in the string 
                    array case, we search for instances that has a param that matchs regex1 AND 
                    a param that matches regex2 AND...
    ApplyMap - If you have some complex way of determining if an instance should be returned, 
               you can create your own function that accept/reject an objects. Your function 
               must return False/True. E.g., def func(node): return (node.iname() == 'ofer')
    Reverse - Search hierarchy as a preorder (true) or postorder (false) traversal.
    """

    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    from_node = self.get_top()
    depth = 10000
    reverse = False
    iNameRegex = None
    mNameRegex = None
    bNameRegex = None
    sNameRegex = None
    
    # Parse the parameters and save them as local vars
    for key in options.keys():
      if re.search('depth', key, re.IGNORECASE):
        depth = options[key]
      elif re.search('from', key, re.IGNORECASE):
        from_node = options[key]
      elif re.search('reverse', key, re.IGNORECASE):
        reverse = options[key]
      elif re.search('inameregex', key, re.IGNORECASE):
        iNameRegex = options[key]
      elif re.search('mnameregex', key, re.IGNORECASE):
        mNameRegex = options[key]
      elif re.search('bnameregex', key, re.IGNORECASE):
        bNameRegex = options[key]
      elif re.search('snameregex', key, re.IGNORECASE):
        sNameRegex = options[key]
      else:
        raise XMLCrawlerArgumentError("Unknown option '"+str(key)+"' with value "+str(val));

    results = from_node._search_subinst_params(from_node, depth, iNameRegex, mNameRegex, bNameRegex, sNameRegex, reverse)

    return results
      
  
  #### Parameter extraction methods
  #################################
  def exists_param(self, name):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    found = False
    paramlist = [];
    
    paramsElem = self._XMLPos.find('Parameters')
    if paramsElem is not None:
      paramlist += paramsElem.findall('ParameterItem')
    immutParamsElem = self._XMLPos.find('ImmutableParameters')
    if immutParamsElem is not None:
      paramlist += immutParamsElem.findall('ParameterItem')

    for paramItemElem in paramlist:
      nameElem = paramItemElem.find('Name')
      if nameElem.text == name:
        found = True
        break
    return found


  def get_param_doc(self, name):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    # raise exception if param is missing
    if not self.exists_param(name):
        raise XMLElementMissingError("No parameter named '" + name + "' found")
    doc = ''
    paramlist = [];
    paramsElem = self._XMLPos.find('Parameters')
    if paramsElem is not None:
      paramlist += paramsElem.findall('ParameterItem')
    immutParamsElem = self._XMLPos.find('ImmutableParameters')
    if immutParamsElem is not None:
      paramlist += immutParamsElem.findall('ParameterItem')
    
    for paramItemElem in paramlist:
      nameElem = paramItemElem.find('Name')
      if nameElem.text == name:
        docElem = paramItemElem.find('Doc')
        if docElem is not None:
          doc = docElem.text
        break
    return doc


  def get_param_val(self, name):
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");
    # raise exception if param is missing
    if not self.exists_param(name):
        raise XMLElementMissingError("No parameter named '" + name + "' found")
    val = None
    paramlist = [];
    paramsElem = self._XMLPos.find('Parameters')
    if paramsElem is not None:
      paramlist += paramsElem.findall('ParameterItem')
    immutParamsElem = self._XMLPos.find('ImmutableParameters')
    if immutParamsElem is not None:
      paramlist += immutParamsElem.findall('ParameterItem')
    
    for paramItemElem in paramlist:
      nameElem = paramItemElem.find('Name')
      if nameElem.text == name:
        val = self._get_param_val(paramItemElem)
        break
    return val

  def _get_param_val(self,elem):
    if not isinstance(elem, Element):
        raise XMLParameterError("Argument not an Element type: "+elem.__class__.__name__)
    if elem.find('Val') is not None:
      valElem = elem.find('Val')
      return valElem.text
    elif elem.find('ArrayType') is not None:
      val  = []
      arrElem = elem.find('ArrayType')
      for arrItemElem in arrElem.findall('ArrayItem'):
        val.append(self._get_param_val(arrItemElem))
      return val
    elif elem.find('HashType') is not None:
      val  = dict()
      hashElem = elem.find('HashType')
      for hashItemElem in hashElem.findall('HashItem'):
        keyElem = hashItemElem.find('Key')
        if keyElem is None:
          raise XMLSchemaError("HashItem missing Key element")
        val[keyElem.text] = self._get_param_val(hashItemElem)
      return val
    elif elem.find('InstancePath') is not None:
      return 'InstancePath'
    else:
      raise XMLSchemaError("Missing parameter value element of tag Val/ArrayType/HashType/InstancePath")
    
  def list_params(self):
    # First check that the XML is open
    if self._DB is None or self._XMLPos is None: 
      raise XMLElementMissingError("XML DB was not yet opened. Try calling 'read_xml' method first");

    # Find all of the parameters (things with ParameterItem tag) which are
    # in either the "Parameters" or "ImmutableParamters" sections.
    paramlist = []
    paramsElem = self._XMLPos.find('Parameters')
    if paramsElem is not None:
      paramlist += paramsElem.findall('ParameterItem')
    immutParamsElem = self._XMLPos.find('ImmutableParameters')
    if immutParamsElem is not None:
      paramlist += immutParamsElem.findall('ParameterItem')

    # Now build a list of the parameter names
    # TODO: Should this be the names, or something else?
    paramnames = []
    for paramItemElem in paramlist:
      paramnames += [paramItemElem.find('Name').text]

    return paramnames

