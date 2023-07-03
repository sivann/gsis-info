#!/bin/bash

username="$1"
password="$2"


if [[ -z "$username" ]] ; then
    echo "$0 username password"
    exit
fi
if [[ -z "$password" ]] ; then
    echo "$0 username password"
    exit
fi


echo "Processing $1"
gsis_link_url='https://www1.aade.gr/taxisnet/mytaxisnet'
gsis_login_url='https://login.gsis.gr/mylogin/login.jsp'
aade_debtinfo_url='https://www1.aade.gr/taxisnet/info/protected/displayDebtInfo.htm'
aade_debtinfo_url='https://www1.aade.gr/taxisnet/info/protected/displayDebtInfoAndPay.htm'

# remove cookies
rm -f cookie.txt

tmp=${username//[^a-zA-Z0-9]/}
tmp="out/$tmp"

mkdir -p $tmp
cd $tmp

# STEP 1, request login page
curl -s -L "$gsis_link_url" -o resp1.html --cookie-jar cookie.txt

## STEP 2, get login page, not needed
#echo "Login.."
#curl -s -L "$gsis_login_url" -o resp2.html --cookie-jar cookie.txt --cookie cookie.txt 


# STEP 2, POST login form
curl -L -s 'https://login.gsis.gr/oam/server/auth_cred_submit' \
  -H 'Connection: close' \
  -H 'Pragma: no-cache' \
  -H 'Cache-Control: no-cache' \
  -H 'sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "macOS"' \
  -H 'Upgrade-Insecure-Requests: 1' \
  -H 'Origin: https://login.gsis.gr' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36' \
  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'Sec-Fetch-Mode: navigate' \
  -H 'Sec-Fetch-User: ?1' \
  -H 'Sec-Fetch-Dest: document' \
  -H 'Referer: https://login.gsis.gr/mylogin/login.jsp' \
  -H 'Accept-Language: en-US,en;q=0.9,el;q=0.8,fr;q=0.7' \
  --cookie cookie.txt \
  --cookie-jar cookie.txt \
  --data-raw "request_id=null&username=$username&password=$password&btn_login="  > resp3.html

if grep -q Σφάλμα resp3.html ; then
    echo "Error logging in"
    exit
fi

#STEP 3  get debt info
curl -s -L "$aade_debtinfo_url" -o debtinfo.html --cookie-jar cookie.txt --cookie cookie.txt 

d=$(date +%FT%H%M%S)
d1=$(date +%F)

cat debtinfo.html | awk '/35%/{start=1} /<\/table>/{if (start==1) print ; start=0} {if (start==1) print; }' > d.html
cat d.html | lynx -stdin -dump -display_charset=UTF-8  -assume_charset=UTF-8 | sed -e '/^$/d' -e 's/^ *//g'  > ${username}.${d1}.debtinfo.txt

rm -f ${username}.debtinfo.txt

vatno=$(cat resp3.html |grep 'Α.Φ.Μ.:'|cut -d: -f2-|sed 's/&nbsp;/ /g'|cut -d- -f1 |sed -e 's/^ *//g')
name=$(cat resp3.html |grep 'Α.Φ.Μ.:'|cut -d: -f2-|sed 's/&nbsp;/ /g'|cut -d- -f2 |sed -e 's/^ *//g')

echo "Name: $name" >> ${username}.${d1}.debtinfo.txt
echo "Vat: $vatno" >> ${username}.${d1}.debtinfo.txt

cat ${username}.${d1}.debtinfo.txt | tee -a ${username}.debtinfo.txt
echo "Queried on: $d"  >> ${username}.debtinfo.txt

echo '<table>' > ${username}.debtinfo.html
cat ${username}.debtinfo.txt | sed -e 's,^,<tr><th align="left">,' -e 's,  ,</th><td>,' -e 's,: ,</th/<td>,' -e 's,$,</td></tr>,' >> ${username}.debtinfo.html
echo '</table>' >> ${username}.debtinfo.html
cd ..
