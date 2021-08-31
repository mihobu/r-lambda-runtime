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

You'll need a place to buid your Docker image. You can do this with Windows or MacOS, but I opted for a small
(t2.micro) EC2 instance that I accessed via SSH:

```
$ ssh -l ec2-user ec2-xxx-xxx-xxx-xxx.us-east-2.compute.amazonaws.com
```

## Get the Files

Clone this repo. One way to do this is to run the following command at the shell prompt:

```
$ git clone https://github.com/mihobu/r-lambda-runtime.git
```

## Build the Docker Container

Change to the clone directory:

```
$ cd r-lambda-runtime
```

