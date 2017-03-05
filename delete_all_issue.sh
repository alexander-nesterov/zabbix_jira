#!/bin/bash
for i in {1..500}
do
curl -D- -u 'zabbix:^7Nm$3%7GtR%6' -X DELETE -H "Content-Type: application/json" jira.nsk.cwc.ru:8080/rest/api/2/issue/ZBX-$i?deleteSubtasks=true
done
