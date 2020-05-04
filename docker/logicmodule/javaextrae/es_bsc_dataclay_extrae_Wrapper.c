#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <es_bsc_dataclay_extrae_Wrapper.h>
#include "extrae_user_events.h"

jclass activityClass;
jobject activityObj;

JNIEXPORT void JNICALL Java_es_bsc_dataclay_extrae_DataClayExtraeWrapper_Flush (JNIEnv *env,
	jclass jc)
{
	UNREFERENCED(env);
	UNREFERENCED(jc);

	Extrae_flush();
}

