# Qwynk URL Shortener

## Description
Qwynk URL Shortener is a comprehensive tool designed to create and manage shortened URLs. It leverages Elixir with Phoenix framework for the backend, PostgreSQL for data persistence, ClickHouse for analytics tracking, Mnesia for local storage of shortened URLs, and Redis for caching analytics data. The application's architecture ensures efficient data retrieval and analytics, while providing seamless integration across various stages of development and deployment.

## Technology Stack
- **Backend**: Elixir with Phoenix framework
- **Database**: PostgreSQL
- **Analytics Storage**: ClickHouse
- **Local Caching**: Mnesia
- **Redis for Analytics**: Redis
- **Docker & Docker Swarm**: For containerization and deployment

## Roadmap

#### Stage 1: URL Shortener with PostgreSQL + Ash (Completed)
- [ ] Create a database schema for shortened URLs.
- [ ] Implement the URL shortening logic using Ash.
- [ ] Design endpoints for creating and retrieving URLs.

#### Stage 2: Analytics with ClickHouse (In Progress)
- [ ] Develop a module to handle analytics data collection.
- [ ] Configure ClickHouse to store analytics in an efficient way.
- [ ] Connect the analytics tracking logic to the Ash resource for tracking user interactions.

#### Stage 3: Mnesia and Redis (Not Started)
- [ ] Design a schema for local storage of shortened URLs.
- [ ] Implement Mnesia for storing shortened URLs locally.
- [ ] Configure Redis to cache analytics data, considering cache invalidation strategies.

#### Stage 4: Further Optimizations (Not Started)
- [ ] Implement monitoring and logging using Prometheus and Grafana.
- [ ] Evaluate the use of caching strategies to enhance performance.
- [ ] Set up CI/CD pipelines for continuous integration and deployment.

## License
Qwynk URL Shortener is licensed under BSD 3-Clause License.
