# Docker Container for Pravega Demo

This is for a Docker container that can perform the following pipeline:
```
Apache access logs -> Logstash with Pravega output plugin -> Pravega stream
```
Applications, e.g., Flink jobs, can then read the data from Pravega stream and process them. 

Services running inside the container.
- Pravega standalone. See more details [here](http://pravega.io/docs/latest/getting-started/)
- Logstash with [Pravega output plugin](https://github.com/pravega/logstash-output-pravega). It is configured to read data from a file that contains Apache access logs and push the logs, by default, to Pravega standalone running inside the container. 

If you just want to stand up a Pravega, you can ignore Logstash and the access log file.

To get started, first, clone this repository
```
git clone https://github.com/hldnova/pravega-docker.git
```

Then build with tag, e.g., `pravega-demo`
```
$ cd pravega-docker 
$ docker build --rm=true -t pravega-demo . 
```

Edit `start.sh` to specify Pravega scope and stream if needed.

Start the script. It would take up to a minute to two for the container to be ready.
```
./start.sh
```

Add more logs to access.log if needed, e.g., by running command like the following.
```
echo '10.1.1.11 - peter [19/Mar/2018:02:24:01 -0400] "PUT /mapping/ HTTP/1.1" 500 182 "http://example.com/myapp" "python-client"' >> access.log
```
