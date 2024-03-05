import { TimestreamWriteClient } from "@aws-sdk/client-timestream-write";
import * as crudAndSimpleIngestionExample from "./client-timestream-write.js";

import https from 'https';
import minimist from 'minimist';

const argv = minimist(process.argv.slice(2), {
    boolean: "skipDeletion"
});

const region = argv.region ?? "us-east-1";

/**
 * Recommended Timestream write client SDK configuration:
 *  - Set SDK retry count to 10.
 *  - Use SDK DEFAULT_BACKOFF_STRATEGY
 *  - Set RequestTimeout to 20 seconds .
 *  - Set max connections to 5000 or higher.
 */
const agent = new https.Agent({
    maxSockets: 5000
});

const writeClient = new TimestreamWriteClient({
    maxRetries: 10,
    httpOptions: {
        timeout: 20000,
        agent: agent
    },
    region: region,
    credentials:{
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey:process.env.AWS_SECRET_ACCESS_KEY
    }
});

async function callServices() {
    while(true){
        await crudAndSimpleIngestionExample.writeRecords(writeClient);
        await new Promise(r => setTimeout(() => r(), 10000));
    }
}

callServices();