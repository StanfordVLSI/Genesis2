Jolin, here's the latest GUI tarball.  I've tried to isolate the
system-dependent parts to two files "gui/CONFIG.TXT" and "gui/index.htm"

If you look at these files it should be obvious what changes need to be
made.  I suggest that you create your own config file e.g.

  gui/configs/CONFIG_cmu.txt

and then either link

  cd gui; ln -s configs/CONFIG_cmu.txt CONFIG.TXT

or simply replace

  cd gui; cp configs/CONFIG_cmu.txt CONFIG.TXT

...and then do the same thing for the home page "gui/index.htm",
i.e. create your own gui/configs/index_cmu.htm and link or replace

  cd gui; ln -s configs/index_cmu.htm index.htm

or

  cd gui; cp configs/index_cmu.htm index.htm

Once you've built configs/CONFIG_cmu.txt and configs/index_cmu.txt you
can use them again when we have future updates and, if you like, you
can even send me the files and I can include them in our source
directory.

Let me know if you run into problems.

Thanks,
Steve
