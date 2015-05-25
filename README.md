swm2m_vms_tests
================

Feature tests of VMS agent

Running VMS test requires replacing Unibox with modified service. This service is available here: VMSTests\InterfaceUnitHelpService.idppkg.
Make sure it is loaded to the terminal and enabled before start of tests.

For modules: TestSmtpModule, TestShellModule and TestPop3Module there need to be switch '-com' passed with name of the com port used for main serial port communication. 
In example: when main serial port connected to com8 there should be argument '- com com8' passed to RunAllModules. 
  