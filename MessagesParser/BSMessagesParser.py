from bs4 import BeautifulSoup
xmlStr = open("2VmsMessages.xml").read()
xmlObj = BeautifulSoup(xmlStr,"xml")

forwardMessages = xmlObj.find("ForwardMessages").findAll("Message")
returnMessages =  xmlObj.find("ReturnMessages").findAll("Message")

outputForward = []
outputReturn = []

print "FORWARD  MSGs:"

for msg in forwardMessages:
  outputForward.append({ "name" : msg.Name.string, "Min" : msg.MIN.string })
  print "{ name =\"%s\", min=%s}"%(msg.Name.string,msg.MIN.string)

print "****"
print "RETURN  MSGs:"

for msg in returnMessages:
  outputReturn.append({ "name" : msg.Name.string, "Min" : msg.MIN.string })
  print "{ name =\"%s\", min=%s}"%(msg.Name.string,msg.MIN.string)


