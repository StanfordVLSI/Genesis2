To start stewie
    mv CONFIG.TXT config.txt.save
    bin/stewie .

To clean up from stewie
    mv config.txt.save CONFIG.TXT

...or maybe
    git checkout master -- CONFIG.TXT
