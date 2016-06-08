global without sharing class OrchestratorSampleBatchJob extends OrchestratorBatchParent {

	global override void execute(Database.BatchableContext BC, List<sObject> scope) {
		log('In execute...');

		// listing parameters

		for (String s : myParametersMap.keyset()) {
			log('Parameter provided: ' + s + ' value: ' + getParameter(s));
		}

		for (SObject s : scope) {
			Account a = (Account)s;
			log('Account id: ' + a.id + ' Name: ' + a.name);
		}
	}

	// in this method, we must initialize the query and debugprefix, any other needed startup values

	global override void init() {
		log('In init...');	
		myName = 'OrchestratorSampleBatchJob';
		query = 'select id, name from Account';
		DEBUGPREFIX = ' ** ORCH_BATCHSAMPLE ** ';
	}


}