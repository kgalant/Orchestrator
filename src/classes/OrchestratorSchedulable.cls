/* 
 * 
 * This is the Orchestrator class which can be scheduled to run using System.schedule
 * Its only purpose is to be scheduled, receive the configuration parameter for which
 * Custom Metadata config to be using and then fire the Queueable part of the 
 * Orchestrator
 * 
 *
*/


global class OrchestratorSchedulable implements Schedulable {
	private String myConfigurationName = '';
	private String myJobId = '';
	private final String DEBUGPREFIX = ' ** ORCH_S ** ';

	global void execute(SchedulableContext sc) {
		myJobId = sc.getTriggerId();
		System.debug(LoggingLevel.DEBUG, DEBUGPREFIX + 'OrchestratorSchedulable called. Will enqueue first job for execution ' + myJobId);
		System.enqueueJob(new OrchestratorQueueable(myJobId, myConfigurationName));
	}

	global OrchestratorSchedulable(String configurationName) {
		myConfigurationName = configurationName;
	}

	// we don't want anybody firing this job without telling it what config to work against

	private OrchestratorSchedulable() {}
}