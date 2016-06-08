/* 
 * 
 * This is the OrchestratorTaskSetup class which reads the config and sets up all 
 * jobs that will be executed according to the config
 *
*/

global without sharing class OrchestratorHousekeeping extends OrchestratorQueueableParent {

	private final String JOBNAME = OrchestratorConstants.HOUSEKEEPING_JOBNAME;
	private final String DEBUGPREFIX = ' ** ORCH_HOUSEKEEPING ** ';

	global OrchestratorHousekeeping() {
		myName = JOBNAME;
	}

	global override boolean execute() {
		// look for the Custom Metadata item

		// rename the custom settings object to save for later
		mySettings.name = 'HK_' +  mySettings.name + Datetime.now().format();
		mySettings.Job_queue__c = '';
		mySettings.Current_job__c = '';

		// update in db

		update mySettings;

		return true; // we're done with the housekeeping so return true
	}
}