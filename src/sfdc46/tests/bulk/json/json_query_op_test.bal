// Copyright (c) 2019 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/log;
import ballerina/test;

@test:Config {
    dependsOn: ["testJsonInsertOperator"]
}
function testJsonQueryOperator() {
    log:printInfo("salesforceBulkClient -> JsonQueryOperator");
    
    // Create JSON insert operator.
    JsonQueryOperator|SalesforceError jsonQueryOperator = sfBulkClient->createJsonQueryOperator("Contact");
    // Query string
    string queryStr = "SELECT Id, Name FROM Contact WHERE Title='Professor Grade 03'";

    if (jsonQueryOperator is JsonQueryOperator) {
        string batchId = EMPTY_STRING;

        // Create json query batch.
        Batch|SalesforceError batch = jsonQueryOperator->query(queryStr);
        if (batch is Batch) {
            test:assertTrue(batch.id.length() > 0, msg = "Creating query batch failed.");
            batchId = batch.id;
        } else {
            test:assertFail(msg = batch.message);
        }

        // Get job information.
        Job|SalesforceError jobInfo = jsonQueryOperator->getJobInfo();
        if (jobInfo is Job) {
            test:assertTrue(jobInfo.id.length() > 0, msg = "Getting job info failed.");
        } else {
            test:assertFail(msg = jobInfo.message);
        }

        // Close job.
        Job|SalesforceError closedJob = jsonQueryOperator->closeJob();
        if (closedJob is Job) {
            test:assertTrue(closedJob.state == "Closed", msg = "Closing job failed.");
        } else {
            test:assertFail(msg = closedJob.message);
        }

        // Get batch information.
        Batch|SalesforceError batchInfo = jsonQueryOperator->getBatchInfo(batchId);
        if (batchInfo is Batch) {
            test:assertTrue(batchInfo.id == batchId, msg = "Getting batch info failed.");
        } else {
            test:assertFail(msg = batchInfo.message);
        }

        // Get informations of all batches of this job.
        BatchInfo|SalesforceError allBatchInfo = jsonQueryOperator->getAllBatches();
        if (allBatchInfo is BatchInfo) {
            test:assertTrue(allBatchInfo.batchInfoList.length() == 1, msg = "Getting all batches info failed.");
        } else {
            test:assertFail(msg = allBatchInfo.message);
        }

        // Get the result list.
        ResultList|SalesforceError resultList = jsonQueryOperator->getResultList(batchId, noOfRetries);

        if (resultList is ResultList) {
            test:assertTrue(resultList.result.length() > 0, msg = "Getting query result list failed.");

            // Get results.
            json|SalesforceError result = jsonQueryOperator->getResult(batchId, resultList.result[0]);
            if (result is json) {
                json[] results = <json[]> result;
                test:assertTrue(results.length() > 0, msg = "Getting query result failed.");
            } else {
                test:assertFail(msg = result.message);
            }
        } else {
            test:assertFail(msg = resultList.message);
        }

        // Abort job.
    Job|SalesforceError abortedJob = jsonQueryOperator->abortJob();
    if (abortedJob is Job) {
        test:assertTrue(abortedJob.state == "Aborted", msg = "Aborting job failed.");
    } else {
        test:assertFail(msg = abortedJob.message);
    }
    } else {
        test:assertFail(msg = jsonQueryOperator.message);
    }
}