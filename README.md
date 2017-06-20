# amq62-groovy

Just playing about...

All this does is place the groovy-all lib into the /opt/amq/lib folder.  This can then enable you to run quick groovy scripts inside the amq pod.
So you can build camel routes and execute via a script to read messages from queues, etc.


```
oc create -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/jboss-image-streams.json -n openshift
oc new-build jboss-amq-62~https://github.com/welshstew/amq62-groovy --allow-missing-imagestream-tags --strategy=docker

```

### run a simple groovy script

`java -cp 'src:.:/opt/amq/lib/*:/opt/amq/lib/camel/*:/opt/amq/lib/optional/*' groovy.ui.GroovyMain camel-thing.groovy`

Copy or use vi to place the following files into say /tmp


camel-thing.groovy

```
import org.apache.camel.Exchange
import org.apache.camel.Processor
import org.apache.camel.builder.RouteBuilder
import org.apache.camel.impl.DefaultCamelContext
import org.apache.camel.impl.SimpleRegistry
import org.slf4j.Logger
import org.slf4j.LoggerFactory

def static setupCamel() {

    def camelCtx = new DefaultCamelContext(new SimpleRegistry())

    camelCtx.addRoutes(new RouteBuilder() {
        def void configure() {
            from('timer:hello?period=5000').log('hello world')
        }
    })

    camelCtx.start()
    // Stop Camel when the JVM is shut down
    Runtime.runtime.addShutdownHook({ ->
        camelCtx.stop()
    })
    synchronized(this){ this.wait() }
}

setupCamel()
```

log4j.properties
```
log4j.rootLogger=INFO, out
log4j.appender.out=org.apache.log4j.ConsoleAppender
log4j.appender.out.layout=org.apache.log4j.PatternLayout
log4j.appender.out.layout.ConversionPattern=%d [%-15.15t] %-5p %-30.30c{1} - %m%n
```


In action:

```
[root@145d799acdc2 tmp]# java -cp 'src:.:/opt/amq/lib/*:/opt/amq/lib/camel/*:/opt/amq/lib/optional/*' groovy.ui.GroovyMain camel-thing.groovy 
Picked up JAVA_TOOL_OPTIONS: -Duser.home=/home/jboss -Duser.name=jboss
2017-06-20 14:16:04,501 [main           ] INFO  DefaultCamelContext            - Apache Camel 2.15.1.redhat-621159 (CamelContext: camel-1) is starting
2017-06-20 14:16:04,503 [main           ] INFO  ManagedManagementStrategy      - JMX is enabled
2017-06-20 14:16:04,703 [main           ] INFO  DefaultTypeConverter           - Loaded 186 type converters
2017-06-20 14:16:04,788 [main           ] INFO  DefaultCamelContext            - AllowUseOriginalMessage is enabled. If access to the original message is not needed, then its recommended to turn this option off as it may improve performance.
2017-06-20 14:16:04,788 [main           ] INFO  DefaultCamelContext            - StreamCaching is not in use. If using streams then its recommended to enable stream caching. See more details at http://camel.apache.org/stream-caching.html
2017-06-20 14:16:04,808 [main           ] INFO  DefaultCamelContext            - Route: route1 started and consuming from: Endpoint[timer://hello?period=5000]
2017-06-20 14:16:04,811 [main           ] INFO  DefaultCamelContext            - Total 1 routes, of which 1 is started.
2017-06-20 14:16:04,832 [main           ] INFO  DefaultCamelContext            - Apache Camel 2.15.1.redhat-621159 (CamelContext: camel-1) started in 0.311 seconds
2017-06-20 14:16:05,820 [- timer://hello] INFO  route1                         - hello world
2017-06-20 14:16:10,811 [- timer://hello] INFO  route1                         - hello world
2017-06-20 14:16:15,812 [- timer://hello] INFO  route1                         - hello world
^C2017-06-20 14:16:17,157 [Thread-2       ] INFO  DefaultCamelContext            - Apache Camel 2.15.1.redhat-621159 (CamelContext: camel-1) is shutting down
2017-06-20 14:16:17,161 [Thread-2       ] INFO  DefaultShutdownStrategy        - Starting to graceful shutdown 1 routes (timeout 300 seconds)
2017-06-20 14:16:17,180 [ - ShutdownTask] INFO  DefaultShutdownStrategy        - Route: route1 shutdown complete, was consuming from: Endpoint[timer://hello?period=5000]
2017-06-20 14:16:17,184 [Thread-2       ] INFO  DefaultShutdownStrategy        - Graceful shutdown of 1 routes completed in 0 seconds
2017-06-20 14:16:17,211 [Thread-2       ] INFO  DefaultCamelContext            - Apache Camel 2.15.1.redhat-621159 (CamelContext: camel-1) uptime 12.711 seconds
2017-06-20 14:16:17,212 [Thread-2       ] INFO  DefaultCamelContext            - Apache Camel 2.15.1.redhat-621159 (CamelContext: camel-1) is shutdown in 0.054 seconds
```