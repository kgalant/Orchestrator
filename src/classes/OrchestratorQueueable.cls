/* 
 * 
 * This is the Orchestrator class which can be queued multiple times to run using 
 * System.enqueueJob. It implements the core Orchestrator functionality to look at
 * configuration given, and trigger the execution of the proper classes
 * 
 *
*/

global class OrchestratorQueueable implements Queueable {
	private String myJobId;
	private String myConfigurationId;
	private final String DEBUGPREFIX = ' ** ORCH_Q ** ';

	public void execute(QueueableContext context) {
        // first of all, check whether this is the initial invocation - if so, fire the initial setup job
        // if not, figure out what we need to be doing and go

        // so, check if custom setting with the job id as the name field exists

        Orchestrator_Execution_Settings__c jobSetting = Orchestrator_Execution_Settings__c.getValues(myJobId);

        if (jobSetting != null) {
        	// we have already setup what to do for this job, so get on with it
        	
        	// but first, check if nothing else is left on queue
        	// in that case, run the housekeeping job

        	if (jobSetting.Current_job__c == null && jobSetting.Job_queue__c == null) {
        		// run housekeeping job to finish up

        		Type setupClass = Type.forName(OrchestratorConstants.HOUSEKEEPING_JOBNAME);

        		OrchestratorJobParent myJob = (OrchestratorJobParent)setupClass.newInstance();

        		myJob.setupParameters(myJobId, myConfigurationId, jobSetting);
        		myJob.startJob();

        		// housekeeping only runs once at the end, and then doesn't reschedule a new queueable
        	} else {
        		// get the current job off the queue, check whether it's a queueable or batch and run it

        		String currentJobName = jobSetting.Current_job__c;

        		log('Will try to instantiate a job class of type: ' + currentJobName);

        		Type currentJobClass = Type.forName(currentJobName);

        		OrchestratorJobParent myJob = (OrchestratorJobParent)currentJobClass.newInstance();

        		log('Job Type: ' + myJob.myJobType);
        		myJob.setupParameters(myJobId, myConfigurationId, jobSetting);

        		if (myJob.myJobType == OrchestratorJobParent.JobType.BATCH) {
        			((OrchestratorBatchParent)myJob).myQueueManager = this;
        		}

        		boolean completedTask = myJob.startJob();

        		if (myJob.myJobType == OrchestratorJobParent.JobType.BATCH) {
        			// do nothing, ignore the return type
        			log('Ignoring return type from BATCH job');
        		} else {
        			if (completedTask == true) 
        				completeJob();
        			else 
        				reschedule();
        		}



        	}


        } else {
        	// can't find a custom setting for this job - that means we have to run the TaskSetup job

        	Type setupClass = Type.forName(OrchestratorConstants.TASKSETUP_JOBNAME);

        	OrchestratorJobParent myJob = (OrchestratorJobParent)setupClass.newInstance();

        	myJob.setupParameters(myJobId, myConfigurationId, null);
        	myJob.startJob();
        	completeJob(); // TaskSetup only ever runs once...
        }
	}

	public OrchestratorQueueable(String jobId, String configurationId) {
		myJobId = jobId;
		myConfigurationId = configurationId;
	}

	public void callCompleteJob() {
		completeJob();
	}

	private void completeJob() {
		// task was completed, so shift the next job off the queue, put the completed one away, and clear tracking setting
		log('completeJob called');

		Orchestrator_Execution_Settings__c jobSetting = Orchestrator_Execution_Settings__c.getValues(myJobId);

		jobSetting.Current_job_tracking_data__c = null;
		String jobsExecuted = jobSetting.Jobs_executed__c;
		jobSetting.Jobs_executed__c = jobSetting.Jobs_executed__c == null || jobSetting.Jobs_executed__c.length() == 0 ? jobSetting.Current_job__c : jobSetting.Jobs_executed__c + ',' + jobSetting.Current_job__c;
		String jobQueue = jobSetting.Job_queue__c;
		if (jobQueue == null || jobQueue.length() == 0) {
			// we're done here
			jobSetting.Current_job__c = null;
		} else {
			// shift next job off the queue
			List<String> jobNames = jobQueue.split(',');
			jobSetting.Current_job__c = jobNames[0];
			jobNames.remove(0);
			jobSetting.Job_queue__c = String.join(jobNames,',');
		}
		update jobSetting;

		System.enqueueJob(new OrchestratorQueueable(myJobId, myConfigurationId));
	}

	private void reschedule() {
		// we just reschedule, since the previous execution of the current job didn't complete its task
		log('reschedule called');
		System.enqueueJob(new OrchestratorQueueable(myJobId, myConfigurationId));

	}

	// we don't want anybody firing this job without telling it what config to work against

	private OrchestratorQueueable() {}

	public void log(String message) {
		log(LoggingLevel.DEBUG, message);
	}

	public void log (LoggingLevel lvl, String message) {
		System.debug(lvl, DEBUGPREFIX + message);
	}

}