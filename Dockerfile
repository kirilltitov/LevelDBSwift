FROM swiftdocker/swift

RUN apt-get update && apt-get install -y libleveldb-dev

WORKDIR /App
COPY Package.swift /App/Package.swift
COPY Sources /App/Sources
COPY Tests /App/Tests

CMD ["swift", "test"]