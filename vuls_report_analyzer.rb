require 'rexml/document'

report_path = ARGV[0]
if !FileTest.exist?(report_path)
    report_path = 'vuls_report.xml'
end
if !FileTest.exist?(report_path)
    puts 'vuls report file not found.'
    exit
end

doc = REXML::Document.new(open(report_path))

##################################################################################
def somePathCount(doc, path)
    hs = Hash.new()
    someCount = 0
    doc.elements.each(path) do | some |
        someCount += 1
    end
    puts "-------------------------------------------------------------------------------"
    puts path + " count " + someCount.to_s
end

##################################################################################
def somePathDuplicate(doc, path)
    hs = Hash.new()
    doc.elements.each(path) do | someElement |
        hs[someElement.text] ||= 0
        hs[someElement.text] += 1
    end
    isOK = true
    hs.keys.each do | key |
        if hs[key] > 1
            puts "NG! " + path + " is dupulicate [" + key + "] " + hs[key].to_s
            isOK = false
        end
    end
    if isOK
        puts "OK! no duplicate " + path + "."
    end
end

##################################################################################
def grepPathValue(doc, path, isDistinct)
    hs = Hash.new()
    pathCount = 0
    pathValues = ""
    doc.elements.each(path) do | someElement |
        pathCount += 1
        hashKey = someElement.text.to_s
        if !isDistinct
            pathValues += hashKey + "\n"
        else
            hs[hashKey] ||= 0
            hs[hashKey] += 1
        end
    end
    puts "-------------------------------------------------------------------------------"
    puts "grep " + path + " " + pathCount.to_s
    if isDistinct
        hs.keys.each do | key |
            puts key + " " + hs[key].to_s
        end
    else
        puts pathValues
    end
end

##################################################################################
def grepNewPackageName(doc)
    hs = Hash.new()
    newPackageCount = 0
    paths = ["vulsreport/ScanResult/KnownCves/Packages", 
             "vulsreport/ScanResult/UnknownCves/Packages"]
    paths.each {| path |
        doc.elements.each(path) do | package |
            if !package.get_elements('NewVersion')[0].has_text?
                next
            end
            newPackageCount += 1
            hashKey = package.get_text('Name').value + '-' + package.get_text('NewVersion').value  + '-' + package.get_text('NewRelease').value
            hs[hashKey] ||= 0
            hs[hashKey] += 1
        end
    }
    puts "-------------------------------------------------------------------------------"
    puts "grepNewPackageName (known & unknown)" + newPackageCount.to_s
    hs.keys.each do | key |
        puts key + " " + hs[key].to_s
    end 
end

##################################################################################
#check ScanedCVEs/CveID is uniq
##################################################################################
path = "vulsreport/ScanResult/ScannedCves/CveID"
somePathCount(doc, path)
somePathDuplicate(doc, path)

##################################################################################
#check KnowCves/CveDetail is uniq
##################################################################################
path = "vulsreport/ScanResult/KnownCves/CveDetail/CveID"
somePathCount(doc, path)
somePathDuplicate(doc, path)

##################################################################################
#check Nvd/CweID is uniq
##################################################################################
path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/CweID"
somePathCount(doc, path)
somePathDuplicate(doc, path)

##################################################################################
#check References/Link is uniq
##################################################################################
path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/References/Link"
somePathCount(doc, path)
somePathDuplicate(doc, path)



##################################################################################
#check ScanResult/Packages dupulication
##################################################################################
path = "vulsreport/ScanResult/Packages/Name"
somePathCount(doc, path)
somePathDuplicate(doc, path)
grepPathValue(doc, path, true)


#grep
path = "vulsreport/ScanResult/ScannedCves/Packages/Name"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/AccessVector"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/AccessComplexity"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/Authentication"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/ConfidentialityImpact"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/IntegrityImpact"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/AvailabilityImpact"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Nvd/References/Source"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Jvn/Title"
grepPathValue(doc, path, false)

path = "vulsreport/ScanResult/KnownCves/CveDetail/Jvn/Score"
grepPathValue(doc, path, true)

path = "vulsreport/ScanResult/KnownCves/CveID"
grepPathValue(doc, path, true)

#########################################################################################
#Important info
path = "vulsreport/ScanResult/ScannedCves/Packages/Name"
grepPathValue(doc, path, true)
path = "vulsreport/ScanResult/KnownCves/Packages/Name"
grepPathValue(doc, path, true)
path = "vulsreport/ScanResult/UnknownCves/Packages/Name"
grepPathValue(doc, path, true)
#grep new package
grepNewPackageName(doc)
