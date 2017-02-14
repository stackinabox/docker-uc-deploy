#!/bin/bash
ucdMediaDir=${1:-/tmp/ibm-ucd-install}
echo replacing in ${ucdMediaDir}
cp ${ucdMediaDir}/install/UCDeployInstaller.groovy ${ucdMediaDir}/
#First replace the ant SQL file executions with println
#this will take either of:
# ant.sql(
                # driver:    dbDriver,
                # url:       firstConnectUrl,
                # userid:    dbUsername,
                # password:  antDBPassword,
                # classpath: extclasspath,
                # src:       srcDir + '/database/vc/' + dbType + '/vc-schema.ddl')
#or
# ant.sql(
#                 driver:    dbDriver,
#                 url:       dbUrl,
#                 userid:    dbUsername,
#                 password:  antDBPassword,
#                 classpath: extclasspath,
#                 src:       foreignKeysDdl)
# and convert to
#         println('ZSQLFILE_'+(new Date().toTimestamp())+'_'+<src>)
# where <src> is the value of the src parameter to ant.sql        
#when the UCD install is executed any db statements will become some  thing like the following in install.log:
#     [echo] ZSQLFILE_2016-07-13 01:17:25.041_/vagrant/ibm-ucd-install/database/vc/mysql/vc-schema.ddl
#which can then be easily extracted using something like:
# grep ZSQLFILE install.log | cut -f 3- -d '_'
perl -i -p0e 's/ant\.sql\(\n\s+driver(.*?)src:\s+(foreignKeysDdl|srcDir.*?)\)/println(\x27ZSQLFILE_\x27+(new Date().toTimestamp())+\x27_\x27+\2)/smg' ${ucdMediaDir}/install/UCDeployInstaller.groovy

#Then replace the hard coded SQL execution with println
#this will take something like:
#         ant.sql(
#                 """update sec_user set password = '${adminPasswordEncrypted}' where name = 'admin'""",
#                 driver:    dbDriver,
#                 url:       dbUrl,
#                 userid:    dbUsername,
#                 password:  antDBPassword,
#                 classpath: extclasspath)
# and convert to
#         println('ZSQLSTMTBEGIN'+"""update sec_user set password = '${adminPasswordEncrypted}' where name = 'admin'""".replaceAll("[\n]", " "))
#when the UCD install is executed any db statements will become some  thing like the following in install.log:
#     [echo] ZSQLSTMTBEGIN_update sec_user set password = 'pbkdf2{dR1YvJGn4LIEIuTToYklfACT/WU=|40960|ABljor6kwqjtEkPSWU2j75q5J9A=}' where name = 'admin'
#which can then be easily extracted using something like:
#  grep ZSQLSTMTBEGIN install.log | cut -f2- -d '_'
perl -i -p0e 's/ant\.sql\(\n\s+(\"\"\"(.*?)\"\"\")(.*?)extclasspath\)/println(\x27ZSQLSTMTBEGIN_\x27+\1.replaceAll("[\\n]", " "\)+\x27;\x27)/smg' ${ucdMediaDir}/install/UCDeployInstaller.groovy
