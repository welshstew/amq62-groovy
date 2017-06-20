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