# r-lambda-runtime

_How to build an R runtime for AWS Lambda_

Updated 2021-Aug-31 by [Michael Burkhardt](mailto:michael@monkeywalk.com)

---

In December 2020, [AWS announced support for container images in Lambda](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/).
I wanted to see if I could build a container to run R code in Lambda. I found a
[blog post](https://mdneuzerling.com/post/r-on-aws-lambda-with-containers/) that got me most of the way there. After some trial
and error, I was able to get it working with my own R code and a few changes to the `bootstrap` and `runtime.R` files.

---

## Getting Started

You'll also need to create a repository in the Elastic Container Store (ECS). Go to the ECS Service page, click **Create repository**
and follow the directions. Make note of the repository name. For this demo, I called mine `r4-on-lambda`. Alternatively,
you can do this from the command line using the AWS CLI, as follows:

```
aws ecr create-repository --repository-name r4-on-lambda --image-scanning-configuration scanOnPush=true
```

You'll need a place to buid your Docker image. You can do this with Windows or MacOS, but I opted for a small
(t2.micro) EC2 instance that I accessed via SSH. _Be sure to adjust the path to your key file appropriately._

```
ssh -i ~/keys/mw-ec2-key.pem ec2-user@ec2-3-144-17-200.us-east-2.compute.amazonaws.com
```

## Get the Files

Clone this repo. One way to do this is to run the following command at the shell prompt:

```
git clone https://github.com/mihobu/r-lambda-runtime.git
```

## Build the Docker image

Go to the directory containing the source files (`r-lambda-runtime`) and then build the image. _This will take a few minutes._

```
docker build -t mburkhardt/r4-on-lambda .
```

## Test the Image Locally

Run a container locally using the new image.

```
docker run -p 9000:8080 mburkhardt/r4-on-lambda "sclrp.handler"
```

Then, in a separate terminal:

```
curl -X POST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"dimensionality": 5,"num-records":1000}'
```

## Tag and Push the Image

Tag your image with the name of your ECS repository.

```
docker tag r4-on-lambda:latest XXXXXXXXXXXX.dkr.ecr.us-east-2.amazonaws.com/r4-on-lambda:latest
```

Retrieve an authentication token and authenticate your Docker client to your registry.
To do this, use the AWS CLI. _Be sure to update the command line with your account number._

```
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin XXXXXXXXXXXX.dkr.ecr.us-east-2.amazonaws.com
```

Push this image to your newly created AWS repository. _This too may take a few minutes._

```
docker push XXXXXXXXXXXX.dkr.ecr.us-east-2.amazonaws.com/r4-on-lambda:latest
```

## Create the Lambda function

Go to the Lambda service page, then follow these steps:

1. Click **Create function**.
2. Select the "Container image" option.
3. Give your function a name.
4. Select the image you just created using the **Browse Images** button.
5. Under permissions, make sure you select the appropriate execution role.
6. In the field labeled **CMD override**, enter `handler.sclrp`
7. Set the function timeout to 20 seconds.

Once the function is created, you can test. Be sure to include the required parameters in the test event. For example:

```
{
   "dimensionality": 5,
   "num-records": 1000
}
```
