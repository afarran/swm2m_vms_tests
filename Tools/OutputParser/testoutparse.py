import re
import xml.etree.cElementTree as ET
import argparse
import sys

def find_test_start(line):
	match = re.match('\*\*\*(.*)Started.*\*\*\*', line)
	if match:
		test_suites["name"] = match.group(1).strip()
		test_suites["suites"] = {}
		return True
	return None
	
def find_test_suite_start(line):
	match = re.match('-- Starting suite \"(.*)\".*', line)
	if match:
		suite_name = match.group(1)
		test_suites["suites"][suite_name] = []
		return suite_name
	return None

def find_test_case_start(line):
	match = re.match('\[STARTING\]: (.*)', line)
	if match:
		return match.group(1)
	else:
		return None
	
def find_test_case(line):
	match = re.match('(FAIL|PASS|SKIP): (.*)', line)
	if match:
		result = match.group(1)
		result_line = match.group(2)
		
		if result == "FAIL":
			try:
				#result contains time
				match = re.match('(.*) \((.*)ms\): (.*)', result_line)			
				name = match.group(1)
				time = match.group(2)
				msg = match.group(3)
			except:
				#result does not containt time
				match = re.match('(.*): (.*)', result_line)
				time = "0.0"
				if match:
					name = match.group(1)
					msg = match.group(2)
				else:
					name = "Problem with parsing FAIL output"
					msg = result_line
				
		elif result == "PASS":
			try:
				match = re.match('(.*) \((.*)ms\)', result_line)			
				msg = ""
				time = match.group(2)
				name = match.group(1)
			except:
				msg = result_line
				time = "0.0"
				name = "Problem with parsing PASS output"
				
		elif result == "SKIP":
			time = "0.0"
			try:
				match = re.match('(.*) - (.*)', result_line)
				msg = match.group(2)
				name = match.group(1)
			except:
				name = "Problem with parsing SKIP output"
				msg = result_line
		
	
		return  {
				"result" : result, 
				"name" : name, 
				"time" : str(float(time)/1000),
				"msg" : msg,
				}
	
	match = re.match('ERROR in (.*)', line)
	if match:
		return  {
				"result" : "ERROR", 
				"name" : match.group(1), 
				"time" : "0.0",
				"msg" : "",
				}
	return None

def find_trace(line):
	match = re.search('.*Finished suite \"(.+?)\"', line)
	if not match:
		return line.rstrip()
	return None
	
def create_xml(data):
	xml_test_suites = ET.Element("testsuites")
	xml_test_suites.set("name", test_suites["name"])
	
	for test_suite_name, test_suite_data in test_suites["suites"].items():
		xml_test_suite = ET.SubElement(xml_test_suites, "testsuite")
		xml_test_suite.set("name", test_suite_name)
		
		for test_case in test_suite_data:
			xml_test_case = ET.SubElement(xml_test_suite, "testcase")
			xml_test_case_std = None
			try:
				tokens = test_case["name"].split("_")
				test_group = tokens[1]
				test_condition = " ".join(re.findall("[A-Z][^A-Z]*", tokens[2]))
				test_expected_result = " ".join(re.findall("[A-Z][^A-Z]*", tokens[3]))
				test_case_name = "%s: %s - %s" % (test_group, test_condition, test_expected_result)
			except:
				test_case_name = test_case["name"]
			xml_test_case.set("name", test_case_name)
			#no idea why next line failed. test_case["time"] should never be none
			try:
				xml_test_case.set("time", test_case["time"])
			except:
				pass
			
			if test_case["result"] == "FAIL":
				xml_test_case_failure = ET.SubElement(xml_test_case, "failure")
				xml_test_case_failure.set("message", test_case["msg"])
			
			if test_case["result"] == "SKIP":
				xml_test_case_skip = ET.SubElement(xml_test_case, "skipped")
				xml_test_case_std = ET.SubElement(xml_test_case, "system-out")
				xml_test_case_std.text = test_case["msg"]
			
			if test_case["result"] == "ERROR":
				xml_test_case_failure = ET.SubElement(xml_test_case, "error")
				xml_test_case_failure.set("message", test_case["msg"])
				
			if "trace" in test_case:
				try:
					xml_test_case_std.text =  xml_test_case_std.text + "\n" + test_case["trace"]
				except:
					xml_test_case_std = ET.SubElement(xml_test_case, "system-out")
					xml_test_case_std.text = test_case["trace"]
			
	return xml_test_suites
	

#----------------------
test_suites = {}
	
parser = argparse.ArgumentParser(description='Creates an JUnity style XML from lunatest output.')
parser.add_argument('--source', default=None)
parser.add_argument('--result', default=None)
parser.add_argument('--log', default=None)
parser.add_argument('--verbose', default=False, action="store_true")
args = parser.parse_args()
all_data = ""
if args.source:
	data = open(args.source)
else:
	data = sys.stdin

#find tests starting point
for line in data:
	if args.verbose:
		print(line.strip())
	all_data = all_data + line
	if find_test_start(line):
		break

current_test_case_data = None
current_suite = None
		
#parse test cases results
for line in data:
	all_data = all_data + line
	new_suite = find_test_suite_start(line)
	if new_suite:
		if current_test_case_data:
			test_suites["suites"][current_suite].append(current_test_case_data)
		current_suite = new_suite
		current_test_case_data = None
		continue
	
	test_case_start = find_test_case_start(line)
	if test_case_start:
		if not current_suite:
			print("Found testcase but no testsuite detected in first place. Parser source seems malformed")
			sys.exit(-1)
		if current_test_case_data:
			test_suites["suites"][current_suite].append(current_test_case_data)
		current_test_case_data = {}
		current_test_case_data["name"] = test_case_start
		current_test_case_data["trace"] = ""
		continue
			
	test_case = find_test_case(line)
	if test_case:
		current_test_case_data["result"] = test_case["result"]
		current_test_case_data["time"] = test_case["time"]
		current_test_case_data["msg"] = test_case["msg"]
		continue
	
	trace = find_trace(line)
	if trace:
		if current_test_case_data:
			current_test_case_data["trace"] = current_test_case_data["trace"] + trace + "\n"

if current_test_case_data:
	if not current_suite:
		print("Found testcase but no testsuite detected in first place. Parser source seems malformed")
		sys.exit(-1)
	test_suites["suites"][current_suite].append(current_test_case_data)
			
try:
	xml_data = create_xml(test_suites)		
except:
	print("*** EXCEPTION IN CREATING XML ***")
	print("Unexpected error:", sys.exc_info()[0])
	print("*** RECEIVED DATA ***")
	print(all_data)
	print("*** END OF RECEIVED DATA ***")
	raise
	
if args.log:
	try:
		lunates_out = open(args.log, 'w')
		lunates_out.write(all_data)
		lunates_out.close()
	except Exception as e:
		print(e)
		print("Failed to save lunatest log " +args.log)

if args.result:
	tree = ET.ElementTree(xml_data)
	tree.write(args.result)
else:
	print (ET.tostring(xml_data, 'utf-8'))

