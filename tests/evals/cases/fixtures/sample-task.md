Task: add rate limiting to our public API. It should cap each API key at 100
requests per minute, return 429 with a Retry-After header when exceeded, and not
affect internal service-to-service calls. Redis is already in the stack.
