"use strict";var Module={},nodeWorkerThreads,parentPort,nodeFS,err;typeof process=="object"&&typeof process.versions=="object"&&typeof process.versions.node=="string"&&(nodeWorkerThreads=require("worker_threads"),parentPort=nodeWorkerThreads.parentPort,parentPort.on("message",function(e){onmessage({data:e})}),nodeFS=require("fs"),Object.assign(global,{self:global,require,Module,location:{href:__filename},Worker:nodeWorkerThreads.Worker,importScripts:function(e){(0,eval)(nodeFS.readFileSync(e,"utf8"))},postMessage:function(e){parentPort.postMessage(e)},performance:global.performance||{now:function(){return Date.now()}}}));function threadPrintErr(){var e=Array.prototype.slice.call(arguments).join(" ");console.error(e)}function threadAlert(){var e=Array.prototype.slice.call(arguments).join(" ");postMessage({cmd:"alert",text:e,threadId:Module._pthread_self()})}err=threadPrintErr,self.alert=threadAlert,Module.instantiateWasm=(e,t)=>{var n=new WebAssembly.Instance(Module.wasmModule,e);return t(n),Module.wasmModule=null,n.exports},self.onmessage=e=>{try{if(e.data.cmd==="load"){if(Module.wasmModule=e.data.wasmModule,Module.wasmMemory=e.data.wasmMemory,Module.buffer=Module.wasmMemory.buffer,Module.ENVIRONMENT_IS_PTHREAD=!0,typeof e.data.urlOrBlob=="string")importScripts(e.data.urlOrBlob);else{var t,n=URL.createObjectURL(e.data.urlOrBlob);importScripts(n),URL.revokeObjectURL(n)}skwasm(Module).then(function(e){Module=e})}else if(e.data.cmd==="run"){Module.__performance_now_clock_drift=performance.now()-e.data.time,Module.__emscripten_thread_init(e.data.threadInfoStruct,0,0,1),Module.establishStackSpace(),Module.PThread.receiveObjectTransfer(e.data),Module.PThread.threadInit();try{t=Module.invokeEntryPoint(e.data.start_routine,e.data.arg),Module.keepRuntimeAlive()?Module.PThread.setExitStatus(t):Module.__emscripten_thread_exit(t)}catch(e){if(e!="unwind")if(e instanceof Module.ExitStatus)Module.keepRuntimeAlive()||Module.__emscripten_thread_exit(e.status);else throw e}}else e.data.cmd==="cancel"?Module._pthread_self()&&Module.__emscripten_thread_exit(-1):e.data.target==="setimmediate"||(e.data.cmd==="processThreadQueue"?Module._pthread_self()&&Module._emscripten_current_thread_process_queued_calls():(err("worker.js received unknown command "+e.data.cmd),err(e.data)))}catch(e){throw err("worker.js onmessage() captured an uncaught exception: "+e),e&&e.stack&&err(e.stack),e}}