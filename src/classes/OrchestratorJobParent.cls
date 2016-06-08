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
	public Map<String,Object> myParametersMap;

	public void setupParameters (String jobId, String configId, Orchestrator_Execution_Settings__c settings) {
		myJobId = jobId;
		myConfigId = configId;
		mySettings = settings;
		setupMyParameters();
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

	private void setupMyParameters() {
		// get the name of the config-specific Custom Metadata Object
		Orchestrator_Configuration__mdt myConfigMDT = 
			[select Custom_Metadata_Object_Name__c, Custom_Metadata_Item_Name__c 
			from Orchestrator_Configuration__mdt 
			WHERE DeveloperName=:myConfigId][0];

		log('Found configuration MDT: ' + myConfigMDT);

		// now get to the right object and get its data
		String myMDTObjectName = myConfigMDT.Custom_Metadata_Object_Name__c;
		String myMDTItemName = myConfigMDT.Custom_Metadata_Item_Name__c;
		Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{myMDTObjectName});
		Schema.SObjectType mdtObjectType = descResult[0].getSObjectType();
		Set<String> objectFields = descResult[0].getSObjectType().getDescribe().fields.getMap().keySet();

		// dynamically generate the query
		
		String query = 'select ' + String.join(new List<String>(objectFields),',') //fieldsListForQuery
		    + ' from ' + myMDTObjectName + 
		    ' WHERE DeveloperName=\'' + myMDTItemName + '\'';
		    
		Sobject myMDT = Database.query(query);

		// now convert the fields from the object into a map
		// getPopulatedFieldsAsMap() method only available in API 37

		//Map<String,Object> fieldMap = myMdt.getPopulatedFieldsAsMap();

		myParametersMap = new Map<String,Object>();

		for (String s : objectFields) {
		    //System.debug('Field: ' + s + ' value: ' + myMDT.get(s));
		    myParametersMap.put(s.toLowerCase(), myMDT.get(s));
		}
	}

	protected String getParameter(String paramName) {
		return (String)myParametersMap.get(paramName.toLowerCase());
	}

	global OrchestratorJobParent() {}

	global abstract boolean startMyJobType();
	global abstract void init();
}