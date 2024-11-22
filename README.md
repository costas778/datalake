 **Building a Proof of Concept for Data Analytics**

A customer who needs an analytics solution to ingest, store, and visualize clickstream data. The customer is a restaurant owner who wants to derive insights for all menu items that are ordered in their restaurant. Because the customer has limited staff for running and maintaining this solution, you will build a proof of concept by using managed services on AWS.

The following architectural diagram shows the flow that you will follow.

![image](https://github.com/user-attachments/assets/e47a5bd2-97b5-4609-9d3a-c13046e023b8)


In this architecture, you use API Gateway to ingest clickstream data. Then, the Lambda function transforms the data and sends it to Kinesis Data Firehose. The Firehose delivery stream places all files in Amazon S3. Then, you use Amazon Athena to query the files. Finally, you use Amazon QuickSight to transform data into graphics.

We will work to achieve the following:

Create IAM policies and roles to follow the best practices of working in the AWS Cloud.
Create the object storage S3 bucket to store clickstream data.
Create the Lambda function for Amazon Kinesis Data Firehose to transform data.
Create a Kinesis Data Firehose delivery stream to deliver real-time streaming data to Amazon S3.
Create a REST API to insert data.
Create an Amazon Athena table to view the obtained data.
Create Amazon QuickSight dashboards to visualize data.

Note:

To complete the instructions in this exercise, choose the US East (N. Virginia) us-east-1 Region in the menu bar the AWS Management Console.

The instructions might prompt you to enter your account ID. Your account ID is a 12-digit account number that appears under your account alias in the top-right corner of the AWS Management Console. When you enter your account number (ID), make sure that you remove hyphens (-).

**Now the clever bit!**

Instead of doing this manually with multiple clicks we wiil use declarative script to achieve this.

In particular we are going to use Terraform. 

Terraform is a high level IAC solution that provisions whole environments (in our case AWS).  

Before that, however, Let's break down what the services above in the diagram do.

Amazon API Gateway Amazon API Gateway is a fully managed service that enables developers to create, publish, maintain, monitor, and secure APIs at any scale. Here are its key functions:

Acts as a "Front Door":
Serves as an entry point for applications to access data, business logic, or functionality from backend services Can connect to services like AWS Lambda, EC2, or any web application

Core Features:
Traffic Management: Handles large numbers of concurrent API calls Authorization & Security: Controls access using IAM roles, Lambda authorizers, or OAuth Monitoring & Metrics: Tracks API usage and performance

The service handles all the heavy lifting of accepting and processing API calls, including traffic management, authorization, monitoring, and version management, allowing developers to focus on their application logic.


