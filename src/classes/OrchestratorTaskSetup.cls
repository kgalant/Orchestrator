/* 
 * 
 * This is the OrchestratorTaskSetup class which reads the config and sets up all 
 * jobs that will be executed according to the config
 *
*/

global without sharing class OrchestratorTaskSetup extends OrchestratorQueueableParent {

	private final String JOBNAME = OrchestratorConstants.TASKSETUP_JOBNAME;
	private final String DEBUGPREFIX = ' ** ORCH_TASKSETUP ** ';

	global OrchestratorTaskSetup() {
		myName = JOBNAME;
	}

	global override boolean execute() {
		log('Executing TaskSetup');

		// look for the Custom Metadata item

		// Orchestrator_Configuration__mdt myConfigMDT = [select QualifiedApiName, Jobs__c from Orchestrator_Configuration__mdt WHERE DeveloperName=:myConfigId][0];
		log('Parameter map: ' + myParametersMap);

		// now create a custom setting for this execution

		Orchestrator_Execution_Settings__c newSetting = new Orchestrator_Execution_Settings__c();
		newSetting.Current_run_Id__c = myJobId;
		newSetting.Name = myJobId;

		// get the jobs from the custom metadata, move over to custom setting

		newSetting.Job_queue__c = getParameter('Jobs__c');

		insert newSetting;

		log(LoggingLevel.FINE, 'Custom setting created: ' + newSetting);

		return true; // we're done with the task setup so return true
	}
}