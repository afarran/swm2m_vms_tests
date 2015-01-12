from bs4 import BeautifulSoup
import sys

class CoreServicesMsgParser():

  inputFile = "metadata"

  def __init__(self):
    self.xmlStr = open(self.inputFile).read()
    self.xmlObj = BeautifulSoup(self.xmlStr,"xml")

  def parse(self,sin=None):
    services = self.xmlObj.find("Services").findAll("Service")

    for service in services:
      self.parseService(service,sin)
   

  def parseService(self, service,requestedSin=None):

    if not service: return

    forwardMessages = service.find("ForwardMessages")
    if not forwardMessages : return

    returnMessages =  service.find("ReturnMessages")
    if not returnMessages : return

    sin = service.find("SIN").string
    if requestedSin != None and int(requestedSin) != int(sin):
      return 

    serviceName = service.find("Name").string
    outputForward = []
    outputReturn = []

    print "FORWARD  MSG of %s (SIN %s) :"%(serviceName,sin)

    for msg in forwardMessages.findAll("Message"):
      outputForward.append({ "name" : msg.Name.string, "Min" : msg.MIN.string })
      print "{ name =\"%s\", min=%s},"%(msg.Name.string,msg.MIN.string)

    print "****"
    print "RETURN  MSG of %s (SIN %s) :"%(serviceName,sin)

    for msg in returnMessages.findAll("Message"):
      outputReturn.append({ "name" : msg.Name.string, "Min" : msg.MIN.string })
      print "{ name =\"%s\", min=%s},"%(msg.Name.string,msg.MIN.string)

parser = CoreServicesMsgParser()
if len(sys.argv) == 2:
  parser.parse(sys.argv[1])
else:
  parser.parse()
