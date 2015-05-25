import argparse
import subprocess
import time
import os

class ModemSimulator():
	def __init__(self, path, com_port):
		self.path = path
		self.default_options()
		self.process = None
		try:
			self.com_port = int(com_port)
		except:
			self.com_port = None
			
		try:
			self.env = os.environ["WORKSPACE"]
		except:
			self.env = r"..\\..\\"
		
	def default_options(self):
		self.options = {
			#Modem Simulator options
			"DefaultDirectory" : "directoryName", #Default directory for message definition and package files
			"MessageDefinitionFiles" : "VMS-v1_4_1.idpmsg", #file1, file2
			#"MobileID" : "xxxxxxxxSKYyyyy",
			"ModemPort" : "COM6", #COMx Connect Modem Simulator to PC serial port
			"ModemBaud" : "9600", #baud Baud rate used by Modem Simulator
			"GatewayURL" : "http://localhost:8081",	
			"GpsURL" : "http://localhost:8081/GpsWebService", 
			#"ModemLogFile" : "file", #Open file to log trace output
			#"ModemLogAppend" : "", #Append to trace log file (otherwise overwrite)
			#"ModemLogTimestamp" : "", #Prepend timestamp to each trace log line
			
			#Terminal options 
			#"TerminalName" : "TERMINAL", #Start Terminal Simulator (new terminal created if not found)
			#"TerminalType" : "IDP680", #|IDP800|IDP780    #(Default: IDP680) Type of terminal to find or create
			#"TerminalGuid" : "guid",                   #Start Terminal Simulator (terminal with GUID must exist)
			#"PackageFiles" : "IDP-680_800_Desktop_v5.0.10.9363,VMS-Dbg-v1_4_1,Lib-Dbg-v1_0_0,InterfaceUnitHelpService",         #Load packages into Terminal Simulator
			#"DisableServices" : "SIN1,SIN2,...", #Disable services (eg: 0-255)
			"EnableServices" : "1-255", #Enable services (eg: 16-63,128)
			"DeviceURL" : "url", #Open device web service (default: http://localhost:8080/DeviceWebService)
			#"RS232MainPort" : "COMx", #Map "rs232main" port to PC serial port
			#"RS232AuxPort" : "COMx", #Map "rs232aux" port to PC serial port
			#"RS485Port" : "COMx", #Map "rs485" port to PC serial port
			#"TraceLogFile" : "file", #Open file to log trace output
			#"TraceLogAppend" : "", #Append to trace log file (otherwise overwrite)
			#"TraceLogTimestamp" : "", #Prepend timestamp to each trace log line
			#"ShellLogFile" : "file", #Open file to log shell output
			#"ShellLogAppend" : "", #Append to shell log file (otherwise overwrite)
			#"ShellLogTimestamp": "", #Prepend timestamp to each shell log line
			"ExitOnError" : "", #On startup error, close Modem Simulator and write message to stdout
			#"OptionsFile" : "filename", #Read options from file (one option per line, no "--" prefix)
		}
		
	def set_instance(self, instance):
		port = str(8000 + int(instance))
		
		
		new_options = {
			"GatewayURL" : "http://localhost:" + port,
			"GpsURL" : "http://localhost:" + port + "/GpsWebService",
			"DeviceURL" : "http://localhost:" + port + "/DeviceWebService",
			#"TerminalName" : "IDP680-VMS-" + instance,
			#"TraceLogFile" : os.path.join(self.env, "_run", "test_" + instance + ".log"),
			#"TraceLogTimestamp" : "",
		}
		self.update_options(new_options)
		if self.com_port:
			comport = "COM" + str(self.com_port)
			self.update_options({"RS232MainPort" : comport,})
		
		
	def update_options(self, new_options):
		for key, value in new_options.items():
			self.options[key] = value
			
	def _build_item(self, key, value):
		if value==None:
			return None
		elif len(value) == 0:
			return "--" + key
		else:
			return "--" + key + "=" + value
	
	def build_args(self):
		args = []
		for key, value in self.options.items():
			item = self._build_item(key, value)
			if item: 
				args.append(item)
		return args
	
	def run(self):
		if not self.process:
			params = self.build_args()
			self.process = subprocess.Popen([self.path] + params)
		else:
			raise Exception("Already running")
			
	def close(self):
		if self.process:
			self.process.kill()
		else:
			raise Exception("Kill attempt while not running")


class TestRunner():
	def __init__(self, luapath = "lua.exe", test_output=None, com_port=None):
		self.luapath = luapath
		self.default_args()
		self.test_output = test_output
		try:
			self.com_port = int(com_port)
		except:
			self.com_port = None
		
		try:
			self.test_env = os.environ["WORKSPACE"]
		except:
			self.test_env = r"../../"
	
	def default_args(self):
		self.args = {
			"v" : "",
		}
	
	def set_instance(self, instance):
		port = str(8000 + int(instance))
		self.args["p"] = port
		if self.com_port:
			comport = "COM" + str(self.com_port)
			self.args["com"] = comport
	
	def _build_item(self, key, value):
		if value==None:
			return None
		elif len(value) == 0:
			return ["-" + key]
		else:
			return ["-" + key, value]
	
	def build_args(self):
		args = ["RunAllModules.lua"]
		for key, value in self.args.items():
			item = self._build_item(key, value)
			if item: 
				args = args + item
		return args
	
	def run(self):
		args = self.build_args()
		if self.test_output:
			output = open(self.test_output, "w")
			self.process = subprocess.call([self.luapath] + args, cwd=self.test_env, stdout=output)
			output.close()
		else:
			self.process = subprocess.call([self.luapath] + args, cwd=self.test_env)
	

argparser = argparse.ArgumentParser()
argparser.add_argument("--modemsim", help="Specifies path to IDP Modem Simulator", required=True)
argparser.add_argument("--firmwaredir", help="Specifies path firmware directory", required=True)
argparser.add_argument("--suite", help="Specifies a test suite to run")
argparser.add_argument("--test", help="Specifies a test name to run")
argparser.add_argument("--testoutput", help="Specifies a test output file")

args = argparser.parse_args()

args.comportA = "com8"

modemsim = ModemSimulator(args.modemsim, com_port=args.comportB)
modemsim.update_options(
	{
		"DefaultDirectory" : args.firmwaredir,
	}
)

modemsim.set_instance(666)
modemsim.run()
time.sleep(5)
test_runner = TestRunner(test_output=args.testoutput, com_port=args.comportA)
test_runner.set_instance(args.instance)

test_runner.args["s"] = args.suite
test_runner.args["t"] = args.test

test_runner.run()

modemsim.close()


