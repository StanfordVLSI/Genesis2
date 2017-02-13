#!/usr/bin/python

print "hello world!"
print;

from Genesis2.XMLCrawler import XMLCrawler


c = XMLCrawler()
print c;
c.read_xml('FPGen.xml')

#c.goto_subinst('top_FPGen');
c = c.get_top()

print c;

print "iname=",c.iname()
print "mname=",c.mname();
print "bname=",c.bname();
print "sname=",c.sname();

print "checkpoint 1";

print 'no parent, right? ', c.get_parent();
print "checkpoint 2";

print "be false... ", c.exists_subinst('ofer')
print "be true... ", c.exists_subinst('TestBench')
print "be false... ", c.exists_subinst('TestssBench')

print "checkpoint 3";

d= c.get_subinst('TestBench')
print "d is TB: iname=",d.iname()
print "d is TB: mname=",d.mname();
print "d is TB: bname=",d.bname();
print "d is TB: sname=",d.sname();
print "d parent is ", d.get_parent();
d = d.get_top();
print "d is top: iname=",d.iname()
print "d is top: mname=",d.mname();
print "d is top: bname=",d.bname();
print "d is top: sname=",d.sname();


print "checkpoint 4"
d= c.get_subinst('TestBench')
print "DUT param exists? (yes)... ", d.exists_param('DUT')
print "ofer param exists? (no)... ", d.exists_param('ofer')
print "seed param exists? (yes)... ", d.exists_param('Seed')

print "DUT doc: ",d.get_param_doc('DUT')
#print "ofer doc: ",d.get_param_doc('ofer')
print "seed doc: ",d.get_param_doc('Seed')

print "checkpoint 5"

print "seed val="+ d.get_param_val('Seed')
print "pofer val=" , d.get_param_val('pofer')

print "checkpoint 6"
print "Subinsts of ", d.iname(), " are: "
for s in d.get_subinst_array("Gen"):
  print s;
print "checkpoint 7"

print "search_subinst of top (depth=3): "
for s in d.search_subinst({'depth':3}):
  print s.get_instance_path(), "\t\t", s;

print "search_subinst of top (depth=3, reverse): "
for s in d.search_subinst({'depth':3, 'reverse':True}):
  print s.get_instance_path(), "\t\t", s;
