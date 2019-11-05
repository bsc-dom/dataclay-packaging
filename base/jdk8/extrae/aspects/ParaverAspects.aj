
import es.bsc.dataclay.paraver.Paraver;
import es.bsc.dataclay.paraver.ParaverEventType;

public aspect ParaverAspects {

	pointcut prvExecution() : (
			
					// *************** Traced classes ******************** //
					// WARNING: Too many classes could produce memory exceptions in COMPSs
						execution(* dataclay.commonruntime.ClientRuntime.*(..)) 
					|| 	execution(* dataclay.commonruntime.DataClayRuntime.*(..)) 
					|| 	execution(* dataclay.commonruntime.DataServiceRuntime.*(..)) 
					|| 	execution(* dataclay.api.DataClay.*(..)) // WARNING: This class MUST be always intervened!
					|| 	execution(* dataclay.dataservice.DataService.*(..))
					|| 	execution(* dataclay.logic.LogicModule.*(..))
					|| 	execution(* dataclay.storagelocation..*(..))
					|| 	execution(* storage.StorageItf.*(..))
					) 
	
					// *************** Avoid tracing Tracer classes ******************** //
					&& !execution(* dataclay.paraver..*(..))
					&& !execution(* *.activateTracing(..))
					&& !execution(* *.deactivateTracing(..))
					&& !execution(* *.activateTracingInDataClayServices(..))
					&& !execution(* *.deactivateTracingInDataClayServices(..))
					&& !execution(* *.getTraces(..))
					&& !execution(* *.init(..))
					&& !execution(* *.finish(..))

					// ********************** Execution/Stubs ************************* //
					//Warning: DataClayObject cannot be advised due to ASM modifications in classes extending it
					// neither StorageObject, DataClaySerializable or any super-class.
					&& !execution(* dataclay.DataClayObject.*(..))
					&& !execution(* dataclay.serialization.DataClaySerializable.*(..))
					&& !execution(* storage.StubItf.*(..))
					&& !execution(* storage.StorageObject.*(..))
					// ******************************************************************* //

			;

	before(): prvExecution() {
		Paraver.emitEvent(true,
				thisJoinPoint.getSignature().getDeclaringTypeName() + "." + thisJoinPoint.getSignature().getName());
	}

	after(): prvExecution() {
		Paraver.emitEvent(false,
				thisJoinPoint.getSignature().getDeclaringTypeName() + "." + thisJoinPoint.getSignature().getName());
	}

	after() throwing (Exception e):  prvExecution() {
		Paraver.emitEvent(true, e.toString());
		Paraver.emitEvent(false, e.toString());
	}

}
