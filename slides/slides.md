---
theme: seriph
background: images/stream.jpg
class: text-center
lineNumbers: false
info: |
  ## Slidev Starter Template
  Presentation slides for developers.

  Learn more at [Sli.dev](https://sli.dev)
drawings:
  persist: false
transition: slide-left
title: Welcome to Slidev
---

# Intro to reactive programming
Volodymyr (Vova) Bilyachat 

---
transition: slide-up
level: 2
---
# Agenda

- Unce upon a time: there was a blocking and non blocking developer
- What is reactive programming
- Webflux
- Examples
- Demo (blocking vs non-blocking)
- Challenges
- Q&A


---
transition: slide-up
level: 2
---
# Fairy tale - blocking developer

- Jira task assigned to our developer
- Developer starts working on it
- Developer is blocked by another team
- For day 1, day 2, day 3
- Developer is unblocked
- Developer finishes the task

---
transition: slide-up
level: 2
---
# Fairy tale - non-blocking developer

- Jira task #1 assigned to our developer
- Developer starts working on it
- Developer is blocked by another team
- Developer park task #1
- Developer starts working on task #2
- Task #1 is unblocked
- Developer keep working on task #2
- Developer finishes the task #2
- Developer finishes the task #1


---
transition: slide-up
level: 2
---
# Reactive in Java?

Reactive systems have certain characteristics that make them ideal for low-latency, high-throughput workloads. Project Reactor and the Spring portfolio work together to enable developers to build enterprise-grade reactive systems that are responsive, resilient, elastic, and message-driven.

![Magic](/images/reactive.jpeg)

---
transition: slide-up
level: 2
---

# Reactive stack

![Magic](/images/reactor.png)
---
transition: slide-up
level: 2
---

# Webflux basic blocks
- Based on project reactor
- Spin up worker thread per CPU core but minimum 4
- Mono - 0 or 1 element
  - Mono.just()
  - Mono.empty()
  - Mono.error()
  - Mono.defer()
- Flux - 0 or N elements
  - Flux.just()
  - Flux.empty()
  - Flux.error()

---
transition: slide-up
level: 2
---

# Examples

---
transition: slide-up
level: 2
---
# Functional endpoints

```java
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.web.reactive.function.server.RequestPredicates.*;
import static org.springframework.web.reactive.function.server.RouterFunctions.route;

PersonRepository repository = ...
PersonHandler handler = new PersonHandler(repository);

RouterFunction<ServerResponse> route = route() (1)
	.GET("/person/{id}", accept(APPLICATION_JSON), handler::getPerson)
	.GET("/person", accept(APPLICATION_JSON), handler::listPeople)
	.POST("/person", handler::createPerson)
	.build();


public class PersonHandler {
	public Mono<ServerResponse> listPeople(ServerRequest request) {
	}

	public Mono<ServerResponse> createPerson(ServerRequest request) {
	}

	public Mono<ServerResponse> getPerson(ServerRequest request) {
	}
}
```

---
transition: slide-up
level: 2
---
# Run the server

```java
@Configuration
@EnableWebFlux
public class WebConfig implements WebFluxConfigurer {

	@Bean
	public RouterFunction<?> routerFunctionA() {
	}

	@Bean
	public RouterFunction<?> routerFunctionB() {
	}

	@Override
	public void configureHttpMessageCodecs(ServerCodecConfigurer configurer) {
	}

	@Override
	public void addCorsMappings(CorsRegistry registry) {
		// configure CORS...
	}

	@Override
	public void configureViewResolvers(ViewResolverRegistry registry) {
		// configure view resolution for HTML rendering...
	}
}
```

---
transition: slide-up
level: 2
---
# Kotlin example

```kotlin 
@Configuration
class CatRouterConfiguration(
    private val catHandler: CatHandler
) {
    @Bean
    fun apiRouter() = coRouter {
        "/api/cats".nest {
            accept(APPLICATION_JSON).nest {
                GET("", catHandler::getAll)

                contentType(APPLICATION_JSON).nest {
                    POST("", catHandler::add)
                }

                "/{id}".nest {
                    GET("", catHandler::getById)
                    DELETE("", catHandler::delete)

                    contentType(APPLICATION_JSON).nest {
                        PUT("", catHandler::update)
                    }
                }
            }
        }
    }
}
```

---
transition: slide-up
level: 2
---
# Kotlin handler

```kotlin
@Component
class CatHandler(
    private val catRepository: CatRepository
) {
    suspend fun getAll(req: ServerRequest): ServerResponse {
        return ServerResponse
            .ok()
            .contentType(MediaType.APPLICATION_JSON)
            .bodyAndAwait(
                catRepository.findAll().map { it.toDto() }
            )
    }

    suspend fun getById(req: ServerRequest): ServerResponse {
        val id = Integer.parseInt(req.pathVariable("id"))
        val existingCat = catRepository.findById(id.toLong())
        return existingCat?.let {
            ServerResponse
                .ok()
                .contentType(MediaType.APPLICATION_JSON)
                .bodyValueAndAwait(it)
        } ?: ServerResponse.notFound().buildAndAwait()
    }
}
```

---
transition: slide-up
level: 2
---
# Kotlin repository

```kotlin
interface CatRepository : CoroutineCrudRepository<Cat, Long> {
    override fun findAll(): Flow<Cat>
    override suspend fun findById(id: Long): Cat?
    override suspend fun existsById(id: Long): Boolean
    override suspend fun <S : Cat> save(entity: S): Cat
    override suspend fun deleteById(id: Long)
}
```

---
transition: slide-up
level: 2
---
# Demo

![Magic](/images/jmeter.png)

---
transition: slide-up
level: 2
---
# Challenges

- Complexity
- Downstream services still can fail
- Learning curve
- Debuging / Stack trace

---
transition: slide-up
level: 2
---

Questions?



