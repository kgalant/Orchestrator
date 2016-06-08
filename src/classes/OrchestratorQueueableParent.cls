/* 
 * 
 * This is the OrchestratorQueueableParent class which all jobs must inherit from 
 * It implements the core functionalities, and leaves the execute method for
 * the child classes to implement
 * 
 *
*/

global abstract without sharing class OrchestratorQueueableParent extends OrchestratorJobParent {

	global OrchestratorQueueableParent() {
		DEBUGPREFIX = ' ** ORCH_QPARENT ** ';
		myJobType = JobType.QUEUEABLE;
		init(); 
	}

	// return value defines whether the job completed or not

	global override boolean startMyJobType() {
		// minimum parameters there, start job
		return execute();
	}

	// execute method which must be overridden in subclass
	// return parameter indicates whether the execute method has completed all of its task (true)
	// or will need another pass (false)

	global abstract boolean execute();

	global override virtual void init() {}

}