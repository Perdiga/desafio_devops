import { constants } from "./constants.js";
import { WriteRecordsCommand} from "@aws-sdk/client-timestream-write";

export async function writeRecords(writeClient) {
    console.log("Writing records");
    const currentTime = Date.now().toString(); // Unix time in milliseconds

    const dimensions = [
        {'Name': 'region', 'Value': 'us-east-1'},
        {'Name': 'az', 'Value': 'az1'},
        {'Name': 'hostname', 'Value': 'host'+parseInt(randomInRange(1,5)).toString()}
    ];

    const cpuUtilization = {
        'Dimensions': dimensions,
        'MeasureName': 'cpu_utilization',
        'MeasureValue': randomInRange(0,100).toString(),
        'MeasureValueType': 'DOUBLE',
        'Time': currentTime.toString()
    };

    const memoryUtilization = {
        'Dimensions': dimensions,
        'MeasureName': 'memory_utilization',
        'MeasureValue': randomInRange(0,4096).toString(),
        'MeasureValueType': 'DOUBLE',
        'Time': currentTime.toString()
    };

    const records = [cpuUtilization, memoryUtilization];

    const params = new WriteRecordsCommand({
        DatabaseName: constants.DATABASE_NAME,
        TableName: constants.TABLE_NAME,
        Records: records
    });

    await writeClient.send(params).then(
        (data) => {
            console.log("Write records successful");
        },
        (err) => {
            if (err.name === 'RejectedRecordsException') {
                printRejectedRecordsException(err);
            } else {
                console.log("Error writing records:", err);
            }
        }
    );
}

function randomInRange(min, max) {
    return Math.random() < 0.5 ? ((1-Math.random()) * (max-min) + min) : (Math.random() * (max-min) + min);
}


export function printRejectedRecordsException(err) {
    // Full log stack is printed in error print so let us print main message and the rejected records only
    console.log("Error writing records: RejectedRecordsException: One or more records have been rejected. See RejectedRecords for details.");
    err.RejectedRecords.forEach((rr) => {
        console.log(`Rejected Index ${rr.RecordIndex}: ${rr.Reason}`);
        if (rr.ExistingVersion) {
            console.log(`Rejected record existing version: ${rr.ExistingVersion}`);
        }
    })

}