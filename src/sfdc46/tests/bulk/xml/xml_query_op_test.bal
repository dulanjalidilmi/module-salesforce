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
    dependsOn: ["testXmlInsertOperator"]
}
function testXmlQueryOperator() {
    log:printInfo("salesforceBulkClient -> XmlQueryOperator");
    
    // Create JSON insert operator.
    XmlQueryOperator|ConnectorError xmlQueryOperator = sfBulkClient->createXmlQueryOperator("Contact");
    // Query string
    string queryStr = "SELECT Id, Name FROM Contact WHERE Title='Professor Grade 05'";

    if (xmlQueryOperator is XmlQueryOperator) {
        string batchId = EMPTY_STRING;

        // Create json query batch.
        BatchInfo|ConnectorError batch = xmlQueryOperator->query(queryStr);
        if (batch is BatchInfo) {
            test:assertTrue(batch.id.length() > 0, msg = "Creating query batch failed.");
            batchId = batch.id;
        } else {
            test:assertFail(msg = batch.detail()?.message.toString());
        }

        // Get job information.
        JobInfo|ConnectorError jobInfo = xmlQueryOperator->getJobInfo();
        if (jobInfo is JobInfo) {
            test:assertTrue(jobInfo.id.length() > 0, msg = "Getting job info failed.");
        } else {
            test:assertFail(msg = jobInfo.detail()?.message.toString());
        }

        // Close job.
        JobInfo|ConnectorError closedJob = xmlQueryOperator->closeJob();
        if (closedJob is JobInfo) {
            test:assertTrue(closedJob.state == "Closed", msg = "Closing job failed.");
        } else {
            test:assertFail(msg = closedJob.detail()?.message.toString());
        }

        // Get batch information.
        BatchInfo|ConnectorError batchInfo = xmlQueryOperator->getBatchInfo(batchId);
        if (batchInfo is BatchInfo) {
            test:assertTrue(batchInfo.id == batchId, msg = "Getting batch info failed.");
        } else {
            test:assertFail(msg = batchInfo.detail()?.message.toString());
        }

        // Get informations of all batches of this job.
        BatchInfo[]|ConnectorError allBatchInfo = xmlQueryOperator->getAllBatches();
        if (allBatchInfo is BatchInfo[]) {
            test:assertTrue(allBatchInfo.length() == 1, msg = "Getting all batches info failed.");
        } else {
            test:assertFail(msg = allBatchInfo.detail()?.message.toString());
        }

        // Get the result list.
        string[]|ConnectorError resultList = xmlQueryOperator->getResultList(batchId, noOfRetries);

        if (resultList is string[]) {
            test:assertTrue(resultList.length() > 0, msg = "Getting query result list failed, resultList=" 
                + resultList.toString());

            // Get results.
            xml|ConnectorError result = xmlQueryOperator->getResult(batchId, resultList[0]);

            if (result is xml) {
                xml records = result[getElementNameWithNamespace("records")];
                test:assertTrue(records.*.elements().length() > 0, msg = "Getting query result failed.");
            } else {
                test:assertFail(msg = result.detail()?.message.toString());
            }
        } else {
            test:assertFail(msg = resultList.detail()?.message.toString());
        }

        // Abort job.
        JobInfo|ConnectorError abortedJob = xmlQueryOperator->abortJob();
        if (abortedJob is JobInfo) {
            test:assertTrue(abortedJob.state == "Aborted", msg = "Aborting job failed.");
        } else {
            test:assertFail(msg = abortedJob.detail()?.message.toString());
        }
    } else {
        test:assertFail(msg = xmlQueryOperator.detail()?.message.toString());
    }
}
