global abstract class OrchestratorBatchParent extends OrchestratorJobParent implements Database.Batchable<sObject>, Database.Stateful {
	
	protected String query;
	public OrchestratorQueueable myQueueManager;

	public OrchestratorBatchParent() {
		myJobType = JobType.BATCH;
		DEBUGPREFIX = ' ** ORCH_BATCHPARENT ** ';
	}

	global override boolean startMyJobType() {
		//check if we have the queue manager populated so that we can reschedule the next execution, if so, fire batch
		if (myQueueManager == null) {
			String msg = 'Job: ' + myName + ' instatiation failed. myQueueManager not populated.';
			log(LoggingLevel.ERROR, msg);
			throw new OrchestratorException(msg);
		} else {

			Database.executeBatch(this);

			// return value doesn't matter, as Orchestrator will check if this was a batch and ignore
			// we will call completejob from the batch's finish method

			return false;
		}
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	global void finish(Database.BatchableContext BC) {
		myQueueManager.callCompleteJob();
	}

	global abstract void execute(Database.BatchableContext BC, List<sObject> scope);
	


}