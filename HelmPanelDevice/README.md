HelmPanelDevice abstraction.
===========================

1. Many different devices should be easily used with no changes in TCs code.

2. Instead example code in our TC like:

   shellSW:postEvent(
     uniboxSW.handleName, 
     uniboxSW.events.connected, 
     change
   )

   which rigidly and ugly binds TC logic to concrete device (unibox) ..

3. Just think about meaningful interface for that. In this case it is:

   HelmPanelDevice:setConnected(change)

4. Implement it in HelmPanelDevice base class if it is generic,  or in concrete device class if it is unique. 

5. Remember that shell and device wrappers are injected in factory - you can use these references.

6. All factory stuff is done in RunAllModules script:

   helmPanel = helmPanelFactory.create("unibox")

   So Factory is the only reason to change when new helm panel device would be pluged. 
   No need to change any TC.

7. Enjoy using it in TC, just simple as that:

   helmPanel:setConnected(change)
