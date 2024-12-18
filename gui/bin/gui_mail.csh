#!/bin/csh -f

# To test: $0 "gui_mail test" line1 line2 "line3:    oobadoo"

unset mail
unset sendmail

which sendmail >& /dev/null && set sendmail
which mail >& /dev/null && set mail

if ($?mail) then
  #echo "found mail"
  set mailer = mail
else if ($?sendmail) then
  #echo "found sendmail"
  set mailer = sendmail
else
  echo "found no mail or sendmail"
  exit -1
endif

set from = `hostname -d`
set subject = "GUI stats $from $argv[1]"; shift argv
set to = steveri@stanford.edu
set body_file = /tmp/tmp$$
#Command line said this: '$argv:q'
cat <<EOF > $body_file
Mailer = '$mailer'
Command line said this:
EOF

while ($#argv)
  echo "  $argv[1]" >> $body_file
  shift argv
end

#unset show_env;
#if ($?show_env) then
#  set hdr = "Hey look here's the environment:"
#  (echo; echo; echo; echo "$hdr"; printenv) >> $body_file
#endif

#set echo
if ($?mail) then
  mail -s "$subject" $to -- -F "$from" < $body_file

else if ($?sendmail) then
  (echo "Subject: $subject"; echo; cat $body_file) | \
  sendmail -i -bm $to

endif

#  sendmail -i -bm $to -f "$from"
