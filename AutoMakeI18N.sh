echo "generating I18N.swift"

touch tempI18N.swift
echo "public struct I18N {" >> tempI18N.swift

inputfile=${SRCROOT}/ko.lproj/Localizable.strings
# inputfile=./ko.lproj/Localizable.strings

cat ${inputfile}
while IFS= read -r line
do
echo $line
pattern='^[a-zA-Z]+(.*)[\\s]*=[\\s]*(.*)$'

comment='\/\/.+'

if [[ $line =~ $pattern ]]
then
    echo "Yes👌"
    temp=${line##*=" \""}
    value=${temp%%\"*}
    
    variableName=$(echo ${line%%=*})
    echo $variableName
    if [ "$variableName" != "" ]; then
        echo "    /// ${value}" >> tempI18N.swift
        echo "    static public let $variableName = \"$variableName\".localized" >> tempI18N.swift
    fi
else
    if [[ $line =~ $comment ]]
    then
        echo "Comment 📝"
        echo "\n    $line" >> tempI18N.swift
    else
        echo "No👎"
    fi
fi
done <${inputfile}

echo "}" >> tempI18N.swift

cat tempI18N.swift > ${SRCROOT}/Shared/Constant/I18N.swift
# cat tempI18N.swift > ./todoApp/Shared/Constant/I18N.swift
rm tempI18N.swift