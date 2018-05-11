# Docker Container for Pravega Demo

This is for running the following pipeline in a Docker container:
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

Edit `start.sh` to adjust Pravega scope/stream or ports if needed.

Start the script. It would take up to a minute to two for the container to be ready.
```
./start.sh
```

Add more logs to access.log if needed, e.g., by running command like the following.
```
echo '10.1.1.11 - peter [19/Mar/2018:02:24:01 -0400] "PUT /mapping/ HTTP/1.1" 500 182 "http://example.com/myapp" "python-client"' >> access.log
```

You can then start a Pravega reader to read from it. The logs are sent to Pravega stream as json string, for example.
```
{
        "request" => "/mapping/",
          "agent" => "\"python-client\"",
           "auth" => "peter",
          "ident" => "-",
           "verb" => "PUT",
        "message" => "10.1.1.11 - peter [19/Mar/2018:02:24:01 -0400] \"PUT /mapping/ HTTP/1.1\" 500 182 \"http://example.com/myapp\" \"python-client\"",
           "path" => "/opt/data/access.log",
       "referrer" => "\"http://example.com/myapp\"",
     "@timestamp" => 2018-03-19T06:24:01.000Z,
       "response" => "500",
          "bytes" => "182",
       "clientip" => "10.1.1.11",
       "@version" => "1",
           "host" => "5e91529a729f",
    "httpversion" => "1.1"
}
```


Besides reading logs from a file, the Logstash can also 
