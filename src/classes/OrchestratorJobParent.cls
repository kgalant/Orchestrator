/* 
 * 
 * This is the OrchestratorJobParent class which all jobs must inherit from 
 * It implements the core functionalities, and leaves the execute method for
 * the child classes to implement
 * 
 *
*/

global abstract without sharing class OrchestratorJobParent {
	protected String myJobId;  // contains the unique job ID
	protected String myConfigId; // contains the pointer (name) of the Custom Metadata Item running this job
	protected Orchestrator_Execution_Settings__c mySettings; // holds the custom settings object for this execution
	protected String myName; // you should populate this field with the name of your job
	protected String DEBUGPREFIX = ' ** ORCH_JOBPARENT ** '; // you should override this String to label your log entries
	public Enum JobType {BATCH, QUEUEABLE}
	public JobType myJobType;

	public void setupParameters (String jobId, String configId, Orchestrator_Execution_Settings__c settings) {
		myJobId = jobId;
		myConfigId = configId;
		mySettings = settings;
		init();
	}

	public void log(String message) {
		log(LoggingLevel.DEBUG, message);
	}

	public void log (LoggingLevel lvl, String message) {
		System.debug(lvl, DEBUGPREFIX + message);
	}

	global boolean startJob() {

		if (myJobId == null || myConfigId == null || myName == null || 
			(mySettings == null && myName != OrchestratorConstants.TASKSETUP_JOBNAME)
		) {
			// cannot start job without core params (unless it's the task setup which creates the custom settings), error out
			String msg = DEBUGPREFIX + 'Job: ' + myName + ' instatiation failed. Minimum parameters not supplied: Job ID: ' 
				+ myJobId + ' Config ID: ' + myConfigId;
			log(LoggingLevel.ERROR, msg);
			throw new OrchestratorException(msg);
		} else {
			// minimum parameters there, start job
			return startMyJobType();
		}
	}

	global OrchestratorJobParent() {}

	global abstract boolean startMyJobType();
	global abstract void init();
}